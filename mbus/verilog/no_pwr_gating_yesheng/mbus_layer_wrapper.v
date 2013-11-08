`include "include/mbus_def.v"

module mbus_layer_wrapper
  (
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

   parameter 		     ADDRESS = 20'h12345;

   wire 		     w_n0lc0_clk_out;
   wire 		     w_n0lc0;


   wire [`DYNA_WIDTH-1:0]    rf_addr_out_to_node;
   wire [`DYNA_WIDTH-1:0]    rf_addr_in_from_node;
   wire 		     rf_addr_valid;
   wire 		     rf_addr_write;
   wire 		     rf_addr_rstn;
   
   mbus_node#(.ADDRESS(ADDRESS)) n0
     (
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
      
      .ASSIGNED_ADDR_IN		(rf_addr_out_to_node), 
      .ASSIGNED_ADDR_OUT	(rf_addr_in_from_node), 
      
      .ASSIGNED_ADDR_VALID	(rf_addr_valid), 
      .ASSIGNED_ADDR_WRITE	(rf_addr_write), 
      .ASSIGNED_ADDR_INVALIDn	(rf_addr_rstn)
	  
      );

   mbus_wire_ctrl lc0
     (
      .RESETn(RESETn), 
      .DOUT_FROM_BUS(w_n0lc0), 
      .CLKOUT_FROM_BUS(w_n0lc0_clk_out),
      .DOUT(DOUT), 
      .CLKOUT(CLKOUT)
      );

   mbus_addr_rf rf0
     (
      .RESETn				(RESETn),
      .ADDR_OUT				(rf_addr_out_to_node),
      .ADDR_IN				(rf_addr_in_from_node),
      .ADDR_VALID			(rf_addr_valid),
      .ADDR_WR_EN			(rf_addr_write),
      .ADDR_CLRn			(rf_addr_rstn)
      );

endmodule // mbus_layer_wrapper

