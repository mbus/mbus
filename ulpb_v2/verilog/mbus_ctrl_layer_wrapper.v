
`include "include/mbus_def.v"

module mbus_ctrl_layer_wrapper(
	input	CLK_EXT,
	input 	CLKIN, 
	input 	RESETn, 
	input 	DIN, 
	output 	CLKOUT,
	output 	DOUT, 
	input 	[`ADDR_WIDTH-1:0] TX_ADDR, 
	input 	[`DATA_WIDTH-1:0] TX_DATA, 
	input 	TX_PEND, 
	input 	TX_REQ, 
	input 	PRIORITY,
	output 	TX_ACK, 
	output 	[`ADDR_WIDTH-1:0] RX_ADDR, 
	output 	[`DATA_WIDTH-1:0] RX_DATA, 
	output 	RX_REQ, 
	input 	RX_ACK, 
	output	RX_BROADCAST,
	output 	RX_FAIL,
	output 	RX_PEND, 
	output 	TX_FAIL, 
	output 	TX_SUCC, 
	input 	TX_RESP_ACK,

	output 	LC_POWER_ON,
	output 	LC_RELEASE_CLK,
	output 	LC_RELEASE_RST,
	output 	LC_RELEASE_ISO,

	input 	REQ_INT,

	input	WAKEUP_PROC
);

parameter ADDRESS = 20'haaaaa;

wire	clk_en;
wire	CLK_GEN;
wire	release_iso_from_s0, release_rst_from_s0;
wire	sleep_req_from_m0;

SLEEP_CONTROLv4 s0(
	.MBC_ISOLATE(release_iso_from_s0), 
	.MBC_ISOLATE_B(), 
	.MBC_RESET(release_rst_from_s0),
    .MBC_RESET_B(), 
	.MBC_SLEEP(),
	.MBC_SLEEP_B(clk_en), 
	.SYSTEM_ACTIVE(),
    .WAKEUP_REQ_ORED(),
	.CLK(CLK_GEN), 
	.MBUS_DIN(DIN), 
	.RESETn(RESETn), 
	.SLEEP_REQ(sleep_req_from_m0),
    .WAKEUP_REQ0(WAKEUP_PROC), 
	.WAKEUP_REQ1(), 
	.WAKEUP_REQ2());


mbus_clk_sim mcs0(
	.ext_clk(CLK_EXT),		// generated from testbench, always ticking
	.clk_en(clk_en),		// from sleep controller
	.clk_out(CLK_GEN)		// to sleep controller, mbus
);

wire	w_m0wc0_clk_out, w_m0wc0;
wire	ext_int_to_wire, ext_int_to_bus;

mbus_ctrl_wrapper #(.ADDRESS(ADDRESS)) m0(
	.CLK_EXT(CLK_GEN), .RESETn(RESETn), 
	.CLKIN(CLKIN), .CLKOUT(w_m0wc0_clk_out), .DIN(DIN), .DOUT(w_m0wc0),
	.TX_ADDR(TX_ADDR), .TX_DATA(TX_DATA), .TX_PEND(TX_PEND), .TX_REQ(TX_REQ), .PRIORITY(PRIORITY), .TX_ACK(TX_ACK), 
	.RX_ADDR(RX_ADDR), .RX_DATA(RX_DATA), .RX_REQ(RX_REQ), .RX_ACK(RX_ACK), .RX_BROADCAST(RX_BROADCAST),
	.RX_FAIL(RX_FAIL), .RX_PEND(RX_PEND), 
	.TX_FAIL(TX_FAIL), .TX_SUCC(TX_SUCC), .TX_RESP_ACK(TX_RESP_ACK), 

	.THRESHOLD(20'h05fff),

	.RELEASE_RST_FROM_SLEEP_CTRL(release_rst_from_s0),
	.POWER_ON_TO_LAYER_CTRL(LC_POWER_ON),
	.RELEASE_CLK_TO_LAYER_CTRL(LC_RELEASE_CLK),
	.RELEASE_RST_TO_LAYER_CTRL(LC_RELEASE_RST),
	.RELEASE_ISO_TO_LAYER_CTRL(LC_RELEASE_ISO),
	.EXTERNAL_INT(ext_int_to_bus), .CLR_EXT_INT(clr_ext_int),
	.WAKEUP_PROC(WAKEUP_PROC),
	.SLEEP_REQUEST_TO_SLEEP_CTRL(sleep_req_from_m0)
);


// always on wire controller
mbus_wire_ctrl wc0
	(.DIN(DIN), .CLKIN(CLKIN), 										// the same input as the node
	 .RELEASE_ISO_FROM_SLEEP_CTRL(release_iso_from_s0),			// from sleep controller
	 .DOUT_FROM_BUS(w_m0wc0), .CLKOUT_FROM_BUS(w_m0wc0_clk_out), 	// the outputs from the node
	 .DOUT(DOUT), .CLKOUT(CLKOUT),									// to next node
	 .EXTERNAL_INT(ext_int_to_wire));

// always on interrupt request
mbus_ext_int int0(
	.CLKIN(CLKIN), 
	.RESETn(RESETn),
	.REQ_INT(REQ_INT), 
	.EXTERNAL_INT_TO_WIRE(ext_int_to_wire), 
	.EXTERNAL_INT_TO_BUS(ext_int_to_bus), 
	.CLR_EXT_INT(clr_ext_int));

endmodule
