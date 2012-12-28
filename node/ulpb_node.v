module ulpb_node(CLK, RESET, IN, OUT, ADDR, DATA1, DATA2, DATA_PENDING, DATA_INDICATOR);

parameter ADDR_WIDTH=8;
parameter DATA_WIDTH=32;
input 	CLK, RESET, IN;
input	[ADDR_WIDTH-1:0] ADDR;
input	[DATA_WIDTH-1:0] DATA1, DATA2;
input	DATA_PENDING;
input	REQ_TX;
output	DATA_INDICATOR;
output	OUT;

parameter IDLE = 0;
parameter ARBITRATION_RESOLVED = 1;
parameter ADDR_LATCH = 2;
parameter ADDR_DRIVE = 3;

//assign OUT = (state==IDLE)? ~REQ_FROM_LC : ((state==RX)||(state==FWD))? in : etc...

reg		state, next_state;
wire	data1_bit_extract = (DATA1 & (1<<bit_position))? 1 : 0;
wire	data2_bit_extract = (DATA2 & (1<<bit_position))? 1 : 0;
wire	addr_bit_extract  = (ADDR  & (1<<bit_position))? 1 : 0;

// Output Combinational Logics
always @ *
begin
	case (state)
		IDLE:
		begin
			OUT = ((~REQ_TX) & IN);
		end

		FWD:
		begin
			OUT = IN;
		end

		END_OF_TX:
		begin
			OUT = 0;
		end

		WAIT_ACK:
		begin
			OUT = 1;
		end

		WAIT_ACK_FWD:
		begin
			OUT = IN;
		end

		default:
		begin
			OUT = bit_out;
		end

	endcase
end

always @ (posedge CLK or negedge RESET)
begin
	if (~RESET)
	begin
		state <= IDLE;
		bit_out <= 1;
	end
	else
	begin
		state <= next_state;
		bit_out <= next_bit_out;
	end
end

always @ *
begin
	next_state = state;
	next_bit_out = bit_out;
	case (state)
		IDLE:
		begin
			if (IN^OUT)
			begin
				next_state = ADDR_DRIVE;
				next_bit_position = ADDR_WIDTH - 1;
			end
			else
				next_state = FWD;
		end

		ADDR_DRIVE:
		begin
			next_bit_out = addr_bit_extract;
			next_state = ADDR_LATCH;
		end

		ADDR_LATCH:
		begin
			if (bit_position)
			begin
				next_bit_position = bit_position - 1;
				next_state = ADDR_DRIVE;
			end
			else
			begin
				next_bit_position = DATA_WIDTH - 1;
				next_state = DATA_DRIVE;
				next_data_indicator = 0;
			end
		end

		DATA_DRIVE:
		begin
			if (~data_indicator)
				next_bit_out = data1_bit_extract;
			else
				next_bit_out = data2_bit_extract;
			next_state = DATA_LATCH;
		end

		DATA_LATCH:
		begin
			if (bit_position)
			begin
				next_bit_position = bit_position - 1;
				next_state = DATA_DRIVE;
			end
			else
			begin
				if (DATA_PENDING)
				begin
					next_data_indicator = ~data_indicator;
					next_state = DATA_DRIVE;
				end
				else
				begin
					next_state = END_OF_TX;
				end
			end
		end
		
		END_OF_TX:
		begin
			next_state = WAIT_ACK;
		end

		WAIT_ACK:
		begin
			next_state = WAIT_ACK_FWD;
		end

		WAIT_ACK_FWD:
		begin
			if (~IN)
				next_state = BUS_RESET;
		end

		BUS_RESET:
		begin
			next_state = IDLE;
		end

	endcase
end


endmodule
