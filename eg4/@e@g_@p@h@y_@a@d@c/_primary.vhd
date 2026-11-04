library verilog;
use verilog.vl_types.all;
entity EG_PHY_ADC is
    generic(
        CH0             : string  := "DISABLE";
        CH1             : string  := "DISABLE";
        CH2             : string  := "DISABLE";
        CH3             : string  := "DISABLE";
        CH4             : string  := "DISABLE";
        CH5             : string  := "DISABLE";
        CH6             : string  := "DISABLE";
        CH7             : string  := "DISABLE";
        VREF            : string  := "DISABLE"
    );
    port(
        clk             : in     vl_logic;
        pd              : in     vl_logic;
        s               : in     vl_logic_vector(2 downto 0);
        soc             : in     vl_logic;
        eoc             : out    vl_logic;
        dout            : out    vl_logic_vector(11 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of CH0 : constant is 1;
    attribute mti_svvh_generic_type of CH1 : constant is 1;
    attribute mti_svvh_generic_type of CH2 : constant is 1;
    attribute mti_svvh_generic_type of CH3 : constant is 1;
    attribute mti_svvh_generic_type of CH4 : constant is 1;
    attribute mti_svvh_generic_type of CH5 : constant is 1;
    attribute mti_svvh_generic_type of CH6 : constant is 1;
    attribute mti_svvh_generic_type of CH7 : constant is 1;
    attribute mti_svvh_generic_type of VREF : constant is 1;
end EG_PHY_ADC;
