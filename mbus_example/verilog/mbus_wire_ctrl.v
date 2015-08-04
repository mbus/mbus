/*
 * MBus Copyright 2015 Regents of the University of Michigan
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

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
 * IMPORTANT: Don't change blocking statement to non-blocking, it causes
 * simulation problems!!
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
		CLKOUT <= `SD 1'b1;
	else if (RELEASE_ISO_FROM_SLEEP_CTRL==`IO_HOLD)
		CLKOUT <= `SD CLKIN;
	else
		CLKOUT <= `SD CLKOUT_FROM_BUS;

	if (~RESETn)
		DOUT <= `SD 1'b1;
	else if (EXTERNAL_INT)
		DOUT <= `SD 0;
	else
	begin
		if (RELEASE_ISO_FROM_SLEEP_CTRL==`IO_HOLD)
			DOUT <= `SD DIN;
		else
			DOUT <= `SD DOUT_FROM_BUS;
	end
end
`else
always @ *
begin
	if (~RESETn)
		CLKOUT <= `SD 1'b1;
	else
		CLKOUT <= `SD CLKOUT_FROM_BUS;

	if (~RESETn)
		DOUT <= `SD 1'b1;
	else
		DOUT <= `SD DOUT_FROM_BUS;
end
`endif

endmodule // mbus_wire_ctrl_wresetn

