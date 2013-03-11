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
	      n1_tx_pend <= 0;
	      n1_tx_req <= 1;
   	      $fdisplay(handle, "N1 Data in =\t32'h%h", rand_dat);
	      state <= TX_WAIT;
	   end
	end
	
	// simple transmission, RX above TX
	TASK1: begin
	   if ((~n1_tx_ack) & (~n1_tx_req)) begin
	      n1_tx_addr <= 8'hab;
	      n1_tx_data <= rand_dat;
	      n1_tx_pend <= 0;
	      n1_tx_req <= 1;
   	      $fdisplay(handle, "N1 Data in =\t32'h%h", rand_dat);
	      state <= TX_WAIT;
	   end
	end

	// streaming down
	TASK2: begin
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
	   end
	end

	// streaming up 
	TASK3: begin
	   if ((~n1_tx_ack) & (~n1_tx_req)) begin
	      n1_tx_addr <= 8'hab;
	      n1_tx_data <= rand_dat;
	      n1_tx_req <= 1;
   	      $fdisplay(handle, "N1 Data in =\t32'h%h", rand_dat);
	      if (word_counter)begin
		 word_counter <= word_counter - 1;
		 n1_tx_pend <= 1;
	      end
	      else begin
		 n1_tx_pend <= 0;
		 state <= TX_WAIT;
	      end
	   end
	end
	
	// Unknown address
	TASK4: begin
	   if ((~n1_tx_ack) & (~n1_tx_req)) begin
	      n1_tx_addr <= 8'hff;
	      n1_tx_data <= rand_dat;
	      n1_tx_pend <= 0;
	      n1_tx_req <= 1;
   	      $fdisplay(handle, "N1 Data in =\t32'h%h", rand_dat);
	      state <= TX_WAIT;
	   end
	end
	
	// TX buffer underflow
	TASK5: begin
	   if ((~n1_tx_ack) & (~n1_tx_req)) begin
	      n1_tx_addr <= 8'hef;
	      n1_tx_data <= rand_dat;
	      n1_tx_pend <= 1;
   	      $fdisplay(handle, "N1 Data in =\t32'h%h", rand_dat);
	      if (word_counter) begin
		 n1_tx_req <= 1;
		 word_counter <= word_counter - 1;
	      end
	      else begin
		 n1_tx_req <= 0;
		 state <= TX_WAIT;
	      end
	   end
	end
	
	// TX buffer underflow
	TASK6: begin
	   if ((~n1_tx_ack) & (~n1_tx_req)) begin
	      n1_tx_addr <= 8'hab;
	      n1_tx_data <= rand_dat;
	      n1_tx_pend <= 1;
   	      $fdisplay(handle, "N1 Data in =\t32'h%h", rand_dat);
	      if (word_counter) begin
		 n1_tx_req <= 1;
		 word_counter <= word_counter - 1;
	      end
	      else
		begin
		   n1_tx_req <= 0;
		   state <= TX_WAIT;
		end
	   end
	end

	// RX buffer overflow, middle of transmission
	TASK7: begin
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
	   end
	   else if (n1_tx_fail) begin
	      state <= TX_WAIT;
	      n1_tx_req <= 0;
	   end
	end
	
	// RX buffer overflow, middle of transmission
	TASK8: begin
	   if ((~n1_tx_ack) & (~n1_tx_req)) begin
	      n1_tx_addr <= 8'hab;
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
	   end
	   else if (n1_tx_fail) begin
	      state <= TX_WAIT;
	      n1_tx_req <= 0;
	   end
	end
	
	// RX buffer overflow, last word
	TASK9: begin
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
	   end
	end

	// RX buffer overflow, last word
	TASK10: begin
	   if ((~n1_tx_ack) & (~n1_tx_req)) begin
	      n1_tx_addr <= 8'hab;
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
	   end
	end
	
	// Arbitration test
	TASK11: begin
	   if ((~n0_tx_ack) & (~n0_tx_req)) begin
	      n0_tx_addr <= 8'hef;
	      n0_tx_data <= rand_dat;
	      n0_tx_pend <= 0;
	      n0_tx_req <= 1;
   	      $fdisplay(handle, "N0 Data in =\t32'h%h", rand_dat);
	   end
	   if ((~n1_tx_ack) & (~n1_tx_req)) begin
	      n1_tx_addr <= 8'hef;
	      n1_tx_data <= rand_dat2;
	      n1_tx_pend <= 0;
	      n1_tx_req <= 1;
   	      $fdisplay(handle, "N1 Data in =\t32'h%h", rand_dat2);
	      state <= TX_WAIT;
	   end
	end

	// Priority test1
	TASK12: begin
	   if ((~n0_tx_ack) & (~n0_tx_req)) begin
	      n0_tx_addr <= 8'hef;
	      n0_tx_data <= rand_dat;
	      n0_tx_pend <= 0;
	      n0_tx_req <= 1;
   	      $fdisplay(handle, "N0 Data in =\t32'h%h", rand_dat);
	   end
	   if ((~n1_tx_ack) & (~n1_tx_req)) begin
	      n1_tx_addr <= 8'hef;
	      n1_tx_data <= rand_dat2;
	      n1_tx_pend <= 0;
	      n1_tx_req <= 1;
	      n1_priority <= 1;
   	      $fdisplay(handle, "N1 Data in =\t32'h%h", rand_dat2);
	      state <= TX_WAIT;
	   end
	end

	// Priority test2
	// Geometry Priority + Priority
	TASK13: begin
	   if ((~n0_tx_ack) & (~n0_tx_req)) begin
	      n0_tx_addr <= 8'hef;
	      n0_tx_data <= rand_dat;
	      n0_tx_pend <= 0;
	      n0_tx_req <= 1;
	      n0_priority <= 1;
   	      $fdisplay(handle, "N0 Data in =\t32'h%h", rand_dat);
	   end
	   if ((~n1_tx_ack) & (~n1_tx_req)) begin
	      n1_tx_addr <= 8'hef;
	      n1_tx_data <= rand_dat2;
	      n1_tx_pend <= 0;
	      n1_tx_req <= 1;
	      n1_priority <= 1;
   	      $fdisplay(handle, "N1 Data in =\t32'h%h", rand_dat2);
	      state <= TX_WAIT;
	   end
	end
	
	// Priority test3
	// Geometry Priority
	TASK14:  begin
	   if ((~n0_tx_ack) & (~n0_tx_req)) begin
	      n0_tx_addr <= 8'hef;
	      n0_tx_data <= rand_dat;
	      n0_tx_pend <= 0;
	      n0_tx_req <= 1;
	      n0_priority <= 1;
   	      $fdisplay(handle, "N0 Data in =\t32'h%h", rand_dat);
	      state <= TX_WAIT;
	   end
	end
	
	// Broadcast test
	TASK15: begin
	   if ((~n0_tx_ack) & (~n0_tx_req)) begin
	      n0_tx_addr <= `BROADCAST_ADDR;
	      n0_tx_data <= rand_dat;
	      n0_tx_pend <= 0;
	      n0_tx_req <= 1;
	      n0_priority <= 1;
   	      $fdisplay(handle, "N0 Data in =\t32'h%h", rand_dat);
	      state <= TX_WAIT;
	   end
	end
	
	// control test, rx_req should not assert
	TASK16: begin
	   if ((~n1_tx_ack) & (~n1_tx_req)) begin
	      n1_tx_addr <= 8'h01;
	      n1_tx_data <= rand_dat;
	      n1_tx_pend <= 0;
	      n1_tx_req <= 1;
	      n1_priority <= 1;
   	      $fdisplay(handle, "N1 Data in =\t32'h%h", rand_dat);
	      state <= TX_WAIT;
	   end
	end
	
	// control test 
	TASK17: begin
	   if ((~n1_tx_ack) & (~n1_tx_req)) begin
	      n1_tx_addr <= 8'haa;
	      n1_tx_data <= rand_dat;
	      n1_tx_pend <= 0;
	      n1_tx_req <= 1;
	      n1_priority <= 1;
   	      $fdisplay(handle, "N1 Data in =\t32'h%h", rand_dat);
	      state <= TX_WAIT;
	   end
	end

	// simple transmission
	TASK18: begin
	   if ((~n0_tx_ack) & (~n0_tx_req)) begin
	      n0_tx_addr <= 8'hcd;
	      n0_tx_data <= rand_dat;
	      n0_tx_pend <= 0;
	      n0_tx_req <= 1;
   	      $fdisplay(handle, "N0 Data in =\t32'h%h", rand_dat);
	      state <= TX_WAIT;
	   end
	end
	
	// simple transmission, RX above TX
	TASK19: begin
	   if ((~n2_tx_ack) & (~n2_tx_req))
	     begin
		n2_tx_addr <= 8'hcd;
		n2_tx_data <= rand_dat;
		n2_tx_pend <= 0;
		n2_tx_req <= 1;
   		$fdisplay(handle, "N2 Data in =\t32'h%h", rand_dat);
		state <= TX_WAIT;
	     end
	end
	
	// streaming down
	TASK20: begin
	   if ((~n0_tx_ack) & (~n0_tx_req))
	     begin
		n0_tx_addr <= 8'hcd;
		n0_tx_data <= rand_dat;
		n0_tx_req <= 1;
   		$fdisplay(handle, "N0 Data in =\t32'h%h", rand_dat);
		if (word_counter) begin
		   word_counter <= word_counter - 1;
		   n0_tx_pend <= 1;
		end
		else begin
		   n0_tx_pend <= 0;
		   state <= TX_WAIT;
		end
	     end
	end
	
	// streaming up 
	TASK21: begin
	   if ((~n2_tx_ack) & (~n2_tx_req)) begin
	      n2_tx_addr <= 8'hcd;
	      n2_tx_data <= rand_dat;
	      n2_tx_req <= 1;
   	      $fdisplay(handle, "N2 Data in =\t32'h%h", rand_dat);
	      if (word_counter) begin
		 word_counter <= word_counter - 1;
		 n2_tx_pend <= 1;
	      end
	      else begin
		 n2_tx_pend <= 0;
		 state <= TX_WAIT;
	      end
	   end
	end

	// RX buffer overflow, middle of transmission
	TASK22: begin
	   if ((~n0_tx_ack) & (~n0_tx_req)) begin
	      n0_tx_addr <= 8'hcd;
	      n0_tx_data <= rand_dat;
	      n0_tx_req <= 1;
   	      $fdisplay(handle, "N0 Data in =\t32'h%h", rand_dat);
	      if (word_counter) begin
		 word_counter <= word_counter - 1;
		 n0_tx_pend <= 1;
	      end
	      else begin
		 n0_tx_pend <= 0;
		 state <= TX_WAIT;
	      end
	   end
	   else if (n0_tx_fail) begin
	      state <= TX_WAIT;
	      n0_tx_req <= 0;
	   end
	end

	TASK23: begin
	   if ((~n2_tx_ack) & (~n2_tx_req)) begin
	      n2_tx_addr <= 8'hcd;
	      n2_tx_data <= rand_dat;
	      n2_tx_req <= 1;
   	      $fdisplay(handle, "N2 Data in =\t32'h%h", rand_dat);
	      if (word_counter) begin
		 word_counter <= word_counter - 1;
		 n2_tx_pend <= 1;
	      end
	      else begin
		 n2_tx_pend <= 0;
		 state <= TX_WAIT;
	      end
	   end
	   else if (n2_tx_fail) begin
	      state <= TX_WAIT;
	      n2_tx_req <= 0;
	   end
	end
	
	// RX buffer overflow, last word
	TASK24: begin
	   if ((~n0_tx_ack) & (~n0_tx_req)) begin
	      n0_tx_addr <= 8'hcd;
	      n0_tx_data <= rand_dat;
	      n0_tx_req <= 1;
   	      $fdisplay(handle, "N0 Data in =\t32'h%h", rand_dat);
	      if (word_counter) begin
		 word_counter <= word_counter - 1;
		 n0_tx_pend <= 1;
	      end
	      else begin
		 n0_tx_pend <= 0;
		 state <= TX_WAIT;
	      end
	   end
	end

	TASK25: begin
	   if ((~n2_tx_ack) & (~n2_tx_req)) begin
	      n2_tx_addr <= 8'hcd;
	      n2_tx_data <= rand_dat;
	      n2_tx_req <= 1;
   	      $fdisplay(handle, "N2 Data in =\t32'h%h", rand_dat);
	      if (word_counter) begin
		 word_counter <= word_counter - 1;
		 n2_tx_pend <= 1;
	      end
	      else begin
		 n2_tx_pend <= 0;
		 state <= TX_WAIT;
	      end
	   end
	end
      endcase // case (state)
   end
end // always @ (posedge clk or negedge resetn)
