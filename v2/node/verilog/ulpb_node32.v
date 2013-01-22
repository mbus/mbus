module ulpb_node32(CLK, RESET, DIN, DOUT, TX_ADDR, TX_DATA, TX_PEND, TX_REQ, TX_ACK, RX_ADDR, RX_DATA, RX_REQ, RX_ACK, RX_PEND, TX_FAIL, TX_SUCC, TX_RESP_ACK);

`include "include/ulpb_func.v"

parameter ADDR_WIDTH=8;
parameter DATA_WIDTH=32;
parameter ADDRESS = 8'hab;
parameter ADDRESS_MASK=8'hff;

input 	CLK, RESET, DIN;
output	DOUT;

input	[ADDR_WIDTH-1:0] TX_ADDR;
input	[DATA_WIDTH-1:0] TX_DATA;
input	TX_REQ;
output	TX_ACK;
input	TX_PEND;

output	TX_SUCC;
output	TX_FAIL;
input	TX_RESP_ACK;

output	[ADDR_WIDTH-1:0] RX_ADDR;
output	[DATA_WIDTH-1:0] RX_DATA;
output	RX_REQ;
input	RX_ACK;
output	RX_PEND;


reg		DOUT;

parameter RESET_CNT = 4;

parameter MODE_IDLE = 0;
parameter MODE_TX = 1;
parameter MODE_RX = 2;
parameter MODE_FWD = 3;

parameter BUS_IDLE = 0;
parameter ARBI_RESOLVED = 1;
parameter DRIVE1 = 2;
parameter LATCH1 = 3;
parameter DRIVE2 = 4;
parameter LATCH2 = 5;
parameter BUS_RESET = 6;

parameter NUM_OF_STATE = 7;

// general registers
reg		[log2(NUM_OF_STATE-1)-1:0] state, next_state;
reg		[log2(RESET_CNT-1)-1:0] reset_cnt, next_reset_cnt;
reg		[log2(DATA_WIDTH-1)-1:0] bit_position, next_bit_position; 
reg		addr_done, next_addr_done;
reg		[1:0] input_buffer;
reg		out_reg, next_out_reg;
reg		[1:0] mode, next_mode;
reg		self_reset, next_self_reset;

// interface registers
reg		TX_ACK, next_tx_ack;
reg		RX_REQ, next_rx_req;
reg		TX_FAIL, next_tx_fail;
reg		TX_SUCC, next_tx_success;

// tx registers
reg		[ADDR_WIDTH-1:0] ADDR, next_addr;
reg		[DATA_WIDTH-1:0] DATA0, next_data0;
reg		tx_end_of_trans, next_tx_end_of_trans;
reg		tx_done, next_tx_done;
reg		tx_wait_for_ack, next_tx_wait_for_ack;
reg		tx_underflow, next_tx_underflow;
reg		tx_pend, next_tx_pend;

// rx registers
reg		[ADDR_WIDTH-1:0] RX_ADDR, next_rx_addr;
reg		[DATA_WIDTH-1:0] RX_DATA, next_rx_data; 
reg		[DATA_WIDTH-2:0] rx_data_out_buf, next_rx_data_buf;
reg		rx_done, next_rx_done; 
reg		rx_overflow, next_rx_overflow;
reg		rx_word_completed, next_rx_word_completed;
reg		RX_PEND, next_rx_pend;

wire	addr_bit_extract = (ADDR  & (1<<bit_position))? 1 : 0;
wire	data0_bit_extract = (DATA0 & (1<<bit_position))? 1 : 0;
wire	input_buffer_xor = input_buffer[0] ^ input_buffer[1];
wire	address_match = ((RX_ADDR^ADDRESS)&ADDRESS_MASK)? 0 : 1;

always @ (posedge CLK or negedge RESET)
begin
	if (~RESET)
	begin
		// general registers
		state <= BUS_IDLE;
		reset_cnt <= RESET_CNT - 1;
		bit_position <= ADDR_WIDTH - 1;
		addr_done <= 0;
		out_reg <= 1;
		mode <= MODE_IDLE;
		self_reset <= 0;
		// interface registers
		TX_ACK <= 0;
		RX_REQ <= 0;
		TX_FAIL <= 0;
		TX_SUCC <= 0;
		// tx registers
		ADDR <= 0;
		DATA0 <= 0;
		tx_end_of_trans <= 0;
		tx_done <= 0;
		tx_wait_for_ack <= 0;
		tx_underflow <= 0;
		tx_pend <= 0;
		// rx registers
		RX_ADDR <= 0;
		RX_DATA <= 0;
		rx_data_out_buf <= 0;
		rx_done <= 0;
		rx_overflow <= 0;
		rx_word_completed <= 0;
		RX_PEND <= 0;
	end
	else
	begin
		// general registers
		state <= next_state;
		reset_cnt <= next_reset_cnt;
		bit_position <= next_bit_position;
		addr_done <= next_addr_done;
		out_reg <= next_out_reg;
		mode <= next_mode;
		self_reset <= next_self_reset;
		// interface registers
		TX_ACK <= next_tx_ack;
		RX_REQ <= next_rx_req;
		TX_FAIL <= next_tx_fail;
		TX_SUCC <= next_tx_success;
		// tx registers
		ADDR <= next_addr;
		DATA0 <= next_data0;
		tx_end_of_trans <= next_tx_end_of_trans;
		tx_done <= next_tx_done;
		tx_wait_for_ack <= next_tx_wait_for_ack;
		tx_underflow <= next_tx_underflow;
		tx_pend <= next_tx_pend;
		// rx registers
		RX_ADDR <= next_rx_addr;
		RX_DATA <= next_rx_data;
		rx_data_out_buf <= next_rx_data_buf;
		rx_done <= next_rx_done;
		rx_overflow <= next_rx_overflow;
		rx_word_completed <= next_rx_word_completed;
		RX_PEND <= next_rx_pend;
	end
end

always @ *
begin
	// general registers
	next_state = state;
	next_reset_cnt = reset_cnt;
	next_bit_position = bit_position;
	next_addr_done = addr_done;
	next_out_reg = out_reg;
	next_mode = mode;
	next_self_reset = self_reset;
	// interface registers
	next_tx_ack = TX_ACK;
	next_rx_req = RX_REQ;
	next_tx_fail = TX_FAIL;
	next_tx_success = TX_SUCC;
	// tx registers
	next_addr = ADDR;
	next_data0 = DATA0;
	next_tx_end_of_trans = tx_end_of_trans;
	next_tx_done = tx_done;
	next_tx_wait_for_ack = tx_wait_for_ack;
	next_tx_underflow = tx_underflow;
	next_tx_pend = tx_pend;
	// rx registers
	next_rx_addr = RX_ADDR;
	next_rx_data = RX_DATA;
	next_rx_data_buf = rx_data_out_buf;
	next_rx_done = rx_done;
	next_rx_overflow = rx_overflow;
	next_rx_word_completed = rx_word_completed;
	next_rx_pend = RX_PEND;

	if (TX_ACK & (~TX_REQ))
		next_tx_ack = 0;
	
	if (RX_REQ & RX_ACK)
	begin
		next_rx_req = 0;
		next_rx_pend = 0;
	end

	if (TX_RESP_ACK)
	begin
		next_tx_fail = 0;
		next_tx_success = 0;
	end

	case (state)
		BUS_IDLE:
		begin
			if (DIN^DOUT)
			begin
				// tx registers
				next_addr = TX_ADDR;
				next_data0 = TX_DATA;
				next_mode = MODE_TX;
				next_tx_ack = 1;
				next_tx_pend = TX_PEND;
				// interface registers
			end
			else
				next_mode = MODE_RX;

			// general registers
			next_state = ARBI_RESOLVED;
			next_bit_position = ADDR_WIDTH - 1;
			next_addr_done = 0;
			next_self_reset = 0;
			// interface registers
			// tx registers
			next_tx_end_of_trans = 0;
			next_tx_done = 0;
			next_tx_wait_for_ack = 0;
			next_tx_underflow = 0;
			// rx registers
			next_rx_done = 0;
			next_rx_overflow = 0;
			next_rx_word_completed = 0;
		end

		ARBI_RESOLVED:
		begin
			next_state = DRIVE1;
			if (mode==MODE_TX)
				next_out_reg = addr_bit_extract;
		end

		DRIVE1:
		begin
			next_state = LATCH1;
			if ((mode==MODE_RX)&&(addr_done==1)&&(address_match==0))
				next_mode = MODE_FWD;
		end

		LATCH1:
		begin
			case (mode)
				MODE_TX:
				begin
					if ((~tx_end_of_trans) & tx_done)
					begin
						if (tx_underflow)
							next_out_reg = 0;
						else
							next_out_reg = 1;
					end
				end

				MODE_RX:
				begin
					if (rx_overflow)
						next_out_reg = ~DIN;
					else if (rx_done)
						next_out_reg = 0;
				end

			endcase
			next_state = DRIVE2;
		end

		DRIVE2:
		begin
			next_state = LATCH2;
			if (mode==MODE_TX)
			begin
				if (tx_done)
					next_tx_end_of_trans = 1;
				else
				begin
					if (bit_position)
						next_bit_position = bit_position - 1;
					else
					begin
						next_bit_position = DATA_WIDTH - 1;
						next_addr_done = 1;
						if (addr_done)
						begin
							if (tx_pend)
							begin
								if (TX_REQ)
								begin
									next_tx_pend = TX_PEND;
									next_data0 = TX_DATA;
									next_tx_ack = 1;
								end
								else
								begin
									next_tx_underflow = 1;
									next_tx_done = 1;
								end
							end
							else
								next_tx_done = 1;
						end
					end
				end
			end
		end

		LATCH2:
		begin
			case (mode)
				MODE_TX:
				begin
					if (self_reset)
						next_state = BUS_RESET;
					else
					begin
						case ({tx_done, tx_end_of_trans})
							// DRIVE End of Bit
							2'b10:
							begin
								if (tx_underflow)
									next_out_reg = 1;
								else
									next_out_reg = 0;
								next_state = DRIVE1;
								// should ALWAYS NOT happen, out of sync
								if (input_buffer_xor)
									next_self_reset = 1;
							end

							2'b11:
							begin
								next_tx_wait_for_ack = 1;
								if (~tx_wait_for_ack)
									next_state = DRIVE1;
								else
								begin
									next_state = BUS_RESET;
									if (input_buffer_xor & (~tx_underflow))
										next_tx_success = 1;
									else
										next_tx_fail = 1;
								end
							end

							default:
							begin
								next_state = DRIVE1;
								// RESET by Receiver
								if (input_buffer_xor)
								begin
									next_self_reset = 1;
									next_tx_fail = 1;
								end
								else
								begin
									if (addr_done)
									begin
										next_out_reg = data0_bit_extract;
									end
									else
										next_out_reg = addr_bit_extract;
								end
							end
						endcase
					end
				end

				MODE_RX:
				begin
					if (self_reset)
						next_state = BUS_RESET;
					else
					begin
						if (input_buffer_xor)
						begin
							if (rx_overflow)
							begin
								next_self_reset = 1;
								next_state = DRIVE1;
							end
							else
							// send ACK
							begin
								next_rx_done = 1;
								if (~rx_done)
								begin
									next_out_reg = 1;
									next_state = DRIVE1;
								end
								else
									next_state = BUS_RESET;

								if (rx_word_completed)
								begin
									next_rx_req = 1;
									next_rx_pend = 0;
									next_rx_word_completed = 0;
								end
							end
						end
						else
						begin
							next_state = DRIVE1;
							if (bit_position)
							begin
								next_bit_position = bit_position - 1;
								if (rx_word_completed)
								begin
									next_rx_req = 1;
									next_rx_pend = 1;
									next_rx_word_completed = 0;
								end
							end
							else
							begin
								next_addr_done = 1;
								next_bit_position = DATA_WIDTH - 1;
								if (addr_done)
								begin
									// OVERFLOW, PREPARE RESET BUS
									if (RX_REQ | RX_ACK)
										next_rx_overflow = 1;
									else
									begin
										next_rx_data = {rx_data_out_buf[DATA_WIDTH-2:0], input_buffer[0]};
										next_rx_word_completed = 1;
									end
								end
							end

							if (~addr_done)
								next_rx_addr = {RX_ADDR[ADDR_WIDTH-2:0], input_buffer[0]};
							else
								next_rx_data_buf = {rx_data_out_buf[DATA_WIDTH-2:0], input_buffer[0]};
						end
					end
				end

				MODE_FWD:
				begin
					if (self_reset)
						next_state = BUS_RESET;
					else
					begin
						next_state = DRIVE1;
						if (input_buffer_xor)
							next_self_reset = 1;
					end
				end
			endcase
			next_reset_cnt = RESET_CNT - 1;
			
		end

		BUS_RESET:
		begin
			if (reset_cnt)
				next_reset_cnt = reset_cnt - 1;
			else
			begin
				next_state = BUS_IDLE;
				next_mode = MODE_IDLE;
			end
		end

	endcase
end

always @ *
begin
	DOUT = DIN;
	case (state)
		BUS_IDLE:
		begin
			DOUT = ((~TX_REQ) & DIN);
		end

		ARBI_RESOLVED:
		begin
			if (mode==MODE_TX)
				DOUT = 0;
			else
				DOUT = DIN;
		end

		DRIVE1:
		begin
			case (mode)
				MODE_TX:
				begin
					if (~tx_wait_for_ack)
						DOUT = out_reg;
					else
						DOUT = DIN;
				end

				MODE_RX:
				begin
					if (rx_done)
						DOUT = out_reg;
					else
						DOUT = DIN;
				end
			endcase
		end

		LATCH1:
		begin
			case (mode)
				MODE_TX:
				begin
					if ((~tx_wait_for_ack)&(~self_reset))
						DOUT = out_reg;
					else
						DOUT = DIN;
				end

				MODE_RX:
				begin
					if ((rx_done)&(~self_reset))
						DOUT = out_reg;
					else
						DOUT = DIN;
				end
			endcase
		end

		DRIVE2:
		begin
			case (mode)
				MODE_TX:
				begin
					if (((~tx_end_of_trans)&tx_done)&(~self_reset))
						DOUT = out_reg;
					else
						DOUT = DIN;
				end

				MODE_RX:
				begin
					if (((rx_done)|(rx_overflow))&(~self_reset))
						DOUT = out_reg;
					else
						DOUT = DIN;
				end
			endcase
		end

		LATCH2:
		begin
			case (mode)
				MODE_TX:
				begin
					if ((~tx_end_of_trans) & tx_done)
						DOUT = out_reg;
					else
						DOUT = DIN;
				end

				MODE_RX:
				begin
					if ((rx_done)||(rx_overflow))
						DOUT = out_reg;
					else
						DOUT = DIN;
				end
			endcase
		end

		BUS_RESET:
		begin
			DOUT = DIN;
		end

	endcase
end

always @ (posedge CLK or negedge RESET)
begin
	if (~RESET)
	begin
		input_buffer <= 0;
	end
	else
	begin
		if ((state==DRIVE1)||(state==DRIVE2))
			input_buffer <= {input_buffer[0], DIN};
	end
end

endmodule
