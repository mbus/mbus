
`include "include/mbus_def.v"

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
	output	CLR_BUSY,
	// wake up processor
	output	reg SLEEP_REQUEST_TO_SLEEP_CTRL
);

parameter ADDRESS = 20'haaaaa;

wire	CLK_CTRL_TO_NODE;
wire	DOUT_CTRL_TO_NODE;
wire	NODE_RX_REQ;
wire	NODE_RX_ACK;
wire	SLEEP_REQ;
reg		ctrl_addr_match, ctrl_rx_ack;

wire 	RESETn_local = (RESETn & (~RELEASE_RST_FROM_SLEEP_CTRL));

always @ *
begin
	if ((RX_BROADCAST) &&  (RX_ADDR[`FUNC_WIDTH-1:0]==`CHANNEL_CTRL))
		ctrl_addr_match = 1;
	else
		ctrl_addr_match = 0;
end

assign RX_REQ = (ctrl_addr_match)? 1'b0 : NODE_RX_REQ;

always @ (posedge CLK_EXT or negedge RESETn_local)
begin
	if (~RESETn_local)
	begin
		ctrl_rx_ack <= 0;
		SLEEP_REQUEST_TO_SLEEP_CTRL <= 0;
	end
	else
	begin
		if (ctrl_addr_match & NODE_RX_REQ)
		begin
			ctrl_rx_ack <= 1;
		end

		if (ctrl_rx_ack & (~NODE_RX_REQ))
			ctrl_rx_ack <= 0;

		// delay 1 cycle
		SLEEP_REQUEST_TO_SLEEP_CTRL <= SLEEP_REQ;
	end
end
assign NODE_RX_ACK = (RX_ACK | ctrl_rx_ack);

mbus_ctrl ctrl0(
	.CLK_EXT(CLK_EXT),
	.RESETn(RESETn_local),
	.CLKIN(CLKIN),
	.CLKOUT(CLK_CTRL_TO_NODE),
	.DIN(DIN),
	.DOUT(DOUT_CTRL_TO_NODE),
	.THRESHOLD(THRESHOLD)
);

mbus_node#(.ADDRESS(ADDRESS), .MASTER_NODE(1'b1), .CPU_LAYER(1'b1)) node0(
	.CLKIN(CLK_CTRL_TO_NODE), 
	.RESETn(RESETn), 
	.DIN(DOUT_CTRL_TO_NODE), 
	.CLKOUT(CLKOUT),
	.DOUT(DOUT), 
	.TX_ADDR(TX_ADDR), 
	.TX_DATA(TX_DATA), 
	.TX_PEND(TX_PEND), 
	.TX_REQ(TX_REQ), 
	.PRIORITY(PRIORITY),
	.TX_ACK(TX_ACK), 
	.RX_ADDR(RX_ADDR), 
	.RX_DATA(RX_DATA), 
	.RX_REQ(NODE_RX_REQ), 
	.RX_ACK(NODE_RX_ACK), 
	.RX_BROADCAST(RX_BROADCAST),
	.RX_FAIL(RX_FAIL),
	.RX_PEND(RX_PEND), 
	.TX_FAIL(TX_FAIL), 
	.TX_SUCC(TX_SUCC), 
	.TX_RESP_ACK(TX_RESP_ACK),
	.RELEASE_RST_FROM_SLEEP_CTRL(RELEASE_RST_FROM_SLEEP_CTRL),
	.POWER_ON_TO_LAYER_CTRL(POWER_ON_TO_LAYER_CTRL),
	.RELEASE_CLK_TO_LAYER_CTRL(RELEASE_CLK_TO_LAYER_CTRL),
	.RELEASE_RST_TO_LAYER_CTRL(RELEASE_RST_TO_LAYER_CTRL),
	.RELEASE_ISO_TO_LAYER_CTRL(RELEASE_ISO_TO_LAYER_CTRL),
	.SLEEP_REQUEST_TO_SLEEP_CTRL(SLEEP_REQ),
	.EXTERNAL_INT(EXTERNAL_INT),
	.CLR_EXT_INT(CLR_EXT_INT),
	.CLR_BUSY(CLR_BUSY),
	.ASSIGNED_ADDR_IN(4'h1),
	.ASSIGNED_ADDR_OUT(),
	.ASSIGNED_ADDR_VALID(1'b1),
	.ASSIGNED_ADDR_WRITE(),
	.ASSIGNED_ADDR_INVALIDn()
);

endmodule
