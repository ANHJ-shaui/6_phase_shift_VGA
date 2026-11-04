library verilog;
use verilog.vl_types.all;
entity gray2bin is
    generic(
        WIDTH           : integer := 8
    );
    port(
        din             : in     vl_logic_vector;
        dout            : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of WIDTH : constant is 1;
end gray2bin;
