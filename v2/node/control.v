
module control(DIN, DOUT, RESET, CLK_OUT, CLK_IN);

`include "include/ulpb_func.v"

input 	CLK_IN;
output	CLK_OUT;
input	RESET;
input	DIN;
output	DOUT;

reg		CLK_OUT, din_reg;
wire	DOUT;

parameter CLK_DIVIDOR = 10;
parameter RESET_CYCLES = 4;
parameter START_HALF_CYCLES = 6;

reg		[log2(CLK_DIVIDOR-1)-1:0] clk_cnt, next_clk_cnt;
reg		[log2(RESET_CYCLES-1)-1:0] reset_cycle_cnt, next_reset_cycle_cnt;
reg		[1:0]	input_buffer, next_input_buffer;
reg		clk_cnt_start, next_clk_cnt_start;
reg		ctrl_hold, next_ctrl_hold;

parameter BUS_IDLE = 0;
parameter WAIT_FOR_START_POS = 1;
parameter WAIT_FOR_START_NEG = 2;
parameter ARBI_RES_POS = 3;
parameter ARBI_RES_NEG = 4;
parameter DRIVE1_POS = 5;
parameter DRIVE1_NEG = 6;
parameter LATCH1_POS = 7;
parameter LATCH1_NEG = 8;
parameter DRIVE2_POS = 9;
parameter DRIVE2_NEG = 10;
parameter LATCH2_POS = 11;
parameter LATCH2_NEG = 12;
parameter BUS_RESET_POS = 13;
parameter BUS_RESET_NEG = 14;
parameter BUS_DISABLE = 15;

parameter NUM_OF_STATES = 16;

reg		[log2(NUM_OF_STATES-1)-1:0] state, next_state;
reg		[1:0] bus_reset, next_bus_reset;
wire input_buffer_xor = input_buffer[0] ^ input_buffer[1];

always @ (posedge CLK_IN or negedge RESET)
begin
	if (~RESET)
		din_reg <= 1;
	else
		din_reg <= DIN;
end

always @ (posedge CLK_IN or negedge RESET)
begin
	if (~RESET)
	begin
		state <= BUS_IDLE;
		clk_cnt <= CLK_DIVIDOR-1;
		clk_cnt_start <= 0;
		input_buffer <= 0;
		reset_cycle_cnt <= RESET_CYCLES - 1;
		ctrl_hold <= 1;
		bus_reset <= 0;
	end
	else
	begin
		state <= next_state;
		clk_cnt <= next_clk_cnt;
		clk_cnt_start <= next_clk_cnt_start;
		input_buffer <= next_input_buffer; 
		reset_cycle_cnt <= next_reset_cycle_cnt;
		ctrl_hold <= next_ctrl_hold;
		bus_reset <= next_bus_reset;
	end
end

assign DOUT = (ctrl_hold)? 1 : din_reg;

always @ *
begin
	CLK_OUT = 1;
	case (state)
		BUS_IDLE: begin CLK_OUT = 1; end
		WAIT_FOR_START_POS: begin CLK_OUT = 1; end
		WAIT_FOR_START_NEG: begin CLK_OUT = 0; end
		ARBI_RES_POS: begin CLK_OUT = 1; end
		ARBI_RES_NEG: begin CLK_OUT = 0; end
		DRIVE1_POS: begin CLK_OUT = 1; end
		LATCH1_POS: begin CLK_OUT = 1; end
		DRIVE1_NEG: begin CLK_OUT = 0; end
		LATCH1_NEG: begin CLK_OUT = 0; end
		DRIVE2_POS: begin CLK_OUT = 1; end
		LATCH2_POS: begin CLK_OUT = 1; end
		DRIVE2_NEG: begin CLK_OUT = 0; end
		LATCH2_NEG: begin CLK_OUT = 0; end
		BUS_RESET_POS: begin CLK_OUT = 1; end
		BUS_RESET_NEG: begin CLK_OUT = 0; end
		BUS_DISABLE: begin CLK_OUT = 1; end
	endcase
end

always @ *
begin
	next_state = state;
	next_clk_cnt = clk_cnt;
	next_clk_cnt_start = clk_cnt_start;
	next_input_buffer = input_buffer;
	next_reset_cycle_cnt = reset_cycle_cnt;
	next_ctrl_hold = ctrl_hold;
	next_bus_reset = bus_reset;

	if (clk_cnt_start)
	begin
		if (clk_cnt)
			next_clk_cnt = clk_cnt - 1;
		else
			next_clk_cnt = CLK_DIVIDOR-1;
	end

	case (state)
		BUS_IDLE:
		begin
			if (~din_reg)
			begin
				next_state = WAIT_FOR_START_POS;
				next_clk_cnt_start = 1;
			end
			next_reset_cycle_cnt = START_HALF_CYCLES - 1;
			next_bus_reset = 0;
		end

		WAIT_FOR_START_POS:
		begin
			if (clk_cnt==0)
			begin
				if (reset_cycle_cnt)
					next_reset_cycle_cnt = reset_cycle_cnt - 1;
				else
					next_state = WAIT_FOR_START_NEG;
			end
		end

		WAIT_FOR_START_NEG:
		begin
			if (clk_cnt==0)
				next_state = ARBI_RES_POS;
		end

		ARBI_RES_POS:
		begin
			if (clk_cnt==0)
				next_state = ARBI_RES_NEG;
		end

		ARBI_RES_NEG:
		begin
			if (clk_cnt==0)
			begin
				next_state = DRIVE1_POS;
				next_ctrl_hold = 0;
			end
		end

		DRIVE1_POS:
		begin
			if (clk_cnt==0)
				next_state = DRIVE1_NEG;
		end

		DRIVE1_NEG:
		begin
			if (clk_cnt==0)
			begin
				next_state = LATCH1_POS;
				next_input_buffer = {input_buffer[0], din_reg};
			end
		end

		LATCH1_POS:
		begin
			if (clk_cnt==0)
				next_state = LATCH1_NEG;
		end

		LATCH1_NEG:
		begin
			if (clk_cnt==0)
				next_state = DRIVE2_POS;
		end

		DRIVE2_POS:
		begin
			if (clk_cnt==0)
				next_state = DRIVE2_NEG;
		end


		DRIVE2_NEG:
		begin
			if (clk_cnt==0)
			begin
				next_state = LATCH2_POS;
				next_input_buffer = {input_buffer[0], din_reg};
			end

			if (bus_reset==2'b01)
				next_bus_reset = 2'b10;
		end

		LATCH2_POS:
		begin
			next_reset_cycle_cnt = RESET_CYCLES - 1;

			if (bus_reset==0)
				if (input_buffer_xor)
					next_bus_reset = 2'b01;

			if (clk_cnt==0)
				next_state = LATCH2_NEG;
		end

		LATCH2_NEG:
		begin
			if (clk_cnt==0)
				if (bus_reset==2'b10)
				begin
					next_state = BUS_RESET_POS;
					next_ctrl_hold = 1;
				end
				else
					next_state = DRIVE1_POS;
		end

		BUS_RESET_POS:
		begin
			if (clk_cnt==0)
				next_state = BUS_RESET_NEG;
		end

		BUS_RESET_NEG:
		begin
			if (clk_cnt==0)
			begin
				if (reset_cycle_cnt)
				begin
					next_reset_cycle_cnt = reset_cycle_cnt - 1;
					next_state = BUS_RESET_POS;
				end
				else
				begin
					next_state = BUS_DISABLE;
					next_reset_cycle_cnt = START_HALF_CYCLES - 1;
				end	
			end
		end

		// disable 3 cycles;
		BUS_DISABLE:
		begin
			if (clk_cnt==0)
			begin
				if (reset_cycle_cnt)
					next_reset_cycle_cnt = reset_cycle_cnt - 1;
				else
				begin
					next_state = BUS_IDLE;
					next_clk_cnt_start = 0;
				end	
			end
		end
	endcase
end

endmodule
