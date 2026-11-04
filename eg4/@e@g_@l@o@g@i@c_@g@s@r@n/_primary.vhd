library verilog;
use verilog.vl_types.all;
entity EG_LOGIC_GSRN is
    generic(
        GSRN_SYNC_SEL   : string  := "DISABLE";
        USR_GSRN_EN     : string  := "DISABLE"
    );
    port(
        gsrn            : in     vl_logic;
        sync_clk        : in     vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of GSRN_SYNC_SEL : constant is 1;
    attribute mti_svvh_generic_type of USR_GSRN_EN : constant is 1;
end EG_LOGIC_GSRN;
