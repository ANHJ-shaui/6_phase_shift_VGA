library verilog;
use verilog.vl_types.all;
entity dff_slice is
    port(
        q0              : out    vl_logic;
        q1              : out    vl_logic;
        ce              : in     vl_logic;
        sr              : in     vl_logic;
        clk             : in     vl_logic;
        gsrn            : in     vl_logic;
        gsrforce_n      : in     vl_logic;
        mc1_syncmode    : in     vl_logic;
        mc1_disgsr      : in     vl_logic;
        mc1_testsh      : in     vl_logic;
        di              : in     vl_logic_vector(1 downto 0);
        f               : in     vl_logic_vector(1 downto 0);
        fx              : in     vl_logic_vector(1 downto 0);
        mc1_sr          : in     vl_logic_vector(1 downto 0);
        mc1_di          : in     vl_logic_vector(1 downto 0);
        mc1_fx          : in     vl_logic_vector(1 downto 0);
        latchmode       : in     vl_logic
    );
end dff_slice;
