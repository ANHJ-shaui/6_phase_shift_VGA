library verilog;
use verilog.vl_types.all;
entity EG_LOGIC_DRAM is
    generic(
        DATA_WIDTH_W    : integer := 4;
        DATA_WIDTH_R    : vl_notype;
        ADDR_WIDTH_W    : integer := 4;
        ADDR_WIDTH_R    : vl_notype;
        DATA_DEPTH_W    : vl_notype;
        DATA_DEPTH_R    : vl_notype;
        INIT_FILE       : string  := "NONE";
        FILL_ALL        : string  := "NONE"
    );
    port(
        di              : in     vl_logic_vector;
        waddr           : in     vl_logic_vector;
        we              : in     vl_logic;
        wclk            : in     vl_logic;
        raddr           : in     vl_logic_vector;
        do              : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of DATA_WIDTH_W : constant is 1;
    attribute mti_svvh_generic_type of DATA_WIDTH_R : constant is 3;
    attribute mti_svvh_generic_type of ADDR_WIDTH_W : constant is 1;
    attribute mti_svvh_generic_type of ADDR_WIDTH_R : constant is 3;
    attribute mti_svvh_generic_type of DATA_DEPTH_W : constant is 3;
    attribute mti_svvh_generic_type of DATA_DEPTH_R : constant is 3;
    attribute mti_svvh_generic_type of INIT_FILE : constant is 1;
    attribute mti_svvh_generic_type of FILL_ALL : constant is 1;
end EG_LOGIC_DRAM;
