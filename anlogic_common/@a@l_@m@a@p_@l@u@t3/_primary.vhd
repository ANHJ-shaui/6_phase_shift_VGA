library verilog;
use verilog.vl_types.all;
entity AL_MAP_LUT3 is
    generic(
        EQN             : string  := "(A)";
        INIT            : vl_logic_vector(0 to 7) := (Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0)
    );
    port(
        o               : out    vl_logic;
        a               : in     vl_logic;
        b               : in     vl_logic;
        c               : in     vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of EQN : constant is 1;
    attribute mti_svvh_generic_type of INIT : constant is 1;
end AL_MAP_LUT3;
