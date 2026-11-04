library verilog;
use verilog.vl_types.all;
entity AL_MAP_LLMUX is
    port(
        i               : in     vl_logic_vector(1 downto 0);
        s               : in     vl_logic;
        o               : out    vl_logic
    );
end AL_MAP_LLMUX;
