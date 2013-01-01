
module control(
	input 	CLK_IN, 
	output	CLK_OUT, 
	input	RESET, 
	input	IN, 
	output	OUT);

reg			CLK_OUT;

parameter CLK_DIVIDOR = 10;
parameter RESET_CYCLES = 7;
parameter START_HALF_CYCLES = 6;

reg		[log2(CLK_DIVIDOR-1):0] clk_cnt, next_clk_cnt;
reg		[log2(RESET_CYCLES-1):0] reset_cycle_cnt, next_reset_cycle_cnt;
reg		[1:0]	input_buffer, next_input_buffer;
reg		clk_cnt_start, next_clk_cnt_start;

parameter BUS_IDLE = 0;
parameter WAIT_FOR_START = 1;
parameter DRIVE1_POS = 2;
parameter LATCH1_POS = 3;
parameter DRIVE1_NEG = 4;
parameter LATCH1_NEG = 5;
parameter DRIVE2_POS = 6;
parameter LATCH2_POS = 7;
parameter DRIVE2_NEG = 8;
parameter LATCH2_NEG = 9;
parameter BUS_RESET_POS = 10;
parameter BUS_RESET_NEG = 11;

parameter NUM_OF_STATES = 12;

reg		[log2(NUM_OF_STATES-1):0] state, next_state;
wire input_buffer_xor = input_buffer[0] ^ input_buffer[1];
wire OUT = (state==BUS_IDLE)? 1 : IN;

always @ (posedge CLK_IN or negedge RESET)
begin
	if (~RESET)
	begin
		state <= BUS_IDLE;
		clk_cnt <= CLK_DIVIDOR-1;
		clk_cnt_start <= 0;
		input_buffer <= 0;
		reset_cycle_cnt <= RESET_CYCLES - 1;
	end
	else
	begin
		state <= next_state;
		clk_cnt <= next_clk_cnt;
		clk_cnt_start <= next_clk_cnt_start;
		input_buffer <= next_input_buffer; 
		reset_cycle_cnt <= next_reset_cycle_cnt;
	end
end

always @ *
begin
	CLK_OUT = 1;
	case (state)
		BUS_IDLE: begin CLK_OUT = 1; end
		WAIT_FOR_START: begin CLK_OUT = 1; end
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
	endcase
end

always @ *
begin
	next_state = state;
	next_clk_cnt = clk_cnt;
	next_clk_cnt_start = clk_cnt_start;
	next_input_buffer = input_buffer;
	next_reset_cycle_cnt = reset_cycle_cnt;

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
			if (~IN)
			begin
				next_state = WAIT_FOR_START;
				next_clk_cnt_start = 1;
			end
			next_reset_cycle_cnt = START_HALF_CYCLES - 1;
		end

		WAIT_FOR_START:
		begin
			if (clk_cnt==0)
			begin
				if (reset_cycle_cnt)
					next_reset_cycle_cnt = reset_cycle_cnt - 1;
				else
					next_state = DRIVE2_NEG;
			end
		end

		DRIVE2_NEG:
		begin
			if (clk_cnt==0)
			begin
				next_state = LATCH2_POS;
				next_input_buffer = {input_buffer[0], IN};
			end
		end

		LATCH2_POS:
		begin
			next_reset_cycle_cnt = RESET_CYCLES - 1;
			if (input_buffer_xor)
				next_state = BUS_RESET_POS;
			else if (clk_cnt==0)
				next_state = LATCH2_NEG;
		end

		LATCH2_NEG:
		begin
			if (clk_cnt==0)
				next_state = DRIVE1_POS;
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
				next_input_buffer = {input_buffer[0], IN};
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

function integer log2;
	input [31:0] value;
	for (log2=0; value>0; log2=log2+1)
	value = value>>1;
endfunction

endmodule
