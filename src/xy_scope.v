//////////////////////////////////////////////////////////////////////////////////
//  模块名称：xy_scope（真实 X-Y 李萨如 · 数字荧光画布）
//
//  目的：
//    第 5 周系统的 X-Y 图形原本只能在示波器上看。本模块把同一个图形搬到 VGA：
//      X 轴 = AD807 采到的真实输入信号（ad_dat_sync）
//      Y 轴 = 送进 DA902 的真实输出数据（ram_rd_data）
//    两者都是 12 位偏移二进制（0..4095，中心 2048），>>5 正好得到 7 位 0..127，
//    拼成一个 14 位地址，直接就是 128×128 画布上的一个格子。
//
//  与 8_siggen 的 xy_curve 的本质区别：
//    xy_curve 是按解析式"算"出来的理想曲线（评委一眼能看出是画的）；
//    xy_scope 是用真实数据流"打"出来的点，与示波器 X-Y 看到的是同一份数据。
//
//  数字荧光（余辉）机制：
//    · 打点侧（100MHz）：每拍把当前 (X,Y) 对应的格子写成最亮 15
//    · 衰减侧（25MHz） ：每帧把全场 16384 个格子各减 1（写成周期性 FTP 扫描）
//      → 连续命中处保持最亮，轨迹扫过处留下拖尾，15 帧（约 250ms）后彻底消失
//    · 衰减只安排在"不在画布显示行"的时间片里跑，
//      因此绝不与屏幕刷新抢端口，屏幕上不会出现撕裂或空洞
//
//  端口策略（真双口 BRAM）：
//    Port A @ clk_dot(100MHz)：只写（打点）
//    Port B @ pclk(25MHz)    ：读（给像素）/ 写（给衰减）
//    时间上互斥：画布显示行 = 读；其余行 + 场消隐 = 衰减读写
//
//  资源：128×128×4bit = 64 Kbit → TD 推断为块 RAM（EG4 上约 7~8 个 9K BRAM）
//////////////////////////////////////////////////////////////////////////////////
module xy_scope #(
    parameter [9:0] X0    = 10'd24,      // 画布左上角屏幕坐标（显示区 256×256）
    parameter [9:0] Y0    = 10'd56,
    parameter       MAG   = 1,           // 放大倍数 2^MAG：128×128 → 256×256
    parameter [3:0] PEAK  = 4'hF         // 打点亮度的峰值
)(
    // ---------------- 打点侧（100MHz 主运算域） ----------------
    input  wire        clk_dot,
    input  wire        dot_en,           // 0 = 失锁/无信号，停止打点（画布自然衰减清空）
    input  wire [11:0] xi,               // X 轴数据：ADC 真实输入
    input  wire [11:0] yi,               // Y 轴数据：DA 真实输出

    // ---------------- 显示侧（25MHz 像素域） ----------------
    input  wire        pclk,
    input  wire [9:0]  sx,               // 当前扫描 x（0..799）
    input  wire [9:0]  sy,               // 当前扫描 y（0..524）
    output wire [3:0]  lv                // 当前像素的荧光亮度 0..15
);

    // ---------------- 画布尺寸 ----------------
    localparam NR   = 7;                       // 128 行/列
    localparam NS   = 1 << NR;                 // 128
    localparam SZX  = NS << MAG;               // 屏幕宽度 256
    localparam SZY  = NS << MAG;               // 屏幕高度 256
    localparam AW   = 2 * NR;                  // 地址宽度 14

    // ============================================================
    //  画布存储（推断为块 RAM）
    // ============================================================
    reg [3:0] mem [0:(NS*NS)-1];

    integer i;
    initial begin
        for (i = 0; i < NS*NS; i = i + 1)
            mem[i] = 4'd0;
    end

    // ---------------- Port A：100MHz 打点写 ----------------
    wire [AW-1:0] addr_a = { yi[11:5], xi[11:5] };   // {row, col} = {Y>>5, X>>5}

    always @(posedge clk_dot) begin
        if (dot_en)
            mem[addr_a] <= PEAK;
    end

    // ============================================================
    //  Port B：25MHz 显示读 / 衰减读写
    // ============================================================
    localparam [13:0] MAXK = (NS*NS) - 1;

    // 画布在屏幕上的可见区域（含 1 像素预取，实际取数用 sx+1）
    wire in_row = (sy >= Y0) && (sy < Y0 + SZY);
    wire in_box = in_row && (sx >= X0) && (sx < X0 + SZX);

    // 预取下一个像素的画布坐标：把读地址提前一拍给出，抵消 BRAM 同步读延迟
    wire [9:0] sx_n  = (sx >= X0 + SZX - 1) ? X0 : (sx + 10'd1);
    wire [NR-1:0] cx  = (sx_n - X0) >> MAG;

    // ---------------- Y 轴翻转（必须！） ----------------
    // 屏幕坐标 y 是"向下增长"，而电压轴的正方向是"向上"。
    // 若不翻转：X、Y 同相(0°)时两点同时向右、向下走，屏幕上画出的是
    //           "左上→右下"的斜线，即二、四象限；
    // 翻转后   ：同上条件画出"左下→右上"，落在一、三象限，与示波器 X-Y 一致。
    // 注意：RAM 里的数据布局不动，只在读取时镜像，所以打点侧零开销。
    wire [NR-1:0] cy_u = (sy - Y0) >> MAG;        // 未翻转：屏幕从上到下

    // 翻转值 = (NS-1) - cy_u。画布内 cy_u 恒在 0..NS-1，因此等价于 NR 位按位取反：
    // 纯反相器实现，不占减法器（这也是为什么这里不写成 127-cy_u 的原因）。
    wire [NR-1:0] cy   = ~cy_u;                   // 翻转后：电压从下到上

    reg [AW-1:0] b_addr;
    reg          b_we;
    reg [3:0]    b_din;
    reg [3:0]    b_dout;

    // ---------------- 衰减轮 ----------------
    // 每帧跑一轮全场 "-1" 扫描；扫完就停，等下一帧。
    // 一轮需要 16384×2 = 32768 拍，而每帧有 (480-256+45)×800 = 215200 拍可用，
    // 余量充足，所以永远追得上刷新，不会出现"衰减做不完"导致的残影堆积。
    reg [13:0] decay_k;
    reg        decay_run;
    reg        decay_ph;      // 0 = 读当前地址，1 = 把减 1 后的值写回

    wire frame_tick = (sx == 10'd0) && (sy == 10'd0);

    always @(posedge pclk) begin
        if (frame_tick) begin
            decay_run <= 1'b1;
            decay_k   <= 14'd0;
            decay_ph  <= 1'b0;
        end else if (decay_run && !in_row) begin
            // 只有不在画布显示行时才推进衰减，避免与屏幕读取争用
            if (decay_ph) begin
                decay_ph <= 1'b0;
                if (decay_k == MAXK) begin
                    decay_k   <= 14'd0;
                    decay_run <= 1'b0;
                end else
                    decay_k   <= decay_k + 14'd1;
            end else begin
                decay_ph <= 1'b1;
            end
        end
    end

    // Port B 地址/写数据仲裁
    always @(*) begin
        if (in_row) begin
            // 画布显示行：只读（给像素）
            b_addr = {cy, cx};
            b_we   = 1'b0;
            b_din  = 4'd0;
        end else if (decay_run && decay_ph) begin
            // 衰减写拍：把上一拍读出的值减 1 写回同一地址
            // 时序说明：上一拍(decay_ph=0)给出地址 decay_k 并发读，
            //           本拍 b_dout 已经是该地址的旧值，「旧值-1」写回同一地址。
            b_addr = decay_k;
            b_we   = 1'b1;
            b_din  = (b_dout == 4'd0) ? 4'd0 : (b_dout - 4'd1);
        end else begin
            // 衰减读拍
            b_addr = decay_k;
            b_we   = 1'b0;
            b_din  = 4'd0;
        end
    end

    // Port B 的同步读 / 条件写
    always @(posedge pclk) begin
        if (b_we)
            mem[b_addr] <= b_din;
        b_dout <= mem[b_addr];      // 同步读，下一拍有效
    end

    // ---------------- 输出 ----------------
    // 像素对齐：当前拍 sx=k 时，b_dout 里已经是第 k 列的值
    // （地址在上一拍 sx=k-1 就由 sx_n 提前给出，抵消了 BRAM 的一拍同步读延迟）
    assign lv = in_box ? b_dout : 4'd0;

endmodule
