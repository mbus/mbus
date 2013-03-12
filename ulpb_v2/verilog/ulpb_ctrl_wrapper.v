
`include "include/ulpb_def.v"

module ulpb_ctrl_wrapper(
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
	output	RX_FAIL,
	output 	RX_PEND, 
	output 	TX_FAIL, 
	output 	TX_SUCC, 
	input 	TX_RESP_ACK,
	input	[31:0] THRESHOLD
);

parameter CTRL_ADDRESS = 8'h01;
parameter NODE_ADDRESS = 8'haa;
parameter CTRL_ADDR_MASK = 8'hff;
parameter NODE_ADDR_MASK = 8'hff;

wire	CLK_CTRL_TO_NODE;
wire	DOUT_CTRL_TO_NODE;
wire	NODE_RX_REQ;
wire	NODE_RX_ACK;
reg		ctrl_addr_match, ctrl_rx_ack;


always @ *
begin
	ctrl_addr_match = 0;
	// address match to ctrl node
	if (((RX_ADDR ^ CTRL_ADDRESS) & CTRL_ADDR_MASK)==0)
		ctrl_addr_match = 1;
end
assign RX_REQ = (ctrl_addr_match)? 1'b0 : NODE_RX_REQ;

always @ (posedge CLK_EXT or negedge RESETn)
begin
	if (~RESETn)
	begin
		ctrl_rx_ack <= 0;
	end
	else
	begin
		if (ctrl_addr_match & NODE_RX_REQ)
		begin
			ctrl_rx_ack <= 1;
		end

		if (ctrl_rx_ack & (~NODE_RX_REQ))
			ctrl_rx_ack <= 0;
	end
end
assign NODE_RX_ACK = (RX_ACK | ctrl_rx_ack);


ulpb_ctrl ctrl0(
	.CLK_EXT(CLK_EXT),
	.RESETn(RESETn),
	.CLKIN(CLKIN),
	.CLKOUT(CLK_CTRL_TO_NODE),
	.DIN(DIN),
	.DOUT(DOUT_CTRL_TO_NODE),
	.THRESHOLD(THRESHOLD)
);

ulpb_node32 #(.ADDRESS(NODE_ADDRESS), .ADDRESS_MASK(NODE_ADDR_MASK), .MULTI_ADDR_EN(1'b1), 
			.ADDRESS2(CTRL_ADDRESS), .ADDRESS_MASK2(NODE_ADDR_MASK)) node0(
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
	.RX_FAIL(RX_FAIL),
	.RX_PEND(RX_PEND), 
	.TX_FAIL(TX_FAIL), 
	.TX_SUCC(TX_SUCC), 
	.TX_RESP_ACK(TX_RESP_ACK)
);

endmodule
