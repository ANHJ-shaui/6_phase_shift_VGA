library verilog;
use verilog.vl_types.all;
entity EG_LOGIC_IDELAY is
    generic(
        INDEL           : integer := 1
    );
    port(
        o               : out    vl_logic;
        i               : in     vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of INDEL : constant is 1;
end EG_LOGIC_IDELAY;
