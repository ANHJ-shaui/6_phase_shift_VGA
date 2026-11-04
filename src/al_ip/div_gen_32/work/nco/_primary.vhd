library verilog;
use verilog.vl_types.all;
entity nco is
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        sync_pulse      : in     vl_logic;
        period_meas     : in     vl_logic_vector(31 downto 0);
        ram_rd_addr     : out    vl_logic_vector(8 downto 0)
    );
end nco;
