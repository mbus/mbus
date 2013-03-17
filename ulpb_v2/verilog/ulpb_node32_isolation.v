
/*
 * Last modified date: 03/16 '13
 * Last modified by: Ye-sheng Kuo <samkuo@umich.edu>
 * Last modified content: Newly added
 * --------------------------------------------------------------------------
 * IMPORTANT: This module should be always on, do NOT connect this module
 * 			to power gated domain. This module sits between Bus controller
 * 			and layer controller
 * --------------------------------------------------------------------------
 * */

`include "include/ulpb_def.v"

module ulpb_node32_isolation(
	input 	RELEASE_ISO_FROM_SLEEP_CTRL,

	// LC stands for Layer Controller
	// Interrconnect between this module and LC
	input 	[`ADDR_WIDTH-1:0] TX_ADDR_FROM_LC, 
	input 	[`DATA_WIDTH-1:0] TX_DATA_FROM_LC, 
	input 	TX_PEND_FROM_LC, 
	input 	TX_REQ_FROM_LC, 
	input 	PRIORITY_FROM_LC,
	output 	reg TX_ACK_TO_LC, 
	output 	reg [`ADDR_WIDTH-1:0] RX_ADDR_TO_LC, 
	output 	reg [`DATA_WIDTH-1:0] RX_DATA_TO_LC, 
	output 	reg RX_REQ_TO_LC, 
	input 	RX_ACK_FROM_LC, 
	output 	reg RX_FAIL_TO_LC,
	output 	reg RX_PEND_TO_LC, 
	output 	reg TX_FAIL_TO_LC, 
	output 	reg TX_SUCC_TO_LC, 
	input 	TX_RESP_ACK_FROM_LC,
	// BC stands for Bus Controller
	// Interrconnect between this module and BC 
	output 	reg [`ADDR_WIDTH-1:0] TX_ADDR_TO_BC, 
	output 	reg [`DATA_WIDTH-1:0] TX_DATA_TO_BC, 
	output 	reg TX_PEND_TO_BC, 
	output 	reg TX_REQ_TO_BC, 
	output 	reg PRIORITY_TO_BC,
	input 	TX_ACK_FROM_BC, 
	input 	[`ADDR_WIDTH-1:0] RX_ADDR_FROM_BC, 
	input 	[`DATA_WIDTH-1:0] RX_DATA_FROM_BC, 
	input 	RX_REQ_FROM_BC, 
	output 	reg RX_ACK_TO_BC, 
	input 	RX_FAIL_FROM_BC,
	input 	RX_PEND_FROM_BC, 
	input 	TX_FAIL_FROM_BC, 
	input 	TX_SUCC_FROM_BC, 
	output 	reg TX_RESP_ACK_TO_BC,

	input 	POWER_ON_FROM_BC,
	input	RELEASE_CLK_FROM_BC,
	input	RELEASE_RST_FROM_BC,
	input 	RELEASE_ISO_FROM_BC,
	// use this to isolate signals between layer controller and CPU/MEM etc.
	output 	reg RELEASE_ISO_FROM_BC_MASKED,
	output	reg POWER_ON_TO_LC,
	output	reg RELEASE_CLK_TO_LC,
	output	reg RELEASE_RST_TO_LC

);

parameter HOLD = `IO_HOLD;			// During sleep
parameter RELEASE = `IO_RELEASE;	// During wake-up

always @ *
begin
	if (RELEASE_ISO_FROM_SLEEP_CTRL==HOLD)
	begin
		POWER_ON_TO_LC = HOLD;
		RELEASE_CLK_TO_LC = HOLD;
		RELEASE_RST_TO_LC = HOLD;
	end
	else
	begin
		POWER_ON_TO_LC = POWER_ON_FROM_BC;
		RELEASE_CLK_TO_LC = RELEASE_CLK_FROM_BC;
		RELEASE_RST_TO_LC = RELEASE_RST_FROM_BC;
	end
end

always @ *
begin
	if (RELEASE_ISO_FROM_SLEEP_CTRL==HOLD)
	begin
		TX_ACK_TO_LC 	= 0;
		RX_ADDR_TO_LC 	= 0;
		RX_DATA_TO_LC 	= 0;
		RX_REQ_TO_LC 	= 0;
		RX_FAIL_TO_LC 	= 0;
		RX_PEND_TO_LC 	= 0;
		TX_FAIL_TO_LC 	= 0;
		TX_SUCC_TO_LC 	= 0;
		RELEASED_ISO_FROM_BC_MASKED = HOLD;
	end
	else
	begin
		TX_ACK_TO_LC 	= TX_ACK_FROM_BC ;
		RX_ADDR_TO_LC 	= RX_ADDR_FROM_BC;
		RX_DATA_TO_LC 	= RX_DATA_FROM_BC;
		RX_REQ_TO_LC 	= RX_REQ_FROM_BC;
		RX_FAIL_TO_LC 	= RX_FAIL_FROM_BC;
		RX_PEND_TO_LC 	= RX_PEND_FROM_BC;
		TX_FAIL_TO_LC 	= TX_FAIL_FROM_BC;
		TX_SUCC_TO_LC 	= TX_SUCC_FROM_BC;
		RELEASED_ISO_FROM_BC_MASKED = RELEASE_ISO_FROM_BC;
	end
end

always @ *
begin
	if (RELEASE_ISO_FROM_BC_MASKED==HOLD)
	begin
		TX_ADDR_TO_BC 	= 0;
		TX_DATA_TO_BC	= 0;
		TX_PEND_TO_BC	= 0;
		TX_REQ_TO_BC	= 0;
		PRIORITY_TO_BC	= 0;
		RX_ACK_TO_BC	= 0;
		TX_RESP_ACK_TO_BC=0;
	end
	else
	begin
		TX_ADDR_TO_BC 	= TX_ADDR_FROM_LC;
		TX_DATA_TO_BC	= TX_DATA_FROM_LC;
		TX_PEND_TO_BC	= TX_PEND_FROM_LC;
		TX_REQ_TO_BC	= TX_REQ_FROM_LC;
		PRIORITY_TO_BC	= PRIORITY_FROM_LC;
		RX_ACK_TO_BC	= RX_ACK_FROM_LC;
		TX_RESP_ACK_TO_BC=TX_RESP_ACK_FROM_LC;
	end
end


endmodule
