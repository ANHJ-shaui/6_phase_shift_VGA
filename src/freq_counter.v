//////////////////////////////////////////////////////////////////////////////////
//  模块名称：freq_counter（闸门频率计）
//  功能：在固定闸门时间内数输入脉冲个数，直接得到 0.01 kHz 单位的频率
//        f = N / T_gate；T_gate = GATE_MS 毫秒
//        freq_centi = N × (100 / GATE_MS)
//        例：GATE_MS=100、48.83kHz → 100ms 内 4883 个脉冲 → 4883（= 48.83 kHz）
//  说明：不需要除法器；闸门结束时更新一次，valid 给出单周期更新脉冲
//        默认闸门 100ms（分辨率 10Hz），仿真时可用参数缩短
//////////////////////////////////////////////////////////////////////////////////
module freq_counter #(
    parameter integer CLK_FREQ = 100_000_000,
    parameter integer GATE_MS  = 100
)(
    input  wire        clk,
    input  wire        rst_n,
    input  wire        sig,          // 输入脉冲（如 pos_pulse）
    output reg  [15:0] freq_centi,   // 0.01 kHz
    output reg         valid         // 更新脉冲
);

    localparam integer GATE_MAX = (CLK_FREQ / 1000) * GATE_MS;
    localparam integer MULT     = 100 / GATE_MS;

    reg [31:0] gate_cnt;
    reg [15:0] pulse_cnt;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            gate_cnt   <= 32'd0;
            pulse_cnt  <= 16'd0;
            freq_centi <= 16'd0;
            valid      <= 1'b0;
        end else begin
            valid <= 1'b0;

            if (sig)
                pulse_cnt <= pulse_cnt + 16'd1;

            if (gate_cnt == GATE_MAX - 1) begin
                gate_cnt   <= 32'd0;
                freq_centi <= pulse_cnt * MULT;   // 闸门结束，锁存
                pulse_cnt  <= 16'd0;
                valid      <= 1'b1;
            end else begin
                gate_cnt <= gate_cnt + 32'd1;
            end
        end
    end

endmodule
