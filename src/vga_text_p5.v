//////////////////////////////////////////////////////////////////////////////////
//  模块名称：vga_text_p5（第 5/6 周 · 面板文字层）
//
//  职责：把第 5 周系统真实存在的量，连同静态标签一起画到屏幕上。
//        所有内容都是 RTL 渲染，没有预生成的位图底图，改布局只需改常量。
//
//  vs 8_siggen 的 vga_text_v3：
//    v3 服务于 8 的完整功能集（INT/EXT、AGC、占空比、波形选择…）；
//    这里只保留第 5 周真实有的：图形、相位、频率、周期、Vpp、Rms、锁定状态。
//
//  单位说明：
//    freq_centi   : 0.01 kHz       例 4883 → "48.83 kHz"
//    period_ticks : 0.01 us（!）   1 tick = 10ns，所以 tick 数天然就是百分之一微秒
//                                  例 2048 → "20.48 us"
//    vpp/rms_x100 : 0.01 V
//
//  布局（8×16 字符网格，屏 640×480）：
//    y 12  标题栏（3 段 × 16 字符）
//    y 36  画布区 / 波形区小标题
//    y 332 GRAPH   | FREQ
//    y 352 PHASE   | PERIOD
//    y 372 DLY-CMP | VPP
//    y 392 STATUS  | RMS
//
//  对齐：addr/char 提前一个像素给出（xa = x+1），同步 BRAM 读的一拍延迟
//////////////////////////////////////////////////////////////////////////////////
module vga_text_p5 (
    input  wire        pclk,
    input  wire        rst_n,
    input  wire [9:0]  x,
    input  wire [9:0]  y,
    input  wire        frame_start,

    input  wire [15:0] freq_centi,      // 0.01 kHz
    input  wire [19:0] period_ticks,    // 0.01 us（100MHz 下的 tick 数）
    input  wire [15:0] vpp_x100,        // 0.01 V
    input  wire [15:0] rms_x100,        // 0.01 V
    input  wire [1:0]  mode,            // 0=LINE 1=CIRCLE 2=INF
    input  wire        lock_ok,         // 0 = 无信号/失锁

    output wire        ink
);

    // ---------------- 行首 y ----------------
    localparam [9:0] R_TITLE = 10'd12;
    localparam [9:0] R_SUB   = 10'd36;
    localparam [9:0] R_1     = 10'd332;
    localparam [9:0] R_2     = 10'd352;
    localparam [9:0] R_3     = 10'd372;
    localparam [9:0] R_4     = 10'd392;

    // ---------------- 列首 x（每段固定 16 字符 = 128 px） ----------------
    localparam [9:0] T1 = 10'd16;       // 标题段1
    localparam [9:0] T2 = 10'd144;      // 标题段2
    localparam [9:0] T3 = 10'd272;      // 标题段3
    localparam [9:0] CL = 10'd24;       // 画布区 / 左列面板
    localparam [9:0] CR = 10'd304;      // 波形区 / 右列面板
    localparam [9:0] S2 = 10'd432;      // 波形区小标题段2

    // ============================================================
    //  二进制 → BCD（double dabble：先加 3 再移位）
    // ============================================================
    function [23:0] bcd5;
        input [15:0] v;
        integer i;
        reg [23:0] b;
        begin
            b = 24'd0;
            for (i = 15; i >= 0; i = i - 1) begin
                if (b[3:0]   > 4'd4) b[3:0]   = b[3:0]   + 4'd3;
                if (b[7:4]   > 4'd4) b[7:4]   = b[7:4]   + 4'd3;
                if (b[11:8]  > 4'd4) b[11:8]  = b[11:8]  + 4'd3;
                if (b[15:12] > 4'd4) b[15:12] = b[15:12] + 4'd3;
                if (b[19:16] > 4'd4) b[19:16] = b[19:16] + 4'd3;
                b = {b[22:0], v[i]};
            end
            bcd5 = b;
        end
    endfunction

    function [27:0] bcd7;
        input [19:0] v;
        integer i;
        reg [27:0] b;
        begin
            b = 28'd0;
            for (i = 19; i >= 0; i = i - 1) begin
                if (b[3:0]   > 4'd4) b[3:0]   = b[3:0]   + 4'd3;
                if (b[7:4]   > 4'd4) b[7:4]   = b[7:4]   + 4'd3;
                if (b[11:8]  > 4'd4) b[11:8]  = b[11:8]  + 4'd3;
                if (b[15:12] > 4'd4) b[15:12] = b[15:12] + 4'd3;
                if (b[19:16] > 4'd4) b[19:16] = b[19:16] + 4'd3;
                if (b[23:20] > 4'd4) b[23:20] = b[23:20] + 4'd3;
                b = {b[26:0], v[i]};
            end
            bcd7 = b;
        end
    endfunction

    function [11:0] bcd3;
        input [8:0] v;
        integer i;
        reg [11:0] b;
        begin
            b = 12'd0;
            for (i = 8; i >= 0; i = i - 1) begin
                if (b[3:0]  > 4'd4) b[3:0]  = b[3:0]  + 4'd3;
                if (b[7:4]  > 4'd4) b[7:4]  = b[7:4]  + 4'd3;
                if (b[11:8] > 4'd4) b[11:8] = b[11:8] + 4'd3;
                b = {b[10:0], v[i]};
            end
            bcd3 = b;
        end
    endfunction

    function [7:0] dg;
        input [3:0] d;
        begin
            dg = 8'd48 + {4'd0, d};
        end
    endfunction

    // ============================================================
    //  每帧统一锁存（避免同一帧内新旧值混排）
    // ============================================================
    reg [23:0] freq_bcd;
    reg [27:0] per_bcd;
    reg [11:0] vpp_bcd;
    reg [11:0] rms_bcd;
    reg [1:0]  mode_q;
    reg        lock_q;

    always @(posedge pclk or negedge rst_n) begin
        if (!rst_n) begin
            freq_bcd <= 24'd0;
            per_bcd  <= 28'd0;
            vpp_bcd  <= 12'd0;
            rms_bcd  <= 12'd0;
            mode_q   <= 2'd0;
            lock_q   <= 1'b0;
        end else if (frame_start) begin
            freq_bcd <= bcd5(freq_centi);
            per_bcd  <= bcd7(period_ticks);
            vpp_bcd  <= bcd3(vpp_x100[8:0]);
            rms_bcd  <= bcd3(rms_x100[8:0]);
            mode_q   <= mode;
            lock_q   <= lock_ok;
        end
    end

    wire [3:0] f4 = freq_bcd[19:16], f3 = freq_bcd[15:12], f2 = freq_bcd[11:8],
               f1 = freq_bcd[7:4],   f0 = freq_bcd[3:0];
    wire [3:0] p6 = per_bcd[27:24], p5 = per_bcd[23:20], p4 = per_bcd[19:16],
               p3 = per_bcd[15:12], p2 = per_bcd[11:8],  p1 = per_bcd[7:4], p0 = per_bcd[3:0];

    // ============================================================
    //  字符解码
    // ============================================================
    wire [9:0] xa = x + 10'd1;

    reg [7:0] ch;
    reg [3:0] row;
    reg [2:0] bit_sel;
    reg       hit;

    // 标题栏内部行有效判定的简写
    wire t_row = (y >= R_TITLE) && (y < R_TITLE + 10'd16);
    wire s_row = (y >= R_SUB)   && (y < R_SUB   + 10'd16);

    always @(*) begin
        ch      = 8'd32;
        row     = 4'd0;
        bit_sel = 3'd0;
        hit     = 1'b0;

        // ============ 标题栏 y12 ============
        if (t_row && (xa >= T1) && (xa < T1 + 10'd128)) begin
            hit     = 1'b1;
            row     = y - R_TITLE;
            bit_sel = 3'd7 - ((xa - T1) & 3'd7);
            case ((xa - T1) >> 3)                       // "ADDA CLOSED-LO"
                4'd0: ch = "A";  4'd1: ch = "D";  4'd2: ch = "D";  4'd3: ch = "A";
                4'd4: ch = " ";  4'd5: ch = "C";  4'd6: ch = "L";  4'd7: ch = "O";
                4'd8: ch = "S";  4'd9: ch = "E";  4'd10: ch = "D"; 4'd11: ch = "-";
                4'd12: ch = "L"; 4'd13: ch = "O"; 4'd14: ch = "O"; 4'd15: ch = "P";
                default: ch = " ";
            endcase
        end
        else if (t_row && (xa >= T2) && (xa < T2 + 10'd128)) begin
            hit     = 1'b1;
            row     = y - R_TITLE;
            bit_sel = 3'd7 - ((xa - T2) & 3'd7);
            case ((xa - T2) >> 3)                       // " PHASE SHIFT  &"
                4'd0: ch = " ";  4'd1: ch = "P";  4'd2: ch = "H";  4'd3: ch = "A";
                4'd4: ch = "S";  4'd5: ch = "E";  4'd6: ch = " ";  4'd7: ch = "S";
                4'd8: ch = "H";  4'd9: ch = "I";  4'd10: ch = "F"; 4'd11: ch = "T";
                4'd12: ch = " "; 4'd13: ch = " "; 4'd14: ch = "&"; 4'd15: ch = " ";
                default: ch = " ";
            endcase
        end
        else if (t_row && (xa >= T3) && (xa < T3 + 10'd128)) begin
            hit     = 1'b1;
            row     = y - R_TITLE;
            bit_sel = 3'd7 - ((xa - T3) & 3'd7);
            case ((xa - T3) >> 3)                       // "X-Y LISSAJOUS  "
                4'd0: ch = "X";  4'd1: ch = "-";  4'd2: ch = "Y";  4'd3: ch = " ";
                4'd4: ch = "L";  4'd5: ch = "I";  4'd6: ch = "S";  4'd7: ch = "S";
                4'd8: ch = "A";  4'd9: ch = "J";  4'd10: ch = "O"; 4'd11: ch = "U";
                4'd12: ch = "S"; 4'd13: ch = " "; 4'd14: ch = " "; 4'd15: ch = " ";
                default: ch = " ";
            endcase
        end

        // ============ 小标题 y36 ============
        else if (s_row && (xa >= CL) && (xa < CL + 10'd128)) begin
            hit     = 1'b1;
            row     = y - R_SUB;
            bit_sel = 3'd7 - ((xa - CL) & 3'd7);
            case ((xa - CL) >> 3)                       // "REAL X-Y TRACE "
                4'd0: ch = "R";  4'd1: ch = "E";  4'd2: ch = "A";  4'd3: ch = "L";
                4'd4: ch = " ";  4'd5: ch = "X";  4'd6: ch = "-";  4'd7: ch = "Y";
                4'd8: ch = " ";  4'd9: ch = "T";  4'd10: ch = "R"; 4'd11: ch = "A";
                4'd12: ch = "C"; 4'd13: ch = "E"; 4'd14: ch = " "; 4'd15: ch = " ";
                default: ch = " ";
            endcase
        end
        else if (s_row && (xa >= CR) && (xa < CR + 10'd128)) begin
            hit     = 1'b1;
            row     = y - R_SUB;
            bit_sel = 3'd7 - ((xa - CR) & 3'd7);
            case ((xa - CR) >> 3)                       // "Y-T WAVEFORM   "
                4'd0: ch = "Y";  4'd1: ch = "-";  4'd2: ch = "T";  4'd3: ch = " ";
                4'd4: ch = "W";  4'd5: ch = "A";  4'd6: ch = "V";  4'd7: ch = "E";
                4'd8: ch = "F";  4'd9: ch = "O";  4'd10: ch = "R"; 4'd11: ch = "M";
                4'd12: ch = " "; 4'd13: ch = " "; 4'd14: ch = " "; 4'd15: ch = " ";
                default: ch = " ";
            endcase
        end
        else if (s_row && (xa >= S2) && (xa < S2 + 10'd128)) begin
            hit     = 1'b1;
            row     = y - R_SUB;
            bit_sel = 3'd7 - ((xa - S2) & 3'd7);
            case ((xa - S2) >> 3)                       // "CYAN=IN YEL=OUT"
                4'd0: ch = "C";  4'd1: ch = "Y";  4'd2: ch = "A";  4'd3: ch = "N";
                4'd4: ch = "=";  4'd5: ch = "I";  4'd6: ch = "N";  4'd7: ch = " ";
                4'd8: ch = "Y";  4'd9: ch = "E";  4'd10: ch = "L"; 4'd11: ch = "=";
                4'd12: ch = "O"; 4'd13: ch = "U"; 4'd14: ch = "T"; 4'd15: ch = " ";
                default: ch = " ";
            endcase
        end

        // ============ 左列 ============
        // ---- GRAPH (CL,332) ----
        else if ((y >= R_1) && (y < R_1 + 10'd16) &&
                 (xa >= CL) && (xa < CL + 10'd128)) begin
            hit     = 1'b1;
            row     = y - R_1;
            bit_sel = 3'd7 - ((xa - CL) & 3'd7);
            case ((xa - CL) >> 3)
                // "GRAPH  " + LINE / CIRCLE / INF
                4'd0: ch = "G";  4'd1: ch = "R";  4'd2: ch = "A";  4'd3: ch = "P";
                4'd4: ch = "H";  4'd5: ch = " ";  4'd6: ch = " ";
                4'd7:  ch = (mode_q == 2'd1) ? "C" : (mode_q == 2'd2) ? "I" : "L";
                4'd8:  ch = (mode_q == 2'd1) ? "I" : (mode_q == 2'd2) ? "N" : "I";
                4'd9:  ch = (mode_q == 2'd1) ? "R" : (mode_q == 2'd2) ? "F" : "N";
                4'd10: ch = (mode_q == 2'd1) ? "C" : (mode_q == 2'd2) ? " " : "E";
                4'd11: ch = (mode_q == 2'd1) ? "L" : (mode_q == 2'd2) ? " " : " ";
                4'd12: ch = (mode_q == 2'd1) ? "E" : (mode_q == 2'd2) ? " " : " ";
                default: ch = " ";
            endcase
        end
        // ---- PHASE (CL,352) ----
        else if ((y >= R_2) && (y < R_2 + 10'd16) &&
                 (xa >= CL) && (xa < CL + 10'd128)) begin
            hit     = 1'b1;
            row     = y - R_2;
            bit_sel = 3'd7 - ((xa - CL) & 3'd7);
            case ((xa - CL) >> 3)
                // "PHASE  " + "0 deg" / "90 deg" / "2x freq"
                4'd0: ch = "P";  4'd1: ch = "H";  4'd2: ch = "A";  4'd3: ch = "S";
                4'd4: ch = "E";  4'd5: ch = " ";  4'd6: ch = " ";
                4'd7:  ch = (mode_q == 2'd0) ? "0" : (mode_q == 2'd1) ? "9" : "2";
                4'd8:  ch = (mode_q == 2'd0) ? " " : (mode_q == 2'd1) ? "0" : "x";
                4'd9:  ch = " ";
                4'd10: ch = (mode_q == 2'd2) ? "f" : "d";
                4'd11: ch = (mode_q == 2'd2) ? "r" : "e";
                4'd12: ch = (mode_q == 2'd2) ? "e" : "g";
                4'd13: ch = (mode_q == 2'd2) ? "q" : " ";
                default: ch = " ";
            endcase
        end
        // ---- DLY-CMP (CL,372)：固有群延迟补偿档位，与 nco.v 的 DELAY_CLKS 对应 ----
        else if ((y >= R_3) && (y < R_3 + 10'd16) &&
                 (xa >= CL) && (xa < CL + 10'd128)) begin
            hit     = 1'b1;
            row     = y - R_3;
            bit_sel = 3'd7 - ((xa - CL) & 3'd7);
            case ((xa - CL) >> 3)
                // "DLYCMP 39 clk"
                4'd0: ch = "D";  4'd1: ch = "L";  4'd2: ch = "Y";  4'd3: ch = "C";
                4'd4: ch = "M";  4'd5: ch = "P";  4'd6: ch = " ";
                4'd7: ch = " ";  4'd8: ch = "3";  4'd9: ch = "9";
                4'd10: ch = " "; 4'd11: ch = "c"; 4'd12: ch = "l"; 4'd13: ch = "k";
                default: ch = " ";
            endcase
        end
        // ---- STATUS (CL,392) ----
        else if ((y >= R_4) && (y < R_4 + 10'd16) &&
                 (xa >= CL) && (xa < CL + 10'd128)) begin
            hit     = 1'b1;
            row     = y - R_4;
            bit_sel = 3'd7 - ((xa - CL) & 3'd7);
            case ((xa - CL) >> 3)
                // "STATUS " + LOCKED / NO SIGNAL
                4'd0: ch = "S";  4'd1: ch = "T";  4'd2: ch = "A";  4'd3: ch = "T";
                4'd4: ch = "U";  4'd5: ch = "S";  4'd6: ch = " ";
                4'd7:  ch = lock_q ? "L" : "N";
                4'd8:  ch = lock_q ? "O" : "O";
                4'd9:  ch = lock_q ? "C" : " ";
                4'd10: ch = lock_q ? "K" : "S";
                4'd11: ch = lock_q ? "E" : "I";
                4'd12: ch = lock_q ? "D" : "G";
                4'd13: ch = lock_q ? " " : "N";
                4'd14: ch = lock_q ? " " : "A";
                4'd15: ch = lock_q ? " " : "L";
                default: ch = " ";
            endcase
        end

        // ============ 右列 ============
        // ---- FREQ (CR,332) ----
        else if ((y >= R_1) && (y < R_1 + 10'd16) &&
                 (xa >= CR) && (xa < CR + 10'd128)) begin
            hit     = 1'b1;
            row     = y - R_1;
            bit_sel = 3'd7 - ((xa - CR) & 3'd7);
            case ((xa - CR) >> 3)
                // "FREQ  " + xxx.xx + " kHz"
                4'd0: ch = "F";  4'd1: ch = "R";  4'd2: ch = "E";  4'd3: ch = "Q";
                4'd4: ch = " ";  4'd5: ch = " ";
                4'd6:  ch = (f4 == 4'd0) ? " " : dg(f4);
                4'd7:  ch = ((f4 == 4'd0) && (f3 == 4'd0)) ? " " : dg(f3);
                4'd8:  ch = dg(f2);
                4'd9:  ch = ".";
                4'd10: ch = dg(f1);
                4'd11: ch = dg(f0);
                4'd12: ch = " "; 4'd13: ch = "k"; 4'd14: ch = "H"; 4'd15: ch = "z";
                default: ch = " ";
            endcase
        end
        // ---- PERIOD (CR,352)：period_ticks 单位就是 0.01us，故天然带两位小数 ----
        else if ((y >= R_2) && (y < R_2 + 10'd16) &&
                 (xa >= CR) && (xa < CR + 10'd128)) begin
            hit     = 1'b1;
            row     = y - R_2;
            bit_sel = 3'd7 - ((xa - CR) & 3'd7);
            case ((xa - CR) >> 3)
                // "PRD" + 前导零消隐 + "xx.xx us"
                // 用 PRD 而不是 PERIOD：16 字符格内要同时放下 7 位数值和 "us" 单位
                4'd0: ch = "P";  4'd1: ch = "R";  4'd2: ch = "D";  4'd3: ch = " ";
                4'd4:  ch = (p6 == 4'd0) ? " " : dg(p6);
                4'd5:  ch = ((p6 == 0) && (p5 == 0)) ? " " : dg(p5);
                4'd6:  ch = ((p6 == 0) && (p5 == 0) && (p4 == 0)) ? " " : dg(p4);
                4'd7:  ch = ((p6 == 0) && (p5 == 0) && (p4 == 0) && (p3 == 0)) ? " " : dg(p3);
                4'd8:  ch = dg(p2);
                4'd9:  ch = ".";
                4'd10: ch = dg(p1);
                4'd11: ch = dg(p0);
                4'd12: ch = "u"; 4'd13: ch = "s";
                default: ch = " ";
            endcase
        end
        // ---- VPP (CR,372) ----
        else if ((y >= R_3) && (y < R_3 + 10'd16) &&
                 (xa >= CR) && (xa < CR + 10'd128)) begin
            hit     = 1'b1;
            row     = y - R_3;
            bit_sel = 3'd7 - ((xa - CR) & 3'd7);
            case ((xa - CR) >> 3)
                // "VPP   " + x.xx + " V"
                4'd0: ch = "V";  4'd1: ch = "P";  4'd2: ch = "P";  4'd3: ch = " ";
                4'd4: ch = " ";  4'd5: ch = " ";  4'd6: ch = " ";
                4'd7:  ch = (vpp_bcd[11:8] == 4'd0) ? " " : dg(vpp_bcd[11:8]);
                4'd8:  ch = ".";
                4'd9:  ch = dg(vpp_bcd[7:4]);
                4'd10: ch = dg(vpp_bcd[3:0]);
                4'd11: ch = " "; 4'd12: ch = "V";
                default: ch = " ";
            endcase
        end
        // ---- RMS (CR,392) ----
        else if ((y >= R_4) && (y < R_4 + 10'd16) &&
                 (xa >= CR) && (xa < CR + 10'd128)) begin
            hit     = 1'b1;
            row     = y - R_4;
            bit_sel = 3'd7 - ((xa - CR) & 3'd7);
            case ((xa - CR) >> 3)
                // "RMS   " + x.xx + " V"
                4'd0: ch = "R";  4'd1: ch = "M";  4'd2: ch = "S";  4'd3: ch = " ";
                4'd4: ch = " ";  4'd5: ch = " ";  4'd6: ch = " ";
                4'd7:  ch = (rms_bcd[11:8] == 4'd0) ? " " : dg(rms_bcd[11:8]);
                4'd8:  ch = ".";
                4'd9:  ch = dg(rms_bcd[7:4]);
                4'd10: ch = dg(rms_bcd[3:0]);
                4'd11: ch = " "; 4'd12: ch = "V";
                default: ch = " ";
            endcase
        end
    end

    // ============================================================
    //  字库 ROM（96 字符 × 16 行）
    // ============================================================
    reg [7:0] font [0:1535];

    initial begin
        $readmemh("font8x16.hex", font);
    end

    wire [10:0] faddr = ({3'd0, ch} - 11'd32) * 11'd16 + {7'd0, row};

    reg [7:0] fdata;
    reg [2:0] bit_q;
    reg       hit_q;

    always @(posedge pclk) begin
        fdata <= font[faddr];
        bit_q <= bit_sel;
        hit_q <= hit;
    end

    assign ink = hit_q & fdata[bit_q];

endmodule
