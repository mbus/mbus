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

// this block is for simulation only, NOT synthesisable


module rf_ctrl #( 
	parameter RF_DEPTH = 256, // this depth SHOULD less or equal than `LC_RF_DEPTH
	parameter LC_RF_DATA_WIDTH = 24
)
(
	input	RESETn,
	input	[LC_RF_DATA_WIDTH-1:0] DIN,
	input	[RF_DEPTH-1:0] LOAD,
	output 	[LC_RF_DATA_WIDTH*RF_DEPTH-1:0] DOUT
);

reg	[LC_RF_DATA_WIDTH-1:0] rf_array [0:RF_DEPTH-1];

genvar idx;
generate 

	for (idx=0; idx<(RF_DEPTH); idx=idx+1)
	begin: PACK
		assign DOUT[LC_RF_DATA_WIDTH*(idx+1)-1:LC_RF_DATA_WIDTH*idx] = rf_array[idx];
	end

	for (idx=0; idx<RF_DEPTH; idx = idx+1)
	begin: RF_WRITE
		always @ (posedge LOAD[idx] or negedge RESETn)
		begin
			if (~RESETn)
				rf_array[idx] <= 0;
			else
				rf_array[idx] <= DIN;
		end
	end
endgenerate

endmodule

