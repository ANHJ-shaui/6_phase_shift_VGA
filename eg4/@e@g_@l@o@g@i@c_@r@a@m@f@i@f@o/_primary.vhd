library verilog;
use verilog.vl_types.all;
entity EG_LOGIC_RAMFIFO is
    generic(
        DATA_WIDTH      : integer := 8;
        ADDR_WIDTH      : integer := 8;
        SHOWAHEAD       : integer := 0;
        IMPLEMENT       : string  := "AUTO"
    );
    port(
        rst             : in     vl_logic;
        di              : in     vl_logic_vector;
        clk             : in     vl_logic;
        re              : in     vl_logic;
        we              : in     vl_logic;
        do              : out    vl_logic_vector;
        empty_flag      : out    vl_logic;
        full_flag       : out    vl_logic;
        rdusedw         : out    vl_logic_vector;
        wrusedw         : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of DATA_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of ADDR_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of SHOWAHEAD : constant is 1;
    attribute mti_svvh_generic_type of IMPLEMENT : constant is 1;
end EG_LOGIC_RAMFIFO;
