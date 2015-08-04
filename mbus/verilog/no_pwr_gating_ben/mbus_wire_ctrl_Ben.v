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
	input RESETn,
	input DIN,
	input CLKIN,
	input DOUT_FROM_BUS,
	input CLKOUT_FROM_BUS,
	input RELEASE_ISO_FROM_SLEEP_CTRL,
	output reg DOUT,
	output reg CLKOUT,
	input EXTERNAL_INT,
	input MASTER_NODE
);

always @ *
begin
	if( !RESETn )
		CLKOUT <= #1 1'b1;
	else if (RELEASE_ISO_FROM_SLEEP_CTRL==`IO_HOLD)
	begin
		if (MASTER_NODE==1'b1)
			CLKOUT <= 1'b1;
		else
			CLKOUT <= #1 CLKIN;
	end
	else
		CLKOUT <= #1 CLKOUT_FROM_BUS;

	if ( !RESETn )
		DOUT <= #1 1'b1;
	else if (EXTERNAL_INT)
	begin
		DOUT <= #1 0;
	end
	else
	begin
		if (RELEASE_ISO_FROM_SLEEP_CTRL==`IO_HOLD)
		begin
			if (MASTER_NODE==1'b1)
				DOUT <= #1 1'b1;
			else
				DOUT <= #1 DIN;
		end
		else
		begin
			DOUT <= #1 DOUT_FROM_BUS;
		end
	end
end

endmodule // mbus_wire_ctrl_wresetn

