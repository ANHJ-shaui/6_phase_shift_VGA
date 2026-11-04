library verilog;
use verilog.vl_types.all;
entity AL_LOGIC_DEBUGHUB is
    generic(
        CTRL_LEN        : integer := 68;
        STAT_LEN        : integer := 22;
        PWR_ON_EXIST    : integer := 0;
        PWR_ON_CTRL     : vl_logic_vector(0 to 67) := (Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0)
    );
    port(
        clk             : in     vl_logic;
        control         : out    vl_logic_vector;
        status          : in     vl_logic_vector;
        rst             : out    vl_logic;
        behavior_clr    : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of CTRL_LEN : constant is 1;
    attribute mti_svvh_generic_type of STAT_LEN : constant is 1;
    attribute mti_svvh_generic_type of PWR_ON_EXIST : constant is 1;
    attribute mti_svvh_generic_type of PWR_ON_CTRL : constant is 1;
end AL_LOGIC_DEBUGHUB;
