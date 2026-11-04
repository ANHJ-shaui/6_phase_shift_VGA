library verilog;
use verilog.vl_types.all;
entity EG_LOGIC_IOTRIBUF is
    port(
        i               : in     vl_logic;
        t               : in     vl_logic;
        o               : out    vl_logic;
        io              : inout  vl_logic
    );
end EG_LOGIC_IOTRIBUF;
