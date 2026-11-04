library verilog;
use verilog.vl_types.all;
entity adda_direct is
    port(
        clk_50m         : in     vl_logic;
        reset_n         : in     vl_logic;
        ad_dat          : in     vl_logic_vector(11 downto 0);
        ad_clk          : out    vl_logic;
        da_clk          : out    vl_logic;
        da_dat          : out    vl_logic_vector(11 downto 0);
        lock_led        : out    vl_logic
    );
end adda_direct;
