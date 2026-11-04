library verilog;
use verilog.vl_types.all;
entity EG_LOGIC_IBUF is
    port(
        i               : in     vl_logic;
        o               : out    vl_logic
    );
end EG_LOGIC_IBUF;
