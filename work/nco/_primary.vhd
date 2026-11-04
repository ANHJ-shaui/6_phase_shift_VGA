library verilog;
use verilog.vl_types.all;
entity nco is
    generic(
        PERIOD_MIN      : integer := 500;
        PERIOD_MAX      : integer := 1000000
    );
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        sync_pulse      : in     vl_logic;
        period_meas     : in     vl_logic_vector(31 downto 0);
        phase_offset    : in     vl_logic_vector(8 downto 0);
        ram_rd_addr     : out    vl_logic_vector(8 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of PERIOD_MIN : constant is 1;
    attribute mti_svvh_generic_type of PERIOD_MAX : constant is 1;
end nco;
