library verilog;
use verilog.vl_types.all;
entity AL_MAP_CARRY4 is
    port(
        co              : out    vl_logic_vector(3 downto 0);
        fco             : out    vl_logic;
        gen             : in     vl_logic_vector(3 downto 0);
        prog            : in     vl_logic_vector(3 downto 0);
        ci              : in     vl_logic;
        fci             : in     vl_logic
    );
end AL_MAP_CARRY4;
