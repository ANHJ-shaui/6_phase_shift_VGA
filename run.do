# ============================================================
#  NCO + RAM 回放 + 三模式切换 仿真脚本
# ============================================================

# 0. 退出旧仿真，重建 work 库
quit -sim
if {[file exists work]} {file delete -force work}
vlib work
vmap work work

# ------------------------------------------------------------
# 1. 编译安路仿真库
# ------------------------------------------------------------
vlib anlogic_common
vmap anlogic_common anlogic_common
vlib eg4
vmap eg4 eg4

vlog -work anlogic_common "C:/Anlogic/TD_6.2.1_Engineer_6.2.168.116/sim_release/common/*.v"
vlog -work eg4 "C:/Anlogic/TD_6.2.1_Engineer_6.2.168.116/sim_release/eg4/*.v"

# ------------------------------------------------------------
# 2. 编译除法器 IP
# ------------------------------------------------------------
vlog -sv +incdir+C:/Users/Administrator/Desktop/2026FPGA/5_phase_shift/src/al_ip/div_gen_32/RTL/include \
     C:/Users/Administrator/Desktop/2026FPGA/5_phase_shift/src/al_ip/div_gen_32/RTL/divider_top_2e799f05df53.sv

vlog -sv +incdir+C:/Users/Administrator/Desktop/2026FPGA/5_phase_shift/src/al_ip/div_gen_32/RTL/include \
     C:/Users/Administrator/Desktop/2026FPGA/5_phase_shift/src/al_ip/div_gen_32/div_gen_32.sv

# ------------------------------------------------------------
# 3. 编译工程源文件（按依赖顺序）
#    注意：key_debounce.v 必须放在 adda_direct.v 之前
# ------------------------------------------------------------
vlog C:/Users/Administrator/Desktop/2026FPGA/5_phase_shift/src/al_ip/PL.v
vlog C:/Users/Administrator/Desktop/2026FPGA/5_phase_shift/src/al_ip/BUFG_0.v
vlog C:/Users/Administrator/Desktop/2026FPGA/5_phase_shift/src/zero_cross_det.v
vlog C:/Users/Administrator/Desktop/2026FPGA/5_phase_shift/src/period_measure.v
vlog C:/Users/Administrator/Desktop/2026FPGA/5_phase_shift/src/nco.v
vlog C:/Users/Administrator/Desktop/2026FPGA/5_phase_shift/src/dpram.v
vlog C:/Users/Administrator/Desktop/2026FPGA/5_phase_shift/src/key_debounce.v
vlog C:/Users/Administrator/Desktop/2026FPGA/5_phase_shift/src/adda_direct.v
vlog C:/Users/Administrator/Desktop/2026FPGA/5_phase_shift/src/adda_direct_tb.v

# ------------------------------------------------------------
# 4. 启动仿真
# ------------------------------------------------------------
vsim -L anlogic_common -L eg4 work.adda_direct_tb

# ------------------------------------------------------------
# 5. 添加观察信号
# ------------------------------------------------------------
view wave

add wave -divider "Clock/Reset"
add wave /adda_direct_tb/clk_50m
add wave /adda_direct_tb/reset_n
add wave /adda_direct_tb/uut/pll_lock
add wave /adda_direct_tb/uut/sys_rst_n

add wave -divider "ADC Source"
add wave -radix unsigned /adda_direct_tb/idx
add wave -radix unsigned /adda_direct_tb/ad_dat
add wave -radix unsigned /adda_direct_tb/uut/ad_dat_sync

add wave -divider "Zero Cross"
add wave /adda_direct_tb/uut/pos_pulse

add wave -divider "Period"
add wave -radix unsigned /adda_direct_tb/uut/period_meas

add wave -divider "NCO"
add wave /adda_direct_tb/uut/u_nco/rdy
add wave /adda_direct_tb/uut/u_nco/sync_pulse
add wave -radix unsigned /adda_direct_tb/uut/u_nco/ftw
add wave -radix unsigned /adda_direct_tb/uut/u_nco/phase_acc
add wave -radix hex /adda_direct_tb/uut/ram_rd_addr

add wave -divider "Phase Offset"
add wave -radix unsigned /adda_direct_tb/uut/u_nco/phase_offset
add wave -radix hex /adda_direct_tb/uut/ram_rd_addr

add wave -divider "DPRAM"
add wave /adda_direct_tb/uut/u_dpram/wr_en
add wave -radix hex /adda_direct_tb/uut/u_dpram/wr_addr
add wave -radix hex /adda_direct_tb/uut/u_dpram/wr_data
add wave -radix hex /adda_direct_tb/uut/u_dpram/rd_addr
add wave -radix hex /adda_direct_tb/uut/u_dpram/rd_data

add wave -divider "Mode"
add wave -radix unsigned /adda_direct_tb/uut/mode
add wave /adda_direct_tb/uut/key_pulse0
add wave /adda_direct_tb/uut/key_pulse1
add wave /adda_direct_tb/uut/key_pulse2
add wave /adda_direct_tb/uut/led_mode0
add wave /adda_direct_tb/uut/led_mode1
add wave /adda_direct_tb/uut/led_mode2

add wave -divider "Output"
add wave -radix hex /adda_direct_tb/da_dat

# ------------------------------------------------------------
# 6. 运行 & 导出
# ------------------------------------------------------------
restart -f
run 620us