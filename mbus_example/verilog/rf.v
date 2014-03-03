//*******************************************************************************************
//Author:         ZhiYoong Foo (zhiyoong@umich.edu)
//Last Modified:  Feb 25 2014
//Description: 	  MBUS Register File
//		  Semi Custom Block
//Update History: Feb 25 2014 - First commit
//******************************************************************************************* 

//*******************************************************************************************
// MEMORY MAP
//*******************************************************************************************
// Address	|| Register Name 			|| Reset Value 	|| R/W || Comments
//*******************************************************************************************
// 8'h0		|| REGISTER 0				||		||     ||
// 8'h0 [3:0]	|| clk_tune				|| 4'hA		|| R/W ||
//*******************************************************************************************
// 8'h1		|| REGISTER 1				||		|| R/W ||
// 8'h1 [0]	|| timer_resetn 			|| 1'h0		|| R/W ||
// 8'h1 [1]	|| timer_en 				|| 1'h0		|| R/W ||
// 8'h1 [2]	|| timer_roi 				|| 1'h0		|| R/W ||
// 8'h1 [10:3]	|| timer_sat 				|| 8'hFF	|| R/W ||
// 8'h1 [18:11]	|| rf2lc_mbus_reply_address_timer	|| 8'h14	|| R/W ||
//*******************************************************************************************
// 8'h2		|| REGISTER 2				||		||     ||
// 8'h2 [7:0]	|| timer_val 				|| 8'h0		|| R   ||
// 8'h2 [8]	|| timer_irq 				|| 1'h0		|| R   ||
//*******************************************************************************************
// 8'h3		|| REGISTER 3				||		||     ||
// 8'h3 [0]	|| ablk_pg 				|| 1'h1		|| R/W ||
// 8'h3 [1]	|| ablk_resetn				|| 1'h0		|| R/W ||
// 8'h3 [2]	|| ablk_en				|| 1'h0		|| R/W ||
// 8'h3 [6:3]	|| ablk_config_0			|| 4'h7		|| R/W ||
// 8'h3 [10:7]	|| ablk_config_1 			|| 4'hD		|| R/W ||

module rf
  (
   //**************************************
   //Power Domain
   //Input  - Always On
   //Output - N/A
   //**************************************
   //Signals
   //Input
   RESETn,
   ISOLATE,
   DATA_IN,
   ADDRESS_IN,
   //Output
   //Register 0
   clk_tune,
   //Register 1
   timer_resetn,
   timer_en,
   timer_roi,
   timer_sat,
   rf2lc_mbus_reply_address_timer,
   //Register 2
   //timer_val,
   //timer_irq,
   //Register 3
   ablk_pg,
   ablk_resetn,
   ablk_en,
   ablk_config_0,
   ablk_config_1
   );

   input            RESETn;
   input 	    ISOLATE;
   input [18:0]     DATA_IN;
   input [3:0] 	    ADDRESS_IN;

   //Register 0
   output reg [3:0] clk_tune;
   //Register 1
   output reg 	    timer_resetn;
   output reg 	    timer_en;
   output reg 	    timer_roi;
   output reg [7:0] timer_sat;
   output reg [7:0] rf2lc_mbus_reply_address_timer;
   //Register 2
   //output [7:0] timer_val;
   //output 	timer_irq;
   //Register 3
   output reg	    ablk_pg;
   output reg	    ablk_resetn;
   output reg	    ablk_en;
   output reg [3:0] ablk_config_0;
   output reg [3:0] ablk_config_1;

   //Isolate Inputs
   wire [3:0] 	    address_in_iso;
   wire [18:0] 	    data_in_iso;

   assign 	    address_in_iso = ~ISOLATE & ADDRESS_IN;
   assign 	    data_in_iso    = ~ISOLATE & DATA_IN;

   //Register 0
   always @(posedge address_in_iso[0] or negedge RESETn) begin
      if (~RESETn) begin
	 clk_tune <= `SD 4'hA;
      end
      else begin
	 clk_tune <= `SD data_in_iso[3:0];
      end
   end
   
   //Register 1
   always @(posedge address_in_iso[1] or negedge RESETn) begin
      if (~RESETn) begin
	 timer_resetn 	<= `SD 1'h0;
	 timer_en 	<= `SD 1'h0;
	 timer_roi 	<= `SD 1'h0;
	 timer_sat 	<= `SD 8'hFF;
	 rf2lc_mbus_reply_address_timer <= `SD 8'h14;
      end
      else begin
	 timer_resetn 	<= `SD data_in_iso[0];
	 timer_en 	<= `SD data_in_iso[1];
	 timer_roi 	<= `SD data_in_iso[2];
	 timer_sat 	<= `SD data_in_iso[10:3];
	 rf2lc_mbus_reply_address_timer <= `SD data_in_iso[18:11];
      end
   end

   //Register 2
   //timer_val READ ONLY
   //timer_irq READ ONLY

   //Register 3
   always @(posedge address_in_iso[3] or negedge RESETn) begin
      if (~RESETn) begin
	 ablk_pg 	<= `SD 1'h1;
	 ablk_resetn 	<= `SD 1'h0;
	 ablk_en 	<= `SD 1'h0;
	 ablk_config_0 	<= `SD 4'h7;
	 ablk_config_1 	<= `SD 4'hD;
      end
      else begin
	 ablk_pg 	<= `SD data_in_iso[0];
	 ablk_resetn 	<= `SD data_in_iso[1];
	 ablk_en 	<= `SD data_in_iso[2];
	 ablk_config_0 	<= `SD data_in_iso[6:3];
	 ablk_config_1 	<= `SD data_in_iso[10:7];
      end
   end

endmodule // rf

