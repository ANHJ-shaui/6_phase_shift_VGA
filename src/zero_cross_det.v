module zero_cross_det (
    input  wire        clk,        // 100MHz 系统时钟
    input  wire        rst_n,      // 异步复位，低有效
    input  wire [11:0] adc_data,   // 来自ADC的12位数据
    output reg         pos_pulse   // 过零上升沿脉冲（单周期）
);

    // 参数定义：中心值和迟滞带宽
    parameter CENTER = 12'd2048;
    parameter HYST   = 12'd50;

    reg state; // 0: 当前在中心值以下, 1: 当前在中心值以上

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state     <= 1'b0;
            pos_pulse <= 1'b0;
        end else begin
            pos_pulse <= 1'b0; // 默认输出低电平

            if (state == 1'b0) begin
                // 当前在低电平区，等待上升越过 CENTER + HYST
                if (adc_data > CENTER + HYST) begin
                    state     <= 1'b1;
                    pos_pulse <= 1'b1; // 产生上升沿脉冲
                end
            end else begin
                // 当前在高电平区，等待下降越过 CENTER - HYST
                if (adc_data < CENTER - HYST) begin
                    state <= 1'b0;
                end
            end
        end
    end

endmodule