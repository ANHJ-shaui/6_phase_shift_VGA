module period_measure (
    input  wire        clk,          // 100MHz 系统时钟
    input  wire        rst_n,        // 异步复位，低有效
    input  wire        pos_pulse,    // 过零检测上升沿脉冲
    output reg  [31:0] period_meas   // 测量到的周期计数值
);

    reg [31:0] cnt;         // 100MHz时钟计数器
    reg [31:0] period_avg;  // 滑动平均后的周期值

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt         <= 32'd0;
            period_meas <= 32'd0;
            period_avg  <= 32'd0;
        end else begin
            // 1. 计数器一直累加
            cnt <= cnt + 1'b1;

            // 2. 捕获过零脉冲
            if (pos_pulse) begin
                period_meas <= cnt; // 锁存当前计数值作为周期
                cnt         <= 32'd0; // 清零，准备测下一个周期
                
                // 3. 简单滑动平均（4次平均，降低抖动）
                // 公式：新平均值 = (旧平均值 * 3 + 新测量值) / 4
                period_avg <= (period_avg * 3 + cnt) >> 2;
            end
        end
    end

endmodule