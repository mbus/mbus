//*******************************************************************************************
//Author:         ZhiYoong Foo (zhiyoong@umich.edu)
//Last Modified:  Feb 25 2014
//Description: 	  MBUS Layer Controller's Clock Generator
//		  Custom Block
//Update History: Feb 25 2014 - First commit
//******************************************************************************************* 

module clkgen
  (
   //**************************************
   //Power Domain
   //Input  - Layer Controller Domain
   //Output - N/A
   //**************************************
   //Signals
   //Input
   CLK_RING_ENn, //Active Low
   CLK_GATE,	 //Active High
   CLK_TUNE,	 //Tuning Bits
   //Output
   CLK_OUT   
   );

   input       CLK_RING_ENn;
   input       CLK_GATE;
   input [3:0] CLK_TUNE;
   
   //Output
   output reg  CLK_OUT;
   
   initial begin
      CLK_OUT <= 1'b0;
   end
   
   always @ (CLK_RING_ENn or CLK_GATE or CLK_OUT) begin
      if (~CLK_RING_ENn && ~CLK_GATE) begin
	 `CLK_HALF_PERIOD;
	 CLK_OUT <= ~CLK_OUT;
      end
      else begin
	 CLK_OUT <= 1'b0;
      end
   end

   always @(CLK_TUNE) begin
      $write("%c[1;34m",27); 
      $display("CLKGEN Input CLK_TUNE Has been changed to:%x", CLK_TUNE);
      $write("%c[0m",27);
   end

endmodule // clkgen
