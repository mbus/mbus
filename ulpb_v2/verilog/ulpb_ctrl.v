
`include "include/ulpb_def.v"

module ulpb_ctrl{
	input CLK_EXT,
	input RESET,
	input CLKIN,
	output CLKOUT,
	input DIN,
	output DOUT
};

parameter BUS_IDLE
parameter BUS_WAIT_START
parameter BUS_ARBITRATE


reg		[3:0] bus_state, next_bus_state;
reg		clk_en, next_clk_en;	

assign CLKOUT = (clk_en)? CLK_EXT : 1'b1;

always @ (posedge CLK_EXT or posedge RESET)
begin
	if (RESET)
	begin
		bus_state <= BUS_IDLE;
		start_cycle_cnt <= START_CYCLES - 1'b1;
		clk_en <= 0;
	end
	else
	begin
		bus_state <= next_bus_state;
		start_cycle_cnt <= next_start_cycle_cnt;
		clk_en <= next_clk_en;
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
		end

		BUS_INTERRUPT:
		begin
			
		end

	endcase
end

always @ (negedge CLK_EXT or posedge RESET)
begin
	if (RESET)
	begin
		clkin_sampled <= 0;
	end
	else
	begin
		clkin_sampled <= CLKIN;
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
	endcase

end

endmodule

