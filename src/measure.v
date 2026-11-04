//////////////////////////////////////////////////////////////////////////////////
//  measure：峰峰值 / 有效值测量
//  窗口：2^20 = 1,048,576 拍（100 MHz 下约 10.5 ms，刷新约 95 Hz）
//  Vpp = max - min
//  RMS = sqrt(Σx² / N)：窗口结束后用 12 拍"试乘法"开方
//  换算：ADC 0..4095 对应 -2V..+2V → 0.01V 单位 = codes × 25 / 256
//////////////////////////////////////////////////////////////////////////////////
module measure (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [11:0] din,
    output reg  [15:0] vpp_x100,
    output reg  [15:0] rms_x100
);

    localparam [19:0] WIN_END = 20'hFFFFF;        // 2^20 - 1

    reg [19:0] cnt;
    reg [11:0] vmin, vmax;
    reg [47:0] sum_sq;

    wire signed [12:0] dac = $signed({1'b0, din}) - 13'sd2048;
    wire [23:0] sq = dac * dac;      // 交流分量平方（去掉直流中点）

    // 乘法结果打一拍，避免"乘法+48位加法"串成一条长路径
    reg [23:0] sq_r;
    always @(posedge clk) sq_r <= sq;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt    <= 20'd0;
            vmin   <= 12'hFFF;
            vmax   <= 12'h000;
            sum_sq <= 48'd0;
        end else begin
            cnt <= cnt + 1'b1;
            if (din < vmin) vmin <= din;
            if (din > vmax) vmax <= din;
            if (cnt == WIN_END) begin
                cnt    <= 20'd0;
                vmin   <= 12'hFFF;
                vmax   <= 12'h000;
                sum_sq <= 48'd0;
            end else begin
                sum_sq <= sum_sq + {24'd0, sq_r};
            end
        end
    end

    reg win_end;
    always @(posedge clk) win_end <= (cnt == WIN_END);

    reg [11:0] pp_r;
    reg [23:0] msq_r;

    // 在窗口最后一拍（含当前样本）锁存统计值
    wire [11:0] vmax_n = (din > vmax) ? din : vmax;
    wire [11:0] vmin_n = (din < vmin) ? din : vmin;
    wire [47:0] sum_n  = sum_sq + {24'd0, sq_r};

    always @(posedge clk) begin
        if (cnt == WIN_END) begin
            pp_r  <= vmax_n - vmin_n;
            msq_r <= sum_n[43:20];                   // (Σx²) >> 20
        end
    end

    // ---------------- 开方（三级流水，12 位逐位试乘） ----------------
    reg        busy;
    reg [1:0]  ph;
    reg [23:0] xq;
    reg [11:0] root, bitt;
    reg [23:0] trial_r, tprod_r;

    wire [23:0] trial_w = {12'd0, root} + {12'd0, bitt};
    wire [23:0] tprod_w = trial_r[11:0] * trial_r[11:0];

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            busy    <= 1'b0;
            ph      <= 2'd0;
            xq      <= 24'd0;
            root    <= 12'd0;
            bitt    <= 12'd0;
            trial_r <= 24'd0;
            tprod_r <= 24'd0;
        end else if (win_end) begin
            busy <= 1'b1;
            ph   <= 2'd0;
            xq   <= msq_r;
            root <= 12'd0;
            bitt <= 12'h800;
        end else if (busy) begin
            case (ph)
                2'd0: begin
                    trial_r <= trial_w;        // 试值
                    ph      <= 2'd1;
                end
                2'd1: begin
                    tprod_r <= tprod_w;        // 试值平方
                    ph      <= 2'd2;
                end
                default: begin
                    if (tprod_r <= xq)
                        root <= trial_r[11:0];
                    bitt <= bitt >> 1;
                    ph   <= 2'd0;
                    if (bitt == 12'd1)
                        busy <= 1'b0;
                end
            endcase
        end
    end

    // ---------------- 电压换算（0.01V） ----------------
    wire [15:0] pp_c  = {4'd0, pp_r};
    wire [15:0] rms_c = {4'd0, root};

    always @(posedge clk) begin
        vpp_x100 <= (pp_c  * 32'd25) >> 8;
        rms_x100 <= (rms_c * 32'd25) >> 8;
    end

endmodule
