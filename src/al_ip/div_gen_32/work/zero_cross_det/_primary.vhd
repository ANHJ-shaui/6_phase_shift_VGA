library verilog;
use verilog.vl_types.all;
entity zero_cross_det is
    generic(
        CENTER          : vl_logic_vector(0 to 11) := (Hi1, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0);
        HYST            : vl_logic_vector(0 to 11) := (Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi1, Hi1, Hi0, Hi0, Hi1, Hi0)
    );
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        adc_data        : in     vl_logic_vector(11 downto 0);
        pos_pulse       : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of CENTER : constant is 1;
    attribute mti_svvh_generic_type of HYST : constant is 1;
end zero_cross_det;
