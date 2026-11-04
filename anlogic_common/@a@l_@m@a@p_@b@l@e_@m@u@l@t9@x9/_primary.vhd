library verilog;
use verilog.vl_types.all;
entity AL_MAP_BLE_MULT9X9 is
    generic(
        INPUTREGA       : string  := "ENABLE";
        INPUTREGB       : string  := "ENABLE";
        OUTPUTREG       : string  := "ENABLE";
        SRMODE          : string  := "ASYNC"
    );
    port(
        acout           : out    vl_logic_vector(8 downto 0);
        bcout           : out    vl_logic_vector(8 downto 0);
        p               : out    vl_logic_vector(17 downto 0);
        signeda         : in     vl_logic;
        signedb         : in     vl_logic;
        a               : in     vl_logic_vector(8 downto 0);
        b               : in     vl_logic_vector(8 downto 0);
        acin            : in     vl_logic_vector(8 downto 0);
        bcin            : in     vl_logic_vector(8 downto 0);
        cea             : in     vl_logic;
        ceb             : in     vl_logic;
        cepd            : in     vl_logic;
        clk             : in     vl_logic;
        rsta_n          : in     vl_logic;
        rstb_n          : in     vl_logic;
        rstpd_n         : in     vl_logic;
        sourcea         : in     vl_logic;
        sourceb         : in     vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of INPUTREGA : constant is 1;
    attribute mti_svvh_generic_type of INPUTREGB : constant is 1;
    attribute mti_svvh_generic_type of OUTPUTREG : constant is 1;
    attribute mti_svvh_generic_type of SRMODE : constant is 1;
end AL_MAP_BLE_MULT9X9;
