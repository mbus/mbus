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

//////////////////////////////////////////
// Author: 	ZhiYoong Foo
// Modified: 	March 6 2013
// Description: Tack on block for ULPB bus
//		Generates Data & Clock Flip Interrupt
// 		Maintains Last seen Clock State
//////////////////////////////////////////

module mbus_swapper
  (
   //Inputs
    input      CLK,
    input      RESETn,
    input      DATA,
    input      INT_FLAG_RESETn,
   //Outputs
    output reg LAST_CLK,
    output reg INT_FLAG
   );

   //Internal Declerations
   wire negp_reset;
   wire posp_reset;
   //Negative Phase Clock Resets
   reg 	  pose_negp_clk_0; //Positive Edge
   reg 	  nege_negp_clk_1; //Negative Edge
   reg 	  pose_negp_clk_2;
   reg 	  nege_negp_clk_3;
   reg 	  pose_negp_clk_4;
   reg 	  nege_negp_clk_5;
   wire   negp_int;        //Negative Phase Interrupt
   //Interrupt Reset
   wire   int_resetn;

   assign negp_reset = ~( CLK && RESETn);
   
   //////////////////////////////////////////
   // Interrupt Generation
   //////////////////////////////////////////
   
   //Negative Phase Clock Resets
   always @(posedge DATA or posedge negp_reset) begin
      if (negp_reset) begin
	 pose_negp_clk_0 = 0;
	 pose_negp_clk_2 = 0;
	 pose_negp_clk_4 = 0;
      end
      else begin
	 pose_negp_clk_0 = 1;
	 pose_negp_clk_2 = nege_negp_clk_1;
	 pose_negp_clk_4 = nege_negp_clk_3;
      end
   end

   always @(negedge DATA or posedge negp_reset) begin
      if (negp_reset) begin
	 nege_negp_clk_1 = 0;
	 nege_negp_clk_3 = 0;
	 nege_negp_clk_5 = 0;
      end
      else begin
	 nege_negp_clk_1 = pose_negp_clk_0;
	 nege_negp_clk_3 = pose_negp_clk_2;
	 nege_negp_clk_5 = pose_negp_clk_4;
      end
   end

   //Negative Phase Interrupt Generation
   assign negp_int = pose_negp_clk_0 &&
		     nege_negp_clk_1 &&
		     pose_negp_clk_2 &&
		     nege_negp_clk_3 &&
		     pose_negp_clk_4 &&
		     nege_negp_clk_5;

   //Interrupt Check & Clear
   assign int_resetn = RESETn && INT_FLAG_RESETn;
   
   always @(posedge negp_int or negedge int_resetn) begin
      if (~int_resetn) begin
	 INT_FLAG = 0;
      end
      else begin
	 INT_FLAG = 1;
      end
   end

   //////////////////////////////////////////
   // Last Seen Clock
   //////////////////////////////////////////

   always @(posedge negp_int or negedge RESETn) begin
      if (~RESETn) begin
	 LAST_CLK = 0;
      end
      else begin
	 LAST_CLK = CLK;
      end
   end
   
endmodule // mbus_swapper
