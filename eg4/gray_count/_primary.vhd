library verilog;
use verilog.vl_types.all;
entity gray_count is
    generic(
        WIDTH           : integer := 8;
        INIT            : integer := 0
    );
    port(
        clk             : in     vl_logic;
        enable          : in     vl_logic;
        reset           : in     vl_logic;
        cnt             : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of WIDTH : constant is 1;
    attribute mti_svvh_generic_type of INIT : constant is 1;
end gray_count;
