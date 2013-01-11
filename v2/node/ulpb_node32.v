module ulpb_node32(CLK, RESET, DIN, DOUT, ADDR_IN, DATA_IN0, DATA_IN1, PENDING, WORD_INDICATOR, REQ_TX, ACK_TX, ADDR_OUT, DATA_OUT, REQ_RX, ACK_RX, ACK_RECEIVED, TX_FAIL);

parameter ADDR_WIDTH=8;
parameter DATA_WIDTH=32;
input 	CLK, RESET, DIN;
input	[ADDR_WIDTH-1:0] ADDR_IN;
input	[DATA_WIDTH-1:0] DATA_IN0, DATA_IN1;
input	PENDING;
input	REQ_TX;
output	ACK_TX;
output	[ADDR_WIDTH-1:0] ADDR_OUT;
output	[DATA_WIDTH-1:0] DATA_OUT;
output	REQ_RX;
input	ACK_RX;
output	DOUT;
output	ACK_RECEIVED;
output	TX_FAIL;
output	WORD_INDICATOR;

reg		DOUT;

parameter ADDRESS = 8'hab;
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
reg		[log2(NUM_OF_STATE-1):0] state, next_state;
reg		[log2(RESET_CNT-1):0] reset_cnt, next_reset_cnt;
reg		[log2(DATA_WIDTH-1):0] bit_position, next_bit_position; 
reg		addr_done, next_addr_done;
reg		[1:0] input_buffer;
reg		out_reg, next_out_reg;
reg		[1:0] mode, next_mode;
reg		self_reset, next_self_reset;

// interface registers
reg		ACK_TX, next_ack_tx;
reg		REQ_RX, next_req_rx;
reg		ACK_RECEIVED, next_ack_received;
reg		TX_FAIL, next_tx_fail;
reg		WORD_INDICATOR, next_word_indicator;

// tx registers
reg		[ADDR_WIDTH-1:0] ADDR, next_addr;
reg		[DATA_WIDTH-1:0] DATA0, next_data0, DATA1, next_data1;
reg		end_of_tx, next_end_of_tx;
reg		tx_done, next_tx_done;
reg		wait_for_ack, next_wait_for_ack;

// rx registers
reg		[ADDR_WIDTH-1:0] ADDR_OUT, next_addr_out;
reg		[DATA_WIDTH-1:0] DATA_OUT, next_data_out, data_out_buf, next_data_out_buf;
reg		rx_done, next_rx_done; 
reg		rx_overflow, next_rx_overflow;


