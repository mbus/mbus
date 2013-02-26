
`include "include/ulpb_def.v"

module ulpb_node32(
	input CLKIN, 
	input RESETn, 
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
parameter ADDRESS_MASK = 8'hff;
// if MULTI_ADDR = 1, check additional address (ADDRESS2)
parameter MULTI_ADDR = 1'b1;	
parameter ADDRESS2 = 8'hef;
parameter ADDRESS_MASK2 = 8'hff;

// Node mode
parameter MODE_TX_NON_PRIO = 0;
parameter MODE_TX = 1;
parameter MODE_RX = 2;
parameter MODE_FWD = 3;

// BUS state
parameter BUS_IDLE = 0;
parameter BUS_ARBITRATE = 1;
parameter BUS_PRIO = 2;
parameter BUS_ADDR = 3;
parameter BUS_DATA_RX_ADDI = 4;
parameter BUS_DATA = 5;
parameter BUS_REQ_INTERRUPT = 6;
parameter BUS_LEAVE_INTERRUPT = 7;
parameter BUS_CONTROL0 = 8;
parameter BUS_CONTROL1 = 9;
parameter BUS_BACK_TO_IDLE = 11;
parameter BUS_DATA_RX_CHECK = 12;
parameter NUM_OF_BUS_STATE = 13;

wire [1:0] CONTROL_BITS = `CONTROL_SEQ;	// EOM?, ~ACK?

// general registers
reg		[1:0] mode, next_mode, mode_neg;
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

// interrupt register
reg		BUS_INT_RSTn;
wire	BUS_INT_STATE, BUS_INT;

// interface registers
reg		next_tx_ack;
reg		next_tx_fail;
reg		next_tx_success;
reg		next_rx_req;
reg		next_rx_pend;

