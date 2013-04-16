
/* Verilog implementation of MBUS
 *
 * This block is the new bus controller, maintaining the same interface
 * as the previous I2C controller. However, the current implementation of
 * MBUS makes certain assumptions about the transmissions:
 *
 * 1. The transmission each round is always 32-bits, i.e. TX_DATA is 32-bit
 * wide. This could be changed in the definitions file include/mbus_def.v
 *
 * 2. Transmissions only use short (8-bit) addresses.
 *
 * In addition, MBUS adds new features:
 *
 * 1. The additional PRIORITY input. This input sets the transmission
 * priority. If the PRIORITY input has been asserted, it gives additional
 * flexibility for the lower layer to win bus arbitration.
 *
 * 2. TX_PEND, RX_PEND. These inputs indicate more data coming after first
 * transmission, i.e. if TX_REQ and TX_PEND are asserted at the same time,
 * when the MBUS controller latches the inputs the BUS controller knows more
 * data to the same destination will follow. If the next TX_REQ does not assert
 * in time, the bus controller experiences a TX_FAIL (tx buffer underflow).
 * Similarly for RX_PEND, if RX_REQ is asserted the layer controller must also
 * monitorthe RX_PEND signal, which indicates more data for the same message
 * follows.
 *
 * 3. The broadcast message. Every layer in MBUS will receive and acknowledge
 * broadcast messages. The destination address of broadcast message is 0x00.
 *
 * To create a simple node that wires up to an old layer controller that
 * generates data in 32-bit segments:
 *
 * 1. connect all interfaces,
 * 2. connect TX_PEND to 0, every transmit is 32-bits wide
 * 3. float RX_PEND, old layer controller doesn't support this
 * 4. connect PRIORITU to 0, every transmission is a regular transmission
 * 5. set corresponding address and address mask by parameter, the address
 *    mask indicates which bits are comparing to:
 * i.e. ADDRESS_MASK = 8'hff, all 8-bits of address must match.
 * i.e. ADDRESS_MASK = 8'hf0, compare only upper 4-bit of address (from MSB)
 * 
 *
 * Last modified date: 04/09 '13
 * Last modified by: Ye-sheng Kuo <samkuo@umich.edu>
 * --------------------------------------------------------------------------
 * IMPORTANT: This module only works for RX only layers, not able to transmit
 * 			at this point.
 * --------------------------------------------------------------------------
 * Update log:
 * 4/16 '13
 * fixed reset state for control node, since control node has different sleep
 * controller, it resets bus controller before clk chain ticks. Thus, it
 * should go to BUS_ILDE state for control node
 * 4/15 '13
 * remove BUS_PWR_OVERRIDE port
 * 4/14 '13
 * Add power related signals, these signals are only for simulation, in real
 * setting, the isolation block will assert these signals to layer controller
 * Add a BUS_PWR_OVERRIDE port, this signal indicates ctrl_wrapper to switch
 * the mux
 * 4/09 '13
 * changed to 32-bit long and short address scheme, 
 * add external int, 
 * 3/16 '13
 * Add power gated signals, move reset state to RX_ADDR
 * 3/6 '13
 * switch clock mux to posedge edge trigger, clock holds at high if a node request 
 * interrupt, bypass clock once interrupt occurred
 * */

`include "include/mbus_def.v"

module mbus_node(
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

`include "include/mbus_func.v"

