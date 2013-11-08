/*
 * MBus master layer wrapper for NON-power gating
 *
 * Update history:
 *
 * date: 11/08 '13
 * modified content: Newly added
 * modified by: Ye-sheng Kuo <samkuo@umich.edu>
 * --------------------------------------------------------------------------
 * IMPORTANT: 
 * --------------------------------------------------------------------------
 * */


`include "include/mbus_def.v"

module mbus_ctrl_layer_wrapper
  (
  	input			 CLK_EXT,
    input 	         CLKIN, 
    input 		     RESETn, 
    input 		     DIN, 
    output 		     CLKOUT,
    output 		     DOUT, 
    input [`ADDR_WIDTH-1:0]  TX_ADDR, 
    input [`DATA_WIDTH-1:0]  TX_DATA, 
    input 		     TX_PEND, 
    input 		     TX_REQ, 
    input 		     TX_PRIORITY,
    output 		     TX_ACK, 
    output [`ADDR_WIDTH-1:0] RX_ADDR, 
    output [`DATA_WIDTH-1:0] RX_DATA, 
    output 		     RX_REQ, 
    input 		     RX_ACK, 
    output 		     RX_BROADCAST,
    output 		     RX_FAIL,
    output 		     RX_PEND, 
    output 		     TX_FAIL, 
    output 		     TX_SUCC, 
    input 		     TX_RESP_ACK
   );

	parameter ADDRESS = 20'haaaaa;

   wire 		     w_n0lc0_clk_out;
   wire 		     w_n0lc0;

   mbus_ctrl_wrapper#(.ADDRESS(ADDRESS)) n0
     (
	  .CLK_EXT		(CLK_EXT),
      .CLKIN		(CLKIN), 
      .CLKOUT		(w_n0lc0_clk_out), 
      .RESETn		(RESETn), 
      .DIN		(DIN), 
      .DOUT		(w_n0lc0), 
      
      .TX_ADDR		(TX_ADDR), 
      .TX_DATA		(TX_DATA), 
      .TX_REQ		(TX_REQ), 
      .TX_ACK		(TX_ACK), 
      .TX_PEND		(TX_PEND), 
      .TX_PRIORITY	(TX_PRIORITY),
      
      .RX_ADDR		(RX_ADDR), 
      .RX_DATA		(RX_DATA), 
      .RX_REQ		(RX_REQ), 
      .RX_ACK		(RX_ACK), 
      .RX_BROADCAST	(RX_BROADCAST), 
      .RX_FAIL		(RX_FAIL), 
      .RX_PEND		(RX_PEND),
      
      .TX_SUCC		(TX_SUCC), 
      .TX_FAIL		(TX_FAIL), 
      .TX_RESP_ACK	(TX_RESP_ACK),

	  .THRESHOLD	(20'h05fff)
	  
      );

   mbus_wire_ctrl lc0
     (
      .RESETn(RESETn), 
      .DOUT_FROM_BUS(w_n0lc0), 
      .CLKOUT_FROM_BUS(w_n0lc0_clk_out),
      .DOUT(DOUT), 
      .CLKOUT(CLKOUT)
      );


endmodule // mbus_layer_wrapper

