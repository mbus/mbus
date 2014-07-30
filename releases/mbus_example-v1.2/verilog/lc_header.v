//*******************************************************************************************
//Author:         ZhiYoong Foo (zhiyoong@umich.edu)
//Last Modified:  Feb 25 2014
//Description: 	  Layer Controller (LC) Power Gate Header (Active High)
//		  Custom Block
//Update History: Feb 25 2014 - First commit
//******************************************************************************************* 

module lc_header
  (
   //**************************************
   //Power Domain
   //Input  - Always On
   //Output - Layer Controller Domain
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
	 $display("*********LAYER CONTROLLER IS POWER GATED*******");
	 $display("*********AT TIME:", $time);
	 $display("***********************************************");
	 $write("%c[0m",27); 
      end
      else begin
	 $write("%c[1;34m",27); 
	 $display("***********************************************");
	 $display("********LAYER CONTROLLER IS POWER UNGATED******");
	 $display("*********AT TIME:", $time);
	 $display("***********************************************");
	 $write("%c[0m",27); 
      end
   end // always @ (SLEEP)

endmodule // lc_header
