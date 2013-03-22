
parameter DEST0 = 8'b1011_0000;
parameter DATA0 = 32'hD800_F0F0;
parameter DEST1 = 8'b1011_1000;
parameter DATA1 = 32'h0AA0_0000;
parameter DEST2 = 8'b1011_1010;
parameter DATA2 = 32'hABCD_1234;
parameter DEST3 = 8'b1011_0010;
parameter DATA3 = 32'h0000_0080;

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
	// COMMAND 0
	TASK0: begin
	   if ((~c0_tx_ack) & (~c0_tx_req)) begin
	      c0_tx_addr <= DEST0;
	      c0_tx_data <= DATA0;
	      c0_tx_pend <= 0;
	      c0_tx_req <= 1;
   	      $fdisplay(handle, "C0 Data in =\t32'h%h", DATA0);
	      state <= TX_WAIT;
	   end
	end

	// COMMAND 1
	TASK1: begin
	   if ((~c0_tx_ack) & (~c0_tx_req)) begin
	      c0_tx_addr <= DEST1;
	      c0_tx_data <= DATA1;
	      c0_tx_pend <= 0;
	      c0_tx_req <= 1;
   	      $fdisplay(handle, "C0 Data in =\t32'h%h", DATA1);
	      state <= TX_WAIT;
	   end
	end

	// COMMAND 2
	TASK2: begin
	   if ((~c0_tx_ack) & (~c0_tx_req)) begin
	      c0_tx_addr <= DEST2;
	      c0_tx_data <= DATA2;
	      c0_tx_pend <= 0;
	      c0_tx_req <= 1;
   	      $fdisplay(handle, "C0 Data in =\t32'h%h", DATA2);
	      state <= TX_WAIT;
	   end
	end

	// COMMAND 3
	TASK3: begin
	   if ((~c0_tx_ack) & (~c0_tx_req)) begin
	      c0_tx_addr <= DEST3;
	      c0_tx_data <= DATA3;
	      c0_tx_pend <= 0;
	      c0_tx_req <= 1;
   	      $fdisplay(handle, "C0 Data in =\t32'h%h", DATA3);
	      state <= TX_WAIT;
	   end
	end

	// COMMAND 4
	TASK4: begin
	   if ((~c0_tx_ack) & (~c0_tx_req)) begin
	      c0_tx_addr <= `BROADCAST_ADDR;
	      c0_tx_data <= (`GLOBAL_SHUTDOWN_MSG<<24);
	      c0_tx_pend <= 0;
	      c0_tx_req <= 1;
   	      $fdisplay(handle, "C0 Data in =\t32'h%h", 32'hff000000);
	      state <= TX_WAIT;
	   end
	end

      endcase // case (state)
   end
end // always @ (posedge clk or negedge resetn)
