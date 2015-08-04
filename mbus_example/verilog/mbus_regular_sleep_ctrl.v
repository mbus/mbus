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

module mbus_regular_sleep_ctrl
  (
   //Input
   MBUS_CLKIN,
   RESETn,
   SLEEP_REQ,
   //Output
   MBC_SLEEP,
   MBC_SLEEP_B,
   MBC_ISOLATE,
   MBC_ISOLATE_B,
   MBC_CLK_EN,
   MBC_CLK_EN_B,
   MBC_RESET,
   MBC_RESET_B
   );

`include "include/mbus_def.v"

   input	MBUS_CLKIN;
   input	RESETn;
   input	SLEEP_REQ;
   
   output reg 	MBC_SLEEP;
   output 	MBC_SLEEP_B;
   output reg 	MBC_CLK_EN_B;
   output 	MBC_CLK_EN;
   output reg 	MBC_RESET;
   output  	MBC_RESET_B;
   output reg 	MBC_ISOLATE;
   output  	MBC_ISOLATE_B;
   
   assign 	MBC_SLEEP_B = ~MBC_SLEEP;
   assign 	MBC_CLK_EN = ~MBC_CLK_EN_B;
   assign  	MBC_RESET_B = ~MBC_RESET;
   assign  	MBC_ISOLATE_B = ~MBC_ISOLATE;

   reg [1:0] 	fsm_pos, fsm_neg;

   parameter 	HOLD = `IO_HOLD;	// During sleep
   parameter 	RELEASE = `IO_RELEASE;	// During wake-up

   reg 		MBC_SLEEP_POS, MBC_SLEEP_NEG;
   reg 		MBC_CLK_EN_B_POS, MBC_CLK_EN_B_NEG;
   reg 		MBC_RESET_POS, MBC_RESET_NEG;
   reg 		MBC_ISOLATE_POS, MBC_ISOLATE_NEG;

   always @ * begin
      if ((MBC_SLEEP_POS==HOLD)||(MBC_SLEEP_NEG==HOLD))
	MBC_SLEEP = HOLD;
      else
	MBC_SLEEP = RELEASE;

      if ((MBC_CLK_EN_B_POS==HOLD)||(MBC_CLK_EN_B_NEG==HOLD))
	MBC_CLK_EN_B = HOLD;
      else
	MBC_CLK_EN_B = RELEASE;

      if ((MBC_RESET_POS==HOLD)||(MBC_RESET_NEG==HOLD))
	MBC_RESET = HOLD;
      else
	MBC_RESET = RELEASE;
      
      if ((MBC_ISOLATE_POS==HOLD)||(MBC_ISOLATE_NEG==HOLD))
	MBC_ISOLATE = HOLD;
      else
	MBC_ISOLATE = RELEASE;
   end

   always @ (posedge MBUS_CLKIN or negedge RESETn) begin
      if (~RESETn) begin
	 fsm_pos <= 0;
	 MBC_SLEEP_POS <= HOLD;
	 MBC_CLK_EN_B_POS <= RELEASE;
	 MBC_ISOLATE_POS <= HOLD;
	 MBC_RESET_POS <= RELEASE;
      end
      else begin
	 case (fsm_pos)
	   0: begin
	      MBC_SLEEP_POS <= RELEASE;
	      MBC_CLK_EN_B_POS <= RELEASE;
	      fsm_pos <= 1;
	   end

	   1: begin
	      MBC_ISOLATE_POS <= RELEASE;
	      MBC_RESET_POS <= RELEASE;
	      fsm_pos <= 2;
	   end
	   2: begin
	      if (SLEEP_REQ)
		begin
		   MBC_ISOLATE_POS <= HOLD;
		   fsm_pos <= 3;
		end
	   end
	   3: begin
	      fsm_pos <= 0;
	      MBC_RESET_POS <= HOLD;
	      MBC_SLEEP_POS <= HOLD;
	      MBC_CLK_EN_B_POS <= HOLD;
	   end
	 endcase
      end
   end

   always @ (negedge MBUS_CLKIN or negedge RESETn) begin
      if (~RESETn) begin
	 fsm_neg <= 0;
	 MBC_SLEEP_NEG <= RELEASE;
	 MBC_CLK_EN_B_NEG <= HOLD;
	 MBC_ISOLATE_NEG <= RELEASE;
	 MBC_RESET_NEG <= HOLD;
      end
      else begin
	 case (fsm_neg)
	   0: begin
	      if (fsm_pos==2'b1) begin
		 MBC_CLK_EN_B_NEG <= RELEASE;
		 fsm_neg <= 1;
	      end
	      else begin
		 MBC_SLEEP_NEG <= RELEASE;
		 MBC_CLK_EN_B_NEG <= HOLD;
		 MBC_ISOLATE_NEG <= RELEASE;
		 MBC_RESET_NEG <= HOLD;
	      end
	   end
	   1: begin
	      MBC_RESET_NEG <= RELEASE;
	      fsm_neg <= 2;
	   end

	   2: begin
	      if (fsm_pos==2'b11)
		begin
		   MBC_SLEEP_NEG <= HOLD;
		   MBC_CLK_EN_B_NEG <= HOLD;
		   MBC_RESET_NEG <= HOLD;
		   fsm_neg <= 0;
		end
	   end
	 endcase
      end
   end

endmodule
