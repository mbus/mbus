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

// Simualtion only memory controller

module mem_ctrl(
	CLK,
	RESETn,
	ADDR,
	DATA_IN,
	MEM_REQ,
	MEM_WRITE,
	DATA_OUT,
	MEM_ACK_OUT
);
	parameter MEM_DEPTH = 65536;
	parameter LC_MEM_DATA_WIDTH = 32;
	parameter LC_MEM_ADDR_WIDTH = 32;

	input 	CLK;
	input	RESETn;
	input	[LC_MEM_ADDR_WIDTH-3:0]	ADDR;
	input	[LC_MEM_DATA_WIDTH-1:0]	DATA_IN;
	input	MEM_REQ;
	input	MEM_WRITE;
	output	reg [LC_MEM_DATA_WIDTH-1:0]	DATA_OUT;
	output	reg	MEM_ACK_OUT;

`include "include/mbus_func.v"


wire	[log2(MEM_DEPTH-1)-1:0] addr_equal = ADDR[log2(MEM_DEPTH-1)-1:0];

reg	 [LC_MEM_DATA_WIDTH-1:0] mem_array [0:MEM_DEPTH-1];
reg	[1:0] fsm;

parameter IDLE = 2'b00;
parameter CLEAR = 2'b01;
parameter WRITE = 2'b10;
parameter READ = 2'b11;

integer idx; 
initial
begin
	for (idx=0; idx<(MEM_DEPTH); idx=idx+1)
	begin
		mem_array[idx] <= 0;
	end
end

always @ (posedge CLK or negedge RESETn)
begin
	if (~RESETn)
	begin
		fsm <= IDLE;
		MEM_ACK_OUT <= 0;
		DATA_OUT <= 0;
	end
	else
	begin
		case (fsm)
			IDLE:
			begin
				if (MEM_REQ)
				begin
					if (MEM_WRITE)
						fsm <= WRITE;
					else
						fsm <= READ;
				end
			end

			WRITE:
			begin
				mem_array[addr_equal] <= DATA_IN;
				MEM_ACK_OUT <= 1;
				fsm <= CLEAR;
			end

			READ:
			begin
				DATA_OUT <= mem_array[addr_equal];
				MEM_ACK_OUT <= 1;
				fsm <= CLEAR;
			end

			CLEAR:
			begin
				if (~MEM_REQ)
				begin
					fsm <= IDLE;
					MEM_ACK_OUT <= 0;
				end
			end
		endcase
	end
end

endmodule
