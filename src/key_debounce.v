// Create Date: 2026/09/30
// Module Name: key_debounce
// Description: 按键消抖，输出单周期脉冲
//              输入时钟 100MHz，消抖 20ms，按键低有效
module key_debounce #(
    parameter integer CLK_FREQ    = 100_000_000,
    parameter integer DEBOUNCE_MS = 20
)(
    input  wire clk,        // 100MHz 系统时钟
    input  wire rst_n,      // 系统复位，低有效
    input  wire key,        // 按键输入，低有效：按下为 0，松开为 1
    output wire key_pulse   // 按下瞬间输出一个时钟周期脉冲
);

    localparam integer CNT_MAX = CLK_FREQ / 1000 * DEBOUNCE_MS;

    reg [31:0] cnt;
    reg key_sync0, key_sync1;
    reg key_stable;
    reg key_stable_d;

    // 两级同步，消除亚稳态
    always @(posedge clk) begin
        key_sync0 <= key;
        key_sync1 <= key_sync0;
    end

    // 消抖计数
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt        <= 32'd0;
            key_stable <= 1'b1;   // 空闲时按键为高
        end
        else if (key_sync1 != key_stable) begin
            if (cnt >= CNT_MAX) begin
                key_stable <= key_sync1;
                cnt        <= 32'd0;
            end
            else begin
                cnt <= cnt + 1'b1;
            end
        end
        else begin
            cnt <= 32'd0;
        end
    end

    // 延迟一拍，用于边沿检测
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            key_stable_d <= 1'b1;
        else
            key_stable_d <= key_stable;
    end

    // 按下瞬间输出单周期脉冲
    assign key_pulse = key_stable_d & ~key_stable;

endmodule