parameter ADDRESS = 20'habcde;
parameter ADDRESS_MASK = {(`PRFIX_WIDTH){1'b1}};
parameter ADDRESS_MASK_SHORT = {`DYNA_WIDTH{1'b1}};

// Node mode
parameter MODE_TX_NON_PRIO = 2'd0;
parameter MODE_TX = 2'd1;
parameter MODE_RX = 2'd2;
parameter MODE_FWD = 2'd3;

// BUS state
parameter BUS_IDLE = 0;
parameter BUS_ARBITRATE = 1;
parameter BUS_PRIO = 2;
parameter BUS_ADDR = 3;
parameter BUS_DATA_RX_ADDI = 4;
parameter BUS_DATA = 5;
parameter BUS_DATA_RX_CHECK = 6;
parameter BUS_REQ_INTERRUPT = 7;
parameter BUS_CONTROL0 = 8;
parameter BUS_CONTROL1 = 9;
parameter BUS_BACK_TO_IDLE = 10;
parameter NUM_OF_BUS_STATE = 11;

// Address enumeration response type
parameter ADDR_ENUM_RESPOND_T1 = 2'b00;
parameter ADDR_ENUM_RESPOND_T2 = 2'b10;
parameter ADDR_ENUM_RESPOND_NONE = 2'b11;

// TX broadcast data length
parameter LENGTH_1BYTE = 2'b00;
parameter LENGTH_2BYTE = 2'b01;
parameter LENGTH_3BYTE = 2'b10;
parameter LENGTH_4BYTE = 2'b11;

parameter RX_ABOVE_TX = 1'b1;
parameter RX_BELOW_TX = 1'b0;

// override this parameter to "1'b1" if the node is master
parameter MASTER_NODE = 1'b0;
// override this parameter to "1'b1" if the layer is CPU
parameter CPU_LAYER = 1'b0;

wire [1:0] CONTROL_BITS = `CONTROL_SEQ;	// EOM?, ~ACK?

// general registers
reg		[1:0] mode, next_mode, mode_neg, mode_temp;
reg		[log2(NUM_OF_BUS_STATE-1)-1:0] bus_state, next_bus_state, bus_state_neg;
reg		[log2(`DATA_WIDTH-1)-1:0] bit_position, next_bit_position; 
reg		req_interrupt, next_req_interrupt;
reg		out_reg_pos, next_out_reg_pos, out_reg_neg;

// tx registers
reg		[`ADDR_WIDTH-1:0] ADDR, next_addr;
reg		[`DATA_WIDTH-1:0] DATA, next_data;
reg		tx_pend, next_tx_pend;
reg		tx_underflow, next_tx_underflow;
reg		ctrl_bit_buf, next_ctrl_bit_buf;

// rx registers
reg		[`ADDR_WIDTH-1:0] next_rx_addr;
reg		[`DATA_WIDTH-1:0] next_rx_data; 
reg		[`DATA_WIDTH+1:0] rx_data_buf, next_rx_data_buf;
reg		next_rx_fail;

// address enumation registers
reg		[1:0] enum_addr_resp, next_enum_addr_resp;
reg		next_assigned_addr_write;
reg		next_assigned_addr_invalidn;

// interrupt register
reg		BUS_INT_RSTn;
wire	BUS_INT;

// interface registers
reg		next_tx_ack;
reg		next_tx_fail;
reg		next_tx_success;
reg		next_rx_req;
reg		next_rx_pend;

wire	addr_bit_extract = ((ADDR  & (1'b1<<bit_position))==0)? 1'b0 : 1'b1;
wire	data_bit_extract = ((DATA & (1'b1<<bit_position))==0)? 1'b0 : 1'b1;
reg		[1:0] addr_match_temp;
wire	address_match = (addr_match_temp[1] | addr_match_temp[0]);

// Broadcast processing
reg		[`BROADCAST_CMD_WIDTH -1:0] rx_broadcast_command;
wire	rx_long_addr_en = (RX_ADDR[`ADDR_WIDTH-1:`ADDR_WIDTH-4]==4'hf)? 1'b1 : 1'b0;
wire	tx_long_addr_en = (TX_ADDR[`ADDR_WIDTH-1:`ADDR_WIDTH-4]==4'hf)? 1'b1 : 1'b0;
reg		tx_broadcast;
reg		[1:0] tx_dat_length, rx_dat_length;
reg		rx_position, rx_dat_length_valid;
reg		wakeup_req;
wire	[`DATA_WIDTH-1:0] broadcast_addr = `BROADCAST_ADDR;
wire	[`DATA_WIDTH-1:0] rx_data_buf_proc = (rx_dat_length_valid)? (rx_position==RX_BELOW_TX)? rx_data_buf[`DATA_WIDTH-1:0] : rx_data_buf[`DATA_WIDTH+1:2] : {`DATA_WIDTH{1'b0}};

// Power gating related signals
`ifdef POWER_GATING
wire 	RESETn_local = (RESETn & (~RELEASE_RST_FROM_SLEEP_CTRL));
`else
wire	RESETn_local = RESETn;
`endif

`ifdef POWER_GATING
reg		[1:0] powerup_seq_fsm;
reg		shutdown, next_shutdown;
reg		ext_int;
`endif

wire	[15:0] layer_slot = (1'b1<<ASSIGNED_ADDR_IN);

// Assignments
assign RX_BROADCAST = addr_match_temp[0];
assign ASSIGNED_ADDR_OUT = DATA[`DYNA_WIDTH-1:0];

// Node priority
// Used only when the BUS_STATE == BUS_PRIO, determine the node should be RX or TX
always @ *
begin
	mode_temp = MODE_RX;
	if (mode==MODE_TX_NON_PRIO)
	begin
		// Other node request priority,
		if (DIN & (~PRIORITY))
			mode_temp = MODE_RX;
		else
			mode_temp = MODE_TX;
	end
	else
	begin
		// the node won first trial doesn't request priority
		if (TX_REQ & PRIORITY & (~DIN))
			mode_temp = MODE_TX;
		else
			mode_temp = MODE_RX;
	end
end
// End of node priority

// TX Broadcast
// For some boradcast message, TX node should take apporiate action, ex: all node sleep
always @ *
begin
	tx_broadcast = 0;
	if (tx_long_addr_en)
	begin
		if (TX_ADDR[`DATA_WIDTH-1:`FUNC_WIDTH]==broadcast_addr[`DATA_WIDTH-1:`FUNC_WIDTH])
			tx_broadcast = 1;
	end
	else
	begin
		if (TX_ADDR[`SHORT_ADDR_WIDTH-1:`FUNC_WIDTH]==broadcast_addr[`SHORT_ADDR_WIDTH-1:`FUNC_WIDTH])
			tx_broadcast = 1;
	end
end
// End of TX broadcast

// Wake up control
// What type of message should wake up the layer controller (LC)
always @ *
begin
	wakeup_req = 0;
	// normal messages
	if (~RX_BROADCAST)
		wakeup_req = address_match;
	else
	begin
		// which channels should wake up
		case (RX_ADDR[`FUNC_WIDTH-1:0])
			`CHANNEL_POWER:
			begin
				case (rx_data_buf[`BROADCAST_CMD_WIDTH-1:0])
					`CMD_CHANNEL_POWER_ALL_WAKE: begin wakeup_req = 1; end
				endcase
			end
			`CHANNEL_ENUM: begin wakeup_req = 1; end
			default: begin end
		endcase
	end
end
// End of Wake up control

// Address compare
// This block determine the incoming message has match the address or not
always @ *
begin
	addr_match_temp = 2'b00;
	if (rx_long_addr_en)
	begin
		if (RX_ADDR[`DATA_WIDTH-1:`FUNC_WIDTH]==broadcast_addr[`DATA_WIDTH-1:`FUNC_WIDTH])
			addr_match_temp[0] = 1;

		if (((RX_ADDR[`DATA_WIDTH-`RSVD_WIDTH-1:`FUNC_WIDTH] ^ ADDRESS) & ADDRESS_MASK)==0)
			addr_match_temp[1] = 1;
		
	end
	// short address assigned
	else
	begin
		if (RX_ADDR[`SHORT_ADDR_WIDTH-1:`FUNC_WIDTH]==broadcast_addr[`SHORT_ADDR_WIDTH-1:`FUNC_WIDTH])
			addr_match_temp[0] = 1;

		if (ASSIGNED_ADDR_VALID)
		begin
			if (((RX_ADDR[`SHORT_ADDR_WIDTH-1:`FUNC_WIDTH] ^ ASSIGNED_ADDR_IN) & ADDRESS_MASK_SHORT)==0)
				addr_match_temp[1] = 1;
		end
		
	end
end
// End of address compare

// TX broadcast command length
// This only take care the broadcast command issued from layer controller
// CANNOT use this in self generate enumerate response
always @ *
begin
	tx_dat_length = LENGTH_4BYTE;
	if (tx_broadcast)
	begin
		case (ADDR[`FUNC_WIDTH-1:0])
			`CHANNEL_ENUM:
			begin
				case (DATA[`DATA_WIDTH-1:`DATA_WIDTH-`BROADCAST_CMD_WIDTH])
					`CMD_CHANNEL_ENUM_QUERRY: 		begin tx_dat_length = LENGTH_1BYTE; end
					`CMD_CHANNEL_ENUM_RESPONSE: 	begin tx_dat_length = LENGTH_4BYTE; end
					`CMD_CHANNEL_ENUM_ENUMERATE: 	begin tx_dat_length = LENGTH_1BYTE; end
					`CMD_CHANNEL_ENUM_INVALIDATE:	begin tx_dat_length = LENGTH_1BYTE; end
				endcase
			end

			`CHANNEL_POWER:
			begin
				case (DATA[`DATA_WIDTH-1:`DATA_WIDTH-`BROADCAST_CMD_WIDTH])
					`CMD_CHANNEL_POWER_ALL_SLEEP: 		begin tx_dat_length = LENGTH_1BYTE; end
					`CMD_CHANNEL_POWER_ALL_WAKE: 		begin tx_dat_length = LENGTH_1BYTE; end
					`CMD_CHANNEL_POWER_SEL_SLEEP: 		begin tx_dat_length = LENGTH_3BYTE; end
					`CMD_CHANNEL_POWER_SEL_SLEEP_FULL: 	begin tx_dat_length = LENGTH_4BYTE; end
					`CMD_CHANNEL_POWER_SEL_WAKE: 		begin tx_dat_length = LENGTH_3BYTE; end	
				endcase
			end
		endcase
	end
end

// This block used to determine the received data length.
// only broadcast can be any byte aligned
// otherwise, regular message has to be word aligned
always @ *
begin
	rx_dat_length = LENGTH_4BYTE;
	rx_dat_length_valid = 0;
	rx_position = RX_ABOVE_TX;
	case (bit_position)
		1: begin rx_dat_length = LENGTH_4BYTE; rx_dat_length_valid = 1; rx_position = RX_BELOW_TX; end
		(`DATA_WIDTH-1'b1): begin rx_dat_length = LENGTH_4BYTE; rx_dat_length_valid = 1; rx_position = RX_ABOVE_TX; end

		9: begin rx_dat_length = LENGTH_3BYTE; if (RX_BROADCAST) rx_dat_length_valid = 1; rx_position = RX_BELOW_TX; end
		7: begin rx_dat_length = LENGTH_3BYTE; if (RX_BROADCAST) rx_dat_length_valid = 1; rx_position = RX_ABOVE_TX; end

		17: begin rx_dat_length = LENGTH_2BYTE; if (RX_BROADCAST) rx_dat_length_valid = 1; rx_position = RX_BELOW_TX; end
		15: begin rx_dat_length = LENGTH_2BYTE; if (RX_BROADCAST) rx_dat_length_valid = 1; rx_position = RX_ABOVE_TX; end

		25: begin rx_dat_length = LENGTH_1BYTE; if (RX_BROADCAST) rx_dat_length_valid = 1; rx_position = RX_BELOW_TX; end
		23: begin rx_dat_length = LENGTH_1BYTE; if (RX_BROADCAST) rx_dat_length_valid = 1; rx_position = RX_ABOVE_TX; end
	endcase
end

always @ *
begin
	rx_broadcast_command = rx_data_buf_proc[`DATA_WIDTH-1:`DATA_WIDTH-`BROADCAST_CMD_WIDTH];
	case (rx_dat_length)
		LENGTH_4BYTE: begin rx_broadcast_command = rx_data_buf_proc[`DATA_WIDTH-1:`DATA_WIDTH-`BROADCAST_CMD_WIDTH]; end
		LENGTH_3BYTE: begin rx_broadcast_command = rx_data_buf_proc[`DATA_WIDTH-9:`DATA_WIDTH-`BROADCAST_CMD_WIDTH-8]; end
		LENGTH_2BYTE: begin rx_broadcast_command = rx_data_buf_proc[`DATA_WIDTH-17:`DATA_WIDTH-`BROADCAST_CMD_WIDTH-16]; end
		LENGTH_1BYTE: begin rx_broadcast_command = rx_data_buf_proc[`DATA_WIDTH-25:`DATA_WIDTH-`BROADCAST_CMD_WIDTH-24]; end
	endcase
 
end

always @ (posedge CLKIN or negedge RESETn_local)
begin
	if (~RESETn_local)
	begin
		`ifdef POWER_GATING
		if (MASTER_NODE==1'b1)
			bus_state <= BUS_IDLE;
		else
			bus_state <= BUS_PRIO;
		`else
		bus_state <= BUS_IDLE;
		`endif
		BUS_INT_RSTn <= 1;
	end
	else
	begin
		if (BUS_INT)
		begin
			bus_state <= BUS_CONTROL0;
			BUS_INT_RSTn <= 0;
		end
		else
		begin
			bus_state <= next_bus_state;
			BUS_INT_RSTn <= 1;
		end
	end
end

wire TX_RESP_RSTn = RESETn_local & (~TX_RESP_ACK);

always @ (posedge CLKIN or negedge TX_RESP_RSTn)
begin
	if (~TX_RESP_RSTn)
	begin
		TX_FAIL <= 0;
		TX_SUCC <= 0;
	end
	else
	begin
		TX_FAIL <= next_tx_fail;
		TX_SUCC <= next_tx_success;
	end
end


always @ (posedge CLKIN or negedge RESETn_local)
begin
	if (~RESETn_local)
	begin
		// general registers
		mode <= MODE_RX;
		bit_position <= `ADDR_WIDTH - 1'b1;
		req_interrupt <= 0;
		out_reg_pos <= 0;
		// Transmitter registers
		ADDR <= 0;
		DATA <= 0;
		tx_pend <= 0;
		tx_underflow <= 0;
		ctrl_bit_buf <= 0;
		// Receiver register
		RX_ADDR <= 0;
		RX_DATA <= 0;
		rx_data_buf <= 0;
		// Interface registers
		TX_ACK <= 0;
		RX_REQ <= 0;
		RX_PEND <= 0;
		RX_FAIL <= 0;
		`ifdef POWER_GATING
		// power gated related signal
		shutdown <= 0;
		`endif
		// address enumeration
		enum_addr_resp <= ADDR_ENUM_RESPOND_NONE;
		// address enumeration interface
		ASSIGNED_ADDR_WRITE <= 0;
		ASSIGNED_ADDR_INVALIDn <= 1;
	end
	else
	begin
		// general registers
		mode <= next_mode;
		if (~BUS_INT)
		begin
			bit_position <= next_bit_position;
			rx_data_buf <= next_rx_data_buf;
			// Receiver register
			RX_ADDR <= next_rx_addr;
			RX_DATA <= next_rx_data;
			RX_REQ <= next_rx_req;
			RX_PEND <= next_rx_pend;
			RX_FAIL <= next_rx_fail;
		end
		req_interrupt <= next_req_interrupt;
		out_reg_pos <= next_out_reg_pos;
		// Transmitter registers
		ADDR <= next_addr;
		DATA <= next_data;
		tx_pend <= next_tx_pend;
		tx_underflow <= next_tx_underflow;
		ctrl_bit_buf <= next_ctrl_bit_buf;
		// Interface registers
		TX_ACK <= next_tx_ack;
		`ifdef POWER_GATING
		// power gated related signal
		shutdown <= next_shutdown;
		`endif
		// address enumeration
		enum_addr_resp <= next_enum_addr_resp;
		// address enumeration interface
		ASSIGNED_ADDR_WRITE <= next_assigned_addr_write;
		ASSIGNED_ADDR_INVALIDn <= next_assigned_addr_invalidn;
	end
end

always @ *
begin
	// general registers
	next_mode = mode;
	next_bus_state = bus_state;
	next_bit_position = bit_position;
	next_req_interrupt = req_interrupt;
	next_out_reg_pos = out_reg_pos;

	// Transmitter registers
	next_addr = ADDR;
	next_data = DATA;
	next_tx_pend = tx_pend;
	next_tx_underflow = tx_underflow;
	next_ctrl_bit_buf = ctrl_bit_buf;

	// Receiver register
	next_rx_addr = RX_ADDR;
	next_rx_data = RX_DATA;
	next_rx_fail = RX_FAIL;
	next_rx_data_buf = rx_data_buf;

	// Interface registers
	next_rx_req = RX_REQ;
	next_rx_pend = RX_PEND;
	next_tx_fail = TX_FAIL;
	next_tx_success = TX_SUCC;
	next_tx_ack = TX_ACK;

	// Address enumeration
	next_enum_addr_resp = enum_addr_resp;

	// Address enumeratio interface
	next_assigned_addr_write = 0;
	next_assigned_addr_invalidn = 1;

	// Asynchronous interface
	if (TX_ACK & (~TX_REQ))
		next_tx_ack = 0;
	
	if (RX_REQ & RX_ACK)
	begin
		next_rx_req = 0;
		next_rx_pend = 0;
	end

	if (RX_FAIL & RX_ACK)
	begin
		next_rx_fail = 0;
	end

	`ifdef POWER_GATING
	// power gating signals
	next_shutdown = shutdown;
	`endif

	case (bus_state)
		BUS_IDLE:
		begin
			if (DIN^DOUT)
				next_mode = MODE_TX_NON_PRIO;
			else
				next_mode = MODE_RX;
			// general registers
			next_bus_state = BUS_ARBITRATE;
			next_bit_position = `ADDR_WIDTH - 1'b1;
		end

		BUS_ARBITRATE:
		begin
			next_bus_state = BUS_PRIO;
		end

		BUS_PRIO:
		begin
			next_mode = mode_temp;
			next_bus_state = BUS_ADDR;
			// no matter this node wins the arbitration or not, must clear
			// type T1
			if (enum_addr_resp== ADDR_ENUM_RESPOND_T1)
				next_enum_addr_resp = ADDR_ENUM_RESPOND_NONE;

			if (mode_temp==MODE_TX)
			begin
				case (enum_addr_resp)
					// respond to enumeration
					ADDR_ENUM_RESPOND_T1:
					begin
						next_bit_position = `SHORT_ADDR_WIDTH - 1'b1;
						next_assigned_addr_write = 1;
					end

					// respond to query
					ADDR_ENUM_RESPOND_T2:
					begin
						next_bit_position = `SHORT_ADDR_WIDTH - 1'b1;
						next_enum_addr_resp = ADDR_ENUM_RESPOND_NONE;
					end

					// TX initiated from layer controller
					default:
					begin
						next_addr = TX_ADDR;
						next_data = TX_DATA;
						next_tx_ack = 1;
						next_tx_pend = TX_PEND;
						if (tx_long_addr_en)
							next_bit_position = `ADDR_WIDTH - 1'b1;
						else
							next_bit_position = `SHORT_ADDR_WIDTH - 1'b1;
					end
				endcase
			end
			else
			// RX mode
			begin
				next_rx_data_buf = 0;
				next_rx_addr = 0;
			end
		end

		BUS_ADDR:
		begin
			case (mode)
				MODE_TX:
				begin
					if (bit_position)
						next_bit_position = bit_position - 1'b1;
					else
					begin
						next_bit_position = `DATA_WIDTH - 1'b1;
						next_bus_state = BUS_DATA;
					end
				end

				MODE_RX:
				begin
					// short address
					if ((bit_position==`ADDR_WIDTH-3'd5)&&(RX_ADDR[3:0]!=4'hf))
						next_bit_position = `SHORT_ADDR_WIDTH - 3'd6;
					else
					begin
						if (bit_position)
							next_bit_position = bit_position - 1'b1;
						else
						begin
							next_bit_position = `DATA_WIDTH - 1'b1;
							next_bus_state = BUS_DATA_RX_ADDI;
						end
					end
					next_rx_addr = {RX_ADDR[`ADDR_WIDTH-2:0], DIN};
				end
			endcase
		end

		BUS_DATA_RX_ADDI:
		begin
			next_rx_data_buf = {rx_data_buf[`DATA_WIDTH:0], DIN};
			next_bit_position = bit_position - 1'b1;
			`ifdef POWER_GATING
			next_shutdown = 0;
			`endif
			if (bit_position==(`DATA_WIDTH-2'b10))
			begin
				next_bus_state = BUS_DATA;
				next_bit_position = `DATA_WIDTH - 1'b1;
			end
			if (address_match==0)
				next_mode = MODE_FWD;
		end

		BUS_DATA:
		begin
			case (mode)
				MODE_TX:
				begin
					// support variable tx length for broadcast messages
					if (((tx_dat_length==LENGTH_4BYTE)&&(bit_position>0))||((tx_dat_length==LENGTH_3BYTE)&&(bit_position>8))||((tx_dat_length==LENGTH_2BYTE)&&(bit_position>16))||((tx_dat_length==LENGTH_1BYTE)&&(bit_position>24)))
					//if (bit_position)
						next_bit_position = bit_position - 1'b1;
					else
					begin
						next_bit_position = `DATA_WIDTH - 1'b1;
						case ({tx_pend, TX_REQ})
							// continue next word
							2'b11:
							begin
								next_tx_pend = TX_PEND;
								next_data = TX_DATA;
								next_tx_ack = 1;
							end
							
							// underflow
							2'b10:
							begin
								next_bus_state = BUS_REQ_INTERRUPT;
								next_tx_underflow = 1;
								next_req_interrupt = 1;
								next_tx_fail = 1;
							end

							default:
							begin
								next_bus_state = BUS_REQ_INTERRUPT;
								next_req_interrupt = 1;
							end
						endcase
					end
				end

				MODE_RX:
				begin
					next_rx_data_buf = {rx_data_buf[`DATA_WIDTH:0], DIN};
					if (bit_position)
						next_bit_position = bit_position - 1'b1;
					else
					begin
						if (RX_REQ)
						begin
							// RX overflow
							next_bus_state = BUS_REQ_INTERRUPT;
							next_req_interrupt = 1;
							next_rx_fail = 1;
						end
						else
						begin
							next_bus_state = BUS_DATA_RX_CHECK;
							next_bit_position = `DATA_WIDTH - 1'b1;
						end
					end
				end

			endcase
		end

		BUS_DATA_RX_CHECK:
		begin
			next_bit_position = bit_position - 1'b1;
			next_rx_data_buf = {rx_data_buf[`DATA_WIDTH:0], DIN};
			next_rx_req = 1;
			next_rx_pend = 1;
			next_rx_data = rx_data_buf[`DATA_WIDTH+1:2];
			next_bus_state = BUS_DATA;
		end

		BUS_REQ_INTERRUPT:
		begin
		end

		BUS_CONTROL0:
		begin
			next_bus_state = BUS_CONTROL1;
			next_ctrl_bit_buf = DIN;

			case (mode)
				MODE_TX:
				begin
					if (req_interrupt)
					begin
						// Prevent wire floating
						next_out_reg_pos = ~CONTROL_BITS[0];
						if (tx_broadcast)
						begin
							case (ADDR[`FUNC_WIDTH-1:0])
								`CHANNEL_POWER:
								begin
									case (DATA[`DATA_WIDTH-1:`DATA_WIDTH-`BROADCAST_CMD_WIDTH ])
										`CMD_CHANNEL_POWER_ALL_SLEEP:
										begin
											next_shutdown = 1;
										end

										`CMD_CHANNEL_POWER_SEL_SLEEP:
										begin
											if ((DATA[27:12]&layer_slot)>0)
												next_shutdown = 1;
										end

										`CMD_CHANNEL_POWER_SEL_SLEEP_FULL:
										begin
											if (((DATA[`PRFIX_WIDTH+3:4] ^  ADDRESS) & ADDRESS_MASK)==0)
												next_shutdown = 1;
										end
									endcase
								end
							endcase
						end
					end
					else
						next_tx_fail = 1;
				end

				MODE_RX:
				begin
					if (req_interrupt)
						next_out_reg_pos = ~CONTROL_BITS[0];
					else
					begin
						// End of Message
						// correct ending state
						// rx above tx = 31
						// rx below tx = 1
						if ((DIN==CONTROL_BITS[1])&&(rx_dat_length_valid))
						begin
							// rx overflow
							if (RX_REQ)
							begin
								next_out_reg_pos = ~CONTROL_BITS[0];
								next_rx_fail = 1;
							end
							else
							// assert rx_req if not a broadcast
							begin
								next_rx_data = rx_data_buf_proc;
								next_out_reg_pos = CONTROL_BITS[0];
								if (~RX_BROADCAST)
									next_rx_req = 1;
								next_rx_pend = 0;
							end

							// broadcast message 
							if (RX_BROADCAST)
							begin
								// assert broadcast rx_req only in CPU layer
								if ((CPU_LAYER==1'b1)&&(~RX_REQ))
									next_rx_req = 1;
								// broadcast channel
								case (RX_ADDR[`FUNC_WIDTH-1:0])
									`CHANNEL_ENUM:
									begin
										case (rx_broadcast_command)
											// any node should report its full prefix and short prefix (dynamic allocated address)
											// Pad "0" if the dynamic address is invalid
											`CMD_CHANNEL_ENUM_QUERRY:
											begin
												// this node doesn't have a valid short address, active low
												next_enum_addr_resp = ADDR_ENUM_RESPOND_T2;
												next_addr = broadcast_addr[`SHORT_ADDR_WIDTH-1:0];
												next_data = ((`CMD_CHANNEL_ENUM_RESPONSE<<(`DATA_WIDTH-`BROADCAST_CMD_WIDTH)) | (ADDRESS<<`DYNA_WIDTH) | ASSIGNED_ADDR_IN);
											end

											// request arbitration, set short prefix if successed
											`CMD_CHANNEL_ENUM_ENUMERATE:
											begin
												if (~ASSIGNED_ADDR_VALID)
												begin
													next_enum_addr_resp = ADDR_ENUM_RESPOND_T1;
													next_addr = broadcast_addr[`SHORT_ADDR_WIDTH-1:0];
													next_data = ((`CMD_CHANNEL_ENUM_RESPONSE<<(`DATA_WIDTH-`BROADCAST_CMD_WIDTH)) | (ADDRESS<<`DYNA_WIDTH) | rx_data_buf_proc[`DYNA_WIDTH-1:0]);
												end
											end

											`CMD_CHANNEL_ENUM_INVALIDATE:
											begin
												case (rx_data_buf_proc[`DYNA_WIDTH-1:0])
													{`DYNA_WIDTH{1'b1}}: begin next_assigned_addr_invalidn  = 0; end
													ASSIGNED_ADDR_IN: begin next_assigned_addr_invalidn  = 0; end
													default: begin end
												endcase
											end
										endcase
									end

									`CHANNEL_POWER:
									begin
										// PWR Command
										case (rx_broadcast_command)
											`CMD_CHANNEL_POWER_ALL_SLEEP:
											begin
												next_shutdown = 1;
											end

											`CMD_CHANNEL_POWER_SEL_SLEEP:
											begin
												if ((rx_data_buf_proc[19:4]&layer_slot)>0)
													next_shutdown = 1;
											end

											`CMD_CHANNEL_POWER_SEL_SLEEP_FULL:
											begin
												if (((rx_data_buf_proc[`PRFIX_WIDTH+3:4] ^  ADDRESS) & ADDRESS_MASK)==0)
													next_shutdown = 1;
											end
										endcase
									end

									// shoud only be active at master
									`CHANNEL_CTRL:
									begin
										if (MASTER_NODE==1'b1)
											next_rx_req = 1;
									end
								endcase
							end // endif rx_broadcast
						end	// endif valid reception
						else
						// invalid data length or invalid EOM
						begin
							next_out_reg_pos = ~CONTROL_BITS[0];
							`ifdef POWER_GATING
							if (~ext_int)
								next_rx_fail = 1;
							`else
								next_rx_fail = 1;
							`endif
						end
					end
				end

			endcase

		end

		BUS_CONTROL1:
		begin
			next_bus_state = BUS_BACK_TO_IDLE;
			if (req_interrupt)
			begin
				if ((mode==MODE_TX)&&(~tx_underflow))
				begin
					// ACK received
					if ({ctrl_bit_buf, DIN}==CONTROL_BITS)
						next_tx_success = 1;
					else
						next_tx_fail = 1;
				end
			end
		end

		BUS_BACK_TO_IDLE:
		begin
			next_bus_state = BUS_IDLE;
			next_req_interrupt = 0;
			next_mode = MODE_RX;
			next_tx_underflow = 0;
		end
	endcase
end

`ifdef POWER_GATING
always @ (negedge CLKIN or negedge RESETn_local)
begin
	if (~RESETn_local)
	begin
		powerup_seq_fsm <= 0;
		POWER_ON_TO_LAYER_CTRL <= `IO_HOLD;
		RELEASE_CLK_TO_LAYER_CTRL <= `IO_HOLD;
		RELEASE_ISO_TO_LAYER_CTRL <= `IO_HOLD;
		RELEASE_RST_TO_LAYER_CTRL <= `IO_HOLD;
		SLEEP_REQUEST_TO_SLEEP_CTRL <= 0;
		ext_int <= 0;
		CLR_EXT_INT <= 0;
	end
	else
	begin
		if (CLR_EXT_INT & (~EXTERNAL_INT))
			CLR_EXT_INT <= 0;

		// master node should wake up layer controller "early"
		if (((bus_state==BUS_ADDR)&&(MASTER_NODE==1'b0))||((bus_state==BUS_IDLE)&&(MASTER_NODE==1'b1)))
		begin
			if (EXTERNAL_INT)
			begin
				ext_int <= 1;
				powerup_seq_fsm <= 1;
				POWER_ON_TO_LAYER_CTRL <= `IO_RELEASE;
			end
			else
				powerup_seq_fsm <= 0;
		end

		if (bus_state==BUS_CONTROL1)
			ext_int <= 0;


		if (ext_int)
		begin
			case (powerup_seq_fsm)
				1: begin RELEASE_CLK_TO_LAYER_CTRL <= `IO_RELEASE; CLR_EXT_INT <= 1; powerup_seq_fsm <= powerup_seq_fsm + 1'b1; end
				2: begin RELEASE_ISO_TO_LAYER_CTRL <= `IO_RELEASE; powerup_seq_fsm <= powerup_seq_fsm + 1'b1; end
				3: begin RELEASE_RST_TO_LAYER_CTRL <= `IO_RELEASE; powerup_seq_fsm <= powerup_seq_fsm + 1'b1; end
				0: begin end
			endcase
		end
		else
		begin
			case (bus_state)
				BUS_DATA:
				begin
					case (powerup_seq_fsm)
						0:
						begin
							// only check the wakeup_req after received broadcast command
							// FSM stays at BUS_ADDR_ADDI for 2 cycles before entering BUS_DATA
							// the complete command should received after `DATA_WIDTH (32) - `BROADCAST_CMD_WIDTH(4) + 2(2 BUS_ADDR_ADDI) - 1
							if ((wakeup_req)&&(bit_position==`DATA_WIDTH-`BROADCAST_CMD_WIDTH+1))
							begin
								POWER_ON_TO_LAYER_CTRL <= `IO_RELEASE;
								powerup_seq_fsm <= powerup_seq_fsm + 1'b1;
							end
						end

						1:
						begin
							RELEASE_CLK_TO_LAYER_CTRL <= `IO_RELEASE;
							powerup_seq_fsm <= powerup_seq_fsm + 1'b1;
						end

						2:
						begin
							RELEASE_ISO_TO_LAYER_CTRL <= `IO_RELEASE;
							powerup_seq_fsm <= powerup_seq_fsm + 1'b1;
						end

						3:
						begin
							RELEASE_RST_TO_LAYER_CTRL <= `IO_RELEASE;
						end
					endcase
				end

				BUS_CONTROL1:
				begin
					if (shutdown)
					begin
						SLEEP_REQUEST_TO_SLEEP_CTRL <= 1;
						RELEASE_ISO_TO_LAYER_CTRL <= `IO_HOLD;
					end
				end

				/*
				BUS_BACK_TO_IDLE:
				begin
					// These signals should be taken care in isolation blocks
					// i.e. SLEEP_REQUEST_TO_SLEEP_CTRL asserted, isolation
					// asserts these
					//
					// only useful to simulate a layer w/o isolation block
					if (shutdown)
					begin
						POWER_ON_TO_LAYER_CTRL <= `IO_HOLD;
						RELEASE_CLK_TO_LAYER_CTRL <= `IO_HOLD;
						RELEASE_RST_TO_LAYER_CTRL <= `IO_HOLD;
					end
				end
				*/
			endcase
		end
	end
end
`endif

always @ (negedge CLKIN or negedge RESETn_local)
begin
	if (~RESETn_local)
	begin
		out_reg_neg <= 1;
		`ifdef POWER_GATING
		if (MASTER_NODE==1'b1)
			bus_state_neg <= BUS_IDLE;
		else
			bus_state_neg <= BUS_PRIO;
		`else
		bus_state_neg <= BUS_IDLE;
		`endif

		mode_neg <= MODE_RX;
	end
	else
	begin
		if (req_interrupt & BUS_INT)
			bus_state_neg <= BUS_CONTROL0;
		else
			bus_state_neg <= bus_state;

		mode_neg <= mode;

		case (bus_state)
			BUS_ADDR:
			begin
				if (mode==MODE_TX)
					out_reg_neg <= addr_bit_extract;
			end

			BUS_DATA:
			begin
				if (mode==MODE_TX)
					out_reg_neg <= data_bit_extract;
			end

			BUS_CONTROL0:
			begin
				if (req_interrupt)
				begin
					if (mode==MODE_TX)
					begin
						if (tx_underflow)
							out_reg_neg <= ~CONTROL_BITS[1];
						else
							out_reg_neg <= CONTROL_BITS[1];
					end
					else
						out_reg_neg <= ~CONTROL_BITS[1];
				end
			end

			BUS_CONTROL1:
			begin
				out_reg_neg <= out_reg_pos;
			end

		endcase
	end
end

always @ *
begin
	DOUT = DIN;
	case (bus_state_neg)
		BUS_IDLE:
		begin
			DOUT = ((~TX_REQ) & DIN & enum_addr_resp[0]);
		end

		BUS_ARBITRATE:
		begin
			if (mode_neg==MODE_TX_NON_PRIO)
				DOUT = 0;
		end

		BUS_PRIO:
		begin
			if (mode_neg==MODE_TX_NON_PRIO)
			begin
				if (PRIORITY)
					DOUT = 1;
				else
					DOUT = 0;
			end
			else if ((mode_neg==MODE_RX)&&(PRIORITY & TX_REQ))
				DOUT = 1;
		end

		BUS_ADDR:
		begin
			// Drive value only if interrupt is low
			if (~BUS_INT &(mode_neg==MODE_TX))
				DOUT = out_reg_neg;
		end

		BUS_DATA:
		begin
			// Drive value only if interrupt is low
			if (~BUS_INT &(mode_neg==MODE_TX))
				DOUT = out_reg_neg;
		end

		BUS_CONTROL0:
		begin
			if (req_interrupt)
				DOUT = out_reg_neg;
		end

		BUS_CONTROL1:
		begin
			if (mode_neg==MODE_RX)
				DOUT = out_reg_neg;
			else if (req_interrupt)
				DOUT = out_reg_neg;
		end

		BUS_BACK_TO_IDLE:
		begin
			DOUT = ((~TX_REQ) & DIN & enum_addr_resp[0]);
		end

	endcase
end

always @ *
begin
	// forward clock once interrupt occurred
	CLKOUT = CLKIN;
	if ((bus_state==BUS_REQ_INTERRUPT)&&(~BUS_INT))
		CLKOUT = 1;
end

mbus_swapper swapper0(
	// inputs
	.CLK(CLKIN),
    .RESETn(RESETn_local),
    .DATA(DIN),
    .INT_FLAG_RESETn(BUS_INT_RSTn),
   	//Outputs
    .LAST_CLK(),
    .INT_FLAG(BUS_INT));

endmodule
