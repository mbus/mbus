
`include "include/mbus_def.v"

// always on busy controller
module mbus_busy_ctrl(
	input	MBUS_CLK,
	input	RESETn,
	input	BC_RELEASE_ISO,
	input	SC_CLR_BUSY,
	input	CLR_BUSY,
	output	reg BUS_BUSYn);

reg	clr_busy_temp;
always @ *
begin
	if (BC_RELEASE_ISO==`IO_HOLD)
		clr_busy_temp = 0;
	else
		clr_busy_temp = CLR_BUSY;
end

wire RESET_BUSY = (RESETn & (~clr_busy_temp) & (~SC_CLR_BUSY));

always @ (negedge MBUS_CLK or negedge RESET_BUSY)
begin
	if (~MBUS_CLK)
		BUS_BUSYn <= 0;
	else
		BUS_BUSYn <= 1;
end

endmodule
