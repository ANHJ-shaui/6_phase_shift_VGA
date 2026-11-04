library verilog;
use verilog.vl_types.all;
entity EG_PHY_MSLICE is
    generic(
        INIT_LUT0       : vl_logic_vector(0 to 15) := (Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0);
        INIT_LUT1       : vl_logic_vector(0 to 15) := (Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0);
        MODE            : string  := "LOGIC";
        ALUTYPE         : string  := "";
        MSFXMUX         : string  := "OFF";
        GSR             : string  := "ENABLE";
        TESTMODE        : string  := "OFF";
        CEMUX           : string  := "CE";
        SRMUX           : string  := "SR";
        CLKMUX          : string  := "CLK";
        SRMODE          : string  := "ASYNC";
        DFFMODE         : string  := "FF";
        REG0_SD         : string  := "MI";
        REG1_SD         : string  := "MI";
        REG0_REGSET     : string  := "SET";
        REG1_REGSET     : string  := "SET"
    );
    port(
        a               : in     vl_logic_vector(1 downto 0);
        b               : in     vl_logic_vector(1 downto 0);
        c               : in     vl_logic_vector(1 downto 0);
        ce              : in     vl_logic;
        clk             : in     vl_logic;
        d               : in     vl_logic_vector(1 downto 0);
        mi              : in     vl_logic_vector(1 downto 0);
        sr              : in     vl_logic;
        fci             : in     vl_logic;
        f               : out    vl_logic_vector(1 downto 0);
        fx              : out    vl_logic_vector(1 downto 0);
        q               : out    vl_logic_vector(1 downto 0);
        fco             : out    vl_logic;
        dpram_mode      : in     vl_logic;
        dpram_di        : in     vl_logic_vector(1 downto 0);
        dpram_we        : in     vl_logic;
        dpram_waddr     : in     vl_logic_vector(3 downto 0);
        dpram_wclk      : in     vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of INIT_LUT0 : constant is 1;
    attribute mti_svvh_generic_type of INIT_LUT1 : constant is 1;
    attribute mti_svvh_generic_type of MODE : constant is 1;
    attribute mti_svvh_generic_type of ALUTYPE : constant is 1;
    attribute mti_svvh_generic_type of MSFXMUX : constant is 1;
    attribute mti_svvh_generic_type of GSR : constant is 1;
    attribute mti_svvh_generic_type of TESTMODE : constant is 1;
    attribute mti_svvh_generic_type of CEMUX : constant is 1;
    attribute mti_svvh_generic_type of SRMUX : constant is 1;
    attribute mti_svvh_generic_type of CLKMUX : constant is 1;
    attribute mti_svvh_generic_type of SRMODE : constant is 1;
    attribute mti_svvh_generic_type of DFFMODE : constant is 1;
    attribute mti_svvh_generic_type of REG0_SD : constant is 1;
    attribute mti_svvh_generic_type of REG1_SD : constant is 1;
    attribute mti_svvh_generic_type of REG0_REGSET : constant is 1;
    attribute mti_svvh_generic_type of REG1_REGSET : constant is 1;
end EG_PHY_MSLICE;
