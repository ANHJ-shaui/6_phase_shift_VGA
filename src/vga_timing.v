//////////////////////////////////////////////////////////////////////////////////
//  模块名称：vga_timing（640×480@60Hz 时序发生器）
//  像素时钟：25 MHz（板载 PLL 的 clk2）
//  行：640 有效 + 16 前肩 + 96 同步 + 48 后肩 = 800
//  场：480 有效 + 10 前肩 +  2 同步 + 33 后肩 = 525
//  帧率 = 25MHz / (800×525) ≈ 59.52 Hz（绝大多数显示器兼容）
//////////////////////////////////////////////////////////////////////////////////
module vga_timing (
    input  wire        pclk,
    input  wire        rst_n,
    output reg  [9:0]  x,           // 0..799
    output reg  [9:0]  y,           // 0..524
    output wire        hs_n,        // 行同步（低有效）
    output wire        vs_n,        // 场同步（低有效）
    output wire        de,          // 数据有效
    output wire        frame_start  // 每帧第一个像素
);

    localparam H_VIS  = 640;
    localparam H_FP   = 16;
    localparam H_SYNC = 96;
    localparam H_BP   = 48;
    localparam H_TOT  = 800;

    localparam V_VIS  = 480;
    localparam V_FP   = 10;
    localparam V_SYNC = 2;
    localparam V_BP   = 33;
    localparam V_TOT  = 525;

    always @(posedge pclk or negedge rst_n) begin
        if (!rst_n) begin
            x <= 10'd0;
            y <= 10'd0;
        end else if (x == H_TOT - 1) begin
            x <= 10'd0;
            y <= (y == V_TOT - 1) ? 10'd0 : (y + 10'd1);
        end else begin
            x <= x + 10'd1;
        end
    end

    assign hs_n = ~((x >= H_VIS + H_FP) && (x < H_VIS + H_FP + H_SYNC));
    assign vs_n = ~((y >= V_VIS + V_FP) && (y < V_VIS + V_FP + V_SYNC));
    assign de   = (x < H_VIS) && (y < V_VIS);
    assign frame_start = (x == 10'd0) && (y == 10'd0);

endmodule
