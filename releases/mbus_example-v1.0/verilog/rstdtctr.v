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
//Description: 	  MBUS Reset Detector (Active Low)
//		  Custom Block
//Update History: Feb 25 2014 - First commit
//******************************************************************************************* 

module rstdtctr
  (
   //Power Domain
   //Always On
   //Input
   //Output
   RESETn
   );

   output reg RESETn; //Active Low

   initial begin
      RESETn <= 1'b0;
      `RESET_TIME;
      RESETn <= 1'b1;
   end


endmodule // rstdtctr

