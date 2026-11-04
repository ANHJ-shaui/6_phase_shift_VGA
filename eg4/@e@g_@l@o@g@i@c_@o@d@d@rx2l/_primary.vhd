library verilog;
use verilog.vl_types.all;
entity EG_LOGIC_ODDRx2l is
    generic(
        ASYNCRST        : string  := "ENABLE"
    );
    port(
        q               : out    vl_logic;
        sclk            : in     vl_logic;
        d3              : in     vl_logic;
        d2              : in     vl_logic;
        d1              : in     vl_logic;
        d0              : in     vl_logic;
        rst             : in     vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of ASYNCRST : constant is 1;
end EG_LOGIC_ODDRx2l;
