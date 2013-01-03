module ulpb_node(CLK, RESET, IN, OUT, ADDR, DATA1, DATA2, DATA_PENDING, REQ_TX, DATA_INDICATOR);

parameter ADDR_WIDTH=8;
parameter DATA_WIDTH=32;
input 	CLK, RESET, IN;
input	[ADDR_WIDTH-1:0] ADDR;
input	[DATA_WIDTH-1:0] DATA1, DATA2;
input	DATA_PENDING;
input	REQ_TX;
output	DATA_INDICATOR;
output	OUT;


wire	data1_bit_extract = (DATA1 & (1<<bit_position))? 1 : 0;
wire	data2_bit_extract = (DATA2 & (1<<bit_position))? 1 : 0;
wire	addr_bit_extract  = (ADDR  & (1<<bit_position))? 1 : 0;

reg		[1:0] input_buffer;
wire	input_buffer_xor = input_buffer[0] ^ input_buffer[1];

parameter RESET_CNT = 3;

parameter BUS_IDLE = 0;
parameter ARBI_RESOLVED = 1;
parameter DRIVE1 = 2;
parameter LATCH1 = 3;
parameter DRIVE2 = 4;
parameter LATCH2 = 5;
parameter BUS_RESET = 6;

parameter NUM_OF_STATE = 7;

reg		[log2(NUM_OF_STATE-1):0] state, next_state;
reg		[log2(DATA_WIDTH-1):0] bit_position, next_bit_position;
reg		DATA_INDICATOR, next_data_indicator;
reg		out_reg, next_out_reg;
reg		addr_done, next_addr_done;
reg		TX_grant, next_TX_grant;
reg		tx_done, next_tx_done;
reg		DATA_INDICATOR, next_data_indicator;
reg		wait_for_ack, next_wait_for_ack;
reg		[log2(RESET_CNT-1):0] reset_cnt, next_reset_cnt;

always @ (posedge CLK or negedge RESET)
begin
	if (~RESET)
	begin
		state <= BUS_IDLE;
		out_reg <= 1;
		bit_position <= ADDR_WIDTH-1;
		addr_done <= 0;
		TX_grant <= 0;
		tx_done <= 0;
		DATA_INDICATOR <= 0;
		wait_for_ack <= 0;
		reset_cnt <= RESET_CNT - 1;
	end
	else
	begin
		state <= next_state;
		out_reg <= next_out_reg;
		bit_position <= next_bit_position;
		addr_done <= next_addr_done;
		TX_grant <= next_TX_grant;
		tx_done <= next_tx_done;
		DATA_INDICATOR <= next_data_indicator;
		wait_for_ack <= next_wait_for_ack;
		reset_cnt <= next_reset_cnt;
	end
end

always @ *
begin
	case (state)
		BUS_IDLE:
		begin
			OUT = ((~REQ_TX) & IN);
		end

		ARBI_RESOLVED:
		begin
			OUT = ((~REQ_TX) & IN);
		end

		default:
		begin
			if (TX_grant)
				OUT = out_reg;
			else
				OUT = IN;
		end
	endcase
end

always @ *
begin
	next_state = state;
	next_out_reg = out_reg;
	next_bit_position = bit_position;
	next_addr_done = addr_done;
	next_TX_grant = TX_grant;
	next_tx_done = tx_done;
	next_data_indicator = DATA_INDICATOR;
	next_wait_for_ack = wait_for_ack;
	next_reset_cnt = reset_cnt;
	case (state)
		BUS_IDLE:
		begin
			if (IN^OUT)
				next_TX_grant = 1;
			next_state = ARBI_RESOLVED;
			next_bit_position = ADDR_WIDTH-1;
		end

		ARBI_RESOLVED:
		begin
			next_state = DRIVE1;
			if (TX_grant)
				next_out_reg = addr_bit_extract;
		end

		DRIVE1:
		begin
			next_state = LATCH1;
		end

		LATCH1:
		begin
			if (tx_done)
				next_out_reg = 1;
			next_state = DRIVE2;
		end

		DRIVE2:
		begin
			next_state = LATCH2;
			case ({TX_grant, tx_done})
				2'b10:
				begin
					if (bit_position)
						next_bit_position = bit_position - 1;
					else
					begin
						next_bit_position = DATA_WIDTH-1;
						next_addr_done = 1;
						if (addr_done)
						begin
							if (DATA_PENDING)
								next_data_indicator = ~DATA_INDICATOR;
							else
								next_tx_done = 1;
						end
					end
				end

				2'b00:
				begin
				end

				default:
				begin
					next_TX_grant = 0;
				end
			endcase
		end

		LATCH2:
		begin
			case ({TX_grant, tx_done})
				// Drive End of Bit
				2'b11:
				begin
					next_out_reg = 0;
					next_state = DRIVE1;
				end

				// Drive Data
				2'b10:
				begin
					case ({addr_done, DATA_INDICATOR})
						2'b00: begin next_out_reg = addr_bit_extract; end
						2'b01: begin next_out_reg = addr_bit_extract; end
						2'b10: begin next_out_reg = data1_bit_extract; end
						2'b11: begin next_out_reg = data2_bit_extract; end
					endcase
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
						// ACK/RESET received
						if (input_buffer_xor)
							next_state = BUS_RESET;
					end
				end

				// Wait for RESET
				2'b00:
				begin
					if (input_buffer_xor)
						next_state = BUS_RESET;
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
				next_TX_grant = 0;
				next_tx_done = 0;
				next_data_indicator = 0;
				next_wait_for_ack <= 0;
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
			input_buffer <= {input_buffer[0], IN};
	end
end

function integer log2;
	input [31:0] value;
	for (log2=0; value>0; log2=log2+1)
	value = value>>1;
endfunction

endmodule
