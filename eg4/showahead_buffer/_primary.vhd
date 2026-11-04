library verilog;
use verilog.vl_types.all;
entity showahead_buffer is
    generic(
        DATA_WIDTH      : integer := 8
    );
    port(
        rstn_i          : in     vl_logic;
        clk_i           : in     vl_logic;
        ena_i           : in     vl_logic;
        rd_i            : in     vl_logic;
        data_i          : in     vl_logic_vector;
        data_o          : out    vl_logic_vector;
        addr_inc_o      : out    vl_logic;
        empty_o         : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of DATA_WIDTH : constant is 1;
end showahead_buffer;
