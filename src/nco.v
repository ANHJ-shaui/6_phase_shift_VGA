module nco (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        sync_pulse,
    input  wire [31:0] period_meas,
    input  wire        mode_2x,       
    input  wire [8:0]  phase_offset,  
    output wire [8:0]  ram_rd_addr,
    output wire [8:0]  addr_al,       // 基准相位地址 = 累加相位 + 延迟补偿（不含 phase_offset）
    output wire [8:0]  phase_addr     // 纯累加相位（不含补偿、不含相移）—— 给 VGA 画布用
);

    reg [31:0] phase_acc;
    reg [31:0] ftw;

    wire [31:0] quotient, remainder;
    wire        rdy;

    wire [31:0] dividend = 32'hFFFFFFFF;

    parameter PERIOD_MIN = 32'd500;
    parameter PERIOD_MAX = 32'd1000000;

    //===========================================================
    // 【新增】系统固有延迟补偿参数（单位：时钟周期）
    // 基于 100kHz 下 -14° 滞后估算，理论值约 39。
    // 若测试出现：
    //   - 仍有正斜率小椭圆 → 说明补偿不足，改大（如 42、45）
    //   - 变成负斜率         → 说明补偿过量，改小（如 35、32）
    //===========================================================
    parameter DELAY_CLKS = 39;

    wire [31:0] period_used = mode_2x ? (period_meas >> 1) : period_meas;

    div_gen_32 u_div (
        .aclk                   (clk),
        .s_axis_divisor_tvalid  (1'b1),
        .s_axis_divisor_tdata   (period_used), 
        .s_axis_dividend_tvalid (1'b1),
        .s_axis_dividend_tdata  (dividend),
        .m_axis_dout_tvalid     (rdy),
        .m_axis_dout_tdata      ({quotient, remainder})
    );

    wire period_valid = (period_used >= PERIOD_MIN) &&
                        (period_used <= PERIOD_MAX);

    wire [31:0] ftw_safe = (quotient == 32'hFFFFFFFF) ? ftw : quotient;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            ftw <= 32'd0;
        else if (rdy && period_valid)
            ftw <= ftw_safe;
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)              phase_acc <= 32'd0;
        else if (sync_pulse)     phase_acc <= 32'd0;
        else                     phase_acc <= phase_acc + ftw;
    end

    // 锁存 phase_offset，防止按键切换瞬间发生地址撕裂
    reg [8:0] phase_offset_r;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) phase_offset_r <= 9'd0;
        else        phase_offset_r <= phase_offset;
    end

    //===========================================================
    // 【新增】动态相位补偿：
    //   Δoffset = 512 * DELAY_CLKS / period
    //           = DELAY_CLKS * FTW / 2^23      （因 FTW = 2^32/period）
    // 除以 2^23 就是右移 23 位，无需除法器。
    // 取 [22] 位实现四舍五入，让补偿更精确。
    //===========================================================
    wire [63:0] comp_offset_wide = ftw * DELAY_CLKS;
    wire [8:0]  comp_offset      = comp_offset_wide[31:23]
                                 + comp_offset_wide[22];

    // 读地址 = (基准相位地址 + 相移) 的低 9 位，按 512 点自然回绕。
    // 分成两段算的目的是给 VGA 也留一个"基准相位"：
    //   addr_al     = 相位 + 延迟补偿          → 对应输入侧(IN)，没有任何相移
    //   ram_rd_addr = addr_al + phase_offset   → 对应输出侧(OUT)
    // 两者严格相差一个 phase_offset，屏幕上的两条曲线才能对上真实相位关系。
    //
    // 【重要】这两条路径都只打一拍寄存器，与改之前的流水线延迟完全一致，
    //        所以 DELAY_CLKS=39 这个实测标定值不受影响，不需要重新调。
    wire [9:0] base_sum    = {1'b0, phase_acc[31:23]} + {1'b0, comp_offset};
    wire [9:0] rd_addr_sum = base_sum + {1'b0, phase_offset_r};

    // 整个加法器输出再打一拍，滤除组合逻辑进位毛刺（第5周实测必须）
    reg  [9:0] rd_addr_sum_r;
    reg  [9:0] base_sum_r;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rd_addr_sum_r <= 10'd0;
            base_sum_r    <= 10'd0;
        end else begin
            rd_addr_sum_r <= rd_addr_sum;
            base_sum_r    <= base_sum;
        end
    end

    assign ram_rd_addr = rd_addr_sum_r[8:0];
    assign addr_al     = base_sum_r[8:0];

    //===========================================================
    //  【第 6 周】纯相位输出（完全不含 DELAY_CLKS 补偿）
    //
    //  为什么需要它：VGA 的 X-Y 画布两轴都取自数字域
    //      X = ad_dat_sync（ADC 当前采样值）
    //      Y = 用本信号当地址读出的周期快照值
    //  这条路径里没有 DAC 建立时间、没有模拟走线、没有探头，
    //  从 ADC 到 RAM 输出只有几个时钟（约 40ns）。
    //
    //  而 DELAY_CLKS=39 是按**示波器**链路标定的（AD采样+FPGA+DAC建立+模拟传播≈388ns）。
    //  若画布也加上这 39 拍，就会过补偿约 350ns：
    //  100kHz 时等效 39×(512/1000) ≈ 20 个地址点 ≈ 14°，方向还反过来，
    //  表现为 0° 对角线被推成"反向张开"的椭圆 —— 也就是频率一高就散开的现象。
    //
    //  画布侧真实残余只有约 4 拍，100kHz 下 ≈ 2 个地址点 ≈ 1.4°，肉眼不可见，
    //  因此这里直接输出未经补偿的累加相位。
    //===========================================================
    reg [8:0] phase_addr_r;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) phase_addr_r <= 9'd0;
        else        phase_addr_r <= phase_acc[31:23];
    end

    assign phase_addr = phase_addr_r;

endmodule