`timescale 1ns / 1ps

module adda_direct_tb;

    reg         clk_50m;
    reg         reset_n;
    reg         key_mode0;
    reg         key_mode1;
    reg         key_mode2;
    reg  [11:0] ad_dat;
    wire        ad_clk;
    wire        da_clk;
    wire [11:0] da_dat;
    wire        lock_led;
    wire        led_mode0;
    wire        led_mode1;
    wire        led_mode2;
    // 第 6 周新增 VGA 输出（仿真中只观察波形，不接显示器）
    wire        vga_hs;
    wire        vga_vs;
    wire [3:0]  vga_r;
    wire [3:0]  vga_g;
    wire [3:0]  vga_b;

    // 例化顶层，按名称连接
    adda_direct uut (
        .clk_50m    (clk_50m),
        .reset_n    (reset_n),
        .key_mode0  (key_mode0),
        .key_mode1  (key_mode1),
        .key_mode2  (key_mode2),
        .ad_dat     (ad_dat),
        .ad_clk     (ad_clk),
        .da_clk     (da_clk),
        .da_dat     (da_dat),
        .lock_led   (lock_led),
        .led_mode0  (led_mode0),
        .led_mode1  (led_mode1),
        .led_mode2  (led_mode2),
        .vga_hs     (vga_hs),
        .vga_vs     (vga_vs),
        .vga_r      (vga_r),
        .vga_g      (vga_g),
        .vga_b      (vga_b)
    );

    // 仿真时加速消抖：三个消抖模块的消抖时间改为 0
    defparam uut.u_key0.DEBOUNCE_MS = 0;
    defparam uut.u_key1.DEBOUNCE_MS = 0;
    defparam uut.u_key2.DEBOUNCE_MS = 0;

    // 50MHz 时钟
    initial clk_50m = 0;
    always #10 clk_50m = ~clk_50m;

    // 正弦波 ROM：512 点
    reg [11:0] sin_rom [0:511];
    initial begin
        $readmemh("sine.mem", sin_rom);
    end

    // 模拟 ADC：100MHz 下每 4 拍更新一次（25MHz 采样率）
    reg [8:0] idx;
    reg [1:0] div_cnt;
    reg clk_100m_sim;

    initial clk_100m_sim = 0;
    always #5 clk_100m_sim = ~clk_100m_sim;

    always @(posedge clk_100m_sim or negedge reset_n) begin
        if (!reset_n) begin
            ad_dat  <= 12'd0;
            idx     <= 9'd0;
            div_cnt <= 2'd0;
        end else if (!uut.pll_lock) begin
            ad_dat  <= 12'd0;
            idx     <= 9'd0;
            div_cnt <= 2'd0;
        end else begin
            div_cnt <= div_cnt + 1'b1;
            if (div_cnt == 2'd3) begin
                ad_dat <= sin_rom[idx];
                idx    <= idx + 1'b1;
            end
        end
    end

    // 按键初始状态：全部松开（高电平）
    initial begin
        key_mode0 = 1'b1;
        key_mode1 = 1'b1;
        key_mode2 = 1'b1;
    end

    //---------------------------------------------------
    // 按键激励：0→1→2 循环，每种模式保持 200us
    // 总仿真 620us，保证三种模式各有完整观察窗口
    //---------------------------------------------------
    initial begin
        reset_n = 0;
        #200;
        reset_n = 1;

        // 等 PLL 锁定和系统稳定
        #20000;   // 20us

        forever begin
            // mode 0：对角线（按 KEY2）
            key_mode0 = 1'b0;
            #1000;
            key_mode0 = 1'b1;
            #199000;   // 保持 200us

            // mode 1：圆（按 KEY3）
            key_mode1 = 1'b0;
            #1000;
            key_mode1 = 1'b1;
            #199000;

            // mode 2：∞形（按 KEY4）
            key_mode2 = 1'b0;
            #1000;
            key_mode2 = 1'b1;
            #199000;
        end
    end

    // 仿真结束：620us
    initial begin
        #620000;   // 620us
        $finish;
    end

    glbl glbl();

endmodule