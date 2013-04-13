
always @ (posedge clk or negedge resetn) begin
	// not in reset
	if (resetn)
	begin
		case (state)
			TASK0:
			begin
				c0_wakeup <= 1;
				state <= TX_WAIT;
			end
      	endcase // case (state)
	end
end // always @ (posedge clk or negedge resetn)
