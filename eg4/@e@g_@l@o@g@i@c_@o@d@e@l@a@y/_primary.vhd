library verilog;
use verilog.vl_types.all;
entity EG_LOGIC_ODELAY is
    generic(
        OUTDEL          : integer := 1
    );
    port(
        o               : out    vl_logic;
        i               : in     vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of OUTDEL : constant is 1;
end EG_LOGIC_ODELAY;
