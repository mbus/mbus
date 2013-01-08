module ulpb_node(CLK, RESET, DIN, DOUT, ADDR_IN, DATA_IN, REQ_TX, ACK_TX, ADDR_OUT, DATA_OUT, REQ_RX, ACK_RX, ACK_RECEIVED);

parameter ADDR_WIDTH=8;
parameter DATA_WIDTH=32;
input 	CLK, RESET, DIN;
input	[ADDR_WIDTH-1:0] ADDR_IN;
input	[DATA_WIDTH-1:0] DATA_IN;
input	REQ_TX;
output	ACK_TX;
output	[ADDR_WIDTH-1:0] ADDR_OUT;
output	[DATA_WIDTH-1:0] DATA_OUT;
output	REQ_RX;
input	ACK_RX;
output	DOUT;
output	ACK_RECEIVED;

reg		DOUT;

parameter ADDRESS = 8'hab;
parameter RESET_CNT = 2;

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


reg		[log2(NUM_OF_STATE-1):0] state, next_state;
reg		[log2(DATA_WIDTH-1):0] bit_position, next_bit_position, rx_bit_counter, next_rx_bit_counter;
reg		out_reg, next_out_reg;
reg		addr_done, next_addr_done;
reg		tx_grant, next_tx_grant;
reg		tx_done, next_tx_done;
reg		wait_for_ack, next_wait_for_ack;
reg		[log2(RESET_CNT-1):0] reset_cnt, next_reset_cnt;
reg		[1:0] input_buffer;
reg		[ADDR_WIDTH-1:0] ADDR, next_addr, ADDR_OUT, next_addr_out;
reg		[DATA_WIDTH-1:0] DATA, next_data, DATA_OUT, next_data_out;
reg		addr_received, next_addr_received, rx_done, next_rx_done;
reg		[1:0] mode, next_mode;
reg		ACK_TX, next_ack_tx, REQ_RX, next_req_rx;
reg		ACK_RECEIVED, next_ack_received;
reg		fwd_done, next_fwd_done;

wire	addr_bit_extract = (ADDR  & (1<<bit_position))? 1 : 0;
wire	data_bit_extract = (DATA & (1<<bit_position))? 1 : 0;
wire	input_buffer_xor = input_buffer[0] ^ input_buffer[1];
wire	address_match = (ADDR_OUT==ADDRESS)? 1 : 0;

always @ (posedge CLK or negedge RESET)
begin
	if (~RESET)
	begin
		state <= BUS_IDLE;
		out_reg <= 1;
		bit_position <= ADDR_WIDTH-1;
		addr_done <= 0;
		tx_grant <= 0;
		tx_done <= 0;
		wait_for_ack <= 0;
		reset_cnt <= RESET_CNT - 1;
		ADDR <= 0;
		DATA <= 0;
		ADDR_OUT <= 0;
		DATA_OUT <= 0;
		rx_bit_counter <= ADDR_WIDTH-1;
		addr_received <= 0;
		mode <= MODE_IDLE;
		rx_done <= 0;
		ACK_TX <= 0;
		REQ_RX <= 0;
		ACK_RECEIVED <= 0;
		fwd_done <= 0;
	end
	else
	begin
		state <= next_state;
		out_reg <= next_out_reg;
		bit_position <= next_bit_position;
		addr_done <= next_addr_done;
		tx_grant <= next_tx_grant;
		tx_done <= next_tx_done;
		wait_for_ack <= next_wait_for_ack;
		reset_cnt <= next_reset_cnt;
		ADDR <= next_addr;
		DATA <= next_data;
		ADDR_OUT <= next_addr_out;
		DATA_OUT <= next_data_out;
		rx_bit_counter <= next_rx_bit_counter;
		addr_received <= next_addr_received;
		mode <= next_mode;
		rx_done <= next_rx_done;
		ACK_TX <= next_ack_tx;
		REQ_RX <= next_req_rx;
		ACK_RECEIVED <= next_ack_received;
		fwd_done <= next_fwd_done;
	end
end

always @ *
begin
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
			//DOUT = ((~REQ_TX) & DIN);
		end

		BUS_RESET:
		begin
			DOUT = 1;
		end

		default:
		begin
			if ((tx_grant)||(rx_done))
				DOUT = out_reg;
			else
				DOUT = DIN;
		end
	endcase
end


