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
