library verilog;
use verilog.vl_types.all;
entity EG_PHY_CONFIG is
    generic(
        MBOOT_AUTO_SEL  : string  := "DISABLE";
        ADDR_SOURCE_SEL : string  := "STATIC";
        STATIC_ADDR     : vl_logic_vector(0 to 7) := (Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0);
        DONE_PERSISTN   : string  := "ENABLE";
        INIT_PERSISTN   : string  := "ENABLE";
        PROGRAMN_PERSISTN: string  := "DISABLE";
        JTAG_PERSISTN   : string  := "DISABLE";
        GSRN_SYNC_SEL   : string  := "DISABLE";
        FREQ            : string  := "2.5";
        USR_GSRN_EN     : string  := "DISABLE"
    );
    port(
        jrstn           : out    vl_logic;
        jrti            : out    vl_logic_vector(1 downto 0);
        jshift          : out    vl_logic;
        jtck            : out    vl_logic;
        jtdi            : out    vl_logic;
        jupdate         : out    vl_logic;
        jscanen         : out    vl_logic_vector(1 downto 0);
        jtms            : out    vl_logic;
        jtdo            : in     vl_logic_vector(1 downto 0);
        jtag8_ipa       : in     vl_logic_vector(7 downto 0);
        jtag8_ipb       : in     vl_logic_vector(7 downto 0);
        done            : out    vl_logic;
        highz           : out    vl_logic;
        cclk            : out    vl_logic;
        cclk_en         : in     vl_logic;
        gsrn_sync_clk   : in     vl_logic;
        usr_gsrn        : in     vl_logic;
        dna_dout        : out    vl_logic;
        dna_clk         : in     vl_logic;
        dna_din         : in     vl_logic;
        dna_shift_en    : in     vl_logic;
        mboot_rebootn   : in     vl_logic;
        mboot_dynamic_addr: in     vl_logic_vector(7 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of MBOOT_AUTO_SEL : constant is 1;
    attribute mti_svvh_generic_type of ADDR_SOURCE_SEL : constant is 1;
    attribute mti_svvh_generic_type of STATIC_ADDR : constant is 1;
    attribute mti_svvh_generic_type of DONE_PERSISTN : constant is 1;
    attribute mti_svvh_generic_type of INIT_PERSISTN : constant is 1;
    attribute mti_svvh_generic_type of PROGRAMN_PERSISTN : constant is 1;
    attribute mti_svvh_generic_type of JTAG_PERSISTN : constant is 1;
    attribute mti_svvh_generic_type of GSRN_SYNC_SEL : constant is 1;
    attribute mti_svvh_generic_type of FREQ : constant is 1;
    attribute mti_svvh_generic_type of USR_GSRN_EN : constant is 1;
end EG_PHY_CONFIG;
