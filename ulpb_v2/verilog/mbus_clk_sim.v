
module mbus_clk_sim(
	input	ext_clk,	// generated from testbench, always ticking
	input	clk_en,		// from sleep controller
	output	clk_out		// to sleep controller, mbus
);

assign clk_out = (clk_en&ext_clk);

endmodule
