
`include "include/ulpb_def.v"

module ulpb_node32(
	input CLK, 
	input RESET, 
	input DIN, 
	output reg DOUT, 
	input [`ADDR_WIDTH-1:0] TX_ADDR, 
	input [`DATA_WIDTH-1:0] TX_DATA, 
	input TX_PEND, 
	input TX_REQ, 
	output reg TX_ACK, 
	output reg [`ADDR_WIDTH-1:0] RX_ADDR, 
	output reg [`DATA_WIDTH-1:0] RX_DATA, 
	output reg RX_REQ, 
	input RX_ACK, 
	output reg RX_PEND, 
	output reg TX_FAIL, 
	output reg TX_SUCC, 
	input TX_RESP_ACK
);

`include "include/ulpb_func.v"

parameter ADDRESS = 8'hef;
parameter ADDRESS_MASK=8'hff;

parameter MODE_IDLE = 0;
parameter MODE_TX = 1;
parameter MODE_RX = 2;
parameter MODE_FWD = 3;

parameter BUS_IDLE = 0;
parameter ARBI_RESOLVED = 1;
parameter DRIVE1 = 2;
parameter LATCH1 = 3;
parameter DRIVE2 = 4;
parameter LATCH2 = 5;
parameter BUS_RESET = 6;

parameter NUM_OF_BUS_STATE = 7;

parameter TRANSMIT_ADDR 		= 0;
parameter TRANSMIT_DATA 		= 1;
parameter TRANSMIT_EOT0 		= 2;
parameter TRANSMIT_EOT1 		= 3;
parameter TRANSMIT_WAIT_ACK0 	= 4;
parameter TRANSMIT_WAIT_ACK1 	= 5;
parameter TRANSMIT_WAIT_ACK2 	= 6;
parameter TRANSMIT_FWD 			= 15;

parameter RECEIVE_ADDR			= 0;
parameter RECEIVE_DATA			= 1;
parameter RECEIVE_CONT			= 2;
parameter RECEIVE_DRIVE_ACK0	= 3;
parameter RECEIVE_DRIVE_ACK1	= 4;
parameter RECEIVE_DRIVE_ACK2	= 5;
parameter RECEIVE_DRIVE_ACK3	= 6;
parameter RECEIVE_OVERFLOW		= 7;
parameter RECEIVE_FWD			= 15;

parameter NUM_OF_NODE_STATE = 15;

// general registers
reg		[log2(NUM_OF_BUS_STATE-1)-1:0] bus_state, next_bus_state;
reg		[log2(NUM_OF_NODE_STATE-1)-1:0] node_state, next_node_state;
reg		[log2(`DATA_WIDTH-1)-1:0] bit_position, next_bit_position; 
reg		[5:0] input_buffer;
reg		out_reg, next_out_reg;
reg		[1:0] mode, next_mode;

// interface registers
reg		next_tx_ack;
reg		next_tx_fail;
reg		next_tx_success;

// tx registers
reg		[`ADDR_WIDTH-1:0] ADDR, next_addr;
reg		[`DATA_WIDTH-1:0] DATA0, next_data0;
reg		tx_pend, next_tx_pend;

// rx registers
reg		[`ADDR_WIDTH-1:0] next_rx_addr;
reg		[`DATA_WIDTH-1:0] next_rx_data; 
reg		[`DATA_WIDTH-1:0] rx_data_out_buf, next_rx_data_buf;
reg		next_rx_req;
reg		next_rx_pend;

wire	addr_bit_extract = ((ADDR  & (1'b1<<bit_position))==0)? 1'b0 : 1'b1;
wire	data0_bit_extract = ((DATA0 & (1'b1<<bit_position))==0)? 1'b0 : 1'b1;
wire	input_buffer_xor = input_buffer[0] ^ input_buffer[1];
wire	address_match = (((RX_ADDR^ADDRESS)&ADDRESS_MASK)==0)? 1'b1 : 1'b0;

always @ (posedge CLK or negedge RESET)
begin
	if (~RESET)
	begin
		// general registers
		bus_state <= BUS_IDLE;
		node_state <= RECEIVE_ADDR;
		bit_position <= `ADDR_WIDTH - 1'b1;
		out_reg <= 1;
		mode <= MODE_IDLE;
		// interface registers
		TX_ACK <= 0;
		TX_FAIL <= 0;
		TX_SUCC <= 0;
		// tx registers
		ADDR <= 0;
		DATA0 <= 0;
		tx_pend <= 0;
		// rx registers
		RX_ADDR <= 0;
		RX_DATA <= 0;
		RX_REQ <= 0;
		RX_PEND <= 0;
		rx_data_out_buf <= 0;
	end
	else
	begin
		// general registers
		bus_state <= next_bus_state;
		node_state <= next_node_state;
		bit_position <= next_bit_position;
		out_reg <= next_out_reg;
		mode <= next_mode;
		// interface registers
		TX_ACK <= next_tx_ack;
		TX_FAIL <= next_tx_fail;
		TX_SUCC <= next_tx_success;
		// tx registers
		ADDR <= next_addr;
		DATA0 <= next_data0;
		tx_pend <= next_tx_pend;
		// rx registers
		RX_ADDR <= next_rx_addr;
		RX_DATA <= next_rx_data;
		RX_REQ <= next_rx_req;
		RX_PEND <= next_rx_pend;
		rx_data_out_buf <= next_rx_data_buf;
	end
end

always @ *
begin
	// general registers
	next_bus_state = bus_state;
	next_bit_position = bit_position;
	next_out_reg = out_reg;
	next_mode = mode;
	next_node_state = node_state;
	// interface registers
	next_tx_ack = TX_ACK;
	next_tx_fail = TX_FAIL;
	next_tx_success = TX_SUCC;
	// tx registers
	next_addr = ADDR;
	next_data0 = DATA0;
	next_tx_pend = tx_pend;
	// rx registers
	next_rx_addr = RX_ADDR;
	next_rx_data = RX_DATA;
	next_rx_req = RX_REQ;
	next_rx_pend = RX_PEND;
	next_rx_data_buf = rx_data_out_buf;

	if (TX_ACK & (~TX_REQ))
		next_tx_ack = 0;
	
	if (RX_REQ & RX_ACK)
	begin
		next_rx_req = 0;
		next_rx_pend = 0;
	end

	if (TX_RESP_ACK)
	begin
		next_tx_fail = 0;
		next_tx_success = 0;
	end

	case (bus_state)
		BUS_IDLE:
		begin
			if (DIN^DOUT)
			begin
				// tx registers
				next_addr = TX_ADDR;
				next_data0 = TX_DATA;
				next_mode = MODE_TX;
				next_tx_ack = 1;
				next_tx_pend = TX_PEND;
				next_node_state = TRANSMIT_ADDR;
				// interface registers
			end
			else
				next_mode = MODE_RX;

			// general registers
			next_bus_state = ARBI_RESOLVED;
			next_bit_position = `ADDR_WIDTH - 1'b1;
			// interface registers
			// tx registers
			// rx registers
			next_node_state = RECEIVE_ADDR;
		end

		ARBI_RESOLVED:
		begin
			next_bus_state = DRIVE1;
			if (mode==MODE_TX)
				next_out_reg = addr_bit_extract;
		end

		DRIVE1:
		begin
			next_bus_state = LATCH1;
			if ((mode==MODE_RX)&&(node_state==RECEIVE_DATA)&&(address_match==0))
				next_mode = MODE_FWD;
		end

		LATCH1:
		begin
			if (input_buffer[2:0]==3'b010)
				next_bus_state = BUS_RESET;
			else
			begin
				next_bus_state = DRIVE2;
				case (mode)
					MODE_TX:
					begin
						case (node_state)
							TRANSMIT_EOT0:
							begin
								next_node_state = TRANSMIT_EOT1;
								next_out_reg = 0;
							end
						endcase
					end

					MODE_RX:
					begin
						case (node_state)
							RECEIVE_DRIVE_ACK0:
							begin
								next_node_state = RECEIVE_DRIVE_ACK1;
								next_out_reg = 1;
							end

							RECEIVE_DRIVE_ACK2:
							begin
								next_node_state = RECEIVE_DRIVE_ACK3;
								next_out_reg = 0;
							end
						endcase
					end
				endcase
			end
		end

		DRIVE2:
		begin
			next_bus_state = LATCH2;
			// advances bit position
			if (mode==MODE_TX)
			begin
				case (node_state)
					TRANSMIT_ADDR:
					begin
						if (bit_position)
							next_bit_position = bit_position - 1'b1;
						else
						begin
							next_bit_position = `DATA_WIDTH - 1'b1;
							next_node_state = TRANSMIT_DATA;
						end
					end

					TRANSMIT_DATA:
					begin
						if (bit_position)
							next_bit_position = bit_position - 1'b1;
						else
						begin
							next_bit_position = `DATA_WIDTH - 1'b1;
							case ({tx_pend, TX_REQ})
								2'b11:
								begin
									next_tx_pend = TX_PEND;
									next_data0 = TX_DATA;
									next_tx_ack = 1;
								end
								
								2'b10:
								begin
									// underflow
									next_node_state = TRANSMIT_FWD;
									next_tx_fail = 1;
								end

								default:
								begin
									next_node_state = TRANSMIT_EOT0;
								end
							endcase
						end
					end

				endcase
			end
		end

		LATCH2:
		begin
			if (input_buffer[2:0]==3'b010)
				next_bus_state = BUS_RESET;
			else
			begin
				next_bus_state = DRIVE1;
				case (mode)
					MODE_TX:
					begin
						case (node_state)
							TRANSMIT_ADDR:
							begin
								next_out_reg = addr_bit_extract;
								if (input_buffer_xor)
								begin
									next_node_state = TRANSMIT_FWD;
									next_tx_fail = 1;
								end
							end

							TRANSMIT_DATA:
							begin
								next_out_reg = data0_bit_extract;
								if (input_buffer_xor)
								begin
									next_node_state = TRANSMIT_FWD;
									next_tx_fail = 1;
								end
							end

							TRANSMIT_EOT0:
							begin
								next_out_reg = 1;
							end

							TRANSMIT_EOT1:
							begin
								next_node_state = TRANSMIT_WAIT_ACK0;
							end

							TRANSMIT_WAIT_ACK0:
							begin
								next_node_state = TRANSMIT_WAIT_ACK1;
							end

							TRANSMIT_WAIT_ACK1:
							begin
								next_node_state = TRANSMIT_WAIT_ACK2;
							end

							TRANSMIT_WAIT_ACK2:
							begin
								next_node_state = TRANSMIT_FWD;
								// received ack
								if (input_buffer==6'b011001)
									next_tx_success = 1;
								else
									next_tx_fail = 1;
							end

						endcase
					end

					MODE_RX:
					begin
						case (node_state)
							RECEIVE_ADDR:
							begin
								if (input_buffer_xor)
									next_node_state = RECEIVE_FWD;
								else
								begin
									if (bit_position)
									begin
										next_bit_position = bit_position - 1'b1;
									end
									else
									begin
										next_bit_position = `DATA_WIDTH - 1'b1;
										next_node_state = RECEIVE_DATA;
									end
									next_rx_addr = {RX_ADDR[`ADDR_WIDTH-2:0], input_buffer[0]};
								end
							end

							RECEIVE_DATA:
							begin
								if (input_buffer_xor)
									next_node_state = RECEIVE_FWD;
								else
								begin
									next_rx_data_buf = {rx_data_out_buf[`DATA_WIDTH-2:0], input_buffer[0]};
									if (bit_position)
									begin
										next_bit_position = bit_position - 1'b1;
									end
									else
									begin
										next_bit_position = `DATA_WIDTH - 1'b1;
										next_node_state = RECEIVE_CONT;
									end
								end
							end

							RECEIVE_CONT:
							begin
								if (RX_REQ | RX_ACK)
								begin
									// reset issue by Receiver?
									next_node_state = RECEIVE_OVERFLOW;
								end
								else
								begin
									next_rx_req = 1;
									next_rx_data = rx_data_out_buf;
									// end of tx
									if (input_buffer_xor)
									begin
										if (input_buffer[1:0]==2'b10)
										begin
											next_node_state = RECEIVE_DRIVE_ACK0;
											next_out_reg = 0;
										end
										else
											next_node_state = RECEIVE_FWD;
										next_rx_pend = 0;
									end
									// bit streaming
									else
									begin
										next_bit_position = bit_position - 1'b1;
										next_rx_data_buf = {rx_data_out_buf[`DATA_WIDTH-2:0], input_buffer[0]};
										next_node_state = RECEIVE_DATA;
										next_rx_pend = 1;
									end
								end
							end

							RECEIVE_DRIVE_ACK1:
							begin
								next_node_state = RECEIVE_DRIVE_ACK2;
								next_out_reg = 1;
							end

							// ACK completed
							RECEIVE_DRIVE_ACK3:
							begin
								next_node_state = RECEIVE_FWD;
							end

							RECEIVE_OVERFLOW:
							begin
							end

						endcase
					end

				endcase
			end
		end

		BUS_RESET:
		begin
			if (input_buffer[1:0]==2'b11)
			begin
				next_bus_state = BUS_IDLE;
				next_mode = MODE_IDLE;
			end
		end

	endcase
end

always @ *
begin
	DOUT = DIN;
	case (bus_state)
		BUS_IDLE:
		begin
			DOUT = ((~TX_REQ) & DIN);
		end

		ARBI_RESOLVED:
		begin
			if (mode==MODE_TX)
				DOUT = 0;
			else
				DOUT = DIN;
		end

		DRIVE1:
		begin
			case (mode)
				MODE_TX:
				begin
					if ((node_state==TRANSMIT_ADDR)||(node_state==TRANSMIT_DATA)||(node_state==TRANSMIT_EOT0))
						DOUT = out_reg;
				end

				MODE_RX:
				begin
					if ((node_state==RECEIVE_DRIVE_ACK0)||(node_state==RECEIVE_DRIVE_ACK2))
						DOUT = out_reg;
				end
			endcase
		end

		DRIVE2:
		begin
			case (mode)
				MODE_TX:
				begin
					if ((node_state==TRANSMIT_ADDR)||(node_state==TRANSMIT_DATA)||(node_state==TRANSMIT_EOT1))
						DOUT = out_reg;
				end

				MODE_RX:
				begin
					if ((node_state==RECEIVE_DRIVE_ACK1)||(node_state==RECEIVE_DRIVE_ACK3))
						DOUT = out_reg;
				end
			endcase
		end

	endcase
end

always @ (posedge CLK or negedge RESET)
begin
	if (~RESET)
	begin
		input_buffer <= 0;
	end
	else
	begin
		if ((bus_state==DRIVE1)||(bus_state==DRIVE2)||(bus_state==BUS_RESET))
			input_buffer <= {input_buffer[4:0], DIN};
	end
end

endmodule
