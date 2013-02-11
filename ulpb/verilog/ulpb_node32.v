
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

`define OVERLAP_ACK

parameter ADDRESS = 8'hef;
parameter ADDRESS_MASK=8'hff;
parameter ERROR_RST_CNT = 5'b00001;	// # of bit should not greater than log2(32) = 5

// Node mode
parameter MODE_IDLE = 0;
parameter MODE_TX = 1;
parameter MODE_RX = 2;
parameter MODE_FWD = 3;

// BUS state
parameter BUS_IDLE = 0;
parameter ARBI_RESOLVED = 1;
parameter DRIVE1 = 2;
parameter LATCH1 = 3;
parameter DRIVE2 = 4;
parameter LATCH2 = 5;
parameter PHASE_ALIGN = 6;
parameter BUS_RESET = 7;

parameter NUM_OF_BUS_STATE = 8;

// Node state, TX
parameter TRANSMIT_ADDR 		= 0;
parameter TRANSMIT_DATA 		= 1;
parameter TRANSMIT_EOT0 		= 2;
parameter TRANSMIT_EOT1 		= 3;
parameter TRANSMIT_WAIT_ACK0 	= 4;
parameter TRANSMIT_WAIT_ACK1 	= 5;
parameter TRANSMIT_WAIT_ACK2 	= 6;
parameter TRANSMIT_UNDERFLOW	= 7;
parameter TRANSMIT_ERROR		= 8;
parameter TRANSMIT_FWD 			= 15;

// Node state, RX
parameter RECEIVE_ADDR			= 0;
parameter RECEIVE_DATA			= 1;
parameter RECEIVE_CONT			= 2;
parameter RECEIVE_DRIVE_ACK0	= 3;
parameter RECEIVE_DRIVE_ACK1	= 4;
parameter RECEIVE_DRIVE_ACK2	= 5;
parameter RECEIVE_DRIVE_ACK3	= 6;
parameter RECEIVE_ERROR			= 7;
parameter RECEIVE_FWD			= 15;

parameter NUM_OF_NODE_STATE = 15;

// general registers
reg		[log2(NUM_OF_BUS_STATE-1)-1:0] bus_state, next_bus_state;
reg		[log2(NUM_OF_NODE_STATE-1)-1:0] node_state, next_node_state;
reg		[log2(`DATA_WIDTH-1)-1:0] bit_position, next_bit_position; 
reg		[4:0] input_buffer;
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

