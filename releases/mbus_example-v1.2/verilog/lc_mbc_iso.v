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
//Description: 	  MBUS Register File
//		  Semi Custom Block
//Update History: Feb 25 2014 - First commit
//******************************************************************************************* 

module lc_mbc_iso
  (
   //**************************************
   //Power Domain
   //Input  - Always On
   //Output - N/A
   //**************************************
   //Signals
   //Input
   MBC_ISOLATE,
   // LC --> MBC
   //Input
   ADDROUT_uniso,	
   DATAOUT_uniso,	
   PENDOUT_uniso,	
   REQOUT_uniso,	
   PRIORITYOUT_uniso,	
   ACKOUT_uniso,	
   RESPOUT_uniso,	
   //Output
   ADDROUT,		// ISOL value = Low
   DATAOUT,		// ISOL value = Low
   PENDOUT,		// ISOL value = Low
   REQOUT, 		// ISOL value = Low
   PRIORITYOUT,		// ISOL value = Low
   ACKOUT,		// ISOL value = Low
   RESPOUT,		// ISOL value = Low
   // MBC --> LC
   //Input
   LRC_SLEEP_uniso,
   LRC_RESET_uniso,
   LRC_ISOLATE_uniso,
   //Output
   LRC_SLEEP,		// ISOL value = High
   LRC_RESET,		// ISOL value = High
   LRC_ISOLATE,		// ISOL value = High
   // MBC --> SC
   //Input
   SLEEP_REQ_uniso,
   //Output
   SLEEP_REQ		// ISOL value = Low
   );

   //Input
   input         MBC_ISOLATE;
   // LC --> MBC
   //Input
   input [31:0]  ADDROUT_uniso;
   input [31:0]  DATAOUT_uniso;
   input 	 PENDOUT_uniso;
   input 	 REQOUT_uniso;
   input 	 PRIORITYOUT_uniso;
   input 	 ACKOUT_uniso;
   input 	 RESPOUT_uniso;
   //Output
   output [31:0] ADDROUT;
   output [31:0] DATAOUT;
   output 	 PENDOUT;
   output 	 REQOUT;
   output 	 PRIORITYOUT;
   output 	 ACKOUT;
   output 	 RESPOUT;
   // MBC --> LC
   //Input
   input 	 LRC_SLEEP_uniso;
   input 	 LRC_RESET_uniso;
   input 	 LRC_ISOLATE_uniso;
   //Output
   output 	 LRC_SLEEP;
   output 	 LRC_RESET;
   output 	 LRC_ISOLATE;
   // MBC --> SC
   input 	 SLEEP_REQ_uniso;
   output 	 SLEEP_REQ;

   // LC --> MBC
   assign 	 ADDROUT     = ~LRC_ISOLATE & ADDROUT_uniso;
   assign 	 DATAOUT     = ~LRC_ISOLATE & DATAOUT_uniso;
   assign 	 PENDOUT     = ~LRC_ISOLATE & PENDOUT_uniso;
   assign 	 REQOUT      = ~LRC_ISOLATE & REQOUT_uniso;
   assign 	 PRIORITYOUT = ~LRC_ISOLATE & PRIORITYOUT_uniso;
   assign 	 ACKOUT      = ~LRC_ISOLATE & ACKOUT_uniso;
   assign 	 RESPOUT     = ~LRC_ISOLATE & RESPOUT_uniso;
   // MBC --> LC
   assign 	 LRC_SLEEP   =  MBC_ISOLATE | LRC_SLEEP_uniso;
   assign 	 LRC_RESET   =  MBC_ISOLATE | LRC_RESET_uniso;
   assign 	 LRC_ISOLATE =  MBC_ISOLATE | LRC_ISOLATE_uniso;
   // MBC --> SC
   assign 	 SLEEP_REQ   = ~MBC_ISOLATE & SLEEP_REQ_uniso;
   
endmodule // lc_mbc_iso
