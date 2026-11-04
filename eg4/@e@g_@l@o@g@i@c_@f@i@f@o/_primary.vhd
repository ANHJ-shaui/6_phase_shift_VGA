library verilog;
use verilog.vl_types.all;
entity EG_LOGIC_FIFO is
    generic(
        DATA_WIDTH_W    : integer := 9;
        DATA_WIDTH_R    : vl_notype;
        DATA_DEPTH_W    : integer := 1024;
        DATA_DEPTH_R    : vl_notype;
        MODE            : string  := "FIFO8K";
        REGMODE_W       : string  := "NOREG";
        REGMODE_R       : string  := "NOREG";
        E               : integer := 0;
        AE              : integer := 6;
        AF              : vl_notype;
        F               : vl_notype;
        GSR             : string  := "DISABLE";
        RESETMODE       : string  := "ASYNC";
        ASYNC_RESET_RELEASE: string  := "SYNC";
        ENDIAN          : string  := "LITTLE"
    );
    port(
        rst             : in     vl_logic;
        di              : in     vl_logic_vector;
        clkw            : in     vl_logic;
        we              : in     vl_logic;
        csw             : in     vl_logic_vector(2 downto 0);
        do              : out    vl_logic_vector;
        clkr            : in     vl_logic;
        re              : in     vl_logic;
        csr             : in     vl_logic_vector(2 downto 0);
        ore             : in     vl_logic;
        empty_flag      : out    vl_logic;
        aempty_flag     : out    vl_logic;
        full_flag       : out    vl_logic;
        afull_flag      : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of DATA_WIDTH_W : constant is 1;
    attribute mti_svvh_generic_type of DATA_WIDTH_R : constant is 3;
    attribute mti_svvh_generic_type of DATA_DEPTH_W : constant is 1;
    attribute mti_svvh_generic_type of DATA_DEPTH_R : constant is 3;
    attribute mti_svvh_generic_type of MODE : constant is 1;
    attribute mti_svvh_generic_type of REGMODE_W : constant is 1;
    attribute mti_svvh_generic_type of REGMODE_R : constant is 1;
    attribute mti_svvh_generic_type of E : constant is 1;
    attribute mti_svvh_generic_type of AE : constant is 1;
    attribute mti_svvh_generic_type of AF : constant is 3;
    attribute mti_svvh_generic_type of F : constant is 3;
    attribute mti_svvh_generic_type of GSR : constant is 1;
    attribute mti_svvh_generic_type of RESETMODE : constant is 1;
    attribute mti_svvh_generic_type of ASYNC_RESET_RELEASE : constant is 1;
    attribute mti_svvh_generic_type of ENDIAN : constant is 1;
end EG_LOGIC_FIFO;
