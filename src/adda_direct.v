//////////////////////////////////////////////////////////////////////////////////
//  模块名称：adda_direct（第 5 周核心 + 第 6 周 VGA 显示）
//
//  【主链路】与第 5 周完全一致，逻辑一行未改：
//      AD807 → 同步 → 过零 → 测周 → 平滑 → NCO(含延迟补偿) → dpram → 中值滤波 → DA902
//      三个按键切换：KEY2 对角线(0°) / KEY3 圆(90°) / KEY4 ∞形(2×)
//
//  【本次新增】纯显示支路，不参与闭环，不影响任何主链路时序：
//      · X-Y 李萨如 xy_scope：X=ADC 真实输入，Y=DA 真实输出，打点 + 余辉
//      · Y-T 波形：从两块"周期快照 dpram"重采样成 320 列（青=IN / 橙黄=OUT）
//      · 参数面板：频率 / 周期 / Vpp / Vrms / 图形 / 相位 / 状态
//
//  为什么 IN/OUT 两条显示曲线都能画对：
//    dpram 里存的是"输入波形的一个完整周期快照"（写地址由相位驱动，一个输入周期写满
//    512 点）。显示侧由 wave_capture 自己线性给出读地址，读出来的内容只取决于地址，
//    与 NCO 当前的扫描速度无关 —— 所以即使在 ∞ 模式下（NCO 走 2 倍频），
//    IN 那条曲线依然是输入的真实一个周期，OUT 那条靠地址翻倍呈现 2 倍频关系。
//    这与示波器上"X 接输入、Y 接 DA 输出"看到的关系一致。
//
//  时钟域：100MHz（采集/运算/打点）、50MHz（DA 输出）、25MHz（VGA 像素）
//
//  【端口与约束】vga_hs / vga_vs / vga_r[3:0] / vga_g[3:0] / vga_b[3:0]
//               必须与 adda_direct.adc 里的名字逐字一致，否则报
//               "Failed to find pin / multi-bit port" 类错误。
//////////////////////////////////////////////////////////////////////////////////
module adda_direct(
    input  clk_50m,        
    input  reset_n,        
    input  key_mode0,      
    input  key_mode1,      
    input  key_mode2,      
    input  [11:0] ad_dat,  
    output ad_clk,         
    output da_clk,         
    output [11:0] da_dat,  
    output lock_led,       
    output led_mode0,      
    output led_mode1,      
    output led_mode2,
    // ---------------- VGA 640x480（第 6 周新增，名字须与 .adc 逐字一致） ----------------
    output vga_hs,
    output vga_vs,
    output [3:0] vga_r,
    output [3:0] vga_g,
    output [3:0] vga_b
);

    wire clk100m_raw, clk50m_raw, clk25m_raw;
    wire pll_lock;

    PL u_pll (
        .refclk(clk_50m),
        .reset(~reset_n),
        .extlock(pll_lock),
        .clk0_out(clk100m_raw),
        .clk1_out(clk50m_raw),
        .clk2_out(clk25m_raw)
    );

    wire clk100m, clk50m, clk25m;
    BUFG_0 u_bufg100 (.i(clk100m_raw), .o(clk100m));
    BUFG_0 u_bufg50  (.i(clk50m_raw),  .o(clk50m));
    BUFG_0 u_bufg25  (.i(clk25m_raw),  .o(clk25m));

    assign ad_clk   = clk25m;
    assign da_clk   = clk50m;
    assign lock_led = pll_lock;
    wire sys_rst_n  = pll_lock & reset_n;

    // 6. ADC数据跨时钟域同步
    (* ASYNC_REG = "TRUE" *) reg [11:0] ad_dat_r1, ad_dat_r2;
    always @(posedge clk100m or negedge sys_rst_n) begin
        if (!sys_rst_n) begin
            ad_dat_r1 <= 12'd0;
            ad_dat_r2 <= 12'd0;
        end else begin
            ad_dat_r1 <= ad_dat;
            ad_dat_r2 <= ad_dat_r1;
        end
    end
    wire [11:0] ad_dat_sync = ad_dat_r2;

    // 7. 过零检测
    wire pos_pulse;
    zero_cross_det u_zero_cross (
        .clk       (clk100m),
        .rst_n     (sys_rst_n),
        .adc_data  (ad_dat_sync),
        .pos_pulse (pos_pulse)
    );

    // 8. 周期测量
    wire [31:0] period_meas;
    period_measure u_period (
        .clk         (clk100m),
        .rst_n       (sys_rst_n),
        .pos_pulse   (pos_pulse),
        .period_meas (period_meas)
    );

    // 【核心修改1】加入周期平滑滤波，消除 1 个时钟抖动带来的余晖
    reg [31:0] period_avg;
    always @(posedge clk100m or negedge sys_rst_n) begin
        if (!sys_rst_n) begin
            period_avg <= 32'd2048;
        end else if (pos_pulse && period_meas > 32'd1000) begin
            // 算术右移两位等效于除以 4：(旧值*3 + 新值) / 4
            period_avg <= ((period_avg << 1) + period_avg + period_meas) >> 2;
        end
    end

    // 9. 三个独立按键消抖
    wire key_pulse0, key_pulse1, key_pulse2;
    key_debounce u_key0 (.clk(clk100m), .rst_n(sys_rst_n), .key(key_mode0), .key_pulse(key_pulse0));
    key_debounce u_key1 (.clk(clk100m), .rst_n(sys_rst_n), .key(key_mode1), .key_pulse(key_pulse1));
    key_debounce u_key2 (.clk(clk100m), .rst_n(sys_rst_n), .key(key_mode2), .key_pulse(key_pulse2));

    // 10. 模式控制
    reg [1:0] mode;
    always @(posedge clk100m or negedge sys_rst_n) begin
        if (!sys_rst_n)      mode <= 2'd0;
        else if (key_pulse0) mode <= 2'd0;   
        else if (key_pulse1) mode <= 2'd1;   
        else if (key_pulse2) mode <= 2'd2;   
    end

    assign led_mode0 = (mode == 2'd0);
    assign led_mode1 = (mode == 2'd1);
    assign led_mode2 = (mode == 2'd2);

    // 11. 模式解码
    reg [8:0] phase_offset;
    reg       mode_2x;
    always @(*) begin
        case (mode)
            2'd0: begin phase_offset = 9'd0;   mode_2x = 1'b0; end
            2'd1: begin phase_offset = 9'd128; mode_2x = 1'b0; end
            2'd2: begin phase_offset = 9'd0;   mode_2x = 1'b1; end
            default: begin phase_offset = 9'd0; mode_2x = 1'b0; end
        endcase
    end

    // 12. 例化 NCO (输入平滑后的周期)
    wire [8:0] ram_rd_addr;
    wire [8:0] phase_addr;        // 纯相位（无延迟补偿），VGA 画布专用
    nco u_nco (
        .clk          (clk100m),
        .rst_n        (sys_rst_n),
        .sync_pulse   (pos_pulse),
        .period_meas  (period_avg),   // 【修改】使用平滑后的周期
        .mode_2x      (mode_2x),      
        .phase_offset (phase_offset),
        .ram_rd_addr  (ram_rd_addr),
        .addr_al      (),             // 补偿后基相位，保留给 TD_DEBUG 观察
        .phase_addr   (phase_addr)    // 纯相位 → VGA 画布 Y 通道
    );

    // 13. RAM 写逻辑 (Bresenham均匀地址)
    reg  [31:0] wr_accum;        
    reg  [8:0]  ram_wr_addr;
    reg         wr_en;
    wire [11:0] ram_rd_data;

    always @(posedge clk100m or negedge sys_rst_n) begin
        if (!sys_rst_n) begin
            wr_accum    <= 32'd0;
            ram_wr_addr <= 9'd0;
            wr_en       <= 1'b0;
        end else if (pos_pulse) begin
            wr_accum    <= 32'd0;
            ram_wr_addr <= 9'd0;
            wr_en       <= 1'b1;  
        end else if (ram_wr_addr < 9'd511) begin
            // 注意：使用平滑后的 period_avg 计算写地址节奏，与读节奏匹配
            if (wr_accum >= period_avg) begin 
                wr_accum    <= wr_accum - period_avg + 32'd512;
                ram_wr_addr <= ram_wr_addr + 1'b1;
                wr_en       <= 1'b1;  
            end else begin
                wr_accum    <= wr_accum + 32'd512;
                wr_en       <= 1'b0;  
            end
        end else begin
            wr_en <= 1'b0;            
        end
    end

    // 【核心修改2】对写入数据打一拍，消除由于ADC跨时钟域采到的毛刺
    reg [11:0] wr_data_reg;
    always @(posedge clk100m or negedge sys_rst_n) begin
        if (!sys_rst_n) wr_data_reg <= 12'd0;
        else            wr_data_reg <= ad_dat_sync;
    end

    // 14. 例化双口 RAM
    dpram u_dpram (
        .wr_clk  (clk100m),
        .wr_en   (wr_en),          
        .wr_addr (ram_wr_addr),
        .wr_data (wr_data_reg),    // 【修改】写入寄存后的数据
        .rd_clk  (clk100m),
        .rd_addr (ram_rd_addr),
        .rd_data (ram_rd_data)
    );

        //------------------------------------------
    // 15. 输出数据跨时钟域同步 (100MHz -> 50MHz) + 中值滤波
    //------------------------------------------
    reg [11:0] da_dat_r1, da_dat_r2, da_dat_r3;

    always @(posedge clk50m or negedge sys_rst_n) begin
        if (!sys_rst_n) begin
            da_dat_r1 <= 12'd0;
            da_dat_r2 <= 12'd0;
            da_dat_r3 <= 12'd0;
        end else begin
            da_dat_r1 <= ram_rd_data; // 抓取 RAM 输出
            da_dat_r2 <= da_dat_r1;   // 打一拍
            da_dat_r3 <= da_dat_r2;   // 打两拍
        end
    end

    // 取三个连续采样的中值，完美滤除单点毛刺，不影响波形斜率
    wire [11:0] max_ab = (da_dat_r1 > da_dat_r2) ? da_dat_r1 : da_dat_r2;
    wire [11:0] min_ab = (da_dat_r1 < da_dat_r2) ? da_dat_r1 : da_dat_r2;
    wire [11:0] median = (da_dat_r3 > max_ab) ? max_ab : ((da_dat_r3 < min_ab) ? min_ab : da_dat_r3);

    assign da_dat = median;

    // ================================================================
    //  以下为第 6 周新增的 VGA 显示支路（纯旁路，不参与闭环）
    // ================================================================

    // ---------------- 显示用周期快照 RAM ----------------
    // 写端口与主 dpram 完全相同（同一份数据），各自独立读端口：
    //   u_dpram_in 的读地址由 wave_capture 线性给出 → 输入的一个完整周期
    //   u_dpram_ot 的读地址在此基础上加相移 / 翻倍 → 输出
    //
    // 这里多花两块 512×12 的 BRAM（各约 1 个 9K 块）换来的好处是：
    // 主 dpram 的读口仍然只服务于 DA 输出那一路连续地址，显示侧完全独立，
    // 两者互不干扰 —— 否则显示扫描会把 DA 波形打乱。
    wire [8:0]  disp_in_addr, disp_ot_addr;
    wire [11:0] disp_in_data, disp_ot_data;

    dpram u_dpram_in (
        .wr_clk  (clk100m),
        .wr_en   (wr_en),
        .wr_addr (ram_wr_addr),
        .wr_data (wr_data_reg),
        .rd_clk  (clk100m),
        .rd_addr (disp_in_addr),
        .rd_data (disp_in_data)
    );

    dpram u_dpram_ot (
        .wr_clk  (clk100m),
        .wr_en   (wr_en),
        .wr_addr (ram_wr_addr),
        .wr_data (wr_data_reg),
        .rd_clk  (clk100m),
        .rd_addr (disp_ot_addr),
        .rd_data (disp_ot_data)
    );

    // ---------------- X-Y 画布专用快照 RAM（第 4 块） ----------------
    // 为什么画布要单独一块、而不是直接用 u_dpram 的 ram_rd_data：
    //   ram_rd_data 的读地址里含 DELAY_CLKS=39 的延迟补偿，
    //   那是为"示波器 X-Y"标定的（含 DAC 建立 + 模拟传播 ≈ 388ns）。
    //   VGA 画布两轴都在数字域，延迟只有几拍，套用 39 拍会过补偿约 350ns，
    //   高频下 0° 对角线会被推成反向张开的椭圆。
    //   所以这里改用 nco 的纯相位 phase_addr，画布上看到的才是
    //   "输入与输出之间真实的相位差"，不掺任何为示波器做的修饰。
    wire [8:0]  xy_rd_addr;
    wire [11:0] xy_rd_data;

    // 画布 Y 通道地址
    //   0°   → 同地址
    //   90°  → +128
    //   2×   → 不额外处理！见下方说明
    //
    // 【重要，踩过的坑】∞ 模式下**不要**再做地址翻倍。
    //   本工程的 NCO 是"整条链路倍频"的：mode_2x 把 period 减半 → ftw 翻倍
    //   → phase_acc（也就是 phase_addr）本身已经以 2 倍速在走。
    //   读同一个基频快照时，2 倍速的地址天然就产生 2 倍频输出，已经对了。
    //   若再套一层 {addr[7:0],1'b0} 就会变成 **4 倍频**，画面上是几个环叠在
    //   一起再交叉的怪图形，而不是 ∞。
    //
    //   注意与 8_siggen 的区别：那边是"NCO 保持基频、只让 CH2 地址翻倍"
    //   （因为它要让 CH1/CH2 同时输出，必须保住 CH1 基频），所以它必须显式翻倍。
    //   本工程是单通道 DA + 外部输入当 X，X 永远是基频，倍频由 NCO 统一完成，
    //   因此画布侧什么都不用做。两套架构不同，写法不能照搬。
    //
    //   同理，Y-T 波形区的 wave_capture 仍然要传 mode_2x：它的读地址基于线性
    //   扫描 pos（与 NCO 无关），那边确实需要显式翻倍才能显示 2 倍频。
    assign xy_rd_addr = phase_addr + phase_offset;

    dpram u_dpram_xy (
        .wr_clk  (clk100m),
        .wr_en   (wr_en),
        .wr_addr (ram_wr_addr),
        .wr_data (wr_data_reg),
        .rd_clk  (clk100m),
        .rd_addr (xy_rd_addr),
        .rd_data (xy_rd_data)
    );

    // ---------------- 测量：频率 / Vpp / Vrms ----------------
    wire [15:0] fc_freq;
    freq_counter #(.GATE_MS(100)) u_fc (
        .clk        (clk100m),
        .rst_n      (sys_rst_n),
        .sig        (pos_pulse),
        .freq_centi (fc_freq),
        .valid      ()
    );

    wire [15:0] vpp_x100, rms_x100;
    measure u_meas (
        .clk      (clk100m),
        .rst_n    (sys_rst_n),
        .din      (ad_dat_sync),
        .vpp_x100 (vpp_x100),
        .rms_x100 (rms_x100)
    );

    // ---------------- 信号有效性（失锁 → 冻结波形层 + 红框 + 停打点） ----------------
    // 连续 2^20 拍（≈10.5ms，对应约 95Hz）没有过零就判定无信号。
    // 与 NCO 的 FTW 保护下限（100Hz）基本对齐，低于该频率本就不在工作范围内。
    reg [20:0] wd_cnt;
    always @(posedge clk100m or negedge sys_rst_n) begin
        if (!sys_rst_n)
            wd_cnt <= 21'd0;
        else if (pos_pulse)
            wd_cnt <= 21'd0;
        else if (!wd_cnt[20])
            wd_cnt <= wd_cnt + 1'b1;
    end
    wire lock_ok_100 = ~wd_cnt[20];

    // ---------------- 波形采集：每帧在场消隐期装载一次，保证不撕裂 ----------------
    wire        wcap_we;
    wire [8:0]  wcap_addr_w;
    wire [23:0] wcap_din;
    wire [9:0]  vgx, vgy;
    wire [8:0]  vga_wave_addr;
    wire [23:0] vga_wave_data;

    // 第 481 行（场消隐第一行）开始装载下一屏：写入约 6.5us，全部落在消隐区内
    wire frame_load = (vgx == 10'd0) && (vgy == 10'd480);

    wave_capture #(
        .AW      (9),
        .DW      (12),
        .POINTS  (320),      // 波形区列数 x 304..623
        .SRC_LEN (512),
        .Y_BASE  (311)       // y = 311 - data/16，落在波形区 y 56..311
    ) u_cap (
        .clk          (clk100m),
        .rst_n        (sys_rst_n),
        .load_start   (frame_load),
        .phase_offset (phase_offset),
        .mode_2x      (mode_2x),
        .rd_in_addr   (disp_in_addr),
        .rd_in_data   (disp_in_data),
        .rd_ot_addr   (disp_ot_addr),
        .rd_ot_data   (disp_ot_data),
        .we           (wcap_we),
        .addr_w       (wcap_addr_w),
        .din          (wcap_din)
    );

    wave_ram #(
        .AW    (9),
        .DW    (24),
        .DEPTH (512)
    ) u_wram (
        .clk_w  (clk100m),
        .we     (wcap_we),
        .addr_w (wcap_addr_w),
        .din    (wcap_din),
        .clk_r  (clk25m),
        .addr_r (vga_wave_addr),
        .dout   (vga_wave_data)
    );

    // ---------------- 参数跨时钟域同步（100MHz → 25MHz） ----------------
    (* ASYNC_REG = "TRUE" *) reg [15:0] fq0, fq1;
    (* ASYNC_REG = "TRUE" *) reg [19:0] pt0, pt1;
    (* ASYNC_REG = "TRUE" *) reg [15:0] vp0, vp1, rm0, rm1;
    (* ASYNC_REG = "TRUE" *) reg [1:0]  md0, md1;
    (* ASYNC_REG = "TRUE" *) reg        lk0, lk1;

    always @(posedge clk25m or negedge sys_rst_n) begin
        if (!sys_rst_n) begin
            fq0 <= 16'd0; fq1 <= 16'd0;
            pt0 <= 20'd0; pt1 <= 20'd0;
            vp0 <= 16'd0; vp1 <= 16'd0;
            rm0 <= 16'd0; rm1 <= 16'd0;
            md0 <= 2'd0;  md1 <= 2'd0;
            lk0 <= 1'b0;  lk1 <= 1'b0;
        end else begin
            fq0 <= fc_freq;          fq1 <= fq0;
            pt0 <= period_avg[19:0]; pt1 <= pt0;   // 显示平滑后的周期，末位不跳
            vp0 <= vpp_x100;         vp1 <= vp0;
            rm0 <= rms_x100;         rm1 <= rm0;
            md0 <= mode;             md1 <= md0;
            lk0 <= lock_ok_100;      lk1 <= lk0;
        end
    end

    // ---------------- VGA UI ----------------
    wire [11:0] vga_rgb;
    wire        vga_de;

    vga_ui_p5 u_vga (
        .pclk         (clk25m),
        .rst_n        (sys_rst_n),
        .freq_centi   (fq1),
        .period_ticks (pt1),
        .vpp_x100     (vp1),
        .rms_x100     (rm1),
        .mode         (md1),
        .lock_ok      (lk1),
        // X-Y 打点：X = ADC 真实输入，Y = DA 真实输出（与示波器 X-Y 同源）
        // X-Y 打点：X = ADC 真实输入；Y = 纯相位寻址的快照（不含示波器补偿）
        .clk_dot      (clk100m),
        .dot_en       (lock_ok_100),
        .dot_x        (ad_dat_sync),
        .dot_y        (xy_rd_data),
        .wave_dout    (vga_wave_data),
        .wave_addr    (vga_wave_addr),
        .hs_n         (vga_hs),
        .vs_n         (vga_vs),
        .de           (vga_de),
        .rgb          (vga_rgb),
        .px           (vgx),
        .py           (vgy),
        .frame_start  ()
    );

    assign vga_r = vga_rgb[11:8];
    assign vga_g = vga_rgb[7:4];
    assign vga_b = vga_rgb[3:0];

endmodule