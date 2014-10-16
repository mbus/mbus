
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


			// C0 writes random data to layer X's RF
			// layer X: dest_short_addr
			// addr: 	rf_addr
			// length: 	word_counter
			TASK7:
			begin
				if ((~c0_tx_ack) & (~c0_tx_req))
				begin
					c0_priority <= 0;
					c0_tx_addr <= {24'h0, dest_short_addr, `LC_CMD_RF_WRITE};
					c0_tx_req <= 1;
					c0_tx_data <= ((rf_addr<<24) | (rand_dat & 32'h00ff_ffff));
					if (word_counter)
					begin
						c0_tx_pend <= 1;
						word_counter <= word_counter - 1;
						rf_addr <= rf_addr + 1;
   	      				$fdisplay(handle, "Write RF addr: 8'h%h,\tData: 24'h%h", rf_addr, (rand_dat&32'h00ffffff));
					end
					else
					begin
						c0_tx_pend <= 0;
   	      				$fdisplay(handle, "Write RF addr: 8'h%h,\tData: 24'h%h", rf_addr, (rand_dat&32'h00ffffff));
						state <= TX_WAIT;
					end
				end
			end

			// C0 reads data from layer X's RF and relay to layer Y with
			// channel Z and location W
			// layer X: dest_short_addr
			// layer Y, channel Z: delay_addr (4'hY, 4'hZ)
			// layer W, destination location
			// addr: 	rf_addr
			// length: 	word_counter
			TASK8:
			begin
				c0_tx_addr <= {24'h0, dest_short_addr, `LC_CMD_RF_READ};
				c0_tx_data <= (rf_addr<<24 | word_counter<<16 | relay_addr<<8 | relay_loc);
				c0_tx_pend <= 0;
				c0_tx_req <= 1;
				c0_priority <= 0;
				state <= TX_WAIT;
			end

			// C0 writes random data to layer X's MEM
			// layer X: dest_short_addr
			// addr: 	mem_addr
			// length: 	word_counter
			TASK9:
			begin
				if ((~c0_tx_ack) & (~c0_tx_req))
				begin
					c0_priority <= 0;
					c0_tx_addr <= {24'h0, dest_short_addr, `LC_CMD_MEM_WRITE};
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
						mem_ptr_set <= 0;
						state <= TX_WAIT;
					end
				end
			end

			// C0 reads data from layer X's MEM and relay to layer Y with
			// channel Z
			// layer X: dest_short_addr
			// layer Y, channel Z: delay_addr (4'hY, 4'hZ)
			// addr: 	mem_addr
			// length: 	word_counter
			TASK10:
			begin
				if ((~c0_tx_ack) & (~c0_tx_req))
				begin
					c0_priority <= 0;
					c0_tx_addr <= {24'h0, dest_short_addr, `LC_CMD_MEM_READ};
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
						mem_ptr_set <= 0;
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

			// C0 writes 3-byte data to layer X's RF
			// layer X: dest_short_addr
			// addr: 	rf_addr
			// data:	rf_data
			TASK12:
			begin
				if ((~c0_tx_ack) & (~c0_tx_req))
				begin
					c0_priority <= 0;
					c0_tx_addr <= {24'h0, dest_short_addr, `LC_CMD_RF_WRITE};
					c0_tx_req <= 1;
					c0_tx_data <= ((rf_addr<<24) | rf_data);
					c0_tx_pend <= 0;
   	      			$fdisplay(handle, "Write RF addr: 8'h%h,\tData: 24'h%h", rf_addr, rf_data);
					state <= TX_WAIT;
				end
			end

			// C0 writes 1-word data to layer X's MEM
			// layer X: dest_short_addr
			// addr: 	mem_addr
			// length: 	word_counter
			// data:	mem_data
			TASK13:
			begin
				if ((~c0_tx_ack) & (~c0_tx_req))
				begin
					c0_priority <= 0;
					c0_tx_addr <= {24'h0, dest_short_addr, `LC_CMD_MEM_WRITE};
					c0_tx_req <= 1;
					if (~mem_ptr_set)
					begin
						c0_tx_data <= ((mem_addr<<2) | 2'b0);
						c0_tx_pend <= 1;
						mem_ptr_set <= 1;
						addr_increment <= 0;
					end
					else
					begin
						c0_tx_data <= mem_data;
						c0_tx_pend <= 0;
   	      				$fdisplay(handle, "Write mem Addr: 32'h%h,\tData: 32'h%h", (mem_addr+addr_increment)<<2, mem_data);
						mem_ptr_set <= 0;
						state <= TX_WAIT;
					end
				end
			end

			// C0 writes random data to layer X's MEM in RF write format
			// 8-bit addr, 24-bit data
			// layer X: dest_short_addr
			// addr: 	mem_addr
			// rf-addr: rf_addr
			// length: 	word_counter
			TASK14:
			begin
				if ((~c0_tx_ack) & (~c0_tx_req))
				begin
					c0_priority <= 0;
					c0_tx_addr <= {24'h0, dest_short_addr, `LC_CMD_MEM_WRITE};
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
						c0_tx_data <= ((rf_addr<<24) | (rand_dat & 32'h00ff_ffff));
						c0_tx_pend <= 1;
						word_counter <= word_counter - 1;
						addr_increment <= addr_increment + 1;
						rf_addr <= rf_addr + 1;
   	      				$fdisplay(handle, "Write MEM addr: 32'h%h,\tData: 32'h%h", (mem_addr+addr_increment)<<2, ((rf_addr<<24) | (rand_dat&32'h00ffffff)));
					end
					else
					begin
						c0_tx_data <= ((rf_addr<<24) | (rand_dat & 32'h00ff_ffff));
						c0_tx_pend <= 0;
   	      				$fdisplay(handle, "Write MEM addr: 32'h%h,\tData: 32'h%h", (mem_addr+addr_increment)<<2, ((rf_addr<<24) | (rand_dat&32'h00ffffff)));
						mem_ptr_set <= 0;
						state <= TX_WAIT;
					end
				end
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
