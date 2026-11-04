library verilog;
use verilog.vl_types.all;
entity AL_MAP_SEQ is
    generic(
        DFFMODE         : string  := "FF";
        REGSET          : string  := "RESET";
        SRMUX           : string  := "SR";
        SRMODE          : string  := "SYNC";
        INI             : string  := "0";
        CEMUX           : string  := "CE";
        CLKMUX          : string  := "CLK";
        GSR             : string  := "DISABLE"
    );
    port(
        ce              : in     vl_logic;
        clk             : in     vl_logic;
        sr              : in     vl_logic;
        d               : in     vl_logic;
        q               : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of DFFMODE : constant is 1;
    attribute mti_svvh_generic_type of REGSET : constant is 1;
    attribute mti_svvh_generic_type of SRMUX : constant is 1;
    attribute mti_svvh_generic_type of SRMODE : constant is 1;
    attribute mti_svvh_generic_type of INI : constant is 1;
    attribute mti_svvh_generic_type of CEMUX : constant is 1;
    attribute mti_svvh_generic_type of CLKMUX : constant is 1;
    attribute mti_svvh_generic_type of GSR : constant is 1;
end AL_MAP_SEQ;