always @ *
begin
	next_state = state;
	next_out_reg = out_reg;
	next_bit_position = bit_position;
	next_addr_done = addr_done;
	next_tx_grant = tx_grant;
	next_tx_done = tx_done;
	next_wait_for_ack = wait_for_ack;
	next_reset_cnt = reset_cnt;
	next_addr = ADDR;
	next_data = DATA;
	next_addr_out = ADDR_OUT;
	next_data_out = DATA_OUT;
	next_rx_bit_counter = rx_bit_counter;
	next_addr_received = addr_received;
	next_mode = mode;
	next_rx_done = rx_done;
	next_ack_tx = ACK_TX;
	next_req_rx = REQ_RX;
	next_ack_received = ACK_RECEIVED;
	next_fwd_done = fwd_done;

	if (ACK_TX & (~REQ_TX))
		next_ack_tx = 0;
	
	if (REQ_RX & ACK_RX)
		next_req_rx = 0;

	case (state)
		BUS_IDLE:
		begin
			if (DIN^DOUT)
			begin
				next_tx_grant = 1;
				next_addr = ADDR_IN;
				next_data = DATA_IN;
				next_mode = MODE_TX;
				next_ack_tx = 1;
			end
			else
				next_mode = MODE_RX;
			next_state = ARBI_RESOLVED;
			next_bit_position = ADDR_WIDTH-1;
			next_rx_bit_counter = ADDR_WIDTH-1;
			next_ack_received = 0;
		end

		ARBI_RESOLVED:
		begin
			next_state = DRIVE1;
			if (tx_grant)
				next_out_reg = addr_bit_extract;
		end

		DRIVE1:
		begin
			next_state = LATCH1;
			if ((addr_received==1)&&(mode==MODE_RX))
			begin
				if (address_match)
					next_mode = MODE_RX;
				else
					next_mode = MODE_FWD;
			end
		end

		LATCH1:
		begin
			case (mode)
				MODE_TX:
				begin
					if (tx_grant & tx_done)
						next_out_reg = 1;
				end

				MODE_RX:
				begin
					if (rx_done)
						next_out_reg = 0;
				end

				default:
				begin
				end
			endcase
			next_state = DRIVE2;
		end

		DRIVE2:
		begin
			next_state = LATCH2;
			case ({tx_grant, tx_done})
				2'b10:
				begin
					if (bit_position)
						next_bit_position = bit_position - 1;
					else
					begin
						next_bit_position = DATA_WIDTH-1;
						next_addr_done = 1;
						if (addr_done)
							next_tx_done = 1;
					end
				end

				2'b11:
				begin
					next_tx_grant = 0;
				end

				default:
				begin
				end

			endcase
		end

		LATCH2:
		begin
			case ({tx_grant, tx_done})
				// Drive End of Bit
				2'b11:
				begin
					next_out_reg = 0;
					next_state = DRIVE1;
				end

				// Drive Data
				2'b10:
				begin
					if (addr_done)
						next_out_reg = data_bit_extract;
					else
						next_out_reg = addr_bit_extract;
					next_state = DRIVE1;
				end

				// Wait for ACK
				2'b01:
				begin
					if (~wait_for_ack)
					begin
						next_wait_for_ack = 1;
						next_state = DRIVE1;
					end
					else
					begin
						next_state = BUS_RESET;
						// ACK/RESET received
						if (input_buffer_xor)
							next_ack_received = 1;
					end
				end

				// Wait for RESET
				2'b00:
				begin
					if (input_buffer_xor)
					begin
						case (mode)
							MODE_RX:
							begin
								if (~rx_done)
								begin
									next_rx_done = 1;
									next_out_reg = 1;
									next_req_rx = 1;
									next_state = DRIVE1;
								end
								else
									next_state = BUS_RESET;
							end

							MODE_FWD:
							begin
								if (~fwd_done)
								begin
									next_fwd_done = 1;
									next_state = DRIVE1;
								end
							end
						endcase
					end
					else
					begin
						if (fwd_done)
							next_state = BUS_RESET;
						else
							next_state = DRIVE1;

						if ((mode==MODE_RX)&&(rx_done==0))
						begin
							if (rx_bit_counter)
							begin
								next_rx_bit_counter = rx_bit_counter - 1;
							end
							else
							begin
								next_addr_received = 1;
								next_rx_bit_counter = DATA_WIDTH - 1;
							end

							if (~addr_received)
								next_addr_out = {ADDR_OUT[ADDR_WIDTH-2:0], input_buffer[0]};
							else
								next_data_out = {DATA_OUT[DATA_WIDTH-2:0], input_buffer[0]};
						end
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
				next_addr_done = 0;
				next_tx_grant = 0;
				next_tx_done = 0;
				next_wait_for_ack = 0;
				next_addr_received = 0;
				next_mode = MODE_IDLE;
				next_rx_done = 0;
				next_fwd_done = 0;
			end
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
