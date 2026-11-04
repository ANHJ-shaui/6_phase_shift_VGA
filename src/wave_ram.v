//////////////////////////////////////////////////////////////////////////////////
//  模块名称：wave_ram（从 6_VGA 移植）
//  功能：双通道波形显示缓冲，同时承担跨时钟域的桥
//      · 写端口：100MHz（波形采集侧）
//      · 读端口：25MHz （VGA 像素侧）
//  宽位宽方案：DW = 24，一条总线同时装两路
//      din[23:12] = IN  (输入/参考，青色)
//      din[11:0]  = OUT (输出/跟踪，橙黄)
//      两路共用同一写地址，物理上零相位差，比分两块 RAM 可靠
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module wave_ram #(
    parameter AW    = 9,        // 512 深度（只用前 323）
    parameter DW    = 24,
    parameter DEPTH = 512
)(
    input  wire             clk_w,
    input  wire             we,
    input  wire [AW-1:0]    addr_w,
    input  wire [DW-1:0]    din,

    input  wire             clk_r,
    input  wire [AW-1:0]    addr_r,
    output reg  [DW-1:0]    dout
);

    reg [DW-1:0] mem [0:DEPTH-1];

    integer i;
    initial begin
        for (i = 0; i < DEPTH; i = i + 1)
            mem[i] = {DW{1'b0}};
    end

    always @(posedge clk_w) begin
        if (we)
            mem[addr_w] <= din;
    end

    always @(posedge clk_r) begin
        dout <= mem[addr_r];
    end

endmodule
