
always @ (posedge clk or negedge resetn) begin
	// not in reset
	if (resetn)
	begin
		case (state)
			// Wake up processor and all B.C.
			TB_PROC_UP:
			begin
				c0_req_int <= 1;
				state <= TX_WAIT;
			end

			// Query nodes
			TB_QUERY:
			begin
				c0_tx_addr <= {28'h000000, `CHANNEL_ENUM};
				c0_tx_data <= {`CMD_CHANNEL_ENUM_QUERRY, 28'h0};
				c0_tx_req <= 1;
				c0_tx_pend <= 0;
				c0_priority <= 0;
				state <= TX_WAIT;
			end

			// Enumerate
			// Parameters:	enum_short_addr (4 bits)
			// address should starts with 4'h2
			TB_ENUM:
			begin
				c0_tx_addr <= {28'h000000, `CHANNEL_ENUM};
				c0_tx_data <= {`CMD_CHANNEL_ENUM_ENUMERATE, enum_short_addr, 24'h0};
				c0_tx_req <= 1;
				c0_tx_pend <= 0;
				c0_priority <= 0;
				state <= TX_WAIT;
			end

			// All layers wake 
			TB_ALL_WAKEUP:
			begin
				c0_tx_addr <= {28'hf00000, `CHANNEL_POWER};
				c0_tx_data <= {`CMD_CHANNEL_POWER_ALL_WAKE, 28'h0};
				c0_tx_req <= 1;
				c0_tx_pend <= 0;
				c0_priority <= 0;
				state <= TX_WAIT;
			end

			// RF Write
			// Parameters:	dest_short_addr (4 bits)
			//				rf_addr (8 bits)
			//				word_counter
			TB_RF_WRITE:
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
   	      				$fdisplay(handle, "Write RF addr: 8'h%h,\tData: 24'h%h", rf_addr, rand_dat[23:0]);
					end
					else
					begin
						c0_tx_pend <= 0;
   	      				$fdisplay(handle, "Write RF addr: 8'h%h,\tData: 24'h%h", rf_addr, rand_dat[23:0]);
						state <= TX_WAIT;
					end
				end
			end

			// RF read
			// Parameters:	dest_short_addr (4 bits)
			//				rf_addr (8 bits)
			//				rf_read_length (8 bits)
			//				relay_addr (8 bits)
			//				rf_relay_loc (8 bits)
			TB_RF_READ:
			begin
				c0_tx_addr <= {24'h0, dest_short_addr, `LC_CMD_RF_READ};
				c0_tx_data <= (rf_addr<<24 | rf_read_length<<16 | relay_addr<<8 | rf_relay_loc);
				c0_tx_pend <= 0;
				c0_tx_req <= 1;
				c0_priority <= 0;
				state <= TX_WAIT;
			end

			// MEM Write (Random Data)
			// Parameters:	dest_short_addr (4 bits)
			//				mem_addr (30 bits)
			//				word_counter
			TB_MEM_WRITE:
			begin
				if ((~c0_tx_ack) & (~c0_tx_req))
				begin
					c0_priority <= 0;
					c0_tx_addr <= {24'h0, dest_short_addr, `LC_CMD_MEM_WRITE};
					c0_tx_req <= 1;
					case (mem_access_state)
						0:
						begin
							c0_tx_data <= ((mem_addr<<2) | 2'b0);
							c0_tx_pend <= 1;
							addr_increment <= 0;
							if (word_counter)
								mem_access_state <= 1;
							else
								mem_access_state <= 2;
						end

						1:
						begin
							c0_tx_data <= rand_dat;
							c0_tx_pend <= 1;
							addr_increment <= addr_increment + 1;
							if (word_counter)
								word_counter <= word_counter - 1;
							else
								mem_access_state <= 2;
						end

						2:
						begin
							c0_tx_data <= rand_dat;
							c0_tx_pend <= 0;
							mem_access_state <= 0;
							state <= TX_WAIT;
						end
					endcase
				end
			end

			// MEM Write, single word with provided data
			// Parameters:	dest_short_addr (4 bits)
			//				mem_addr (30 bits)
			//				mem_w_data (32 bits)
			TB_SINGLE_MEM_WRITE:
			begin
				if ((~c0_tx_ack) & (~c0_tx_req))
				begin
					c0_priority <= 0;
					c0_tx_addr <= {24'h0, dest_short_addr, `LC_CMD_MEM_WRITE};
					c0_tx_req <= 1;
					case (mem_access_state)
						0:
						begin
							c0_tx_data <= ((mem_addr<<2) | 2'b0);
							c0_tx_pend <= 1;
							addr_increment <= 0;
							mem_access_state <= 1;
						end
						
						1:
						begin
							c0_tx_data <= mem_w_data;
							c0_tx_pend <= 0;
							mem_access_state <= 0;
							state <= TX_WAIT;
						end
					endcase
				end
			end

			// MEM Read command (3 words command)
			// Parameters:	dest_short_addr (4 bits)
			//				mem_read_length (20 bits)
			//				mem_addr (30 bits)
			//				relay_addr (8 bits)
			//				mem_relay_loc (30 bits)
			TB_MEM_READ:
			begin
				if ((~c0_tx_ack) & (~c0_tx_req))
				begin
					c0_priority <= 0;
					c0_tx_addr <= {24'h0, dest_short_addr, `LC_CMD_MEM_READ};
					c0_tx_req <= 1;
					case (mem_access_state)
						0:
						begin
							c0_tx_data <= ((relay_addr<<24) | (4'b0<<20) | mem_read_length);
							c0_tx_pend <= 1;
							mem_access_state <= 1;
						end

						1:
						begin
							c0_tx_data <= ((mem_addr<<2) | 2'b0);
							c0_tx_pend <= 1;
							mem_access_state <= 2;
						end

						2:
						begin
							c0_tx_data <= ((mem_relay_loc<<2) | 2'b0);
							c0_tx_pend <= 0;
							mem_access_state <= 0;
							state <= TX_WAIT;
						end
					endcase
				end
			end

			// Selective sleep N1 using full prefix
			// Parameters:	long_addr (20 bits)
			TB_SEL_SLEEP_FULL_PREFIX:
			begin
				c0_tx_addr <= {28'hf00000, `CHANNEL_POWER};
				c0_tx_data <= {`CMD_CHANNEL_POWER_SEL_SLEEP_FULL, 4'h0, long_addr, 4'h0};
				c0_tx_req <= 1;
				c0_tx_pend <= 0;
				c0_priority <= 0;
				state <= TX_WAIT;
			end

			// All layers sleep
			TB_ALL_SLEEP:
			begin
				c0_tx_addr <= {28'hf00000, `CHANNEL_POWER};
				c0_tx_data <= {`CMD_CHANNEL_POWER_ALL_SLEEP, 28'h0};
				c0_tx_req <= 1;
				c0_tx_pend <= 0;
				c0_priority <= 0;
				state <= TX_WAIT;
			end

			// Invalidate all short address
			TB_ALL_SHORT_ADDR_INVALID:
			begin
				c0_tx_addr <= {24'he0000, 4'h0, `CHANNEL_ENUM};
				c0_tx_data <= {`CMD_CHANNEL_ENUM_INVALIDATE, 4'hf, 24'h0}; // 4'hf -> all short address
				c0_tx_req <= 1;
				c0_tx_pend <= 0;
				c0_priority <= 0;
				state <= TX_WAIT;
			end

			// Interrupt
			// Parameters:	layer_number (0-3)
			//				int_vec		 (LC_INT_DEPTH bits)
			TB_SINGLE_INTERRUPT:
			begin
				case (layer_number)
					0: begin n0_int_vector<= (1'b1<<int_vec); end
					1: begin n1_int_vector<= (1'b1<<int_vec); end
					2: begin n2_int_vector<= (1'b1<<int_vec); end
					3: begin n3_int_vector<= (1'b1<<int_vec); end
				endcase
				state <= TX_WAIT;
			end

      	endcase // case (state)
	end
end // always @ (posedge clk or negedge resetn)
