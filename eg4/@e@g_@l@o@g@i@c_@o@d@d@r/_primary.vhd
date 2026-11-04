library verilog;
use verilog.vl_types.all;
entity EG_LOGIC_ODDR is
    generic(
        ASYNCRST        : string  := "ENABLE"
    );
    port(
        q               : out    vl_logic;
        clk             : in     vl_logic;
        d1              : in     vl_logic;
        d0              : in     vl_logic;
        rst             : in     vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of ASYNCRST : constant is 1;
end EG_LOGIC_ODDR;
