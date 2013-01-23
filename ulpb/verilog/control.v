
`timescale 1ns/1ps

module control(DIN, DOUT, RESET, CLK_OUT, CLK_IN);

`include "include/ulpb_func.v"

input 	CLK_IN;
output	CLK_OUT;
input	RESET;
input	DIN;
output	DOUT;

reg		CLK_EN, next_clk_en;
wire	DOUT;

parameter RESET_CYCLES = 4;
parameter START_CYCLES = 6;

reg		[log2(START_CYCLES-1)-1:0] reset_cycle_cnt, next_reset_cycle_cnt;
reg		[1:0]	input_buffer, next_input_buffer;
reg		ctrl_hold, next_ctrl_hold;

parameter BUS_IDLE = 0;
parameter WAIT_FOR_START = 1;
parameter ENABLE_CLK = 2;
parameter ARBI_RES = 3;
parameter DRIVE1 = 4;
parameter LATCH1 = 5;
parameter DRIVE2 = 6;
parameter LATCH2 = 7;
parameter BUS_RESET = 8;
parameter BUS_DISABLE = 9;

parameter NUM_OF_STATES = 10;

reg		[log2(NUM_OF_STATES-1)-1:0] state, next_state;
reg		bus_reset, next_bus_reset;

wire input_buffer_xor = input_buffer[0] ^ input_buffer[1];
wire	CLK_OUT = (CLK_IN | (~CLK_EN));

always @ (posedge CLK_IN or negedge RESET)
begin
	if (~RESET)
	begin
		CLK_EN <= 0;
		state <= BUS_IDLE;
		input_buffer <= 0;
		reset_cycle_cnt <= START_CYCLES - 1;
		ctrl_hold <= 1;
		bus_reset <= 0;
	end
	else
	begin
		CLK_EN <= next_clk_en;
		state <= next_state;
		input_buffer <= next_input_buffer; 
		reset_cycle_cnt <= next_reset_cycle_cnt;
		ctrl_hold <= next_ctrl_hold;
		bus_reset <= next_bus_reset;
	end
end

assign DOUT = (ctrl_hold)? 1 : DIN;

always @ *
begin
	next_clk_en = CLK_EN;
	next_state = state;
	next_input_buffer = input_buffer;
	next_reset_cycle_cnt = reset_cycle_cnt;
	next_ctrl_hold = ctrl_hold;
	next_bus_reset = bus_reset;


	case (state)
		BUS_IDLE:
		begin
			if (~DIN)
			begin
				next_state = WAIT_FOR_START;
			end
			next_reset_cycle_cnt = START_CYCLES - 1;
			next_bus_reset = 0;
		end

		WAIT_FOR_START:
		begin
			if (reset_cycle_cnt)
				next_reset_cycle_cnt = reset_cycle_cnt - 1;
			else
			begin
				next_state = ENABLE_CLK;
				next_clk_en = 1;
			end
		end

		ENABLE_CLK:
		begin
			next_state = ARBI_RES;
		end

		ARBI_RES:
		begin
			next_state = DRIVE1;
			next_ctrl_hold = 0;
		end

		DRIVE1:
		begin
			next_state = LATCH1;
			next_input_buffer = {input_buffer[0], DIN};
		end

		LATCH1:
		begin
			next_state = DRIVE2;
		end

		DRIVE2:
		begin
			next_input_buffer = {input_buffer[0], DIN};
			next_state = LATCH2;
		end

		LATCH2:
		begin
			if (bus_reset==1)
			begin
				next_state = BUS_RESET;
				next_ctrl_hold = 1;
			end
			else
			begin
				next_state = DRIVE1;
				if (input_buffer_xor)
					next_bus_reset = 1;
			end
			next_reset_cycle_cnt = RESET_CYCLES - 1;
		end

		BUS_RESET:
		begin
			if (reset_cycle_cnt)
			begin
				next_reset_cycle_cnt = reset_cycle_cnt - 1;
			end
			else
			begin
				next_state = BUS_DISABLE;
				next_reset_cycle_cnt = RESET_CYCLES - 1;
				next_clk_en = 0;
			end	
		end

		BUS_DISABLE:
		begin
			if (reset_cycle_cnt)
				next_reset_cycle_cnt = reset_cycle_cnt - 1;
			else
				next_state = BUS_IDLE;
		end
	endcase
end

endmodule
