library verilog;
use verilog.vl_types.all;
entity AL_PHY_MULT18 is
    generic(
        INPUTREGA       : string  := "ENABLE";
        INPUTREGB       : string  := "ENABLE";
        OUTPUTREG       : string  := "ENABLE";
        SRMODE          : string  := "ASYNC";
        MODE            : string  := "MULT18X18C";
        CEAMUX          : string  := "SIG";
        CEBMUX          : string  := "SIG";
        CEPDMUX         : string  := "SIG";
        RSTANMUX        : string  := "SIG";
        RSTBNMUX        : string  := "SIG";
        RSTPDNMUX       : string  := "SIG";
        CLKMUX          : string  := "SIG";
        SIGNEDAMUX      : string  := "SIG";
        SIGNEDBMUX      : string  := "SIG";
        SOURCEAMUX      : string  := "SIG";
        SOURCEBMUX      : string  := "SIG"
    );
    port(
        acout           : out    vl_logic_vector(17 downto 0);
        bcout           : out    vl_logic_vector(17 downto 0);
        p               : out    vl_logic_vector(35 downto 0);
        signeda         : in     vl_logic;
        signedb         : in     vl_logic;
        a               : in     vl_logic_vector(17 downto 0);
        b               : in     vl_logic_vector(17 downto 0);
        acin            : in     vl_logic_vector(17 downto 0);
        bcin            : in     vl_logic_vector(17 downto 0);
        cea             : in     vl_logic;
        ceb             : in     vl_logic;
        cepd            : in     vl_logic;
        clk             : in     vl_logic;
        rstan           : in     vl_logic;
        rstbn           : in     vl_logic;
        rstpdn          : in     vl_logic;
        sourcea         : in     vl_logic;
        sourceb         : in     vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of INPUTREGA : constant is 1;
    attribute mti_svvh_generic_type of INPUTREGB : constant is 1;
    attribute mti_svvh_generic_type of OUTPUTREG : constant is 1;
    attribute mti_svvh_generic_type of SRMODE : constant is 1;
    attribute mti_svvh_generic_type of MODE : constant is 1;
    attribute mti_svvh_generic_type of CEAMUX : constant is 1;
    attribute mti_svvh_generic_type of CEBMUX : constant is 1;
    attribute mti_svvh_generic_type of CEPDMUX : constant is 1;
    attribute mti_svvh_generic_type of RSTANMUX : constant is 1;
    attribute mti_svvh_generic_type of RSTBNMUX : constant is 1;
    attribute mti_svvh_generic_type of RSTPDNMUX : constant is 1;
    attribute mti_svvh_generic_type of CLKMUX : constant is 1;
    attribute mti_svvh_generic_type of SIGNEDAMUX : constant is 1;
    attribute mti_svvh_generic_type of SIGNEDBMUX : constant is 1;
    attribute mti_svvh_generic_type of SOURCEAMUX : constant is 1;
    attribute mti_svvh_generic_type of SOURCEBMUX : constant is 1;
end AL_PHY_MULT18;
