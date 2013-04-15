
`include "include/mbus_def.v"

module mbus_master_node(
	input 	CLKIN, 
	input 	RESETn, 
	input 	DIN, 
	output 	reg CLKOUT,
	output 	reg DOUT, 

	input 		[`ADDR_WIDTH-1:0] TX_ADDR, 
	input 		[`DATA_WIDTH-1:0] TX_DATA, 
	input 		TX_PEND, 
	input 		TX_REQ, 
	output 	reg TX_ACK, 
	input 		PRIORITY,

	output 	reg [`ADDR_WIDTH-1:0] RX_ADDR, 
	output 	reg [`DATA_WIDTH-1:0] RX_DATA, 
	output 	reg RX_PEND, 
	output 	reg RX_REQ, 
	input 		RX_ACK, 
	output 		RX_BROADCAST,

	output 	reg RX_FAIL,
	output 	reg TX_FAIL, 
	output 	reg TX_SUCC, 
	input 		TX_RESP_ACK,

	`ifdef POWER_GATING
	// power gated signals from sleep controller
	input 		RELEASE_RST_FROM_SLEEP_CTRL,
	// power gated signals to layer controller
	output 	reg POWER_ON_TO_LAYER_CTRL,
	output 	reg RELEASE_CLK_TO_LAYER_CTRL,
	output 	reg RELEASE_RST_TO_LAYER_CTRL,
	output 	reg RELEASE_ISO_TO_LAYER_CTRL,
	// power gated signal to sleep controller
	output 	reg SLEEP_REQUEST_TO_SLEEP_CTRL,
	// External interrupt
	input 		EXTERNAL_INT,
	output 	reg CLR_EXT_INT,
	`endif
	// interface with local register files (RF)
	input		[`DYNA_WIDTH-1:0] ASSIGNED_ADDR_IN,
	output	 	[`DYNA_WIDTH-1:0] ASSIGNED_ADDR_OUT,
	input		ASSIGNED_ADDR_VALID,
	output	reg	ASSIGNED_ADDR_WRITE,
	output	reg	ASSIGNED_ADDR_INVALIDn
);

`define CPU_LAYER

`include "mbus_node_core.v"

endmodule
