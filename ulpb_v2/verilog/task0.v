
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

			// n1->n0 using long address
			TASK5:
			begin
				n1_tx_addr <= {4'hf, 4'h0, 20'hbbbb0, 4'h3};
				n1_tx_data <= rand_dat;
				n1_tx_pend <= 0;
				n1_tx_req <= 1;
				n1_priority <= 0;
   	      		$fdisplay(handle, "N1 Data in =\t32'h%h", rand_dat);
				state <= TX_WAIT;
			end

			// n1->n2 using long address
			TASK6:
			begin
				n1_tx_addr <= {4'hf, 4'h0, 20'hbbbb2, 4'h5};
				n1_tx_data <= rand_dat;
				n1_tx_pend <= 0;
				n1_tx_req <= 1;
				n1_priority <= 0;
   	      		$fdisplay(handle, "N1 Data in =\t32'h%h", rand_dat);
				state <= TX_WAIT;
			end

			// n1->n0 using short address
			TASK7:
			begin
				n1_tx_addr <= {24'h0, 4'h2, 4'h5}; // last 4-bits (4'h5) are functional ID
				n1_tx_data <= rand_dat;
				n1_tx_pend <= 0;
				n1_tx_req <= 1;
				n1_priority <= 0;
   	      		$fdisplay(handle, "N1 Data in =\t32'h%h", rand_dat);
				state <= TX_WAIT;
			end

			// n1->n2 using short address
			TASK8:
			begin
				n1_tx_addr <= {24'h0, 4'h4, 4'h1};	// last 4-bits (4'h1) are functional ID
				n1_tx_data <= rand_dat;
				n1_tx_pend <= 0;
				n1_tx_req <= 1;
				n1_priority <= 0;
   	      		$fdisplay(handle, "N1 Data in =\t32'h%h", rand_dat);
				state <= TX_WAIT;
			end

			// Invalidate short address 4'h2 
			TASK9:
			begin
				c0_tx_addr <= {28'h000000, `CHANNEL_ENUM};
				c0_tx_data <= {`CMD_CHANNEL_ENUM_INVALIDATE, 4'h2, 24'h0};
				c0_tx_pend <= 0;
				c0_tx_req <= 1;
				c0_priority <= 0;
				state <= TX_WAIT;
			end

			// Enumerate with 4'h8
			TASK10:
			begin
				c0_tx_addr <= {28'h000000, `CHANNEL_ENUM};
				c0_tx_data <= {`CMD_CHANNEL_ENUM_ENUMERATE, 4'h8, 24'h0};
				c0_tx_req <= 1;
				c0_tx_pend <= 0;
				c0_priority <= 0;
				state <= TX_WAIT;
			end

			// n1->n0 using new short address
			TASK11:
			begin
				n1_tx_addr <= {24'h0, 4'h8, 4'h1};	// last 4-bits (4'h1) are functional ID
				n1_tx_data <= rand_dat;
				n1_tx_pend <= 0;
				n1_tx_req <= 1;
				n1_priority <= 0;
   	      		$fdisplay(handle, "N1 Data in =\t32'h%h", rand_dat);
				state <= TX_WAIT;
			end

			// Sleep n0, n2 
			TASK12:
			begin
				c0_tx_addr <= {28'h000000, `CHANNEL_POWER};
				c0_tx_data <= (`CMD_CHANNEL_POWER_SEL_SLEEP<<28) | ((1'b1<<8)|(1'b1<<4))<<12 | 12'h0;
				c0_tx_req <= 1;
				c0_tx_pend <= 0;
				c0_priority <= 0;
				state <= TX_WAIT;
			end

			// n2 assert ext_int
			TASK13:
			begin
				n2_req_int <= 1;
				state <= TX_WAIT;
			end

			// n2->n0 using short address
			TASK14:
			begin
				n2_tx_addr <= {24'h0, 4'h8, 4'h2};	// last 4-bits (4'h2) are functional ID
				n2_tx_data <= rand_dat;
				n2_tx_pend <= 0;
				n2_tx_req <= 1;
				n2_priority <= 0;
   	      		$fdisplay(handle, "N2 Data in =\t32'h%h", rand_dat);
				state <= TX_WAIT;
			end
      	endcase // case (state)
	end
end // always @ (posedge clk or negedge resetn)
