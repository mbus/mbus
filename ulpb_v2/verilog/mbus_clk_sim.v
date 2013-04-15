
module mbus_clk_sim(
	input	ext_clk,	// generated from testbench, always ticking
	input	clk_en,		// from sleep controller
	output	clk_out		// to sleep controller, mbus
);

//assign clk_out = #5 (clk_en&ext_clk);

reg clk_out;

always @ *
begin
	if( clk_en)
		#3 clk_out <= #3 ext_clk;
	else
		#3 clk_out <= #3 1'b0;
end

endmodule
