
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

			// n1 -> n3 byte streamming using short address
			TASK6: 
			begin
	   			if ((~n1_tx_ack) & (~n1_tx_req)) 
				begin
	      			n1_tx_addr <= {24'h0, 4'h5, 4'h1};	// 4'h1 is functional ID
	      			n1_tx_data <= rand_dat;
	      			n1_tx_req <= 1;
   	      			$fdisplay(handle, "N1 Data in =\t32'h%h", rand_dat);
	      			if (word_counter) 
					begin
		 				word_counter <= word_counter - 1;
		 				n1_tx_pend <= 1;
						if (word_counter==2)
							err_start <= 1;
	      			end
	      			else 
					begin
		 				n1_tx_pend <= 0;
		 				state <= TX_WAIT;
						err_start <= 0;
	      			end
	   			end

				if (n1_tx_fail)
				begin
		 			n1_tx_pend <= 0;
		 			state <= TX_WAIT;
					err_start <= 0;
				end
			end

			TASK7: 
			begin
	   			if ((~n1_tx_ack) & (~n1_tx_req)) 
				begin
	      			n1_tx_addr <= {24'h0, 4'h5, 4'h1};	// 4'h1 is functional ID
	      			n1_tx_data <= rand_dat;
	      			n1_tx_req <= 1;
   	      			$fdisplay(handle, "N1 Data in =\t32'h%h", rand_dat);
		 			n1_tx_pend <= 0;
		 			state <= TX_WAIT;
	   			end
			end

			// n1 -> n3 byte streamming using short address
			TASK8: 
			begin
	   			if ((~n1_tx_ack) & (~n1_tx_req)) 
				begin
	      			n1_tx_addr <= {24'h0, 4'h5, 4'h1};	// 4'h1 is functional ID
	      			n1_tx_data <= rand_dat;
	      			n1_tx_req <= 1;
   	      			$fdisplay(handle, "N1 Data in =\t32'h%h", rand_dat);
	      			if (word_counter) 
					begin
		 				word_counter <= word_counter - 1;
		 				n1_tx_pend <= 1;
						if (word_counter==2)
						begin
							err_start <= 1;
							err_type <= 1;
						end
	      			end
	      			else 
					begin
		 				n1_tx_pend <= 0;
		 				state <= TX_WAIT;
						err_start <= 0;
						err_type <= 0;
	      			end
	   			end

				if (n1_tx_fail)
				begin
		 			n1_tx_pend <= 0;
		 			state <= TX_WAIT;
					err_start <= 0;
					err_type <= 0;
				end
			end

			// n1 -> n3, clk glitch after interrupt
			TASK9: 
			begin
	   			if ((~n1_tx_ack) & (~n1_tx_req)) 
				begin
	      			n1_tx_addr <= {24'h0, 4'h5, 4'h1};	// 4'h1 is functional ID
	      			n1_tx_data <= rand_dat;
	      			n1_tx_req <= 1;
   	      			$fdisplay(handle, "N1 Data in =\t32'h%h", rand_dat);
		 			n1_tx_pend <= 0;
					err_start <= 1;
					err_type <= 2;
		 			state <= TX_WAIT;
	   			end
			end

			// n1 -> n3, missing clk edge after interrupt
			TASK10: 
			begin
	   			if ((~n1_tx_ack) & (~n1_tx_req)) 
				begin
	      			n1_tx_addr <= {24'h0, 4'h5, 4'h1};	// 4'h1 is functional ID
	      			n1_tx_data <= rand_dat;
	      			n1_tx_req <= 1;
   	      			$fdisplay(handle, "N1 Data in =\t32'h%h", rand_dat);
		 			n1_tx_pend <= 0;
					err_start <= 1;
					err_type <= 3;
		 			state <= TX_WAIT;
	   			end
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
