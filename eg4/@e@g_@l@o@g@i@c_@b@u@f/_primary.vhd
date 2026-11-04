library verilog;
use verilog.vl_types.all;
entity EG_LOGIC_BUF is
    port(
        o               : out    vl_logic;
        i               : in     vl_logic
    );
end EG_LOGIC_BUF;
