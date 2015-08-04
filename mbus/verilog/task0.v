/*
 * MBus Copyright 2015 Regents of the University of Michigan
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

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

			// n1->n0 using long address
			TASK6:
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
			TASK7:
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
			TASK8:
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
			TASK9:
			begin
				n1_tx_addr <= {24'h0, 4'h4, 4'h1};	// last 4-bits (4'h1) are functional ID
				n1_tx_data <= rand_dat;
				n1_tx_pend <= 0;
				n1_tx_req <= 1;
				n1_priority <= 0;
   	      		$fdisplay(handle, "N1 Data in =\t32'h%h", rand_dat);
				state <= TX_WAIT;
			end

			// n1->n3 using short address
			TASK10:
			begin
				n1_tx_addr <= {24'h0, 4'h5, 4'h2};	// last 4-bits (4'h2) are functional ID
				n1_tx_data <= rand_dat;
				n1_tx_pend <= 0;
				n1_tx_req <= 1;
				n1_priority <= 0;
   	      		$fdisplay(handle, "N1 Data in =\t32'h%h", rand_dat);
				state <= TX_WAIT;
			end

			// Invalidate short address 4'h2 
			TASK11:
			begin
				c0_tx_addr <= {28'h000000, `CHANNEL_ENUM};
				c0_tx_data <= {`CMD_CHANNEL_ENUM_INVALIDATE, 4'h2, 24'h0};
				c0_tx_pend <= 0;
				c0_tx_req <= 1;
				c0_priority <= 0;
				state <= TX_WAIT;
			end

			// Enumerate with 4'h8
			TASK12:
			begin
				c0_tx_addr <= {28'h000000, `CHANNEL_ENUM};
				c0_tx_data <= {`CMD_CHANNEL_ENUM_ENUMERATE, 4'h8, 24'h0};
				c0_tx_req <= 1;
				c0_tx_pend <= 0;
				c0_priority <= 0;
				state <= TX_WAIT;
			end

			// n1->n0 using new short address
			TASK13:
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
			TASK14:
			begin
				c0_tx_addr <= {28'h000000, `CHANNEL_POWER};
				c0_tx_data <= (`CMD_CHANNEL_POWER_SEL_SLEEP<<28) | ((1'b1<<8)|(1'b1<<4))<<12 | 12'h0;
				c0_tx_req <= 1;
				c0_tx_pend <= 0;
				c0_priority <= 0;
				state <= TX_WAIT;
			end

			// n2 assert ext_int
			TASK15:
			begin
				n2_req_int <= 1;
				state <= TX_WAIT;
			end

			// n2->n0 using short address
			TASK16:
			begin
				n2_tx_addr <= {24'h0, 4'h8, 4'h2};	// last 4-bits (4'h2) are functional ID
				n2_tx_data <= rand_dat;
				n2_tx_pend <= 0;
				n2_tx_req <= 1;
				n2_priority <= 0;
   	      		$fdisplay(handle, "N2 Data in =\t32'h%h", rand_dat);
				state <= TX_WAIT;
			end

			// Long querry nodes
			TASK17:
			begin
				c0_tx_addr <= {28'hf00000, `CHANNEL_ENUM};
				c0_tx_data <= {`CMD_CHANNEL_ENUM_QUERRY, 28'h0};
				c0_tx_req <= 1;
				c0_tx_pend <= 0;
				c0_priority <= 0;
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

			// All layers wake 
			TASK19:
			begin
				c0_tx_addr <= {28'hf00000, `CHANNEL_POWER};
				c0_tx_data <= {`CMD_CHANNEL_POWER_ALL_WAKE, 28'h0};
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

			// Selective sleep N1 using full prefix
			TASK21:
			begin
				c0_tx_addr <= {28'hf00000, `CHANNEL_POWER};
				c0_tx_data <= {`CMD_CHANNEL_POWER_SEL_SLEEP_FULL, 4'h0, 20'hbbbb1, 4'h0};
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

			// n2 querry
			TASK23:
			begin
				n2_tx_addr <= {28'hf00000, `CHANNEL_ENUM};
				n2_tx_data <= {`CMD_CHANNEL_ENUM_QUERRY, 28'h0};
				n2_tx_pend <= 0;
				n2_tx_req <= 1;
				n2_priority <= 0;
				state <= TX_WAIT;
			end

			// n2 sends to control
			TASK24:
			begin
				n2_tx_addr <= {28'hf00000, `CHANNEL_CTRL};
				n2_tx_data <= rand_dat;
				n2_tx_pend <= 0;
				n2_tx_req <= 1;
				n2_priority <= 0;
   	      		$fdisplay(handle, "N2 Data in =\t32'h%h", rand_dat);
				state <= TX_WAIT;
			end

			// n2 -> n1 byte streamming using long address, 
			// n3 request interrupt
			TASK25: 
			begin
	   			if ((~n2_tx_ack) & (~n2_tx_req)) 
				begin
	      			n2_tx_addr <= {4'hf, 4'h0, 20'hbbbb1, 4'h1};	// 4'h1 is functional ID
	      			n2_tx_data <= rand_dat;
	      			n2_tx_req <= 1;
   	      			$fdisplay(handle, "N1 Data in =\t32'h%h", rand_dat);
	      			if (word_counter) 
					begin
		 				word_counter <= word_counter - 1;
		 				n2_tx_pend <= 1;
						if (word_counter==1)
							n3_req_int <= 1;
	      			end
	      			else 
					begin
		 				n2_tx_pend <= 0;
		 				state <= TX_WAIT;
	      			end
	   			end
			end

      	endcase // case (state)
	end
end // always @ (posedge clk or negedge resetn)
