library verilog;
use verilog.vl_types.all;
entity EG_LOGIC_MBOOT is
    generic(
        ADDR_SOURCE_SEL : string  := "STATIC";
        STATIC_ADDR     : vl_logic_vector(0 to 7) := (Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0)
    );
    port(
        rebootn         : in     vl_logic;
        dynamic_addr    : in     vl_logic_vector(7 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of ADDR_SOURCE_SEL : constant is 1;
    attribute mti_svvh_generic_type of STATIC_ADDR : constant is 1;
end EG_LOGIC_MBOOT;
