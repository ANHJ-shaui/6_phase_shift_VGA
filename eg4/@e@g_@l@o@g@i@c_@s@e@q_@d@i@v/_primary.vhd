library verilog;
use verilog.vl_types.all;
entity EG_LOGIC_SEQ_DIV is
    generic(
        NUMER_WIDTH     : integer := 16;
        DENOM_WIDTH     : integer := 16
    );
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        start           : in     vl_logic;
        numer           : in     vl_logic_vector;
        denom           : in     vl_logic_vector;
        quotient        : out    vl_logic_vector;
        remain          : out    vl_logic_vector;
        done            : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of NUMER_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of DENOM_WIDTH : constant is 1;
end EG_LOGIC_SEQ_DIV;
