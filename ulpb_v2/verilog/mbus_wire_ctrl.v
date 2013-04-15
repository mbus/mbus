/*
 * Last modified date: 04/08 '13
 * Last modified by: Ye-sheng Kuo <samkuo@umich.edu>
 * Last modified content: add external interrupt
 * --------------------------------------------------------------------------
 * IMPORTANT:  
 * --------------------------------------------------------------------------
 * */

`timescale 1ns/1ps

`include "include/mbus_def.v"

module mbus_wire_ctrl(
	input DIN,
	input CLKIN,
	input DOUT_FROM_BUS,
	input CLKOUT_FROM_BUS,
	input RELEASE_ISO_FROM_SLEEP_CTRL,
	output reg DOUT,
	output reg CLKOUT,
	input EXTERNAL_INT
);

always @ *
begin
	if (RELEASE_ISO_FROM_SLEEP_CTRL==`IO_HOLD)
	begin
		DOUT = DIN;
		CLKOUT = CLKIN;
		if (EXTERNAL_INT)
			DOUT = 0;
		else
			DOUT = DIN;
	end
	else
	begin
		DOUT = DOUT_FROM_BUS;
		CLKOUT = CLKOUT_FROM_BUS;
	end
end

endmodule
