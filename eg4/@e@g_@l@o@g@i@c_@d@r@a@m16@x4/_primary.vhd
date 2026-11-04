library verilog;
use verilog.vl_types.all;
entity EG_LOGIC_DRAM16X4 is
    generic(
        INIT_D0         : vl_logic_vector(0 to 15) := (Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0);
        INIT_D1         : vl_logic_vector(0 to 15) := (Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0);
        INIT_D2         : vl_logic_vector(0 to 15) := (Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0);
        INIT_D3         : vl_logic_vector(0 to 15) := (Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0)
    );
    port(
        di              : in     vl_logic_vector(3 downto 0);
        waddr           : in     vl_logic_vector(3 downto 0);
        we              : in     vl_logic;
        wclk            : in     vl_logic;
        raddr           : in     vl_logic_vector(3 downto 0);
        do              : out    vl_logic_vector(3 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of INIT_D0 : constant is 1;
    attribute mti_svvh_generic_type of INIT_D1 : constant is 1;
    attribute mti_svvh_generic_type of INIT_D2 : constant is 1;
    attribute mti_svvh_generic_type of INIT_D3 : constant is 1;
end EG_LOGIC_DRAM16X4;
