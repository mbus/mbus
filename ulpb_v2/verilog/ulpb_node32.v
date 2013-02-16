
`include "include/ulpb_def.v"

module ulpb_node32(
	input CLKIN, 
	input RESET, 
	input DIN, 
	output reg CLKOUT,
	output reg DOUT, 
	input [`ADDR_WIDTH-1:0] TX_ADDR, 
	input [`DATA_WIDTH-1:0] TX_DATA, 
	input TX_PEND, 
	input TX_REQ, 
	input PRIORITY,
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

// Node mode
parameter MODE_TX_NON_PRIO = 0;
parameter MODE_TX = 1;
parameter MODE_RX = 2;
parameter MODE_FWD = 3;

parameter NUM_OF_BUS_STATE = 10;

// general registers
reg		[2:0] RESET_COUNT;		// magic reset counter
reg		[log2(NUM_OF_BUS_STATE-1)-1:0] bus_state, next_bus_state, bus_state_neg;
reg		[log2(NUM_OF_NODE_STATE-1)-1:0] node_state, next_node_state;
reg		[log2(`DATA_WIDTH-1)-1:0] bit_position, next_bit_position; 
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
wire	data_bit_extract = ((DATA & (1'b1<<bit_position))==0)? 1'b0 : 1'b1;
wire	address_match = (((RX_ADDR^ADDRESS)&ADDRESS_MASK)==0)? 1'b1 : 1'b0;


// FSM1 changes at every posedge CLK
// always @ (negedge CLKIN)
// 		FSM2 <= FSM1
// always @ *
// case (FSM2)
// 	CLKOUT = 0, CLKOUT = CLKIN:
//
always @ (posedge CLKIN or posedge RESET)
begin
	if (RESET)
	begin
		bus_state <= BUS_IDLE;
	end
	else
	begin
		bus_state <= next_bus_state;
	end
end

always @ *
begin
	next_bus_state = bus_state;
	
	// Interface registers
	next_tx_ack = TX_ACK;
	next_rx_reg = RX_REQ;
	next_rx_pend = RX_PEND;
	next_tx_fail = TX_FAIL;
	next_tx_success = TX_SUCC;

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

	case (bus_state)
		BUS_IDLE:
		begin
			if (DIN^DOUT)
				next_mode = MODE_TX_NON_PRIO;
			else
				next_mode = MODE_RX;
			// general registers
			next_bus_state = BUS_ARBITRATE;
			next_bit_position = `ADDR_WIDTH - 1'b1;
		end

		BUS_ARBITRATE:
		begin
			next_bus_state = BUS_PRIO_D;
		end

		BUS_PRIO_D:
		begin
			if (mode==MODE_TX_NON_PRIO)
			begin
				// Lose Priority
				if (DIN^DOUT)
				begin
					next_mode = MODE_RX;
					next_node_state = RECEIVE_ADDR;
				end
				// Remain Arbitration
				else
				begin
					next_addr = TX_ADDR;
					next_data0 = TX_DATA;
					next_mode = MODE_TX;
					next_tx_ack = 1;
					next_tx_pend = TX_PEND;
					next_node_state = TRANSMIT_ADDR;
				end
			end
			else
			begin
				// Win Priority
				if (DIN^DOUT)
				begin
					next_addr = TX_ADDR;
					next_data0 = TX_DATA;
					next_mode = MODE_TX;
					next_tx_ack = 1;
					next_tx_pend = TX_PEND;
					next_node_state = TRANSMIT_ADDR;
				end
				else
				begin
					next_mode = MODE_RX;
					next_node_state = RECEIVE_ADDR;
				end
			end
			next_bus_state = BUS_PRIO_L;
		end

		BUS_PRIO_L:
		begin
			if (mode==MODE_TX)
			begin
				next_out_reg = addr_bit_extract;
				next_bit_position = bit_position - 1'b1;
			end
			next_bus_state = BUS_ADDR;
		end

		BUS_ADDR:
		begin
			if (mode==MODE_TX)
			begin
				next_out_reg = addr_bit_extract;
				if (bit_position)
					next_bit_position = bit_position - 1'b1;
				else
				begin
					next_bit_position = `DATA_WIDTH - 1'b1;
					next_bus_state = BUS_DATA;
				end
			end
			else
			begin
				next_rx_addr = {RX_ADDR[`ADDR_WIDTH-2:0], DIN};
			end
		end

		BUS_DATA:
		begin
			case (mode)
				MODE_TX:
				begin
					next_out_reg = data_bit_extract;
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
							end

							// Drive last bit
							default:
							begin
								next_bus_state = BUS_EOB;
							end
						endcase
					end
				end

				BUS_EOB:
				begin
					next_bus_state = BUS_EOT;
				end

				MODE_RX:
				begin
					next_rx_addr = {RX_DATA[`DATA_WIDTH-2:0], DIN};
					if (address_match==0)
						next_mode = MODE_FWD;
				end

				MODE_FWD:
				begin
				end
			endcase
		end
	endcase
end

always @ (negedge CLKIN or posedge RESET)
begin
	if (RESET)
	begin
		bus_state_neg <= BUS_IDLE;
		out_reg <= 1;
	end
	else
	begin
		bus_state_neg <= bus_state;
		if (mode==MODE_TX)
		begin
			case (bus_state)
				BUS_ADDR: begin out_reg <= addr_bit_extract; end
				BUS_DATA: begin out_reg <= data_but_extract; end
				default: begin out_reg <= 1; end
			endcase
		end
	end
end

always @ *
begin
	DOUT = DIN;
	case (bus_state_neg)
		BUS_IDLE:
		begin
			DOUT = ((~TX_REQ) & DIN);
		end

		BUS_ARBITRATE:
		begin
			if (mode==MODE_TX_NON_PRIO)
				DOUT = 0;
		end

		BUS_PRIO_D:
		begin
			if (mode==MODE_TX_NON_PRIO)
			begin
				if (~PRIORITY)
					DOUT = 0;
				else
					DOUT = DIN;
			end
			else if ((mode==MODE_RX)&&(PRIORITY & TX_REQ))
				DOUT = 1;
		end

		BUS_PRIO_L:
		begin
			DOUT = 0;
		end

		BUS_ADDR:
		begin
			if (mode==MODE_TX)
				DOUT = out_reg;
		end

		BUS_DATA:
		begin
			if (mode==MODE_TX)
				DOUT = out_reg;
		end

	endcase
end

always @ *
begin
	CLKOUT = CLKIN;
	case (bus_state_neg)
		
	endcase
end

always @ (posedge DIN or posedge CLKIN)
begin
	if (CLKIN)
		RESET_COUNT <= 0;
	else
		RESET_COUNT <= RESET_COUNT + 1'b1;
end

endmodule
