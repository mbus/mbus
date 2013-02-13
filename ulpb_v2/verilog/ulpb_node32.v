
`include "include/ulpb_def.v"

module ulpb_node32(
	input CLKIN, 
	input RESET, 
	input DIN, 
	output reg CLKOUT,
	output reg DOUT, 
	input [`ADDR_WIDTH-1:0] TX_ADDR, 
	input [`DATA_WIDTH-1:0] TX_DATA, 
	input TX_PEND, 
	input TX_REQ, 
	input PRIORITY,
	output reg TX_ACK, 
	output reg [`ADDR_WIDTH-1:0] RX_ADDR, 
	output reg [`DATA_WIDTH-1:0] RX_DATA, 
	output reg RX_REQ, 
	input RX_ACK, 
	output reg RX_PEND, 
	output reg TX_FAIL, 
	output reg TX_SUCC, 
	input TX_RESP_ACK
);

`include "include/ulpb_func.v"

parameter ADDRESS = 8'hef;
parameter ADDRESS_MASK=8'hff;

// Node mode
parameter MODE_TX_NON_PRIO = 0;
parameter MODE_TX = 1;
parameter MODE_RX = 2;
parameter MODE_FWD = 3;

parameter NUM_OF_BUS_STATE = 10;

// general registers
reg		[log2(NUM_OF_BUS_STATE-1)-1:0] bus_state, next_bus_state;
reg		[log2(NUM_OF_NODE_STATE-1)-1:0] node_state, next_node_state;
reg		[log2(`DATA_WIDTH-1)-1:0] bit_position, next_bit_position; 
reg		[4:0] input_buffer;
reg		out_reg, next_out_reg;
reg		[1:0] mode, next_mode;

// interface registers
reg		next_tx_ack;
reg		next_tx_fail;
reg		next_tx_success;

// tx registers
reg		[`ADDR_WIDTH-1:0] ADDR, next_addr;
reg		[`DATA_WIDTH-1:0] DATA0, next_data0;
reg		tx_pend, next_tx_pend;

// rx registers
reg		[`ADDR_WIDTH-1:0] next_rx_addr;
reg		[`DATA_WIDTH-1:0] next_rx_data; 
reg		[`DATA_WIDTH-1:0] rx_data_out_buf, next_rx_data_buf;
reg		next_rx_req;
reg		next_rx_pend;

wire	addr_bit_extract = ((ADDR  & (1'b1<<bit_position))==0)? 1'b0 : 1'b1;
wire	data0_bit_extract = ((DATA0 & (1'b1<<bit_position))==0)? 1'b0 : 1'b1;
wire	input_buffer_xor = input_buffer[0] ^ input_buffer[1];
wire	address_match = (((RX_ADDR^ADDRESS)&ADDRESS_MASK)==0)? 1'b1 : 1'b0;


// FSM1 changes at every posedge CLK
// always @ (negedge CLKIN)
// 		FSM2 <= FSM1
// always @ *
// case (FSM2)
// 	CLKOUT = 0, CLKOUT = CLKIN:

endmodule
