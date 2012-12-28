
module control(IN, OUT, RESET, CLK_OUT, CLK_IN);

input 	IN, RESET, CLK_IN;
output 	OUT, CLK_OUT;

parameter CLK_DIVIDOR = 10;

reg		[2:0] state, next_state;
reg		CLK_OUT, next_CLK_OUT;
reg		[log2(CLK_DIVIDOR-1):0] clk_cnt, next_clk_cnt;
reg		clk_edge, next_clk_edge;
reg		[1:0] input_buffer, next_input_buffer;
reg		[1:0] drive_state_cnt, next_drive_state_cnt;
reg		[1:0] bus_reset_state_cnt, next_bus_reset_state_cnt;

wire input_buffer_xor = (input_buffer[1] ^ input_buffer[0]);
parameter IDLE = 0;
parameter WAIT_HALF_CYCLE = 1;
parameter ARB_RES = 2;
parameter DRIVE = 3;
parameter LATCH = 4;
parameter BUS_RESET = 5;

always @ *
begin
	OUT = 1;
	case (state)
		DRIVE:
		begin
			OUT = IN;
		end

		LATCH:
		begin
			OUT = IN;
		end

		BUS_RESET:
		begin
			OUT = IN;
		end

		default:
		begin
			OUT = 1;
		end
	endcase
end

always @ (posedge CLK_IN or negedge RESET)
begin
	if (~RESET)
	begin
		state <= IDLE;
		CLK_OUT <= 1;
		clk_cnt <= 0;
		clk_edge <= 0;
		input_buffer <= 0;
		drive_state_cnt <= 0;
		bus_reset_state_cnt <= 0;
	end
	else
	begin
		state <= next_state;
		CLK_OUT <= next_CLK_OUT;
		clk_cnt <= next_clk_cnt;
		clk_edge <= next_clk_edge;
		input_buffer <= next_input_buffer;
		drive_state_cnt <= next_drive_state_cnt;
		bus_reset_state_cnt <= next_bus_reset_cnt;
	end
end

always @ *
begin
	next_state = state;
	next_CLK_OUT = CLK_OUT;
	next_clk_cnt = clk_cnt;
	next_clk_edge = clk_edge;
	next_input_buffer = input_buffer;
	next_drive_state_cnt = drive_state_cnt;
	next_bus_reset_state_cnt = bus_reset_state_cnt;
	case (state)
		IDLE:
		begin
			if (~IN)
				next_state = WAIT_HALF_CYCLE;
			next_clk_cnt = 0;	
			next_CLK_OUT = 1;
			next_clk_edge = 0;
		end

		WAIT_HALF_CYCLE:
		begin
			next_clk_cnt = clk_cnt + 1;
			if (clk_cnt==(CLK_DIVIDOR-1))
			begin
				next_clk_cnt = 0;
				next_CLK_OUT = ~CLK_OUT;
				next_clk_edge = ~clk_edge;
				if (clk_edge)
					next_state = ARB_RES;
			end
		end

		ARB_RES:
		begin
			next_clk_cnt = clk_cnt + 1;
			if (clk_cnt==(CLK_DIVIDOR-1))
			begin
				next_clk_cnt = 0;
				next_CLK_OUT = ~CLK_OUT;
				next_clk_edge = ~clk_edge;
				if (clk_edge)
					next_state = DRIVE;
			end
		end

		DRIVE:
		begin
			next_clk_cnt = clk_cnt + 1;
			// Check for reset
			if (drive_state_cnt==2)
			begin
				if (input_buffer_xor)
					next_state = BUS_RESET;
			end

			if (clk_cnt==(CLK_DIVIDOR-1))
			begin
				next_clk_cnt = 0;
				next_CLK_OUT = ~CLK_OUT;
				next_clk_edge = ~clk_edge;
				if (clk_edge)
				begin
					next_input_buffer = {input_buffer[0], IN};
					next_state = LATCH;
					if (drive_state_cnt < 2)
						next_drive_state_cnt = drive_state_cnt + 1;
				end
			end
		end

		LATCH:
		begin
			next_clk_cnt = clk_cnt + 1;
			if (clk_cnt==(CLK_DIVIDOR-1))
			begin
				next_clk_cnt = 0;
				next_CLK_OUT = ~CLK_OUT;
				next_clk_edge = ~clk_edge;
				if (clk_edge)
				begin
					next_input_buffer = {input_buffer[0], IN};
					next_state = DRIVE;
				end
			end
		end

		BUS_RESET:
		begin
			next_clk_cnt = clk_cnt + 1;
			if (clk_cnt==(CLK_DIVIDOR-1))
			begin
				next_clk_cnt = 0;
				next_CLK_OUT = ~CLK_OUT;
				next_clk_edge = ~clk_edge;
				if (clk_edge)
				begin
					if (bus_reset_state_cnt < 3)
						next_bus_reset_state_cnt = bus_reset_state_cnt + 1;
					else
						next_state = IDLE;
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
