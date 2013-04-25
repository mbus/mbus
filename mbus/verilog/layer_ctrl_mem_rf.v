
// this module just read a word from ADDR_IN
// it has to tell either from RF or memory
module layer_ctrl_memrf_read(
	input 	CLK,
	input	RESETn,
	input	[SOMEWIDTH-1:0] ADDR_IN, // target address
	input	[SOMEWITH_FROM_RF-1:0] RF_DATA_IN,	// data from RF
	input	[SOMEWIDTH-1:0]	MEM_DIN,	// data from memory
	input	start_read,
	
	output	reg	[SOMEWIDTH-1:0]	DATA_OUT,	// data to upper module
	output	reg [SOME_WIDTH-1:0] MEM_ADDR_OUT, // address for memory
	output	reg MEM_READ,		// memory read interface
	output	reg data_ready
);

parameter	RF_ADDR_BASE = some address;
parameter	MEM_ADDR_BASE = some address;
parameter	SENSOR_BASE	= some address;

some address compare here...

reg		[2:0] state, next_state;
reg		next_data_ready;
reg		next_mem_read;
reg		[SOMEWIDTH-1:0] next_mem_addr_out;
reg		[SOMEWIDTH-1:0]	next_data_out;

always @ (posedge CLK or negedge RESETn)
begin
	if (~RESETn)
	begin
		state <= STATE_IDLE;
		data_ready <= 0;
		MEM_READ <= 0;
		MEM_ADDR_OUT <= 0;
		DATA_OUT <= 0;
	end
	else
	begin
		state <= next_state;
		data_ready <= next_data_ready;
		MEM_READ <= next_mem_read;
		MEM_ADDR_OUT <= next_mem_addr_out;
		DATA_OUT <= next_data_out;
	end
end

always @ *
begin
	next_state = state;
	next_data_ready = data_ready;
	next_mem_addr_out = MEM_ADDR_OUT;
	next_mem_read = MEM_READ;

	case (state)
		STATE_IDLE:
		begin
			if (start_read)
			begin
				case ()
					next_state = STATE_MEM_READ;
					next_mem_addr_out = something;
					next_mem_read = 1;
					next_state = STATE_RF_READ;
					next_state = STATE_SENSOR_READ;
				endcase
			end
		end

		STATE_MEM_READ:
		begin
			if (MEM_ACK_IN)
			begin
				next_mem_read = 0;
				next_data_ready = 1;
				next_state = STATE_IDLE;
				next_data_out = MEM_DIN;	// double check this line, make sure width is consistant
			end
		end

		STATE_RF_READ:
		begin
		end

		STATE_SENSOR_READ:
		begin
		end
	endcase
end

endmodule
