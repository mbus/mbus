
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

			// All layers wake 
			TASK6:
			begin
				c0_tx_addr <= {28'hf00000, `CHANNEL_POWER};
				c0_tx_data <= {`CMD_CHANNEL_POWER_ALL_WAKE, 28'h0};
				c0_tx_req <= 1;
				c0_tx_pend <= 0;
				c0_priority <= 0;
				state <= TX_WAIT;
			end


			// c0->n1, write RF
			TASK7:
			begin
				if ((~c0_tx_ack) & (~c0_tx_req))
				begin
					c0_priority <= 0;
					c0_tx_addr <= {24'h0, 4'h3, `LC_CMD_RF_WRITE};
					c0_tx_req <= 1;
					c0_tx_data <= ((rf_addr<<24) | (rand_dat & 32'h00ff_ffff));
					if (word_counter)
					begin
						c0_tx_pend <= 1;
						word_counter <= word_counter - 1;
						rf_addr <= rf_addr + 1;
   	      				$fdisplay(handle, "Write mem Addr: 32'h%h,\tData: 32'h%h", rf_addr, (rand_dat&32'h00ffffff));
					end
					else
					begin
						c0_tx_pend <= 0;
   	      				$fdisplay(handle, "Write mem Addr: 32'h%h,\tData: 32'h%h", rf_addr, (rand_dat&32'h00ffffff));
						state <= TX_WAIT;
					end
				end
			end

			// c0->n1, read RF
			TASK8:
			begin
				c0_tx_addr <= {24'h0, 4'h3, `LC_CMD_RF_READ};
				c0_tx_data <= (rf_addr<<24 | word_counter<<16 | relay_addr<<8 | 8'h0);
				c0_tx_pend <= 0;
				c0_tx_req <= 1;
				c0_priority <= 0;
				state <= TX_WAIT;
			end

			// c0->n1, write MEM
			TASK9:
			begin
				if ((~c0_tx_ack) & (~c0_tx_req))
				begin
					c0_priority <= 0;
					c0_tx_addr <= {24'h0, 4'h3, `LC_CMD_MEM_WRITE};
					c0_tx_req <= 1;
					if (~mem_ptr_set)
					begin
						c0_tx_data <= ((mem_addr<<2) | 2'b0);
						c0_tx_pend <= 1;
						mem_ptr_set <= 1;
						addr_increment <= 0;
					end
					else if (word_counter)
					begin
						c0_tx_data <= rand_dat;
						c0_tx_pend <= 1;
						word_counter <= word_counter - 1;
						addr_increment <= addr_increment + 1;
   	      				$fdisplay(handle, "Write mem Addr: 32'h%h,\tData: 32'h%h", (mem_addr+addr_increment)<<2, rand_dat);
					end
					else
					begin
						c0_tx_data <= rand_dat;
						c0_tx_pend <= 0;
   	      				$fdisplay(handle, "Write mem Addr: 32'h%h,\tData: 32'h%h", (mem_addr+addr_increment)<<2, rand_dat);
						state <= TX_WAIT;
					end
				end
			end

			// c0->n1, read MEM
			TASK10:
			begin
				if ((~c0_tx_ack) & (~c0_tx_req))
				begin
					c0_priority <= 0;
					c0_tx_addr <= {24'h0, 4'h3, `LC_CMD_MEM_READ};
					c0_tx_req <= 1;
					if (~mem_ptr_set)
					begin
						c0_tx_data <= ((mem_addr<<2) | 2'b0);
						c0_tx_pend <= 1;
						mem_ptr_set <= 1;
					end
					else
					begin
						c0_tx_data <= ((relay_addr<<24) | word_counter);
						c0_tx_pend <= 0;
						state <= TX_WAIT;
					end
				end
			end
			// Selective sleep N1 using full prefix
			TASK11:
			begin
				c0_tx_addr <= {28'hf00000, `CHANNEL_POWER};
				c0_tx_data <= {`CMD_CHANNEL_POWER_SEL_SLEEP_FULL, 4'h0, 20'hbbbb1, 4'h0};
				c0_tx_req <= 1;
				c0_tx_pend <= 0;
				c0_priority <= 0;
				state <= TX_WAIT;
			end


			// n1 assert ext_int
			TASK14:
			begin
				n1_int_vector <= 8'h1;
				state <= TX_WAIT;
			end

			// All layers sleep
			TASK18:
			begin
				c0_tx_addr <= {28'hf00000, `CHANNEL_POWER};
				c0_tx_data <= {`CMD_CHANNEL_POWER_ALL_SLEEP, 28'h0};
				c0_tx_req <= 1;
				c0_tx_pend <= 0;
				c0_priority <= 0;
				state <= TX_WAIT;
			end

			// Invalidate all short address
			TASK20:
			begin
				c0_tx_addr <= {24'he0000, 4'h0, `CHANNEL_ENUM};
				c0_tx_data <= {`CMD_CHANNEL_ENUM_INVALIDATE, 4'hf, 24'h0}; // 4'hf -> all short address
				c0_tx_req <= 1;
				c0_tx_pend <= 0;
				c0_priority <= 0;
				state <= TX_WAIT;
			end

			// Selective sleep processor using full prefix
			TASK22:
			begin
				c0_tx_addr <= {28'hf00000, `CHANNEL_POWER};
				c0_tx_data <= {`CMD_CHANNEL_POWER_SEL_SLEEP_FULL, 4'h0, 20'haaaa0, 4'h0};
				c0_tx_req <= 1;
				c0_tx_pend <= 0;
				c0_priority <= 0;
				state <= TX_WAIT;
			end

      	endcase // case (state)
	end
end // always @ (posedge clk or negedge resetn)
