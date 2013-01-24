
module testbench();

reg 	IN, RESET, CLK_IN;
reg		output_release;

wire	OUT, CLK_OUT;

control c0(IN, OUT, RESET, CLK_OUT, CLK_IN);

`define SD #1

initial
begin
	CLK_IN = 0;
	IN = 1;
	RESET = 0;
	output_release = 0;
	@ (negedge CLK_IN)
	@ (posedge CLK_IN)
		`SD RESET = 1;
		IN = 0;

	@ (posedge CLK_OUT)
	@ (posedge CLK_OUT)
		`SD IN = 1;
	@ (posedge CLK_OUT)
	@ (posedge CLK_OUT)
	@ (posedge CLK_OUT)
	@ (posedge CLK_OUT)
		`SD IN = 0;
	@ (posedge CLK_OUT)
	@ (posedge CLK_OUT)
	@ (posedge CLK_OUT)
	@ (posedge CLK_OUT)
		`SD IN = 1;
	@ (posedge CLK_OUT)
	@ (posedge CLK_OUT)
	@ (posedge CLK_OUT)
	@ (posedge CLK_OUT)
		`SD IN = 1;
	@ (posedge CLK_OUT)
	@ (posedge CLK_OUT)
	@ (posedge CLK_OUT)
	@ (posedge CLK_OUT)
		`SD IN = 0;
	@ (posedge CLK_OUT)
	@ (posedge CLK_OUT)
	@ (posedge CLK_OUT)
	@ (posedge CLK_OUT)
		`SD IN = 1;
	@ (posedge CLK_OUT)
	@ (posedge CLK_OUT)
	@ (posedge CLK_OUT)
	@ (posedge CLK_OUT)
	// End Sequence
		`SD IN = 0;
	@ (posedge CLK_OUT)
	@ (posedge CLK_OUT)
		`SD IN = 1;
	@ (posedge CLK_OUT)
	@ (posedge CLK_OUT)
		`SD IN = 1;
	@ (posedge CLK_OUT)
	@ (posedge CLK_OUT)
		`SD IN = 0;
	@ (posedge CLK_OUT)
	@ (posedge CLK_OUT)
	// ACK
		`SD IN = 0;
	@ (posedge CLK_OUT)
	@ (posedge CLK_OUT)
		`SD IN = 1;
	@ (posedge CLK_OUT)
	@ (posedge CLK_OUT)
		`SD IN = 1;
	@ (posedge CLK_OUT)
	@ (posedge CLK_OUT)
		`SD IN = 0;
	@ (posedge CLK_OUT)
		output_release = 1;
	@ (posedge CLK_OUT)
	#200
		$stop;
end

always @ (*)
	if (output_release)
		IN <= OUT;

always #5 CLK_IN = ~CLK_IN;

endmodule
