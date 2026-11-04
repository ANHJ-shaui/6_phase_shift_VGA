library verilog;
use verilog.vl_types.all;
entity EG_LOGIC_MULT is
    generic(
        INPUT_WIDTH_A   : integer := 18;
        INPUT_WIDTH_B   : integer := 18;
        OUTPUT_WIDTH    : integer := 36;
        INPUTFORMAT     : string  := "SIGNED";
        INPUTREGA       : string  := "ENABLE";
        INPUTREGB       : string  := "ENABLE";
        OUTPUTREG       : string  := "ENABLE";
        IMPLEMENT       : string  := "AUTO";
        SRMODE          : string  := "ASYNC"
    );
    port(
        p               : out    vl_logic_vector;
        a               : in     vl_logic_vector;
        b               : in     vl_logic_vector;
        cea             : in     vl_logic;
        ceb             : in     vl_logic;
        cepd            : in     vl_logic;
        clk             : in     vl_logic;
        rstan           : in     vl_logic;
        rstbn           : in     vl_logic;
        rstpdn          : in     vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of INPUT_WIDTH_A : constant is 1;
    attribute mti_svvh_generic_type of INPUT_WIDTH_B : constant is 1;
    attribute mti_svvh_generic_type of OUTPUT_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of INPUTFORMAT : constant is 1;
    attribute mti_svvh_generic_type of INPUTREGA : constant is 1;
    attribute mti_svvh_generic_type of INPUTREGB : constant is 1;
    attribute mti_svvh_generic_type of OUTPUTREG : constant is 1;
    attribute mti_svvh_generic_type of IMPLEMENT : constant is 1;
    attribute mti_svvh_generic_type of SRMODE : constant is 1;
end EG_LOGIC_MULT;
