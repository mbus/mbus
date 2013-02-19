
`include "include/ulpb_def.v"

module ulpb_ctrl{
	input CLK_EXT,
	input RESETn,
	input CLKIN,
	output CLKOUT,
	input DIN,
	output DOUT
};

parameter BUS_INTERRUPT_COUNTER 

parameter BUS_IDLE
parameter BUS_WAIT_START
parameter BUS_ARBITRATE


reg		[3:0] bus_state, next_bus_state;
reg		clk_en, next_clk_en;

reg		[log2(BUS_INTERRUPT_COUNTER-1)-1:0] bus_interrupt_cnt, next_bus_interrupt_cnt;

assign CLKOUT = (clk_en)? CLK_EXT : 1'b1;

always @ (posedge CLK_EXT or negedge RESETn)
begin
	if (~RESETn)
	begin
		bus_state <= BUS_IDLE;
		start_cycle_cnt <= START_CYCLES - 1'b1;
		clk_en <= 0;
		bus_interrupt_cnt <= BUS_INTERRUPT_CNT - 1'b1;
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
			if (~clkin_sampled)
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
				next_bus_state = BUS_INTERRUPT_CHECK;
		end

		BUS_INTERRUPT_CHECK:
		begin
			if (din_sampled_neg ^ din_sampled_pos)
			begin
				next_bus_state = BUS_SWITCH_ROLE;
				next_clk_en = 1;
			end
		end

		BUS_SWITCH_ROLE:
		begin

		end

	endcase
end

always @ (negedge CLK_EXT or negedge RESETn)
begin
	if (~RESETn)
	begin
		clkin_sampled <= 0;
		din_sampled_neg <= 0;
	end
	else
	begin
		clkin_sampled <= CLKIN;
		if (bus_state==BUS_INTERRUPT)
			din_sampled_neg <= DIN;
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
			din_sampled_pos <= DIN;
	end
end


always @ *
begin
	DOUT = DIN;
	case (bus_state)
		BUS_IDLE: begin DOUT = 1; end
		BUS_WAIT_START: begin DOUT = 1; end
		BUS_ARBITRATE: begin DOUT = 1; end
		BUS_INTERRUPT: begin DOUT = CLK_EXT; end
		BUS_INTERRUPT_CHECK: begin DOUT = CLK_EXT; end
	endcase

end

endmodule

