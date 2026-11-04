library verilog;
use verilog.vl_types.all;
entity EG_LOGIC_DNA is
    port(
        dout            : out    vl_logic;
        clk             : in     vl_logic;
        din             : in     vl_logic;
        shift_en        : in     vl_logic
    );
end EG_LOGIC_DNA;
