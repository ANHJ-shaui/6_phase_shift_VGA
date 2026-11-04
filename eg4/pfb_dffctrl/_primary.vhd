library verilog;
use verilog.vl_types.all;
entity pfb_dffctrl is
    port(
        s_d0            : out    vl_logic;
        s_ce            : out    vl_logic;
        ffc_asrn        : out    vl_logic;
        ffc_sr          : out    vl_logic;
        sr_n            : out    vl_logic;
        sr              : in     vl_logic;
        mc1_testsh      : in     vl_logic;
        ce              : in     vl_logic;
        latchmode       : in     vl_logic;
        gsrn            : in     vl_logic;
        gsrforce_n      : in     vl_logic;
        mc1_disgsr      : in     vl_logic;
        mc1_syncmode    : in     vl_logic
    );
end pfb_dffctrl;