wire	addr_bit_extract = (ADDR  & (1<<bit_position))? 1 : 0;
wire	data0_bit_extract = (DATA0 & (1<<bit_position))? 1 : 0;
wire	data1_bit_extract = (DATA1 & (1<<bit_position))? 1 : 0;
wire	input_buffer_xor = input_buffer[0] ^ input_buffer[1];
wire	address_match = (ADDR_OUT==ADDRESS)? 1 : 0;


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
		ACK_TX <= 0;
		REQ_RX <= 0;
		ACK_RECEIVED <= 0;
		TX_FAIL <= 0;
		WORD_INDICATOR <= 0;
		// tx registers
		ADDR <= 0;
		DATA0 <= 0;
		DATA1 <= 0;
		end_of_tx <= 0;
		tx_done <= 0;
		wait_for_ack <= 0;
		// rx registers
		ADDR_OUT <= 0;
		DATA_OUT <= 0;
		data_out_buf <= 0;
		rx_done <= 0;
		rx_overflow <= 0;
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
		ACK_TX <= next_ack_tx;
		REQ_RX <= next_req_rx;
		ACK_RECEIVED <= next_ack_received;
		TX_FAIL <= next_tx_fail;
		WORD_INDICATOR <= next_word_indicator;
		// tx registers
		ADDR <= next_addr;
		DATA0 <= next_data0;
		DATA1 <= next_data1;
		end_of_tx <= next_end_of_tx;
		tx_done <= next_tx_done;
		wait_for_ack <= next_wait_for_ack;
		// rx registers
		ADDR_OUT <= next_addr_out;
		DATA_OUT <= next_data_out;
		data_out_buf <= next_data_out_buf;
		rx_done <= next_rx_done;
		rx_overflow <= next_rx_overflow;
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
	next_ack_tx = ACK_TX;
	next_req_rx = REQ_RX;
	next_ack_received = ACK_RECEIVED;
	next_tx_fail = TX_FAIL;
	next_word_indicator = WORD_INDICATOR;
	// tx registers
	next_addr = ADDR;
	next_data0 = DATA0;
	next_data1 = DATA1;
	next_end_of_tx = end_of_tx;
	next_tx_done = tx_done;
	next_wait_for_ack = wait_for_ack;
	// rx registers
	next_addr_out = ADDR_OUT;
	next_data_out = DATA_OUT;
	next_data_out_buf = data_out_buf;
	next_rx_done = rx_done;
	next_rx_overflow = rx_overflow;

	if (ACK_TX & (~REQ_TX))
		next_ack_tx = 0;
	
	if (REQ_RX & ACK_RX)
		next_req_rx = 0;

	case (state)
		BUS_IDLE:
		begin
			if (DIN^DOUT)
			begin
				// tx registers
				next_addr = ADDR_IN;
				next_data0 = DATA_IN0;
				next_mode = MODE_TX;
				next_ack_tx = 1;
				// interface registers
				next_tx_fail = 0;
			end
			else
				next_mode = MODE_RX;

			// general registers
			next_state = ARBI_RESOLVED;
			next_bit_position = ADDR_WIDTH - 1;
			next_addr_done = 0;
			next_self_reset = 0;
			// interface registers
			next_ack_received = 0;
			next_word_indicator = 0;
			// tx registers
			next_end_of_tx = 0;
			next_tx_done = 0;
			next_wait_for_ack = 0;
			// rx registers
			next_rx_done = 0;
			next_rx_overflow = 0;
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
					if ((~end_of_tx) & tx_done)
						next_out_reg = 1;
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
					next_end_of_tx = 1;
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
							if (PENDING)
							begin
								next_word_indicator = ~WORD_INDICATOR;
								// update data1 register
								if (~WORD_INDICATOR)
									next_data1 = DATA_IN1;
								// update data0 register
								else
									next_data0 = DATA_IN0;

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
						case ({tx_done, end_of_tx})
							// DRIVE End of Bit
							2'b10:
							begin
								next_out_reg = 0;
								next_state = DRIVE1;
								// should ALWAYS NOT happen, out of sync
								if (input_buffer_xor)
									next_self_reset = 1;
							end

							2'b11:
							begin
								next_wait_for_ack = 1;
								if (~wait_for_ack)
									next_state = DRIVE1;
								else
								begin
									next_state = BUS_RESET;
									if (input_buffer_xor)
										next_ack_received = 1;
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
										if (~WORD_INDICATOR)
											next_out_reg = data0_bit_extract;
										else
											next_out_reg = data1_bit_extract;
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
							end
						end
						else
						begin
							next_state = DRIVE1;
							if (bit_position)
							begin
								next_bit_position = bit_position - 1;
							end
							else
							begin
								next_addr_done = 1;
								next_bit_position = DATA_WIDTH - 1;
								if (addr_done)
								begin
									// OVERFLOW, PREPARE RESET BUS
									if (REQ_RX)
										next_rx_overflow = 1;
									else
									begin
										next_data_out = {data_out_buf[DATA_WIDTH-2:0], input_buffer[0]};
										next_req_rx = 1;
									end
								end
							end

							if (~addr_done)
								next_addr_out = {ADDR_OUT[ADDR_WIDTH-2:0], input_buffer[0]};
							else
								next_data_out_buf = {data_out_buf[DATA_WIDTH-2:0], input_buffer[0]};
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
			DOUT = ((~REQ_TX) & DIN);
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
					if (~wait_for_ack)
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
					if ((~wait_for_ack)&(~self_reset))
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
					if (((~end_of_tx)&tx_done)&(~self_reset))
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
					if ((~end_of_tx) & tx_done)
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

function integer log2;
	input [31:0] value;
	for (log2=0; value>0; log2=log2+1)
	value = value>>1;
endfunction

endmodule
