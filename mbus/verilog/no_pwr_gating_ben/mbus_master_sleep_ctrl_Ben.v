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

module SLEEP_CONTROLv4
  ( 
    output reg MBC_ISOLATE, 
    output     MBC_ISOLATE_B,
    output reg MBC_RESET,
    output     MBC_RESET_B,
    output     MBC_SLEEP,
    output     MBC_SLEEP_B,
    output     SYSTEM_ACTIVE,
    output     WAKEUP_REQ_ORED,
  
    input      CLK,
    input      MBUS_DIN,
    input      RESETn,
    input      SLEEP_REQ,
    input      WAKEUP_REQ0,
    input      WAKEUP_REQ1,
    input      WAKEUP_REQ2 
    );

   reg 	       set_tran_to_wake;
   reg 	       rst_tran_to_wake;	// act as tran to "sleep"

   assign      MBC_ISOLATE_B = ~MBC_ISOLATE;
   assign      MBC_RESET_B = ~MBC_RESET;
   reg 	       MBC_SLEEP_int;
   assign      MBC_SLEEP_B = ~MBC_SLEEP;
   
   reg 	       tran_to_wake;
   
   assign      SYSTEM_ACTIVE = MBC_SLEEP_B | MBC_ISOLATE_B;
   
   assign      WAKEUP_REQ_ORED	= WAKEUP_REQ0 | WAKEUP_REQ1 | WAKEUP_REQ2;
   

   // set_tran_to_wake
	always @ *
	begin
		if (RESETn & ( WAKEUP_REQ_ORED | ( MBC_SLEEP_int & ~MBUS_DIN )))	// Wake up if there is internal req or DIN pulled down
	     	set_tran_to_wake = 1'b1;
		else
   			set_tran_to_wake = 1'b0;
	end

   // rst_tran_to_wake
	always @ *
	begin
		if ((~RESETn) | ( WAKEUP_REQ_ORED | (MBC_SLEEP_int & ~MBUS_DIN) | ~SLEEP_REQ ))
			rst_tran_to_wake	<= 1'b1;	// reverse the edge, @ Ye-sheng
		else
			rst_tran_to_wake	<= 1'b0;
	end

	/*
   	// tran_to_wake
	always @ ( posedge rst_tran_to_wake or posedge set_tran_to_wake )
	begin
		if( rst_tran_to_wake ) 
	  		tran_to_wake	<= 1'b0;
		else if ( set_tran_to_wake ) 
	  		tran_to_wake	<= 1'b1;
		else
	  		tran_to_wake  <= tran_to_wake;
     end
	 */

	wire tran_to_wake_r = RESETn & rst_tran_to_wake;
	always @ (negedge tran_to_wake_r or posedge set_tran_to_wake)
	begin
		if (~tran_to_wake_r)
			tran_to_wake <= 1'b0;
		else
			tran_to_wake <= 1'b1;
	end

    // MBC_ISOLATE
	always @ ( negedge RESETn or posedge CLK )
	begin
		if( ~RESETn )
			MBC_ISOLATE	<= 1'b1;
		else 
			MBC_ISOLATE	<= (MBC_SLEEP_int | (~tran_to_wake));
	end

    // MBC_SLEEP
	always @ ( negedge RESETn or posedge CLK )
	begin
		if( ~RESETn )
			MBC_SLEEP_int	<= 1'b1;
		else
			MBC_SLEEP_int	<= (MBC_ISOLATE & (~tran_to_wake));
	end

   assign	MBC_SLEEP = MBC_SLEEP_int & ~ (WAKEUP_REQ_ORED | (MBC_SLEEP_int & ~MBUS_DIN) );

   // MBC_RESET
	always @ ( negedge RESETn or posedge CLK )
	begin
		if( ~RESETn )
	  		MBC_RESET	<= 1'b1;
		else
	   		MBC_RESET	<= MBC_ISOLATE;
	end
endmodule // SLEEP_CONTROLv4

