library verilog;
use verilog.vl_types.all;
entity div_gen_32 is
    port(
        aclk            : in     vl_logic;
        aresetn         : in     vl_logic;
        s_axis_dividend_tdata: in     vl_logic_vector(31 downto 0);
        s_axis_dividend_tvalid: in     vl_logic;
        s_axis_divisor_tdata: in     vl_logic_vector(31 downto 0);
        s_axis_divisor_tvalid: in     vl_logic;
        m_axis_dout_tdata: out    vl_logic_vector(63 downto 0);
        m_axis_dout_tvalid: out    vl_logic
    );
end div_gen_32;
