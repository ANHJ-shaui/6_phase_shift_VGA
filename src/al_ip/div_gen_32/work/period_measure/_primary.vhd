library verilog;
use verilog.vl_types.all;
entity period_measure is
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        pos_pulse       : in     vl_logic;
        period_meas     : out    vl_logic_vector(31 downto 0)
    );
end period_measure;
