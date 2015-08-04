/*
 * MBus Copyright 2015 Regents of the University of Michigan
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

`include "include/mbus_def.v"

module mbus_ctrl_wrapper(
	input 	CLK_EXT,
	input 	CLKIN,
	output	CLKOUT,
	input 	RESETn,
	input 	DIN,
	output 	DOUT,
	input	[`ADDR_WIDTH-1:0] TX_ADDR,
	input 	[`DATA_WIDTH-1:0] TX_DATA, 
	input 	TX_PEND, 
	input 	TX_REQ, 
	input 	TX_PRIORITY,
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

	`ifdef POWER_GATING
	// power gated signals from sleep controller
	input 	MBC_RESET,
	// power gated signals to layer controller
	output 	LRC_SLEEP,
	output 	LRC_CLKENB,
	output 	LRC_RESET,
	output 	LRC_ISOLATE,
	// wake up bus controller
	input 	EXTERNAL_INT,
	output	CLR_EXT_INT,
	output	CLR_BUSY,
	// wake up processor
	output	reg SLEEP_REQUEST_TO_SLEEP_CTRL,
	`endif

	input 	[`WATCH_DOG_WIDTH-1:0] THRESHOLD
);

parameter ADDRESS = 20'haaaaa;

wire	CLK_CTRL_TO_NODE;
wire	DOUT_CTRL_TO_NODE;
wire	NODE_RX_REQ;
wire	NODE_RX_ACK;
`ifdef POWER_GATING
wire	SLEEP_REQ;
`endif
reg		ctrl_addr_match, ctrl_rx_ack;

`ifdef POWER_GATING
wire 	RESETn_local = (RESETn & (~MBC_RESET));
`else
wire 	RESETn_local = RESETn;
`endif


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
		`ifdef POWER_GATING
		SLEEP_REQUEST_TO_SLEEP_CTRL <= 0;
		`endif
	end
	else
	begin
		if (ctrl_addr_match & NODE_RX_REQ)
		begin
			ctrl_rx_ack <= 1;
		end

		if (ctrl_rx_ack & (~NODE_RX_REQ))
			ctrl_rx_ack <= 0;

		`ifdef POWER_GATING
		// delay 1 cycle
		SLEEP_REQUEST_TO_SLEEP_CTRL <= SLEEP_REQ;
		`endif
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
	.TX_PRIORITY(TX_PRIORITY),
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
	`ifdef POWER_GATING
	.MBC_RESET(MBC_RESET),
	.LRC_SLEEP(LRC_SLEEP),
	.LRC_CLKENB(LRC_CLKENB),
	.LRC_RESET(LRC_RESET),
	.LRC_ISOLATE(LRC_ISOLATE),
	.SLEEP_REQUEST_TO_SLEEP_CTRL(SLEEP_REQ),
	.EXTERNAL_INT(EXTERNAL_INT),
	.CLR_EXT_INT(CLR_EXT_INT),
	.CLR_BUSY(CLR_BUSY),
	`endif
	.ASSIGNED_ADDR_IN(4'h1),
	.ASSIGNED_ADDR_OUT(),
	.ASSIGNED_ADDR_VALID(1'b1),
	.ASSIGNED_ADDR_WRITE(),
	.ASSIGNED_ADDR_INVALIDn()
);

endmodule
