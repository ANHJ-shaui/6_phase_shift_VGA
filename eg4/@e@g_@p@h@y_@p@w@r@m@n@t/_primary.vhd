library verilog;
use verilog.vl_types.all;
entity EG_PHY_PWRMNT is
    generic(
        MNT_LVL         : integer := 0
    );
    port(
        sel_pwr         : in     vl_logic;
        pwr_mnt_pd      : in     vl_logic;
        pwr_dwn_n       : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of MNT_LVL : constant is 1;
end EG_PHY_PWRMNT;
