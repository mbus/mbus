
`include "include/mbus_def.v"

// always on busy controller
module mbus_busy_ctrl(
	input	CLKIN,
	input	RESETn,
	input	BC_RELEASE_ISO,
	input	SC_CLR_BUSY,
	input	MBUS_CLR_BUSY,
	output	reg BUS_BUSYn);

reg	clr_busy_temp;
always @ *
begin
	if (BC_RELEASE_ISO==`IO_HOLD)
		clr_busy_temp = 0;
	else
		clr_busy_temp = MBUS_CLR_BUSY;
end

wire RESETn_BUSY = ((~clr_busy_temp) & (~SC_CLR_BUSY));

// Use SRFF
always @ (negedge CLKIN or negedge RESETn or negedge RESETn_BUSY)
begin
	// set port
	if (~RESETn)
		BUS_BUSYn <= 1;
	// reset port
	else if (~CLKIN)
		BUS_BUSYn <= 0;
	// clk port
	else
		BUS_BUSYn <= 1;
end

endmodule
