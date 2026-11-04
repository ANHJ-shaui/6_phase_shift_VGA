library verilog;
use verilog.vl_types.all;
entity AL_MAP_ADDER is
    generic(
        ALUTYPE         : string  := "ADD"
    );
    port(
        a               : in     vl_logic;
        b               : in     vl_logic;
        c               : in     vl_logic;
        o               : out    vl_logic_vector(1 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of ALUTYPE : constant is 1;
end AL_MAP_ADDER;
