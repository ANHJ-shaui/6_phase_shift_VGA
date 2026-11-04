library verilog;
use verilog.vl_types.all;
entity key_debounce is
    generic(
        CLK_FREQ        : integer := 100000000;
        DEBOUNCE_MS     : integer := 20
    );
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        key             : in     vl_logic;
        key_pulse       : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of CLK_FREQ : constant is 2;
    attribute mti_svvh_generic_type of DEBOUNCE_MS : constant is 2;
end key_debounce;
