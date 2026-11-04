library verilog;
use verilog.vl_types.all;
entity EG_PHY_DDR_8M_16 is
    port(
        clk             : in     vl_logic;
        clk_n           : in     vl_logic;
        ras_n           : in     vl_logic;
        cas_n           : in     vl_logic;
        we_n            : in     vl_logic;
        cs_n            : in     vl_logic;
        addr            : in     vl_logic_vector(11 downto 0);
        ba              : in     vl_logic_vector(1 downto 0);
        dq              : inout  vl_logic_vector(15 downto 0);
        ldqs            : inout  vl_logic;
        udqs            : inout  vl_logic;
        ldm             : in     vl_logic;
        udm             : in     vl_logic;
        cke             : in     vl_logic
    );
end EG_PHY_DDR_8M_16;
