module dpram (
    // 写端口（100MHz域）
    input  wire        wr_clk,
    input  wire        wr_en,
    input  wire [8:0]  wr_addr,
    input  wire [11:0] wr_data,
    // 读端口（100MHz域）
    input  wire        rd_clk,
    input  wire [8:0]  rd_addr,
    output reg  [11:0] rd_data
);

    reg [11:0] ram [0:511]; // 512 x 12bit 的存储空间

    // 写逻辑
    always @(posedge wr_clk) begin
        if (wr_en) begin
            ram[wr_addr] <= wr_data;
        end
    end

    // 读逻辑（同步读，输出延迟一拍）
    always @(posedge rd_clk) begin
        rd_data <= ram[rd_addr];
    end

endmodule