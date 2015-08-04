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
//Description: 	  MBUS Bus Controller (MBC) Power Gate Header (Active High)
//		  Custom Block
//Update History: Feb 25 2014 - First commit
//******************************************************************************************* 

module mbc_header
  (
   //**************************************
   //Power Domain
   //Input  - Always On
   //Output - MBUS Bus Controller Domain
   //**************************************
   //Signals
   //Input
   SLEEP
   //Output
   );

   input SLEEP; //Active High

   always @(SLEEP) begin
      if (SLEEP) begin
	 $write("%c[1;34m",27); 
	 $display("***********************************************");
	 $display("*********MBUS CONTROLLER IS POWER GATED********");
	 $display("*********AT TIME:", $time);
	 $display("***********************************************");
	 $write("%c[0m",27); 
      end
      else begin
	 $write("%c[1;34m",27); 
	 $display("***********************************************");
	 $display("********MBUS CONTROLLER IS POWER UNGATED*******");
	 $display("*********AT TIME:", $time);
	 $display("***********************************************");
	 $write("%c[0m",27); 
      end
   end // always @ (SLEEP)

endmodule // mbc_header
