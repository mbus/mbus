`include "include/mbus_def.v"

module mbus_layer_wrapper
  (
    input 	             CLKIN, 
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

   wire 		     ext_int_to_wire;
   wire 		     ext_int_to_bus;
   wire 		     clr_ext_int;
   wire 		     clr_busy; 

   wire [`DYNA_WIDTH-1:0]    rf_addr_out_to_node;
   wire 		     rf_addr_in_from_node;
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
      
      .MBC_RESET	(), 
      .SLEEP_REQUEST_TO_SLEEP_CTRL(), 
      
      .LRC_SLEEP	(),
      .LRC_CLKENB	(),
      .LRC_RESET	(),
      .LRC_ISOLATE	(),
      
      .EXTERNAL_INT	(ext_int_to_bus), 
      .CLR_EXT_INT	(clr_ext_int), 
      .CLR_BUSY		(clr_busy),
      
      .ASSIGNED_ADDR_IN		(rf_addr_out_to_node), 
      .ASSIGNED_ADDR_OUT	(rf_addr_in_from_node), 
      
      .ASSIGNED_ADDR_VALID	(rf_addr_valid), 
      .ASSIGNED_ADDR_WRITE	(rf_addr_write), 
      .ASSIGNED_ADDR_INVALIDn	(rf_addr_rstn)
      );

   mbus_wire_ctrl lc0
     (
      .RESETn(RESETn), 
      .DIN(DIN), 
      .CLKIN(CLKIN),
      .RELEASE_ISO_FROM_SLEEP_CTRL(1'b0),
      .DOUT_FROM_BUS(w_n0lc0), 
      .CLKOUT_FROM_BUS(w_n0lc0_clk_out),
      .DOUT(DOUT), 
      .CLKOUT(CLKOUT),
      .EXTERNAL_INT(ext_int_to_wire)
      );

   mbus_addr_rf rf0
     (
      .RESETn				(RESETn),
      .RELEASE_ISO_FROM_SLEEP_CTRL	(1'b0),
      .ADDR_OUT				(rf_addr_out_to_node),
      .ADDR_IN				(rf_addr_in_from_node),
      .ADDR_VALID			(rf_addr_valid),
      .ADDR_WR_EN			(rf_addr_write),
      .ADDR_CLRn			(rf_addr_rstn)
      );

   // always on interrupt controller
   mbus_int_ctrl mic0
     (
      .CLKIN			(CLKIN),
      .RESETn			(RESETn),
      .MBC_ISOLATE		(1'b0),
      .SC_CLR_BUSY		(1'b0),
      .MBUS_CLR_BUSY		(clr_busy),
      
      .REQ_INT			(1'b0), 
      .MBC_SLEEP		(1'b0),
      .LRC_SLEEP		(1'b0),
      .EXTERNAL_INT_TO_WIRE	(ext_int_to_wire), 
      .EXTERNAL_INT_TO_BUS	(ext_int_to_bus), 
      .CLR_EXT_INT		(clr_ext_int)
      );

endmodule // mbus_layer_wrapper

