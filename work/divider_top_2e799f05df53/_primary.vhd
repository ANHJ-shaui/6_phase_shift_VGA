library verilog;
use verilog.vl_types.all;
entity divider_top_2e799f05df53 is
    generic(
        OPERAND_SIGN    : integer := 0;
        DIVIDEND_DW     : integer := 8;
        DIVISOR_DW      : integer := 8;
        DIVIDEND_CEIL_DW: integer := 8;
        DIVISOR_CEIL_DW : integer := 8;
        OUTPUT_DW       : integer := 16;
        FLOW_CONTROL    : integer := 0;
        OUT_BLOCKING    : integer := 0;
        LATENCY         : integer := 0
    );
    port(
        aclk            : in     vl_logic;
        aresetn         : in     vl_logic;
        s_axis_dividend_tdata: in     vl_logic_vector;
        s_axis_dividend_tvalid: in     vl_logic;
        s_axis_dividend_tready: out    vl_logic;
        s_axis_divisor_tdata: in     vl_logic_vector;
        s_axis_divisor_tvalid: in     vl_logic;
        s_axis_divisor_tready: out    vl_logic;
        m_axis_dout_tdata: out    vl_logic_vector;
        m_axis_dout_tvalid: out    vl_logic;
        m_axis_dout_tready: in     vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of OPERAND_SIGN : constant is 1;
    attribute mti_svvh_generic_type of DIVIDEND_DW : constant is 1;
    attribute mti_svvh_generic_type of DIVISOR_DW : constant is 1;
    attribute mti_svvh_generic_type of DIVIDEND_CEIL_DW : constant is 1;
    attribute mti_svvh_generic_type of DIVISOR_CEIL_DW : constant is 1;
    attribute mti_svvh_generic_type of OUTPUT_DW : constant is 1;
    attribute mti_svvh_generic_type of FLOW_CONTROL : constant is 1;
    attribute mti_svvh_generic_type of OUT_BLOCKING : constant is 1;
    attribute mti_svvh_generic_type of LATENCY : constant is 1;
end divider_top_2e799f05df53;
