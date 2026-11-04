library verilog;
use verilog.vl_types.all;
entity adda_direct is
    port(
        clk_50m         : in     vl_logic;
        reset_n         : in     vl_logic;
        key_mode0       : in     vl_logic;
        key_mode1       : in     vl_logic;
        key_mode2       : in     vl_logic;
        ad_dat          : in     vl_logic_vector(11 downto 0);
        ad_clk          : out    vl_logic;
        da_clk          : out    vl_logic;
        da_dat          : out    vl_logic_vector(11 downto 0);
        lock_led        : out    vl_logic;
        led_mode0       : out    vl_logic;
        led_mode1       : out    vl_logic;
        led_mode2       : out    vl_logic
    );
end adda_direct;
