
module mbus_int_ctrl(
	input	CLKIN,
	input	RESETn,
	input	BC_RELEASE_ISO,
	input	SC_CLR_BUSY,
	input	MBUS_CLR_BUSY,

	input	REQ_INT, 
	input	BC_PWR_ON,
	input	LC_PWR_ON,
	output 	EXTERNAL_INT_TO_WIRE, 
	output	EXTERNAL_INT_TO_BUS, 
	input	CLR_EXT_INT
);

wire mbus_busyn;

mbus_busy_ctrl busy0(
	.CLKIN(CLKIN),
	.RESETn(RESETn),
	.BC_RELEASE_ISO(BC_RELEASE_ISO),
	.SC_CLR_BUSY(SC_CLR_BUSY),
	.MBUS_CLR_BUSY(MBUS_CLR_BUSY),
	.BUS_BUSYn(mbus_busyn));

mbus_ext_int ext0(
	.CLKIN(CLKIN), 
	.RESETn(RESETn),
	.REQ_INT(REQ_INT), 
	.BUS_BUSYn(mbus_busyn),
	.BC_PWR_ON(BC_PWR_ON),
	.LC_PWR_ON(LC_PWR_ON),
	.EXTERNAL_INT_TO_WIRE(EXTERNAL_INT_TO_WIRE), 
	.EXTERNAL_INT_TO_BUS(EXTERNAL_INT_TO_BUS), 
	.CLR_EXT_INT(CLR_EXT_INT)
);

endmodule
