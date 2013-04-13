
`include "include/mbus_def.v"

module mbus_ctrl_layer_wrapper(
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

	input 	REQ_INT
);



module mbus_ctrl_wrapper(
	input 	CLK_EXT,
	input 	RESETn,
	input 	CLKIN,
	output	CLKOUT,
	input 	DIN,
	output 	DOUT,
	input	[`ADDR_WIDTH-1:0] TX_ADDR,
	input 	[`DATA_WIDTH-1:0] TX_DATA, 
	input 	TX_PEND, 
	input 	TX_REQ, 
	input 	PRIORITY,
	output 	TX_ACK, 
	output 	[`ADDR_WIDTH-1:0] RX_ADDR, 
	output 	[`DATA_WIDTH-1:0] RX_DATA, 
	output 	RX_REQ, 
	input 	RX_ACK, 
	output  RX_BROADCAST,
	output	RX_FAIL,
	output 	RX_PEND, 
	output 	TX_FAIL, 
	output 	TX_SUCC, 
	input 	TX_RESP_ACK,
	input 	[`WATCH_DOG_WIDTH-1:0] THRESHOLD,
	// power gated signals from sleep controller
	input 	RELEASE_RST_FROM_SLEEP_CTRL,
	// power gated signals to layer controller
	output 	POWER_ON_TO_LAYER_CTRL,
	output 	RELEASE_CLK_TO_LAYER_CTRL,
	output 	RELEASE_RST_TO_LAYER_CTRL,
	output 	RELEASE_ISO_TO_LAYER_CTRL,
	// wake up bus controller
	input 	EXTERNAL_INT,
	output	CLR_EXT_INT,
	// wake up processor
	input	WAKEUP_PROC,
	output	SLEEP_REQUEST_TO_SLEEP_CTRL
);