wire	addr_bit_extract = ((ADDR  & (1'b1<<bit_position))==0)? 1'b0 : 1'b1;
wire	data_bit_extract = ((DATA & (1'b1<<bit_position))==0)? 1'b0 : 1'b1;
reg		address_match;
always @ *
begin
	address_match = 0;
	if (RX_ADDR==`BROADCAST_ADDR)
		address_match = 1;
	
	if (((RX_ADDR ^ ADDRESS) & ADDRESS_MASK)==0)
		address_match = 1;
	else if ((MULTI_ADDR==1'b1) && (((RX_ADDR ^ ADDRESS2) & ADDRESS_MASK2)==0))
		address_match = 1;
end

always @ (posedge CLKIN or negedge RESETn)
begin
	if (~RESETn)
	begin
		bus_state <= BUS_IDLE;
		BUS_INT_RSTn <= 1;
	end
	else
	begin
		if (BUS_INT)
		begin
			bus_state <= BUS_LEAVE_INTERRUPT;
			BUS_INT_RSTn <= 0;
		end
		else
		begin
			bus_state <= next_bus_state;
			BUS_INT_RSTn <= 1;
		end
	end
end

wire TX_RESP_RSTn = RESETn & (~TX_RESP_ACK);

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


always @ (posedge CLKIN or negedge RESETn)
begin
	if (~RESETn)
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
	next_rx_data_buf = rx_data_buf;

	// Interface registers
	next_rx_req = RX_REQ;
	next_rx_pend = RX_PEND;
	next_tx_fail = TX_FAIL;
	next_tx_success = TX_SUCC;
	next_tx_ack = TX_ACK;

	// Asynchronous interface
	if (TX_ACK & (~TX_REQ))
		next_tx_ack = 0;
	
	if (RX_REQ & RX_ACK)
	begin
		next_rx_req = 0;
		next_rx_pend = 0;
	end

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
			if (mode==MODE_TX_NON_PRIO)
			begin
				// Lose Priority
				if (DIN^DOUT)
				begin
					next_mode = MODE_RX;
				end
				// Remain Arbitration
				else
				begin
					next_addr = TX_ADDR;
					next_data = TX_DATA;
					next_mode = MODE_TX;
					next_tx_ack = 1;
					next_tx_pend = TX_PEND;
				end
			end
			else
			begin
				// Win Priority
				if (DIN^DOUT)
				begin
					next_addr = TX_ADDR;
					next_data = TX_DATA;
					next_mode = MODE_TX;
					next_tx_ack = 1;
					next_tx_pend = TX_PEND;
				end
				else
				begin
					next_mode = MODE_RX;
				end
			end
			next_bus_state = BUS_ADDR;
		end

		BUS_ADDR:
		begin
			if (bit_position)
				next_bit_position = bit_position - 1'b1;
			else
			begin
				next_bit_position = `DATA_WIDTH - 1'b1;
				if (mode==MODE_RX)
					next_bus_state = BUS_DATA_RX_ADDI;
				else
					next_bus_state = BUS_DATA;
			end
			if (mode==MODE_RX)
				next_rx_addr = {RX_ADDR[`ADDR_WIDTH-2:0], DIN};
		end

		BUS_DATA_RX_ADDI:
		begin
			next_rx_data_buf = {rx_data_buf[`DATA_WIDTH:0], DIN};
			next_bit_position = bit_position - 1'b1;
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
					if (bit_position)
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
						// RX overflow
						if (RX_REQ)
						begin
							next_bus_state = BUS_REQ_INTERRUPT;
							next_req_interrupt = 1;
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

		BUS_LEAVE_INTERRUPT:
		begin
			next_bus_state = BUS_CONTROL0;
			if ((mode==MODE_TX)&&(~req_interrupt))
				next_tx_fail = 1;
		end

		BUS_CONTROL0:
		begin
			next_bus_state = BUS_CONTROL1;
			next_ctrl_bit_buf = DIN;

			// Prevent wire floating
			if (req_interrupt)
				next_out_reg_pos = ~CONTROL_BITS[0];
			else
			begin
				if (mode==MODE_RX)
				begin
					// End of Message
					if (DIN==CONTROL_BITS[1])
					begin
						// correct ending state
						// rx above tx = 31
						// rx below tx = 1
						if ((bit_position==1)||(bit_position==(`DATA_WIDTH-1'b1)))
						begin
							// RX overflow
							if (RX_REQ)
								next_out_reg_pos = ~CONTROL_BITS[0];
							else
							begin
								next_out_reg_pos = CONTROL_BITS[0];
								next_rx_req = 1;
								next_rx_pend = 0;
								if (BUS_INT_STATE)
									next_rx_data = rx_data_buf[`DATA_WIDTH+1:2];
								else
									next_rx_data = rx_data_buf[`DATA_WIDTH-1:0];
							end
						end
						else
							next_out_reg_pos = ~CONTROL_BITS[0];
					end
					else
						next_out_reg_pos = ~CONTROL_BITS[0];
				end
			end
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

always @ (negedge CLKIN or negedge RESETn)
begin
	if (~RESETn)
	begin
		out_reg_neg <= 1;
		bus_state_neg <= BUS_IDLE;
		mode_neg <= MODE_RX;
	end
	else
	begin
		if (req_interrupt & BUS_INT)
			bus_state_neg <= BUS_LEAVE_INTERRUPT;
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
			DOUT = ((~TX_REQ) & DIN);
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
				if (~PRIORITY)
					DOUT = 0;
				else
					DOUT = DIN;
			end
			else if ((mode_neg==MODE_RX)&&(PRIORITY & TX_REQ))
				DOUT = 1;
		end

		BUS_ADDR:
		begin
			// BUS interrupt happened, forward DIN
			if (mode_neg==MODE_TX)
				DOUT = (((~BUS_INT)&out_reg_neg) | (DIN & BUS_INT));
		end

		BUS_DATA:
		begin
			// BUS interrupt happened, forward DIN
			if (mode_neg==MODE_TX)
				DOUT = (((~BUS_INT)&out_reg_neg) | (DIN & BUS_INT));
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
			DOUT = ((~TX_REQ) & DIN);
		end

	endcase
end

always @ *
begin
	if (bus_state_neg==BUS_REQ_INTERRUPT)
		CLKOUT = 0;
	else
		CLKOUT = CLKIN;
end

ulpb_swapper swapper0(
	// inputs
	.CLK(CLKIN),
    .RESETn(RESETn),
    .DATA(DIN),
    .INT_FLAG_RESETn(BUS_INT_RSTn),
   	//Outputs
    .INT(),
    .LAST_CLK(BUS_INT_STATE),
    .INT_FLAG(BUS_INT));

endmodule
