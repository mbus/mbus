module control(IN, OUT, RESET, CLK_OUT, CLK_IN);

input 	IN, RESET, CLK_IN;
output 	OUT, CLK_OUT;

reg		[1:0] state, next_state;
reg		CLK_OUT, next_CLK_OUT;

parameter CLK_DIVIDOR = 10;

always @ (posedge CLK_IN or negedge RESET)
begin
	if (~RESET)
	begin
		state <= IDLE;
		CLK_OUT <= 1;
	end
	else
	begin
		state <= next_state;
		CLK_OUT <= next_CLK_OUT;
	end
end

always @ *
begin
	next_state = state;
	next_clk_cnt = clk_cnt;
	case (state)
		IDLE:
		begin
			if (~IN)
				next_state = WAIT_HALF_CYCLE;
			next_clk_cnt = 0;	
		end

		WAIT_HALF_CYCLE:
		begin
			next_clk_cnt = clk_cnt + 1;
			if (clk_cnt==CLK_DIVIDOR)
			begin
				
			end
		end
	endcase
end

endmodule
