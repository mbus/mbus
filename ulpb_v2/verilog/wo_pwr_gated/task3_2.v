always @ (posedge clk or negedge resetn) begin
   if (~resetn) begin
      n0_tx_addr  <= 0;
      n0_tx_data  <= 0;
      n0_tx_pend  <= 0;
      n0_tx_req   <= 0;
      n0_priority <= 0;

      n1_tx_addr  <= 0;
      n1_tx_data  <= 0;
      n1_tx_pend  <= 0;
      n1_tx_req   <= 0;
      n1_priority <= 0;

      n2_tx_addr  <= 0;
      n2_tx_data  <= 0;
      n2_tx_pend  <= 0;
      n2_tx_req   <= 0;
      n2_priority <= 0;

      c0_tx_addr  <= 0;
      c0_tx_data  <= 0;
      c0_tx_pend  <= 0;
      c0_tx_req   <= 0;
      c0_priority <= 0;

      word_counter <= 0;
   end
   else begin
      if (n0_tx_ack) n0_tx_req <= 0;
      if (n1_tx_ack) n1_tx_req <= 0;
      if (n2_tx_ack) n2_tx_req <= 0;
      if (c0_tx_ack) c0_tx_req <= 0;

      case (state)
	// simple transmission
	TASK0: begin
	   if ((~n1_tx_ack) & (~n1_tx_req)) begin
	      n1_tx_addr <= 8'hef;
	      n1_tx_data <= rand_dat;
	      n1_tx_req <= 1;
   	      $fdisplay(handle, "N1 Data in =\t32'h%h", rand_dat);
	      if (word_counter) begin
		 word_counter <= word_counter - 1;
		 n1_tx_pend <= 1;
	      end
	      else begin
		 n1_tx_pend <= 0;
		 state <= TX_WAIT;
	      end
	   end // if ((~n1_tx_ack) & (~n1_tx_req))
	end // case: TASK0
      endcase // case (state)
   end // else: !if(~resetn)
end // always @ (posedge clk or negedge resetn)
