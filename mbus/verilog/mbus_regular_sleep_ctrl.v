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

/* Regular sleep controller
 * Author: Ye-Sheng Kuo, <samkuo@umich.edu>
 *
 *
 * Last modified: 8/11 '14 by Ye-Sheng
 *
 * Changing log:
 * 8/11 '14:
 * Renaming ports, adding complementary port
 */

module mbus_regular_sleep_ctrl(
	input	MBUS_CLKIN,
	input	RESETn,
	input	SLEEP_REQ,
	output	reg MBC_SLEEP,
	output	MBC_SLEEP_B,
	output	MBC_CLK_EN,
	output	reg MBC_CLK_EN_B,
	output	reg MBC_RESET,
	output	MBC_RESET_B,
	output	reg MBC_ISOLATE,
	output	MBC_ISOLATE_B,
	output	reg	INT_CLR_BUSY
);
assign MBC_SLEEP_B = ~MBC_SLEEP;
assign MBC_CLK_EN = ~MBC_CLK_EN_B;
assign MBC_RESET_B = ~MBC_RESET;
assign MBC_ISOLATE_B = ~MBC_ISOLATE;

`include "include/mbus_def.v"

reg	[1:0] fsm_pos, fsm_neg;

parameter HOLD = `IO_HOLD;			// During sleep
parameter RELEASE = `IO_RELEASE;	// During wake-up

reg	POWER_ON_POS, POWER_ON_NEG;
reg	RELEASE_CLK_POS, RELEASE_CLK_NEG;
reg RELEASE_RST_POS, RELEASE_RST_NEG;
reg	RELEASE_ISO_POS, RELEASE_ISO_NEG;

always @ *
begin
	if ((POWER_ON_POS==HOLD)||(POWER_ON_NEG==HOLD))
		MBC_SLEEP = HOLD;
	else
		MBC_SLEEP = RELEASE;

	if ((RELEASE_CLK_POS==HOLD)||(RELEASE_CLK_NEG==HOLD))
		MBC_CLK_EN_B = HOLD;
	else
		MBC_CLK_EN_B = RELEASE;

	if ((RELEASE_RST_POS==HOLD)||(RELEASE_RST_NEG==HOLD))
		MBC_RESET = HOLD;
	else
		MBC_RESET = RELEASE;
	
	if ((RELEASE_ISO_POS==HOLD)||(RELEASE_ISO_NEG==HOLD))
		MBC_ISOLATE = HOLD;
	else
		MBC_ISOLATE = RELEASE;
end

always @ (posedge MBUS_CLKIN or negedge RESETn)
begin
	if (~RESETn)
	begin
		fsm_pos <= 0;
		POWER_ON_POS <= HOLD;
		RELEASE_CLK_POS <= RELEASE;
		RELEASE_ISO_POS <= HOLD;
		RELEASE_RST_POS <= RELEASE;
		INT_CLR_BUSY <= 0;
	end
	else
	begin
		case (fsm_pos)
			0:
			begin
				POWER_ON_POS <= RELEASE;
				RELEASE_CLK_POS <= RELEASE;
				fsm_pos <= 1;
				INT_CLR_BUSY <= 0;
			end

			1:
			begin
				RELEASE_ISO_POS <= RELEASE;
				RELEASE_RST_POS <= RELEASE;
				fsm_pos <= 2;
			end

			2:
			begin
				if (SLEEP_REQ)
				begin
					RELEASE_ISO_POS <= HOLD;
					fsm_pos <= 3;
				end
			end

			3:
			begin
				fsm_pos <= 0;
				RELEASE_RST_POS <= HOLD;
				POWER_ON_POS <= HOLD;
				RELEASE_CLK_POS <= HOLD;
				INT_CLR_BUSY <= 1;
			end

		endcase
	end
end

always @ (negedge MBUS_CLKIN or negedge RESETn)
begin
	if (~RESETn)
	begin
		fsm_neg <= 0;
		POWER_ON_NEG <= RELEASE;
		RELEASE_CLK_NEG <= HOLD;
		RELEASE_ISO_NEG <= RELEASE;
		RELEASE_RST_NEG <= HOLD;
	end
	else
	begin
		case (fsm_neg)
			0:
			begin
				if (fsm_pos==2'b1)
				begin
					RELEASE_CLK_NEG <= RELEASE;
					fsm_neg <= 1;
				end
				else
				begin
					POWER_ON_NEG <= RELEASE;
					RELEASE_CLK_NEG <= HOLD;
					RELEASE_ISO_NEG <= RELEASE;
					RELEASE_RST_NEG <= HOLD;
				end
			end

			1:
			begin
				RELEASE_RST_NEG <= RELEASE;
				fsm_neg <= 2;
			end

			2:
			begin
				if (fsm_pos==2'b11)
				begin
					POWER_ON_NEG <= HOLD;
					RELEASE_CLK_NEG <= HOLD;
					RELEASE_RST_NEG <= HOLD;
					fsm_neg <= 0;
				end
			end
		endcase
	end
end


endmodule
