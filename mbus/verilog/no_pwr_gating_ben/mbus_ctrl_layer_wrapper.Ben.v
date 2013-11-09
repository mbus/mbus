`include "include/mbus_def.v"

module mbus_ctrl_layer_wrapper
  (
    input	            CLK_EXT,
    input 		    CLKIN,
    input 		    RESETn,
    input 		    DIN,
    output 		    CLKOUT,
    output 		    DOUT,
    input [`ADDR_WIDTH-1:0] TX_ADDR,
    input [`DATA_WIDTH-1:0] TX_DATA,
    input 		    TX_PEND,
    input 		    TX_REQ,
    input 		    TX_PRIORITY,
    output 		    TX_ACK,
    output [`ADDR_WIDTH:0]  RX_ADDR,
    output [`DATA_WIDTH:0]  RX_DATA,
    output 		    RX_REQ,
    input 		    RX_ACK,
    output 		    RX_BROADCAST,
    output 		    RX_FAIL,
    output 		    RX_PEND,
    output 		    TX_FAIL,
    output 		    TX_SUCC,
    input 		    TX_RESP_ACK
   );

   parameter 		    ADDRESS = 20'haaaaa;

   wire 		    w_m0wc0_clk_out;
   wire 		    w_m0wc0;
   
   wire 		    ext_int_to_wire;
   wire 		    ext_int_to_bus;
   wire 		    clr_ext_int;
   wire 		    clr_busy;

   mbus_ctrl_wrapper #(.ADDRESS(ADDRESS)) m0
     (
      .CLK_EXT		(CLK_EXT),
      .RESETn		(RESETn),
      .CLKIN		(CLKIN),
      .CLKOUT		(w_m0wc0_clk_out),
      .DIN		(DIN),
      .DOUT		(w_m0wc0),
      .TX_ADDR		(TX_ADDR),
      .TX_DATA		(TX_DATA),
      .TX_PEND		(TX_PEND),
      .TX_REQ		(TX_REQ),
      .TX_PRIORITY	(TX_PRIORITY),
      .TX_ACK		(TX_ACK),
      .RX_ADDR		(RX_ADDR),
      .RX_DATA		(RX_DATA),
      .RX_REQ		(RX_REQ),
      .RX_ACK		(RX_ACK),
      .RX_BROADCAST	(RX_BROADCAST),
      .RX_FAIL		(RX_FAIL),
      .RX_PEND		(RX_PEND),
      .TX_FAIL		(TX_FAIL),
      .TX_SUCC		(TX_SUCC),
      .TX_RESP_ACK	(TX_RESP_ACK),

      .THRESHOLD	(20'h05fff),

      .MBC_RESET	(1'b0),
      .LRC_SLEEP	(),
      .LRC_CLKENB	(),
      .LRC_RESET	(),
      .LRC_ISOLATE	(),
      .EXTERNAL_INT	(ext_int_to_bus), //?
      .CLR_EXT_INT	(clr_ext_int),
      .CLR_BUSY		(clr_busy),
      .SLEEP_REQUEST_TO_SLEEP_CTRL()
      );

   // always on wire controller
   mbus_master_wire_ctrl wc0
     (
      .RESETn				(RESETn),
      .RELEASE_ISO_FROM_SLEEP_CTRL	(1'b0),
      .DOUT_FROM_BUS			(w_m0wc0),
      .CLKOUT_FROM_BUS			(w_m0wc0_clk_out),
      .DOUT				(DOUT),
      .CLKOUT				(CLKOUT),
      .EXTERNAL_INT			(ext_int_to_wire)
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


endmodule
