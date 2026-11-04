library verilog;
use verilog.vl_types.all;
entity HARD_SAR12_ADC is
    generic(
        DATASIZE        : integer := 12;
        S_SIZE          : integer := 3;
        CH_SIZE         : integer := 8;
        CONVERT_SIZE    : integer := 16;
        SAMPLE_SIZE     : integer := 4;
        Td_B            : integer := 0;
        Td_EOC          : integer := 0
    );
    port(
        VDDA            : in     vl_logic;
        VSSA            : in     vl_logic;
        CLK             : in     vl_logic;
        PD              : in     vl_logic;
        SOC             : in     vl_logic;
        S               : in     vl_logic_vector(2 downto 0);
        CH              : in     vl_logic_vector(7 downto 0);
        VREF            : in     vl_logic;
        EOC             : out    vl_logic;
        B               : out    vl_logic_vector(11 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of DATASIZE : constant is 1;
    attribute mti_svvh_generic_type of S_SIZE : constant is 1;
    attribute mti_svvh_generic_type of CH_SIZE : constant is 1;
    attribute mti_svvh_generic_type of CONVERT_SIZE : constant is 1;
    attribute mti_svvh_generic_type of SAMPLE_SIZE : constant is 1;
    attribute mti_svvh_generic_type of Td_B : constant is 1;
    attribute mti_svvh_generic_type of Td_EOC : constant is 1;
end HARD_SAR12_ADC;
