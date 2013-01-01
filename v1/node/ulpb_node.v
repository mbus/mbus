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
parameter ADDR_DRIVE = 2;
parameter ADDR_LATCH = 3;
parameter DATA_DRIVE = 4;
parameter DATA_LATCH = 5;
parameter END_OF_TX = 6;
parameter WAIT_ACK = 7;
parameter WAIT_ACK_FWD = 8;
parameter BUS_RESET = 9;

parameter NUM_OF_STATE = 10;

//assign OUT = (state==IDLE)? ~REQ_FROM_LC : ((state==RX)||(state==FWD))? in : etc...

reg		[log2(NUM_OF_STATE-1):0] state, next_state;
reg		[log2(DATA_WIDTH-1):0] bit_position, next_bit_position;
reg		bit_out, next_bit_out;
reg		DATA_INDICATOR, next_data_indicator;

wire	data1_bit_extract = (DATA1 & (1<<bit_position))? 1 : 0;
wire	data2_bit_extract = (DATA2 & (1<<bit_position))? 1 : 0;
wire	addr_bit_extract  = (ADDR  & (1<<bit_position))? 1 : 0;

// Output Combinational Logics
always @ *
begin
	OUT = bit_out;

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
		bit_position <= (ADDR_WIDTH-1);
		bit_out <= 1;
		DATA_INDICATOR <= 0;
	end
	else
	begin
		state <= next_state;
		bit_position <= next_bit_position;
		bit_out <= next_bit_out;
		DATA_INDICATOR <= next_data_indicator;
	end
end

always @ *
begin
	next_state = state;
	next_bit_position = bit_position;
	next_bit_out = bit_out;
	next_data_indicator = DATA_INDICATOR;
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
			if (~DATA_INDICATOR)
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
					next_data_indicator = ~DATA_INDICATOR;
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

always @ (posedge CLK or negedge RESET)
begin
	if (~RESET)
		input_buffer <= 0;
	else
		input_buffer <= {input_buffer[0], IN};
end

function integer log2;
	input [31:0] value;
	for (log2=0; value>0; log2=log2+1)
	value = value>>1;
endfunction

endmodule