// constant
wire	[1:0] MES_SEQ_CONST = `MES_SEQ;
wire	[1:0] ACK_SEQ_CONST = `ACK_SEQ;

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

	// Asynchronous interface
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

	// BUS FSM
	case (bus_state)
		BUS_IDLE:
		begin
			// Win Arbitration, Transmitter
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
			// Lose Arbitration, Receiver
			else
			begin
				next_mode = MODE_RX;
				// rx registers
				next_node_state = RECEIVE_ADDR;
			end

			// general registers
			next_bus_state = ARBI_RESOLVED;
			next_bit_position = `ADDR_WIDTH - 1'b1;
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
			// Address completed received, Address mismatch -> Forwarder
			if ((mode==MODE_RX)&&(node_state==RECEIVE_DATA)&&(address_match==0))
				next_mode = MODE_FWD;
		end

		LATCH1:
		begin
			if (input_buffer[2:0]==`RST_SEQ)
			begin
				next_bus_state = PHASE_ALIGN;
				`ifdef OVERLAP_ACK
				if ((node_state==TRANSMIT_WAIT_ACK2)&&(mode==MODE_TX))
				begin
					if (input_buffer[4:3]==`ACK_SEQ)
						next_tx_success = 1;
					else
						next_tx_fail = 1;
				end
				`endif
			end
			else
			begin
				next_bus_state = DRIVE2;
				case (mode)
					MODE_TX:
					begin
						case (node_state)
							TRANSMIT_ERROR:
							begin
								next_out_reg = ~out_reg;
							end

							TRANSMIT_EOT0:
							begin
								next_node_state = TRANSMIT_EOT1;
								next_out_reg = MES_SEQ_CONST[0];
							end

							`ifdef OVERLAP_ACK
							TRANSMIT_WAIT_ACK2:
							begin
								next_node_state = TRANSMIT_FWD;
								next_tx_fail = 1;
							end
							`endif
						endcase
					end

					MODE_RX:
					begin
						case (node_state)
							RECEIVE_DRIVE_ACK0:
							begin
								next_node_state = RECEIVE_DRIVE_ACK1;
								next_out_reg = ACK_SEQ_CONST[0];
							end

							RECEIVE_ERROR:
							begin
								next_out_reg = ~out_reg;
							end

						endcase
					end
				endcase
			end
		end

		DRIVE2:
		begin
			next_bus_state = LATCH2;
			// Transmiter advances bit position
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
								// continue next word
								2'b11:
								begin
									next_tx_pend = TX_PEND;
									next_data0 = TX_DATA;
									next_tx_ack = 1;
								end
								
								// underflow
								2'b10:
								begin
									next_node_state = TRANSMIT_UNDERFLOW;
								end

								// End of current tx, prepare drive EOT
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
			if (input_buffer[2:0]==`RST_SEQ)
				next_bus_state = PHASE_ALIGN;
			else
			begin
				next_bus_state = DRIVE1;
				case (mode)
					MODE_TX:
					begin
						case (node_state)
							TRANSMIT_ADDR:
							begin
								// Received is the same as transmitted
								if (input_buffer[1:0]=={2{out_reg}})
								begin
									next_out_reg = addr_bit_extract;
								end
								// Received differ from transmitted, error
								else
								begin
									next_node_state = TRANSMIT_ERROR;
									next_tx_fail = 1;
									next_out_reg = ~MES_SEQ_CONST[1];
									next_bit_position = ERROR_RST_CNT - 1'b1;
								end
							end

							TRANSMIT_DATA:
							begin
								// Received is the same as transmitted
								if (input_buffer[1:0]=={2{out_reg}})
								begin
									next_out_reg = data0_bit_extract;
								end
								// Received differ from transmitted, error
								else
								begin
									next_node_state = TRANSMIT_ERROR;
									next_tx_fail = 1;
									next_out_reg = ~MES_SEQ_CONST[1];
									next_bit_position = ERROR_RST_CNT - 1'b1;
								end
							end

							TRANSMIT_EOT0:
							begin
								next_out_reg = MES_SEQ_CONST[1];
							end

							TRANSMIT_EOT1:
							begin
								next_node_state = TRANSMIT_WAIT_ACK0;
							end

							TRANSMIT_WAIT_ACK0:
							begin
							`ifdef OVERLAP_ACK
								next_node_state = TRANSMIT_WAIT_ACK1;
							`else
								if (input_buffer[1:0]==`ACK_SEQ)
									next_tx_success = 1;
								else
									next_tx_fail = 1;
								next_node_state = TRANSMIT_FWD;
							`endif
							end

							`ifdef OVERLAP_ACK
							TRANSMIT_WAIT_ACK1:
							begin
								next_node_state = TRANSMIT_WAIT_ACK2;
							end
							`endif

							TRANSMIT_UNDERFLOW:
							begin
								next_node_state = TRANSMIT_ERROR; 
								next_tx_fail = 1;
								next_out_reg = ~MES_SEQ_CONST[1];
								next_bit_position = ERROR_RST_CNT - 1'b1;
							end

							TRANSMIT_ERROR:
							begin
								if (bit_position)
								begin
									next_bit_position = bit_position - 1'b1;
									next_out_reg = ~out_reg;
								end
								else
									next_node_state = TRANSMIT_FWD;
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
									// RX overflow 
									next_bit_position = ERROR_RST_CNT - 1'b1;
									// happenede in last bit
									if (input_buffer_xor)
										next_node_state = RECEIVE_FWD;
									else
									begin
										next_out_reg = ~MES_SEQ_CONST[1];
										next_node_state = RECEIVE_ERROR;
									end
								end
								else
								begin
									next_rx_req = 1;
									next_rx_data = rx_data_out_buf;
									// end of tx
									if (input_buffer_xor)
									begin
										if (input_buffer[1:0]==`MES_SEQ)
										begin
											next_node_state = RECEIVE_DRIVE_ACK0;
											next_out_reg = ACK_SEQ_CONST[1];
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

							RECEIVE_ERROR:
							begin
								if (bit_position)
								begin
									next_bit_position = bit_position - 1'b1;
									next_out_reg = ~out_reg;
								end
								else
									next_node_state = RECEIVE_FWD;
							end

							// ACK completed
							RECEIVE_DRIVE_ACK1:
							begin
								next_node_state = RECEIVE_FWD;
							end


						endcase
					end

				endcase
			end
		end

		PHASE_ALIGN:
		begin
			next_bus_state = BUS_RESET;
		end

		BUS_RESET:
		begin
			if (input_buffer[2:0]==3'b111)
			begin
				next_bus_state = BUS_IDLE;
				next_mode = MODE_IDLE;
			end
		end

	endcase
end

// Output MUX
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
					if ((node_state==TRANSMIT_ADDR)||(node_state==TRANSMIT_DATA)||(node_state==TRANSMIT_EOT0)||(node_state==TRANSMIT_ERROR))
						DOUT = out_reg;
				end

				MODE_RX:
				begin
					if ((node_state==RECEIVE_DRIVE_ACK0)||(node_state==RECEIVE_ERROR))
					//if (node_state==RECEIVE_DRIVE_ACK0)
						DOUT = out_reg;
				end
			endcase
		end

		LATCH1:
		begin
			case (mode)
				MODE_TX:
				begin
					if (node_state==TRANSMIT_ERROR)
						DOUT = out_reg;
				end

				MODE_RX:
				begin
					if (node_state==RECEIVE_ERROR)
						DOUT = out_reg;
				end
			endcase
		end

		DRIVE2:
		begin
			case (mode)
				MODE_TX:
				begin
					if ((node_state==TRANSMIT_ADDR)||(node_state==TRANSMIT_DATA)||(node_state==TRANSMIT_EOT1)||(node_state==TRANSMIT_ERROR))
						DOUT = out_reg;
				end

				MODE_RX:
				begin
					if ((node_state==RECEIVE_DRIVE_ACK1)||(node_state==RECEIVE_ERROR))
					//if (node_state==RECEIVE_DRIVE_ACK1)
						DOUT = out_reg;
				end
			endcase
		end

		LATCH2:
		begin
			case (mode)
				MODE_TX:
				begin
					if (node_state==TRANSMIT_ERROR)
						DOUT = out_reg;
				end

				MODE_RX:
				begin
					if (node_state==RECEIVE_ERROR)
						DOUT = out_reg;
				end
			endcase
		end

		default: begin DOUT = DIN; end

	endcase
end

// Latch DIN only when BUS state in D1, D2, phase align, reset1, reset2
always @ (posedge CLK or negedge RESET)
begin
	if (~RESET)
	begin
		input_buffer <= 0;
	end
	else
	begin
		if ((bus_state==DRIVE1)||(bus_state==DRIVE2)||(bus_state==PHASE_ALIGN)||(bus_state==BUS_RESET))
			input_buffer <= {input_buffer[3:0], DIN};
	end
end

endmodule
