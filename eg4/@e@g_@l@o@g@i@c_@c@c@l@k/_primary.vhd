library verilog;
use verilog.vl_types.all;
entity EG_LOGIC_CCLK is
    generic(
        FREQ            : string  := "4.5"
    );
    port(
        cclk            : out    vl_logic;
        en              : in     vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of FREQ : constant is 1;
end EG_LOGIC_CCLK;
