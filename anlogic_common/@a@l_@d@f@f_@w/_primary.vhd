library verilog;
use verilog.vl_types.all;
entity AL_DFF_W is
    generic(
        WIDTH           : integer := 1;
        INIT            : vl_notype;
        SSROVERCE       : string  := "ENABLE";
        GSR             : string  := "DISABLE"
    );
    port(
        ar              : in     vl_logic_vector;
        as              : in     vl_logic_vector;
        sr              : in     vl_logic_vector;
        ss              : in     vl_logic_vector;
        en              : in     vl_logic_vector;
        clk             : in     vl_logic;
        d               : in     vl_logic_vector;
        q               : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of WIDTH : constant is 1;
    attribute mti_svvh_generic_type of INIT : constant is 3;
    attribute mti_svvh_generic_type of SSROVERCE : constant is 1;
    attribute mti_svvh_generic_type of GSR : constant is 1;
end AL_DFF_W;
