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

`include "include/mbus_def.v"
// simulate the always on register file which holds the assigned address

module mbus_addr_rf(
	input		RESETn,
	`ifdef POWER_GATING
	input		RELEASE_ISO_FROM_SLEEP_CTRL,
	`endif
	output	reg	[`DYNA_WIDTH-1:0] ADDR_OUT,
	input		[`DYNA_WIDTH-1:0] ADDR_IN,
	output	reg	ADDR_VALID,
	input		ADDR_WR_EN,
	input		ADDR_CLRn
);

wire	RESETn_local = (RESETn & ADDR_CLRn); 
`ifdef POWER_GATING
wire	ADDR_UPDATE = (ADDR_WR_EN & (~RELEASE_ISO_FROM_SLEEP_CTRL));
`else
wire	ADDR_UPDATE = ADDR_WR_EN;
`endif

always @ (posedge ADDR_UPDATE or negedge RESETn_local)
begin
	if (~RESETn_local)
	begin
		ADDR_OUT <= {`DYNA_WIDTH{1'b1}};
		ADDR_VALID <= 0;
	end
	else
	begin
		ADDR_OUT <= ADDR_IN;
		ADDR_VALID <= 1;
	end
end

endmodule
