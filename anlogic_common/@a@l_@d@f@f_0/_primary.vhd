library verilog;
use verilog.vl_types.all;
entity AL_DFF_0 is
    generic(
        SSROVERCE       : string  := "ENABLE";
        GSR             : string  := "DISABLE";
        REGSET          : string  := "RESET"
    );
    port(
        ar              : in     vl_logic;
        as              : in     vl_logic;
        sr              : in     vl_logic;
        ss              : in     vl_logic;
        en              : in     vl_logic;
        clk             : in     vl_logic;
        d               : in     vl_logic;
        q               : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of SSROVERCE : constant is 1;
    attribute mti_svvh_generic_type of GSR : constant is 1;
    attribute mti_svvh_generic_type of REGSET : constant is 1;
end AL_DFF_0;
