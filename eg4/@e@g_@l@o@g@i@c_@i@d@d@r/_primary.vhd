library verilog;
use verilog.vl_types.all;
entity EG_LOGIC_IDDR is
    generic(
        ASYNCRST        : string  := "ENABLE";
        PIPEMODE        : string  := "PIPED"
    );
    port(
        q1              : out    vl_logic;
        q0              : out    vl_logic;
        clk             : in     vl_logic;
        d               : in     vl_logic;
        rst             : in     vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of ASYNCRST : constant is 1;
    attribute mti_svvh_generic_type of PIPEMODE : constant is 1;
end EG_LOGIC_IDDR;
