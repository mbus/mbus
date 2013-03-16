/*
 * Last modified date: 03/16 '13
 * Last modified by: Ye-sheng Kuo <samkuo@umich.edu>
 * Last modified content: Newly added
 * --------------------------------------------------------------------------
 * IMPORTANT: This module only works for RX only layers, not able to transmit.
 * 			Also, this module should be always on, do NOT connect this module
 * 			to power gated domain.
 * --------------------------------------------------------------------------
 * */

`include "include/ulpb_def.v"

module line_controller_rx_only(
	input DIN,
	input CLKIN,
	input DOUT_FROM_BUS,
	input CLKOUT_FROM_BUS,
	input RELEASE_ISO,
	output DOUT,
	output CLKOUT
);

parameter HOLD = `IO_HOLD;			// During sleep
parameter RELEASE = `IO_RELEASE;	// During wake-up

always @ *
begin
	if (RELEASE_ISO==HOLD)
	begin
		DOUT = 1;
		CLKOUT = CLKIN;
	end
	else
	begin
		DOUT = DOUT_FROM_BUS;
		CLKOUT = CLKOUT_FROM_BUS;
	end
end

endmodule
