library verilog;
use verilog.vl_types.all;
entity dff_slice_half is
    port(
        q               : out    vl_logic;
        clk             : in     vl_logic;
        f               : in     vl_logic;
        di              : in     vl_logic;
        fx              : in     vl_logic;
        ffc_asrn        : in     vl_logic;
        mc1_sr          : in     vl_logic;
        mc1_di          : in     vl_logic;
        mc1_fx          : in     vl_logic;
        mc1_testsh      : in     vl_logic;
        s_d0            : in     vl_logic;
        s_ce            : in     vl_logic;
        ffc_sr          : in     vl_logic;
        sr_n            : in     vl_logic;
        latchmode       : in     vl_logic
    );
end dff_slice_half;
