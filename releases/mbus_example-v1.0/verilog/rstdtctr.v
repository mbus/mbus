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

