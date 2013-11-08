/*
 * Update history:
 *
 * date: 04/08 '13
 * modified content: add external interrupt
 * modified by: Ye-sheng Kuo <samkuo@umich.edu>
 *
 * date: 11/08 '13
 * modified content: add power gating macro
 * modified by: Ye-sheng Kuo <samkuo@umich.edu>
 * --------------------------------------------------------------------------
 * IMPORTANT:  
 * --------------------------------------------------------------------------
 * */

`timescale 1ns/1ps

`include "include/mbus_def.v"

module mbus_wire_ctrl(
	input RESETn,
	input DOUT_FROM_BUS,
	input CLKOUT_FROM_BUS,
	`ifdef POWER_GATING
	input DIN,
	input CLKIN,
	input RELEASE_ISO_FROM_SLEEP_CTRL,
	input EXTERNAL_INT,
	`endif
	output reg DOUT,
	output reg CLKOUT
);

`ifdef POWER_GATING
always @ *
begin
	if (~RESETn)
		CLKOUT = `SD 1'b1;
	else if (RELEASE_ISO_FROM_SLEEP_CTRL==`IO_HOLD)
		CLKOUT = `SD CLKIN;
	else
		CLKOUT = `SD CLKOUT_FROM_BUS;

	if (~RESETn)
		DOUT = `SD 1'b1;
	else if (EXTERNAL_INT)
		DOUT = `SD 0;
	else
	begin
		if (RELEASE_ISO_FROM_SLEEP_CTRL==`IO_HOLD)
			DOUT = `SD DIN;
		else
			DOUT = `SD DOUT_FROM_BUS;
	end
end
`else
always @ *
begin
	if (~RESETn)
		CLKOUT = `SD 1'b1;
	else
		CLKOUT = `SD CLKOUT_FROM_BUS;

	if (~RESETn)
		DOUT = `SD 1'b1;
	else
		DOUT = `SD DOUT_FROM_BUS;
end
`endif

endmodule // mbus_wire_ctrl_wresetn

