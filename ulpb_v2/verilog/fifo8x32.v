
module fifo8x32(DATA, Q, CLK, WE, RE, RESET, FULL, EMPTY);

`include "include/ulpb_func.v"

parameter WIDTH = 32;
parameter DEPTH = 8;

input	[WIDTH-1:0] DATA;
output	[WIDTH-1:0] Q;

input	CLK, RESET, WE, RE;
output	FULL, EMPTY;

reg		[WIDTH-1:0] mem [0:DEPTH-1];
reg		[log2(DEPTH-1)-1:0] head, tail; 

wire	[WIDTH-1:0] Q_buf = mem[tail][WIDTH-1:0];
reg		[WIDTH-1:0] Q;

assign EMPTY = ((head==0)&&(tail==DEPTH-1))? 1 : (head == (tail+1))? 1 : 0;
assign FULL = (head==tail)? 1:0;

always @ (posedge CLK)
begin
	if (~RESET)
		Q <= 0;
	else
		Q <= Q_buf;
end

integer k;

always @ (posedge CLK)
begin
	if (~RESET)
	begin
		head <= 0;
		tail <= DEPTH - 1;
		for (k=0;k<DEPTH;k=k+1)
			mem[k] <= 0;
	end
	else
	begin
		if (RE & ~EMPTY)
		begin
			tail <= tail + 1;
		end

		if (WE & ~FULL)
		begin
			mem[head] <= DATA;
			head <= head + 1;
		end
	end
end


endmodule
