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

module mbus_clk_sim(
	input	ext_clk,	// generated from testbench, always ticking
	input	clk_en,		// from sleep controller
	output	reg clk_out	// to sleep controller, mbus
);

//assign clk_out = #5 (clk_en&ext_clk);

always @ *
begin
	if(clk_en)
		#3 clk_out <= #3 ext_clk;
	else
		#3 clk_out <= #3 1'b0;
end

endmodule
