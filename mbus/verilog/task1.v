
always @ (posedge clk or negedge resetn) begin
	// not in reset
	if (resetn)
	begin
		case (state)
			// Wake up processor and all B.C.
			TASK0:
			begin
				c0_req_int <= 1;
				state <= TX_WAIT;
			end

			// Querry nodes
			TASK1:
			begin
				c0_tx_addr <= {28'h000000, `CHANNEL_ENUM};
				c0_tx_data <= {`CMD_CHANNEL_ENUM_QUERRY, 28'h0};
				c0_tx_req <= 1;
				c0_tx_pend <= 0;
				c0_priority <= 0;
				state <= TX_WAIT;
			end

			// Enumerate with 4'h2
			TASK2:
			begin
				c0_tx_addr <= {28'h000000, `CHANNEL_ENUM};
				// address should starts with 4'h2
				c0_tx_data <= {`CMD_CHANNEL_ENUM_ENUMERATE, 4'h2, 24'h0};
				c0_tx_req <= 1;
				c0_tx_pend <= 0;
				c0_priority <= 0;
				state <= TX_WAIT;
			end

			// Enumerate with 4'h3
			TASK3:
			begin
				c0_tx_addr <= {28'h000000, `CHANNEL_ENUM};
				c0_tx_data <= {`CMD_CHANNEL_ENUM_ENUMERATE, 4'h3, 24'h0};
				c0_tx_req <= 1;
				c0_tx_pend <= 0;
				c0_priority <= 0;
				state <= TX_WAIT;
			end

			// Enumerate with 4'h4
			TASK4:
			begin
				c0_tx_addr <= {28'h000000, `CHANNEL_ENUM};
				c0_tx_data <= {`CMD_CHANNEL_ENUM_ENUMERATE, 4'h4, 24'h0};
				c0_tx_req <= 1;
				c0_tx_pend <= 0;
				c0_priority <= 0;
				state <= TX_WAIT;
			end

			// Enumerate with 4'h5
			TASK5:
			begin
				c0_tx_addr <= {28'h000000, `CHANNEL_ENUM};
				c0_tx_data <= {`CMD_CHANNEL_ENUM_ENUMERATE, 4'h5, 24'h0};
				c0_tx_req <= 1;
				c0_tx_pend <= 0;
				c0_priority <= 0;
				state <= TX_WAIT;
			end
			// n0 -> 4'h2
			// n1 -> 4'h3
			// n2 -> 4'h4
			// n3 -> 4'h5

			// n1 -> n2 byte streamming using short address
			TASK6: 
			begin
	   			if ((~n1_tx_ack) & (~n1_tx_req)) 
				begin
	      			n1_tx_addr <= {24'h0, 4'h4, 4'h1};	// 4'h1 is functional ID
	      			n1_tx_data <= rand_dat;
	      			n1_tx_req <= 1;
   	      			$fdisplay(handle, "N1 Data in =\t32'h%h", rand_dat);
	      			if (word_counter) 
					begin
		 				word_counter <= word_counter - 1;
		 				n1_tx_pend <= 1;
	      			end
	      			else 
					begin
		 				n1_tx_pend <= 0;
		 				state <= TX_WAIT;
	      			end
	   			end
			end

			// n1 -> n0 byte streamming using short address
			TASK7: 
			begin
	   			if ((~n1_tx_ack) & (~n1_tx_req)) 
				begin
	      			n1_tx_addr <= {24'h0, 4'h2, 4'h3};	// 4'h3 is functional ID
	      			n1_tx_data <= rand_dat;
	      			n1_tx_req <= 1;
   	      			$fdisplay(handle, "N1 Data in =\t32'h%h", rand_dat);
	      			if (word_counter) 
					begin
		 				word_counter <= word_counter - 1;
		 				n1_tx_pend <= 1;
	      			end
	      			else 
					begin
		 				n1_tx_pend <= 0;
		 				state <= TX_WAIT;
	      			end
	   			end
			end

			// n1 -> n2 byte streamming using long address
			TASK8: 
			begin
	   			if ((~n1_tx_ack) & (~n1_tx_req)) 
				begin
	      			n1_tx_addr <= {4'hf, 4'h0, 20'hbbbb2, 4'h1};	// 4'h1 is functional ID
	      			n1_tx_data <= rand_dat;
	      			n1_tx_req <= 1;
   	      			$fdisplay(handle, "N1 Data in =\t32'h%h", rand_dat);
	      			if (word_counter) 
					begin
		 				word_counter <= word_counter - 1;
		 				n1_tx_pend <= 1;
	      			end
	      			else 
					begin
		 				n1_tx_pend <= 0;
		 				state <= TX_WAIT;
	      			end
	   			end
			end

			// n1 -> n0 byte streamming using short address
			TASK9: 
			begin
	   			if ((~n1_tx_ack) & (~n1_tx_req)) 
				begin
	      			n1_tx_addr <= {4'hf, 4'h0, 20'hbbbb0, 4'h3};	// 4'h3 is functional ID
	      			n1_tx_data <= rand_dat;
	      			n1_tx_req <= 1;
   	      			$fdisplay(handle, "N1 Data in =\t32'h%h", rand_dat);
	      			if (word_counter) 
					begin
		 				word_counter <= word_counter - 1;
		 				n1_tx_pend <= 1;
	      			end
	      			else 
					begin
		 				n1_tx_pend <= 0;
		 				state <= TX_WAIT;
	      			end
	   			end
			end

			// Unknown address
			TASK10:
			begin
	   			if ((~n1_tx_ack) & (~n1_tx_req)) 
				begin
	      			n1_tx_addr <= {4'hf, 4'h0, 20'hbbbb5, 4'h2};
	      			n1_tx_data <= rand_dat;
	      			n1_tx_pend <= 0;
	      			n1_tx_req <= 1;
   	      			$fdisplay(handle, "N1 Data in =\t32'h%h", rand_dat);
	      			state <= TX_WAIT;
	   			end
			end
	
			// n1 -> n2 TX buffer underflow
			TASK11: 
			begin
	   			if ((~n1_tx_ack) & (~n1_tx_req)) 
				begin
	      			n1_tx_addr <= {24'h0, 4'h4, 4'h3};
	      			n1_tx_data <= rand_dat;
	      			n1_tx_pend <= 1;
   	      			$fdisplay(handle, "N1 Data in =\t32'h%h", rand_dat);
	      			if (word_counter) 
					begin
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
	
			// n1 -> n0 TX buffer underflow
			TASK12: 
			begin
	   			if ((~n1_tx_ack) & (~n1_tx_req)) 
				begin
	      			n1_tx_addr <= {24'h0, 4'h2, 4'h8};
	      			n1_tx_data <= rand_dat;
	      			n1_tx_pend <= 1;
   	      			$fdisplay(handle, "N1 Data in =\t32'h%h", rand_dat);
	      			if (word_counter) 
					begin
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
	

			// n1 -> n2 RX buffer overflow, middle of transmission
			TASK13: 
			begin
	   			if ((~n1_tx_ack) & (~n1_tx_req)) 
				begin
	      			n1_tx_addr <= {24'h0, 4'h4, 4'h3};
	      			n1_tx_data <= rand_dat;
	      			n1_tx_req <= 1;
   	      			$fdisplay(handle, "N1 Data in =\t32'h%h", rand_dat);
	      			if (word_counter) 
					begin
		 				word_counter <= word_counter - 1;
		 				n1_tx_pend <= 1;
	      			end
	      			else 
					begin
		 				n1_tx_pend <= 0;
		 				state <= TX_WAIT;
	      			end
	   			end
	   			else if (n1_tx_fail) 
				begin
	      			state <= TX_WAIT;
	      			n1_tx_req <= 0;
	   			end
			end
	
			// n1 -> n0 RX buffer overflow, middle of transmission
			TASK14: 
			begin
	   			if ((~n1_tx_ack) & (~n1_tx_req)) 
				begin
	      			n1_tx_addr <= {24'h0, 4'h2, 4'h9};
	      			n1_tx_data <= rand_dat;
	      			n1_tx_req <= 1;
   	      			$fdisplay(handle, "N1 Data in =\t32'h%h", rand_dat);
	      			if (word_counter) 
					begin
		 				word_counter <= word_counter - 1;
		 				n1_tx_pend <= 1;
	      			end
	      			else 
					begin
		 				n1_tx_pend <= 0;
		 				state <= TX_WAIT;
	      			end
	   			end
	   			else if (n1_tx_fail) 
				begin
	      			state <= TX_WAIT;
	      			n1_tx_req <= 0;
	   			end
			end

			//  n1 -> n2 RX buffer overflow, last word
			TASK15: 
			begin
	   			if ((~n1_tx_ack) & (~n1_tx_req)) 
				begin
	      			n1_tx_addr <= {24'h0, 4'h4, 4'h3};
	      			n1_tx_data <= rand_dat;
	      			n1_tx_req <= 1;
   	      			$fdisplay(handle, "N1 Data in =\t32'h%h", rand_dat);
	      			if (word_counter) 
					begin
		 				word_counter <= word_counter - 1;
		 				n1_tx_pend <= 1;
	      			end
	      			else 
					begin
		 				n1_tx_pend <= 0;
		 				state <= TX_WAIT;
	      			end
	   			end
			end

			//  n1 -> n0 RX buffer overflow, last word
			TASK16: 
			begin
	   			if ((~n1_tx_ack) & (~n1_tx_req)) 
				begin
	      			n1_tx_addr <= {24'h0, 4'h2, 4'h9};
	      			n1_tx_data <= rand_dat;
	      			n1_tx_req <= 1;
   	      			$fdisplay(handle, "N1 Data in =\t32'h%h", rand_dat);
	      			if (word_counter) 
					begin
		 				word_counter <= word_counter - 1;
		 				n1_tx_pend <= 1;
	      			end
	      			else 
					begin
		 				n1_tx_pend <= 0;
		 				state <= TX_WAIT;
	      			end
	   			end
			end
	
			// Arbitration test, both n0, n1 transmit to n3.
			// n0 transmits first
			TASK17: 
			begin
	   			if ((~n0_tx_ack) & (~n0_tx_req)) 
				begin
	      			n0_tx_addr <= {24'h0, 4'h5, 4'h8};
	      			n0_tx_data <= rand_dat;
	      			n0_tx_pend <= 0;
	      			n0_tx_req <= 1;
   	      			$fdisplay(handle, "N0 Data in =\t32'h%h", rand_dat);
	   			end
	   			if ((~n1_tx_ack) & (~n1_tx_req)) 
				begin
	      			n1_tx_addr <= {24'h0, 4'h5, 4'h3};
	    		  	n1_tx_data <= rand_dat2;
	    		  	n1_tx_pend <= 0;
	    		  	n1_tx_req <= 1;
   	    		  	$fdisplay(handle, "N1 Data in =\t32'h%h", rand_dat2);
	   			end
	    		state <= TX_WAIT;
			end

			// Priority test1, both n0, n1 transmit to n3
			// n1 sets priority, n1 transmits first
			TASK18: 
			begin
	   			if ((~n0_tx_ack) & (~n0_tx_req)) 
				begin
	      			n0_tx_addr <= {24'h0, 4'h5, 4'h8};
	      			n0_tx_data <= rand_dat;
	      			n0_tx_pend <= 0;
	      			n0_tx_req <= 1;
   	      			$fdisplay(handle, "N0 Data in =\t32'h%h", rand_dat);
	   			end
	   			if ((~n1_tx_ack) & (~n1_tx_req)) 
				begin
	      			n1_tx_addr <= {24'h0, 4'h5, 4'h3};
	      			n1_tx_data <= rand_dat2;
	      			n1_tx_pend <= 0;
	      			n1_tx_req <= 1;
	      			n1_priority <= 1;
   	      			$fdisplay(handle, "N1 Data in =\t32'h%h", rand_dat2);
	   			end
	      		state <= TX_WAIT;
			end

			// Priority test2, both n0, n1 transmit to n3
			// both sets priority. n0 transmits first
			TASK19: 
			begin
	   			if ((~n0_tx_ack) & (~n0_tx_req)) 
				begin
	      			n0_tx_addr <= {24'h0, 4'h5, 4'h8};
	      			n0_tx_data <= rand_dat;
	      			n0_tx_pend <= 0;
	      			n0_tx_req <= 1;
	      			n0_priority <= 1;
   	      			$fdisplay(handle, "N0 Data in =\t32'h%h", rand_dat);
	   			end
	   			if ((~n1_tx_ack) & (~n1_tx_req)) 
				begin
	      			n1_tx_addr <= {24'h0, 4'h5, 4'h3};
	      			n1_tx_data <= rand_dat2;
	      			n1_tx_pend <= 0;
	      			n1_tx_req <= 1;
	      			n1_priority <= 1;
   	      			$fdisplay(handle, "N1 Data in =\t32'h%h", rand_dat2);
	   			end
	      		state <= TX_WAIT;
			end
	
			// Priority test3, only n0 transmits with priority set
			TASK20:  
			begin
	   			if ((~n0_tx_ack) & (~n0_tx_req)) 
				begin
	      			n1_tx_addr <= {24'h0, 4'h5, 4'h3};
	      			n0_tx_data <= rand_dat;
	      			n0_tx_pend <= 0;
	      			n0_tx_req <= 1;
	      			n0_priority <= 1;
   	      			$fdisplay(handle, "N0 Data in =\t32'h%h", rand_dat);
	      			state <= TX_WAIT;
	   			end
			end

			// Sleep all
			TASK21:
			begin
				c0_tx_addr <= {28'hf00000, `CHANNEL_POWER};
				c0_tx_data <= {`CMD_CHANNEL_POWER_ALL_SLEEP, 28'h0};
				c0_tx_req <= 1;
				c0_tx_pend <= 0;
				c0_priority <= 0;
				state <= TX_WAIT;
			end

			// N2 asserts interrupt
			TASK22:
			begin
				n2_req_int <= 1;
				state <= TX_WAIT;
			end

			// n2 -> c0 using short address
			TASK23:
			begin
				n2_tx_addr <= {24'h0, 4'h1, 4'h3};	// 4'h3 is functional ID
				n2_tx_data <= rand_dat;
				n2_tx_req <= 1;
				n2_tx_pend <= 0;
				n2_priority <= 0;
   	      		$fdisplay(handle, "N2 Data in =\t32'h%h", rand_dat);
				state <= TX_WAIT;
			end

			// All layers wake 
			TASK24:
			begin
				c0_tx_addr <= {28'hf00000, `CHANNEL_POWER};
				c0_tx_data <= {`CMD_CHANNEL_POWER_ALL_WAKE, 28'h0};
				c0_tx_req <= 1;
				c0_tx_pend <= 0;
				c0_priority <= 0;
				state <= TX_WAIT;
			end
		endcase
	end
end
