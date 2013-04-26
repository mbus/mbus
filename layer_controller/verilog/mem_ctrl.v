
// Simualtion only memory controller
`include "include/mbus_def.v"

module mem_ctrl(
	input 	CLK,
	input	RESETn,
	input	[`LC_MEM_ADDR_WIDTH-1:0]	ADDR,
	input	[`LC_MEM_DATA_WIDTH-1:0]	DATA_IN,
	input	MEM_REQ,
	input	MEM_WRITE,
	output	reg [`LC_MEM_DATA_WIDTH-1:0]	DATA_OUT,
	output	reg	MEM_ACK_OUT
);

`include "include/mbus_func.v"

parameter MEM_DEPTH = 65536;

wire	[log2(MEM_DEPTH-1)-1:0] addr_equal = ADDR[log2(MEM_DEPTH-1)-1:0];

reg	 [`LC_MEM_DATA_WIDTH-1:0] mem_array [0:MEM_DEPTH-1];
reg	[1:0] fsm;

parameter IDLE = 2'b00;
parameter CLEAR = 2'b01;
parameter WRITE = 2'b10;
parameter READ = 2'b11;

integer idx; 
initial
begin
	for (idx=0; idx<(MEM_DEPTH); idx=idx+1)
	begin
		mem_array[idx] <= 0;
	end
end

always @ (posedge CLK or negedge RESETn)
begin
	if (~RESETn)
	begin
		fsm <= IDLE;
		MEM_ACK_OUT <= 0;
		DATA_OUT <= 0;
	end
	else
	begin
		case (fsm)
			IDLE:
			begin
				if ((MEM_REQ) && (ADDR<MEM_DEPTH))
				begin
					if (MEM_WRITE)
						fsm <= WRITE;
					else
						fsm <= READ;
				end
			end

			WRITE:
			begin
				mem_array[addr_equal] <= DATA_IN;
				MEM_ACK_OUT <= 1;
				fsm <= CLEAR;
			end

			READ:
			begin
				DATA_OUT <= mem_array[addr_equal];
				MEM_ACK_OUT <= 1;
				fsm <= CLEAR;
			end

			CLEAR:
			begin
				if (~MEM_REQ)
					fsm <= IDLE;
			end
		endcase
	end
end

endmodule
