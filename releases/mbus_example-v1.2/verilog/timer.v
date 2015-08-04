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

//*******************************************************************************************
//Author:         ZhiYoong Foo (zhiyoong@umich.edu)
//Last Modified:  Feb 25 2014
//Description: 	  MBUS Timer Block Example
//		  Synthesize Block
//Update History: Feb 25 2014 - First commit
//******************************************************************************************* 

module timer
  (
   //**************************************
   //Power Domain
   //Input  - Layer Controller
   //Output - N/A
   //**************************************
   //Signals
   //Input
   CLK,
   TIMER_RESETn,
   TIMER_EN,
   TIMER_ROI,
   TIMER_SAT,
   TIMER_CLR_IRQ,
   //Output
   TIMER_VAL,
   TIMER_IRQ
   );

   input            CLK;
   input            TIMER_RESETn;
   input 	    TIMER_EN;
   input [7:0] 	    TIMER_SAT;
   input 	    TIMER_ROI;
   input 	    TIMER_CLR_IRQ;
   output reg [7:0] TIMER_VAL;
   output reg 	    TIMER_IRQ;

   reg [7:0] 	    next_TIMER_VAL;
   reg 		    next_TIMER_IRQ;
   
   always @* begin
      if (~TIMER_RESETn) begin
	 next_TIMER_VAL <= 8'h00;
      end
      else if (TIMER_EN) begin
	 if (TIMER_VAL == TIMER_SAT) begin
	    if (TIMER_ROI) begin
	       next_TIMER_VAL <= 8'h00;
	    end
	    else begin
	       next_TIMER_VAL <= TIMER_VAL;
	    end
	 end
	 else begin
	    next_TIMER_VAL <= TIMER_VAL +1;
	 end // else: !if(TIMER_VAL == TIMER_SAT)
      end // if (TIMER_EN)
      else begin
	 next_TIMER_VAL <= 8'h00;
      end // else: !if(TIMER_EN)
   end

   always @* begin
      if (~TIMER_RESETn) begin
	 next_TIMER_IRQ <= 1'b0;
      end
      else if (TIMER_CLR_IRQ) begin
	 next_TIMER_IRQ <= 1'b0;
      end
      else if ((next_TIMER_VAL == TIMER_SAT) && (next_TIMER_VAL != TIMER_VAL)) begin
	 next_TIMER_IRQ <= 1'b1;
      end
   end

   always @(posedge CLK or negedge TIMER_RESETn) begin
      if (~TIMER_RESETn) begin
	 TIMER_VAL <= `SD 8'h00;
	 TIMER_IRQ <= `SD 1'b0;
      end
      else begin
	 TIMER_VAL <= `SD next_TIMER_VAL;
	 TIMER_IRQ <= `SD next_TIMER_IRQ;
      end
   end
      
endmodule // timer
