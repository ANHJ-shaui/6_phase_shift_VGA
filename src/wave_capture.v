//////////////////////////////////////////////////////////////////////////////////
//  模块名称：wave_capture（从 6_VGA 的 wave_source 改造而来）
//  功能：每帧把"一个周期的真实波形"重采样成屏幕列，写入 24 位 wave_ram
//
//  与 6_VGA 沙盒的区别：沙盒里是自己造正弦；这里读的是 dpram 里存的真实
//  一个周期快照（由 ADC 采样 + 相位地址写入），所以显示的是真实信号。
//
//  工作机制（不撕裂的关键，与 6_VGA 完全一致）：
//      每帧在场消隐期收到一次 load_start，就把 323 列一次性写完，然后停手。
//      有效显示期间 RAM 内容静止，读侧看到的是一张稳定快照。
//
//  重采样：dpram 深度 512（一个周期），屏幕 323 列，用累加器代替除法
//          addr(k) = (k × 405) >> 8，405/256 ≈ 512/323，全程无除法器
//
//  OUT 路相位：rd_ot_addr = rd_in_addr + phase_offset，9 位自然回绕即 360°，
//              所以 OUT 的相位差由 NCO 的 phase_offset（0/128/256 = 0°/90°/180°）
//              精确控制 —— 这是能画出真圆的前提。
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module wave_capture #(
    parameter AW      = 9,
    parameter DW      = 12,
    parameter POINTS  = 323,      // 波形区列数（x 301~623）
    parameter SRC_LEN = 512,      // dpram 深度 = 一个完整周期
    parameter Y_BASE  = 331       // y = 331 - data/16，与 vga_ui_v4 原映射一致
)(
    input  wire            clk,           // 100MHz 采集侧
    input  wire            rst_n,
    input  wire            load_start,    // 25M 域 frame_start（内部同步+取沿）
    input  wire [8:0]      phase_offset,  // OUT 路相位偏移（0/128/256）
    input  wire            mode_2x,       // 1 = OUT 路二倍频（地址翻倍，画 ∞ 用）

    // 读 dpram：IN 路（本模块给地址，下一拍拿数据）
    output reg  [8:0]      rd_in_addr,
    input  wire [DW-1:0]   rd_in_data,
    // 读 dpram：OUT 路（地址 = IN 地址 + phase_offset）
    output reg  [8:0]      rd_ot_addr,
    input  wire [DW-1:0]   rd_ot_data,

    output reg             we,
    output reg  [AW-1:0]   addr_w,
    output reg  [2*DW-1:0] din
);

    // 重采样步长：512/323 × 256 ≈ 405
    localparam [15:0] STEP = (SRC_LEN * 256) / POINTS;

    // 12 位 ADC 值 → 屏幕 Y（与 vga_ui_v4 原来的映射完全相同，视觉位置不变）
    wire [9:0]  y_in = Y_BASE - (rd_in_data >> 4);
    wire [9:0]  y_ot = Y_BASE - (rd_ot_data >> 4);
    wire [11:0] yin = {2'b00, y_in};
    wire [11:0] yot = {2'b00, y_ot};

    // load_start 跨时钟域同步 + 上升沿检测（25M → 100M）
    reg ld0, ld1;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            ld0 <= 1'b0;
            ld1 <= 1'b0;
        end else begin
            ld0 <= load_start;
            ld1 <= ld0;
        end
    end
    wire ld_trig = ld0 & ~ld1;

    reg          running;
    reg [AW-1:0] k;
    reg [17:0]   pos;

    // OUT 路读地址：二倍频时地址翻倍（9 位自然回绕 = 2 个周期），否则加相位偏移
    wire [8:0] nx_addr    = (pos + {2'b0, STEP}) >> 8;                  // 下一个 IN 地址
    wire [8:0] nx_ot_addr = mode_2x ? {nx_addr[7:0], 1'b0}
                                    : (nx_addr + phase_offset);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            running    <= 1'b0;
            k          <= {AW{1'b0}};
            pos        <= 18'd0;
            we         <= 1'b0;
            addr_w     <= {AW{1'b0}};
            din        <= {2*DW{1'b0}};
            rd_in_addr <= 9'd0;
            rd_ot_addr <= 9'd0;
        end else begin
            we <= 1'b0;

            if (!running) begin
                if (ld_trig) begin
                    running    <= 1'b1;
                    k          <= {AW{1'b0}};
                    pos        <= 18'd0;
                    rd_in_addr <= 9'd0;                    // 第 0 点
                    rd_ot_addr <= mode_2x ? 9'd0 : (9'd0 + phase_offset);
                end
            end else begin
                // 本拍的 rd_*_data 对应上一拍给出的地址 → 正是第 k 点
                we     <= 1'b1;
                addr_w <= k;
                din    <= {yin, yot};

                if (k == POINTS - 1) begin
                    running <= 1'b0;               // 一屏写满，等下一帧
                end else begin
                    k   <= k + 8'd1;
                    pos <= pos + {2'b0, STEP};
                    rd_in_addr <= nx_addr;
                    rd_ot_addr <= nx_ot_addr;
                end
            end
        end
    end

endmodule
