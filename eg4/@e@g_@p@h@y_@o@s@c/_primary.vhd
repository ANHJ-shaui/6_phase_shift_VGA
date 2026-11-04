library verilog;
use verilog.vl_types.all;
entity EG_PHY_OSC is
    generic(
        STDBY           : string  := "DISABLE"
    );
    port(
        osc_dis         : in     vl_logic;
        osc_clk         : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of STDBY : constant is 1;
end EG_PHY_OSC;
