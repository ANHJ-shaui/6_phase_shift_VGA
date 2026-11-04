/************************************************************\
**	Copyright (c) 2012-2025 Anlogic Inc.
**	All Right Reserved.
\************************************************************/
/************************************************************\
**	Build time: Sep 29 2026 09:27:17
**	TD version	:	6.2.168116
************************************************************/
`timescale 1ns/1ps
module div_gen_32
(
  input                         aclk,
  input                         aresetn,
  input   [31:0]                s_axis_dividend_tdata,
  input                         s_axis_dividend_tvalid,
  input   [31:0]                s_axis_divisor_tdata,
  input                         s_axis_divisor_tvalid,
  output  [63:0]                m_axis_dout_tdata,
  output                        m_axis_dout_tvalid
);

  divider_top_2e799f05df53
  #(
      .OPERAND_SIGN(0),
      .DIVIDEND_DW(32),
      .DIVISOR_DW(32),
      .DIVIDEND_CEIL_DW(32),
      .DIVISOR_CEIL_DW(32),
      .OUTPUT_DW(64),
      .FLOW_CONTROL(0),
      .LATENCY(20)
  )divider_top_2e799f05df53_Inst
  (
      .aclk(aclk),
      .aresetn(aresetn),
      .s_axis_dividend_tdata(s_axis_dividend_tdata),
      .s_axis_dividend_tvalid(s_axis_dividend_tvalid),
      .s_axis_divisor_tdata(s_axis_divisor_tdata),
      .s_axis_divisor_tvalid(s_axis_divisor_tvalid),
      .m_axis_dout_tdata(m_axis_dout_tdata),
      .m_axis_dout_tvalid(m_axis_dout_tvalid)
  );
endmodule
