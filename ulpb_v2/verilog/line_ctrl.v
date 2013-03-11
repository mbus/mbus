module line_controller(
	input DIN,
	input CLKIN,
	input DOUT_FROM_BUS,
	input DOUT_EN_FROM_BUS,
	input BUS_INTERRUPT,
	input RELEASE_ISO,
	input EXT_INTERRUPT,
	output DOUT,
	output CLKOUT
);

parameter HOLD = 1'b1;
parameter RELEASE = ~HOLD;

always @ *
begin
	DOUT = DIN;

	if (EXT_INTERRUPT)
		DOUT = 0;
	else if ((RELEASE_ISO==RELEASE)&&(DOUT_EN_FROM_BUS))
		DOUT = DOUT_FROM_BUS;
end

endmodule
