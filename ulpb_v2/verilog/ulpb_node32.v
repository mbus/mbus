
`include "include/ulpb_def.v"

module ulpb_node32(
	input CLKIN, 
	input RESETn, 
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

// BUS interrupt interface
reg		BUS_INT_RSTn, next_bus_int_rstn;
wire	BUS_INT_STATE, BUS_INT;

// FSM1 changes at every posedge CLK
// always @ (negedge CLKIN)
// 		FSM2 <= FSM1
// always @ *
// case (FSM2)
// 	CLKOUT = 0, CLKOUT = CLKIN:
//
always @ (posedge CLKIN or negedge RESETn or posedge BUS_INT)
begin
	if (~RESETn)
	begin
		bus_state <= BUS_IDLE;
		BUS_INT_RSTn <= 1;
	end
	else
	begin
		if (BUS_INT)
			bus_state <= BUS_INTERRUPT;
		else
			bus_state <= next_bus_state;
		BUS_INT_RSTn <= next_bus_int_rstn;
	end
end

always @ *
begin
	next_bus_state = bus_state;
	next_bus_int_rstn = 1;
	next_req_interrupt = req_interrupt;
	
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
			next_bus_state = BUS_PRIO;
		end

		BUS_PRIO:
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
			next_bus_state = BUS_ADDR;
		end

		BUS_ADDR:
		begin
			if (bit_position)
				next_bit_position = bit_position - 1'b1;
			else
			begin
				next_bit_position = `DATA_WIDTH - 1'b1;
				next_bus_state = BUS_DATA;
			end
			if (mode==MODE_RX)
				next_rx_addr = {RX_ADDR[`ADDR_WIDTH-2:0], DIN};
		end

		BUS_DATA:
		begin
			case (mode)
				MODE_TX:
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
								next_bus_state = BUS_INTERRUPT;
								next_req_interrupt = 1;
							end

							default:
							begin
								next_bus_state = BUS_INTERRUPT;
								next_req_interrupt = 1;
							end
						endcase
					end
				end

				MODE_RX:
				begin
					next_rx_data_buffer = {rx_data_buffer[0], DIN};
					next_rx_data = {RX_DATA[`DATA_WIDTH-2:0], rx_data_buffer[1]};
					if (bit_position)
						next_bit_position = bit_position - 1'b1;
					else
						next_bit_position = `DATA_WIDTH - 1'b1;
					if (address_match==0)
						next_mode = MODE_FWD;
				end

			endcase
		end

		BUS_INTERRUPT:
		begin
			next_bus_state = BUS_CONTROL0;
		end

		BUS_CONTROL0:
		begin
			next_bus_state = BUS_CONTROL1;
		end

		BUS_CONTROL1:
		begin
			next_bus_state = BUS_CONTROL2;
		end

		BUS_CONTROL2:
		begin
			next_bus_state = BUS_IDLE;
		end
	endcase
end

always @ (negedge CLKIN or negedge RESETn)
begin
	if (~RESETn)
	begin
		bus_state_neg <= BUS_IDLE;
		out_reg <= 1;
	end
	else
	begin
		bus_state_neg <= bus_state;
		case (bus_state)
			BUS_ADDR:
			begin
				if (mode==MODE_TX)
					out_reg <= addr_bit_extract;
			end

			BUS_DATA:
			begin
				if (mode==MODE_TX)
					out_reg <= data_bit_extract;
			end

		endcase
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

		BUS_PRIO:
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
		BUS_INTERRUPT: begin if (req_interrupt) CLK_OUT = 0; end
	endcase
end

ulpb_swapper swapper0(
	// inputs
	.CLK(CLKIN),
    .RESETn(RESETn),
    .DATA(DIN),
    .INT_FLAG_RESETn(BUS_INT_RSTn),
   	//Outputs
    .INT(),
    .LAST_CLK(BUS_INT_STATE),
    .INT_FLAG(BUS_INT));

endmodule
