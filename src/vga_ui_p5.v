//////////////////////////////////////////////////////////////////////////////////
//  模块名称：vga_ui_p5（第 5/6 周 · 640×480 UI 顶层）
//
//  设计取舍：不用预生成位图底图
//    8_siggen 的 vga_ui_v4 依赖 ui4_b0~b9.hex（由 Python 脚本烧出来的 1bpp 位图），
//    好处是对齐像素级精确，坏处是改布局要"脚本 + hex + RTL 坐标"三处同步。
//    这里的标签数量只有十来个，全部改用 RTL 渲染：
//      · 边框 / 网格：纯坐标判定
//      · 静态标签：在 vga_text_p5 里以字符常量形式给出
//    代价是几十行 case，收益是布局常量改一处即可重排。
//
//  布局（640×480）：
//    y 0..43    顶栏
//    y 56..311  左：X-Y 李萨如画布 256×256（x 24..279）
//               右：Y-T 波形区   320×256（x 304..623）
//    y 320..479 参数面板（由 vga_text_p5 渲染）
//
//  图层（优先级自高而低）：
//    ① X-Y 荧光画布（真实数据打点）
//    ② Y-T 波形（青=输入 / 橙黄=输出）
//    ③ 动态文字
//    ④ 网格（32px，用 & 判断避免除法器）
//    ⑤ 边框（失锁时转红）
//    ⑥ 区域底色
//////////////////////////////////////////////////////////////////////////////////
module vga_ui_p5 (
    input  wire        pclk,           // 25MHz 像素钟
    input  wire        rst_n,

    // ---- 面板数据（25MHz 域，顶层已同步） ----
    input  wire [15:0] freq_centi,
    input  wire [19:0] period_ticks,
    input  wire [15:0] vpp_x100,
    input  wire [15:0] rms_x100,
    input  wire [1:0]  mode,
    input  wire        lock_ok,

    // ---- X-Y 打点侧（100MHz 域真实数据） ----
    input  wire        clk_dot,
    input  wire        dot_en,
    input  wire [11:0] dot_x,          // X 轴：ADC 输入
    input  wire [11:0] dot_y,          // Y 轴：DA 输出

    // ---- Y-T 波形 RAM ----
    input  wire [23:0] wave_dout,      // {IN[23:12], OUT[11:0]}，均为 12 位屏幕 y
    output wire [8:0]  wave_addr,

    // ---- 时序输出 ----
    output wire        hs_n,
    output wire        vs_n,
    output wire        de,
    output reg  [11:0] rgb,
    output wire [9:0]  px,
    output wire [9:0]  py,
    output wire        frame_start
);

    // ============================================================
    //  布局常量（改这里即可重排）
    // ============================================================
    localparam [9:0] CX0 = 10'd24;      // 画布区左上
    localparam [9:0] CY0 = 10'd56;
    localparam [9:0] CSZ = 10'd256;     // 画布边长（128 点 ×2 放大）
    localparam [9:0] CX1 = CX0 + CSZ - 10'd1;      // 279
    localparam [9:0] CY1 = CY0 + CSZ - 10'd1;      // 311

    localparam [9:0] WX0 = 10'd304;     // 波形区左上
    localparam [9:0] WY0 = 10'd56;
    localparam [9:0] WW  = 10'd320;     // 列数
    localparam [9:0] WH  = 10'd256;
    localparam [9:0] WX1 = WX0 + WW - 10'd1;       // 623
    localparam [9:0] WY1 = WY0 + WH - 10'd1;       // 311

    localparam [9:0] TOP_H = 10'd44;    // 顶栏高度

    // ============================================================
    //  时序发生器
    // ============================================================
    wire [9:0] x, y;

    vga_timing u_timing (
        .pclk        (pclk),
        .rst_n       (rst_n),
        .x           (x),
        .y           (y),
        .hs_n        (hs_n),
        .vs_n        (vs_n),
        .de          (de),
        .frame_start (frame_start)
    );

    assign px = x;
    assign py = y;

    // ============================================================
    //  ① X-Y 真实李萨如画布
    // ============================================================
    wire [3:0] scope_lv;

    xy_scope #(
        .X0  (CX0),
        .Y0  (CY0),
        .MAG (1)
    ) u_scope (
        .clk_dot (clk_dot),
        .dot_en  (dot_en),
        .xi      (dot_x),
        .yi      (dot_y),
        .pclk    (pclk),
        .sx      (x),
        .sy      (y),
        .lv      (scope_lv)
    );

    wire canv_pix = (scope_lv != 4'd0);

    // ============================================================
    //  ② Y-T 波形层（青=IN / 橙黄=OUT）
    //   三件套：地址提前一拍 / prev 打一拍补邻列 / min-max 区间填充
    // ============================================================
    assign wave_addr = ((x >= WX0 - 10'd1) && (x <= WX1 - 10'd1)) ?
                       (x - (WX0 - 10'd1)) : 9'd0;

    reg [9:0] wprev_in, wprev_ot;
    always @(posedge pclk or negedge rst_n) begin
        if (!rst_n) begin
            wprev_in <= 10'd0;
            wprev_ot <= 10'd0;
        end else begin
            wprev_in <= wave_dout[21:12];
            wprev_ot <= wave_dout[9:0];
        end
    end

    wire [9:0] wy_in_now = wave_dout[21:12];
    wire [9:0] wy_in_prv = wprev_in;
    wire [9:0] wy_ot_now = wave_dout[9:0];
    wire [9:0] wy_ot_prv = wprev_ot;

    wire [9:0] wy_in_lo = (wy_in_now < wy_in_prv) ? wy_in_now : wy_in_prv;
    wire [9:0] wy_in_hi = (wy_in_now < wy_in_prv) ? wy_in_prv : wy_in_now;
    wire [9:0] wy_ot_lo = (wy_ot_now < wy_ot_prv) ? wy_ot_now : wy_ot_prv;
    wire [9:0] wy_ot_hi = (wy_ot_now < wy_ot_prv) ? wy_ot_prv : wy_ot_now;

    wire in_plot = (x >= WX0) && (x <= WX1) && (y >= WY0) && (y <= WY1);

    // 失锁时关闭波形层：ADC 悬空的随机噪声不会被补线成满屏竖线
    wire wave_ink_in  = in_plot && lock_ok && (y >= wy_in_lo) && (y <= wy_in_hi);
    wire wave_ink_out = in_plot && lock_ok && (y >= wy_ot_lo) && (y <= wy_ot_hi);

    // ============================================================
    //  ③-⑤ 网格 / 边框（32px 网格：用 & 判断，无除法器）
    // ============================================================
    wire [9:0] cdx = x - CX0;
    wire [9:0] cdy = y - CY0;
    wire [9:0] wdx = x - WX0;
    wire [9:0] wdy = y - WY0;

    wire in_canv = (x >= CX0) && (x <= CX1) && (y >= CY0) && (y <= CY1);
    wire in_wave = (x >= WX0) && (x <= WX1) && (y >= WY0) && (y <= WY1);

    wire grid_canv = in_canv && (((cdx & 5'b11111) == 5'd0) || ((cdy & 5'b11111) == 5'd0));
    wire grid_wave = in_wave && (((wdx & 5'b11111) == 5'd0) || ((wdy & 5'b11111) == 5'd0));
    wire grid      = grid_canv | grid_wave;

    // 画布中心十字（对齐用，暗色，不覆盖曲线）
    wire cross = in_canv && ((x == CX0 + 10'd128) || (x == CX0 + 10'd127) ||
                             (y == CY0 + 10'd128) || (y == CY0 + 10'd127));

    wire b_canv = in_canv && ((x == CX0) || (x == CX1) || (y == CY0) || (y == CY1));
    wire b_wave = in_wave && ((x == WX0) || (x == WX1) || (y == WY0) || (y == WY1));
    wire border = b_canv | b_wave;

    // 失锁：画布 + 波形区边框转红
    wire edge_red = ~lock_ok && border;

    // ============================================================
    //  文字层
    // ============================================================
    wire text_ink;

    vga_text_p5 u_text (
        .pclk         (pclk),
        .rst_n        (rst_n),
        .x            (x),
        .y            (y),
        .frame_start  (frame_start),
        .freq_centi   (freq_centi),
        .period_ticks (period_ticks),
        .vpp_x100     (vpp_x100),
        .rms_x100     (rms_x100),
        .mode         (mode),
        .lock_ok      (lock_ok),
        .ink          (text_ink)
    );

    // ============================================================
    //  颜色仲裁
    // ============================================================
    always @(*) begin
        if (canv_pix)
            // 荧光青绿：绿通道=亮度，蓝通道取高 2 位做轻微偏色，随余辉一起衰减
            rgb = {4'h0, scope_lv, 2'b00, scope_lv[3:2]};
        else if (wave_ink_out)
            rgb = 12'hFD0;                            // 输出（DA）：橙黄
        else if (wave_ink_in)
            rgb = 12'h0FF;                            // 输入（ADC）：青
        else if (y < TOP_H)
            rgb = text_ink ? 12'hFFF : 12'h136;        // 顶栏：白字蓝底
        else if (text_ink)
            rgb = 12'hFD6;                            // 面板文字：淡黄
        else if (edge_red)
            rgb = 12'hC00;                            // 失锁：红框
        else if (border)
            rgb = 12'h5CF;                            // 边框：淡蓝
        else if (cross)
            rgb = 12'h2A6;                            // 画布中心十字
        else if (grid)
            rgb = 12'h134;                            // 网格
        else if (in_canv || in_wave)
            rgb = 12'h001;                            // 图形区底色
        else
            rgb = 12'h011;                            // 页面底色
    end

endmodule
