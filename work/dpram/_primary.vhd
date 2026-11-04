library verilog;
use verilog.vl_types.all;
entity dpram is
    port(
        wr_clk          : in     vl_logic;
        wr_en           : in     vl_logic;
        wr_addr         : in     vl_logic_vector(8 downto 0);
        wr_data         : in     vl_logic_vector(11 downto 0);
        rd_clk          : in     vl_logic;
        rd_addr         : in     vl_logic_vector(8 downto 0);
        rd_data         : out    vl_logic_vector(11 downto 0)
    );
end dpram;
