
module control(
	input DIN, 
	input CLK
	input RESET, 
	output reg DOUT, 
	output reg CLK_OUT, 
	);

`include "include/ulpb_func.v"

parameter START_CYCLES = 6;

parameter BUS_IDLE = 0;
parameter WAIT_FOR_START = 1;
parameter ENABLE_CLK = 2;
parameter ARBI_RES = 3;
parameter DRIVE1 = 4;
parameter LATCH1 = 5;
parameter DRIVE2 = 6;
parameter LATCH2 = 7;
parameter RESET_S0_D = 8;
parameter RESET_S0_L = 9;
parameter RESET_S1_D = 10;
parameter RESET_S1_L = 11;
parameter RESET_S0_D1 = 12;
parameter RESET_S0_L1 = 13;
parameter RESET_R_D = 14;
parameter RESET_R_L = 15;
parameter NUM_OF_STATES = 16;

// CLK registers
reg		CLK_HALF, next_clk_half;

// Reset registers
reg		[2:0] seq_state, next_seq_state;

// General registers
reg		[log2(NUM_OF_STATES-1)-1:0] state, next_state;
reg		[log2(START_CYCLES-1)-1:0] start_cycle_cnt, next_start_cycle_cnt;
reg		[3:0]	input_buffer;

// Combinational logics
reg		CLK_EN;
reg		HALF_SPEED;
reg		ctrl_dout; 
reg		ctrl_hold; 
reg		out_of_phase;
assign CLK_OUT = (CLK_EN)? (HALF_SPEED)? CLK_HALF : CLK : 1;
assign DOUT = (ctrl_hold)? ctrl_dout : DIN;

always @ (posedge CLK or negedge RESET)
begin
	if (~RESET)
	begin
		// CLK registers
		CLK_HALF <= 0;
		// Reset registers
		seq_state <= 0;
		// General registers
		state <= BUS_IDLE;
		start_cycle_cnt <= START_CYCLES - 1'b1;
	end
	else
	begin
		// CLK registers
		CLK_HALF <= next_clk_half;
		// Reset registers
		seq_state <= next_seq_state;
		// General registers
		state <= next_state;
		start_cycle_cnt <= next_start_cycle_cnt;
	end
end

always @ *
begin
	case (state)
		RESET_S0_D: begin ctrl_dout = 0; end
		RESET_S0_L: begin ctrl_dout = 0; end
		RESET_S0_D1: begin ctrl_dout = 0; end
		RESET_S0_L1: begin ctrl_dout = 0; end
		default: begin ctrl_dout = 1; end
	endcase
end

always @ *
begin
	if ((state==BUS_IDLE)||(state==WAIT_FOR_START))
		CLK_EN = 0;
	else
		CLK_EN = 1;
end

always @ *
begin
	case (state)
		RESET_S0_D: begin HALF_SPEED = 1; end
		RESET_S0_L: begin HALF_SPEED = 1; end
		RESET_S1_D: begin HALF_SPEED = 1; end
		RESET_S1_L: begin HALF_SPEED = 1; end
		RESET_S0_D1: begin HALF_SPEED = 1; end
		RESET_S0_L1: begin HALF_SPEED = 1; end
		RESET_R_D: begin HALF_SPEED = 1; end
		RESET_R_L: begin HALF_SPEED = 1; end
		default: begin HALF_SPEED = 0; end
	endcase
end

always @ *
begin
	case (state)
		DRIVE1: begin ctrl_hold = 0; end
		LATCH1: begin ctrl_hold = 0; end
		DRIVE2: begin ctrl_hold = 0; end
		LATCH2: begin ctrl_hold = 0; end
		default: begin ctrl_hold = 1; end
	endcase
end

always @ *
begin
	if ((state==DRIVE1)||(state==DRIVE2))
		out_of_phase = (input_buffer[1]^input_buffer[0]);
	else
		out_of_phase = 0;
end

always @ *
begin
	// CLK registers
	next_clk_half = CLK_HALF;
	// Reset registers
	next_seq_state = seq_state;
	// General registers
	next_state = state;
	next_start_cycle_cnt = start_cycle_cnt;

	case (state)
		BUS_IDLE:
		begin
			if (~DIN)
			begin
				next_state = WAIT_FOR_START;
			end
			next_start_cycle_cnt = START_CYCLES - 1'b1;
			next_seq_state = 0;
			next_clk_half = 0;
		end

		WAIT_FOR_START:
		begin
			if (start_cycle_cnt)
				next_start_cycle_cnt = start_cycle_cnt - 1'b1;
			else
			begin
				next_state = ENABLE_CLK;
			end
		end

		ENABLE_CLK:
		begin
			next_state = ARBI_RES;
		end

		ARBI_RES:
		begin
			next_state = DRIVE1;
		end

		DRIVE1:
		begin
			if (out_of_phase)
			begin
				next_state = RESET_S0_D;
			end
			else
				next_state = LATCH1;
		end

		LATCH1:
		begin
			case (seq_state)
				0:
				begin
					next_state = DRIVE2;
				end

				// 3rd of end of meesage
				1:
				begin
					// 011
					if (input_buffer[0])
					begin
						next_seq_state = seq_state + 1;
						next_state = DRIVE2;
					end
					// 010, reset
					else
					begin
						next_state = RESET_S0_D;
					end
				end

				// 1st of ACK
				3:
				begin
					if (input_buffer[0])
					begin
						next_state = RESET_S0_D;
					end
					else
					begin
						next_seq_state = seq_state + 1;
						next_state = DRIVE2;
					end
				end

				// 3rd of ACK
				5:
				begin
					if (input_buffer[0])
					begin
						next_seq_state = seq_state + 1;
						next_state = DRIVE2;
					end
					// 010, reset
					else
					begin
						next_state = RESET_S0_D;
					end
				end
			endcase
		end

		DRIVE2:
		begin
			if (out_of_phase)
			begin
				next_state = RESET_S0_D;
			end
			else
				next_state = LATCH2;
		end

		LATCH2:
		begin
			case (seq_state)
				0:
				begin
					case ({input_buffer[2], input_buffer[0]})
						// 2nd bit of message end
						2'b01:
						begin
							next_seq_state = seq_state + 1;
							next_state = DRIVE1;
						end

						2'b10:
						begin
							next_state = RESET_S0_D;
						end

						default:
						begin
							next_state = DRIVE1;
						end
					endcase
				end

				// 4th bit of end of message
				2:
				begin
					// 0111, reset
					if (input_buffer[0])
					begin
						next_state = RESET_S0_D;
					end
					// 0110, end of sequence
					else
					begin
						next_seq_state = seq_state + 1;
						next_state = DRIVE1;
					end
				end

				// 2nd bit of ACK
				4:
				begin
					if (input_buffer[0])
					begin
						next_seq_state = seq_state + 1;
						next_state = DRIVE1;
					end
					else
					begin
						next_state = RESET_S0_D;
					end
				end

				6:
				begin
					next_state = RESET_S0_D;
				end
			endcase
		end

		RESET_S0_D:
		begin
			next_clk_half = ~CLK_HALF;
			if (CLK_HALF)
				next_state = RESET_S0_L;
		end

		RESET_S0_L:
		begin
			next_clk_half = ~CLK_HALF;
			if (CLK_HALF)
			begin
				// 1st reset bit successed
				if (input_buffer[2:0]==0)
					next_state = RESET_S1_D;
				// 1st reset bit failed
				else
					next_state = RESET_S0_D;
			end
		end

		RESET_S1_D:
		begin
			next_clk_half = ~CLK_HALF;
			if (CLK_HALF)
				next_state = RESET_S1_L;
		end

		RESET_S1_L:
		begin
			next_clk_half = ~CLK_HALF;
			if (CLK_HALF)
			begin
				// 2nd reset bit successed
				if (input_buffer==4'b0111)
					next_state = RESET_S0_D1;
				// 2nd reset bit failed
				else
					next_state = RESET_S0_D;
			end
		end

		RESET_S0_D1:
		begin
			next_clk_half = ~CLK_HALF;
			if (CLK_HALF)
				next_state = RESET_S0_L1;
		end

		RESET_S0_L1:
		begin
			next_clk_half = ~CLK_HALF;
			if (CLK_HALF)
			begin
				// 3rd reset bit successed
				if (input_buffer==4'b1000)
					next_state = RESET_R_D;
				// 3rd reset bit failed
				else
					next_state = RESET_S0_D;
			end
		end

		RESET_R_D:
		begin
			next_clk_half = ~CLK_HALF;
			if (CLK_HALF)
				next_state = RESET_R_L;
		end

		RESET_R_L:
		begin
			if (CLK_HALF)
				next_state = BUS_IDLE;
			else
				next_clk_half = ~CLK_HALF;
		end

	endcase
end

always @ (posedge CLK or negedge RESET)
begin
	if (~RESET)
		input_buffer <= 0;
	else
		input_buffer <= {input_buffer[2:0], DIN};
end


endmodule
