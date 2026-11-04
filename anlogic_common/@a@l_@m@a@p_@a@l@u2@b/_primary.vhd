library verilog;
use verilog.vl_types.all;
entity AL_MAP_ALU2B is
    generic(
        INIT0           : vl_logic_vector(15 downto 0) := (Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0);
        INIT1           : vl_logic_vector(15 downto 0) := (Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0);
        FUNC0           : string  := "NO";
        FUNC1           : string  := "NO"
    );
    port(
        cin             : in     vl_logic;
        a0              : in     vl_logic;
        b0              : in     vl_logic;
        c0              : in     vl_logic;
        d0              : in     vl_logic;
        a1              : in     vl_logic;
        b1              : in     vl_logic;
        c1              : in     vl_logic;
        d1              : in     vl_logic;
        s0              : out    vl_logic;
        s1              : out    vl_logic;
        cout            : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of INIT0 : constant is 2;
    attribute mti_svvh_generic_type of INIT1 : constant is 2;
    attribute mti_svvh_generic_type of FUNC0 : constant is 1;
    attribute mti_svvh_generic_type of FUNC1 : constant is 1;
end AL_MAP_ALU2B;
