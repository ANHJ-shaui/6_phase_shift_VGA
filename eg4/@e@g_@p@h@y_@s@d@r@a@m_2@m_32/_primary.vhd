library verilog;
use verilog.vl_types.all;
entity EG_PHY_SDRAM_2M_32 is
    port(
        clk             : in     vl_logic;
        ras_n           : in     vl_logic;
        cas_n           : in     vl_logic;
        we_n            : in     vl_logic;
        addr            : in     vl_logic_vector(10 downto 0);
        ba              : in     vl_logic_vector(1 downto 0);
        dq              : inout  vl_logic_vector(31 downto 0);
        cs_n            : in     vl_logic;
        dm0             : in     vl_logic;
        dm1             : in     vl_logic;
        dm2             : in     vl_logic;
        dm3             : in     vl_logic;
        cke             : in     vl_logic
    );
end EG_PHY_SDRAM_2M_32;
