
always @ (posedge clk or negedge resetn) begin
	// not in reset
	if (resetn)
	begin
		case (state)
			// wake up processor
			TASK0:
			begin
				c0_wakeup <= 1;
				state <= TX_WAIT;
			end

			// prepare to transmit
			TASK1:
			begin
				c0_req_int <= 1;
				state <= TX_WAIT;
			end
      	endcase // case (state)
	end
end // always @ (posedge clk or negedge resetn)
