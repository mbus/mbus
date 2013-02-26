
`include "include/ulpb_def.v"

module ulpb_ctrl(
	input CLK_EXT,
	input RESETn,
	input CLKIN,
	output CLKOUT,
	input DIN,
	output reg DOUT
);

`include "include/ulpb_func.v"

parameter BUS_IDLE = 0;
parameter BUS_WAIT_START = 1;
parameter BUS_IDLE_ARBI = 12;
parameter BUS_ARBITRATE = 2;
parameter BUS_PRIO = 3;
parameter BUS_ACTIVE = 4;
parameter BUS_INTERRUPT = 5;
parameter BUS_SWITCH_ROLE = 6;
parameter BUS_LEAVE_INTERRUPT = 7;
parameter BUS_CONTROL0 = 8;
parameter BUS_CONTROL1 = 9;
parameter BUS_BACK_TO_IDLE = 11;

parameter NUM_OF_BUS_STATE = 13;
parameter START_CYCLES = 10;
parameter BUS_INTERRUPT_COUNTER = 6;

reg		[log2(START_CYCLES-1)-1:0] start_cycle_cnt, next_start_cycle_cnt;
reg		[log2(NUM_OF_BUS_STATE-1)-1:0] bus_state, next_bus_state, bus_state_neg;
reg		clk_en, next_clk_en;
reg		[log2(BUS_INTERRUPT_COUNTER-1)-1:0] bus_interrupt_cnt, next_bus_interrupt_cnt;

reg		clkin_sampled_neg; 
reg		[2:0] din_sampled_neg, din_sampled_pos;

assign CLKOUT = (clk_en)? CLK_EXT : 1'b1;

always @ (posedge CLK_EXT or negedge RESETn)
begin
	if (~RESETn)
	begin
		bus_state <= BUS_IDLE;
		start_cycle_cnt <= START_CYCLES - 1'b1;
		clk_en <= 0;
		bus_interrupt_cnt <= BUS_INTERRUPT_COUNTER - 1'b1;
	end
	else
	begin
		bus_state <= next_bus_state;
		start_cycle_cnt <= next_start_cycle_cnt;
		clk_en <= next_clk_en;
		bus_interrupt_cnt <= next_bus_interrupt_cnt;
	end
end

always @ *
begin
	next_bus_state = bus_state;
	next_start_cycle_cnt = start_cycle_cnt;
	next_clk_en = clk_en;
	next_bus_interrupt_cnt = bus_interrupt_cnt;

	case (bus_state)
		BUS_IDLE:
		begin
			if (~DIN)
				next_bus_state = BUS_WAIT_START;	
			next_start_cycle_cnt = START_CYCLES - 1'b1;
		end

		BUS_WAIT_START:
		begin
			if (start_cycle_cnt)
				next_start_cycle_cnt = start_cycle_cnt - 1'b1;
			else
			begin
				next_clk_en = 1;
				next_bus_state = BUS_ARBITRATE;
			end
		end

		BUS_IDLE_ARBI:
		begin
			next_bus_state = BUS_ARBITRATE;
		end

		BUS_ARBITRATE:
		begin
			next_bus_state = BUS_PRIO;
		end

		BUS_PRIO:
		begin
			next_bus_state = BUS_ACTIVE;
		end

		BUS_ACTIVE:
		begin
			if (~clkin_sampled_neg)
			begin
				next_clk_en = 0;
				next_bus_state = BUS_INTERRUPT;
			end
			next_bus_interrupt_cnt = BUS_INTERRUPT_COUNTER - 1'b1;
		end

		BUS_INTERRUPT:
		begin
			if (bus_interrupt_cnt)
				next_bus_interrupt_cnt = bus_interrupt_cnt - 1'b1;
			else
			begin
				if ({din_sampled_neg, din_sampled_pos}==6'b111_000)
				begin
					next_bus_state = BUS_SWITCH_ROLE;
					next_clk_en = 1;
				end
			end
		end

		BUS_SWITCH_ROLE:
		begin
			next_bus_state = BUS_LEAVE_INTERRUPT;
		end

		BUS_LEAVE_INTERRUPT:
		begin
			next_bus_state = BUS_CONTROL0;
		end

		BUS_CONTROL0:
		begin
			next_bus_state = BUS_CONTROL1;
		end

		BUS_CONTROL1:
		begin
			next_bus_state = BUS_BACK_TO_IDLE;
		end

		BUS_BACK_TO_IDLE:
		begin
			if (~DIN)
			begin
				next_bus_state = BUS_IDLE_ARBI;
			end
			else
			begin
				next_bus_state = BUS_IDLE;
				next_clk_en = 0;
			end
		end
	endcase
end

always @ (negedge CLK_EXT or negedge RESETn)
begin
	if (~RESETn)
	begin
		clkin_sampled_neg <= 0;
		din_sampled_neg <= 0;
		bus_state_neg <= BUS_IDLE;
	end
	else
	begin
		clkin_sampled_neg <= CLKIN;
		if (bus_state==BUS_INTERRUPT)
			din_sampled_neg <= {din_sampled_neg[1:0], DIN};
		bus_state_neg <= bus_state;
	end
end

always @ (posedge CLK_EXT or negedge RESETn)
begin
	if (~RESETn)
	begin
		din_sampled_pos <= 0;
	end
	else
	begin
		if (bus_state==BUS_INTERRUPT)
			din_sampled_pos <= {din_sampled_pos[1:0], DIN};
	end
end

always @ *
begin
	DOUT = DIN;
	case (bus_state_neg)
		BUS_IDLE: begin DOUT = 1; end
		BUS_WAIT_START: begin DOUT = 1; end
		BUS_IDLE_ARBI: begin DOUT = 1; end
		BUS_ARBITRATE: begin DOUT = 1; end
		BUS_INTERRUPT: begin DOUT = CLK_EXT; end
		BUS_BACK_TO_IDLE: begin DOUT = 1; end
	endcase

end
endmodule

