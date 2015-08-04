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
//Description: 	  MBUS Analog Block Example
//		  Custom Block
//Update History: Feb 25 2014 - First commit
//******************************************************************************************* 

module ablk
  (
   //**************************************
   //Power Domain
   //Input  - Own Power Domain
   //Output - N/A
   //**************************************
   //Signals
   //Input
   ABLK_PG,	 //Active High
   ABLK_RESETn,  //Active Low
   ABLK_EN,	 //Active High
   ABLK_CONFIG_0,//Config Bits
   ABLK_CONFIG_1 //Config Bits
   //Output
   );

   input       ABLK_PG;
   input       ABLK_RESETn;
   input       ABLK_EN;
   input [3:0] ABLK_CONFIG_0;
   input [3:0] ABLK_CONFIG_1;

   always @(ABLK_PG) begin
      $write("%c[1;34m",27); 
      $display("ablk Input ABLK_PG Has been changed to:%x", ABLK_PG);
      $write("%c[0m",27);
   end

   always @(ABLK_RESETn) begin
      $write("%c[1;34m",27); 
      $display("ablk Input ABLK_RESETn Has been changed to:%x", ABLK_RESETn);
      $write("%c[0m",27);
   end

   always @(ABLK_EN) begin
      $write("%c[1;34m",27); 
      $display("ablk Input ABLK_EN Has been changed to:%x", ABLK_EN);
      $write("%c[0m",27);
   end

   always @(ABLK_CONFIG_0) begin
      $write("%c[1;34m",27); 
      $display("ablk Input ABLK_CONFIG_0 Has been changed to:%x", ABLK_CONFIG_0);
      $write("%c[0m",27);
   end

   always @(ABLK_CONFIG_1) begin
      $write("%c[1;34m",27); 
      $display("ablk Input ABLK_CONFIG_1 Has been changed to:%x", ABLK_CONFIG_1);
      $write("%c[0m",27);
   end

endmodule // ablk
