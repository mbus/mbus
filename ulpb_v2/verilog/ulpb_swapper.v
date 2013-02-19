//////////////////////////////////////////
// Author: 	ZhiYoong Foo
// Modified: 	Feb 15 2013
// Description: Tack on block for ULPB bus
//		Generates Data & Clock Flip Interrupt
// 		Maintains Last seen Clock State
//////////////////////////////////////////

module ulpb_swapper
  (
   //Inputs
    input      CLK,
    input      RESETn,
    input      DATA,
    input      INT_FLAG_RESETn,
   //Outputs
    output     INT,
    output reg LAST_CLK,
    output reg INT_FLAG
   );

   //Internal Declerations
   wire negp_reset;
   wire posp_reset;
   //Positive Phase Clock Resets
   reg 	  pose_posp_clk_0; //Positive Edge
   reg 	  nege_posp_clk_1; //Negative Edge
   reg 	  pose_posp_clk_2;
   reg 	  nege_posp_clk_3;
   reg 	  pose_posp_clk_4;
   reg 	  nege_posp_clk_5;
   wire   posp_int;        //Positive Phase Interrupt
   //Negative Phase Clock Resets
   reg 	  pose_negp_clk_0; //Positive Edge
   reg 	  nege_negp_clk_1; //Negative Edge
   reg 	  pose_negp_clk_2;
   reg 	  nege_negp_clk_3;
   reg 	  pose_negp_clk_4;
   reg 	  nege_negp_clk_5;
   wire   negp_int;        //Negative Phase Interrupt
   //Interrupt Reset
   wire   int_resetn;

   assign negp_reset = ~( CLK && RESETn);
   assign posp_reset = ~(~CLK && RESETn);
   
   //////////////////////////////////////////
   // Interrupt Generation
   //////////////////////////////////////////
   
   //Positive Phase Clock Resets
   always @(posedge DATA or posedge posp_reset) begin
      if (posp_reset) begin
	 pose_posp_clk_0 = 0;
	 pose_posp_clk_2 = 0;
	 pose_posp_clk_4 = 0;
      end
      else begin
	 pose_posp_clk_0 = 1;
	 pose_posp_clk_2 = nege_posp_clk_1;
	 pose_posp_clk_4 = nege_posp_clk_3;
      end
   end

   always @(negedge DATA or posedge posp_reset) begin
      if (posp_reset) begin
	 nege_posp_clk_1 = 0;
	 nege_posp_clk_3 = 0;
	 nege_posp_clk_5 = 0;
      end
      else begin
	 nege_posp_clk_1 = pose_posp_clk_0;
	 nege_posp_clk_3 = pose_posp_clk_2;
	 nege_posp_clk_5 = pose_posp_clk_4;
      end
   end // always @ (negedge DATA or posedge CLK)

   //Positive Phase Interrupt Generation
   assign posp_int = pose_posp_clk_0 &&
		     nege_posp_clk_1 &&
		     pose_posp_clk_2 &&
		     nege_posp_clk_3 &&
		     pose_posp_clk_4 &&
		     nege_posp_clk_5;
		     
   //Negative Phase Clock Resets
   always @(posedge DATA or posedge negp_reset) begin
      if (negp_reset) begin
	 pose_negp_clk_0 = 0;
	 pose_negp_clk_2 = 0;
	 pose_negp_clk_4 = 0;
      end
      else begin
	 pose_negp_clk_0 = 1;
	 pose_negp_clk_2 = nege_negp_clk_1;
	 pose_negp_clk_4 = nege_negp_clk_3;
      end
   end

   always @(negedge DATA or posedge negp_reset) begin
      if (negp_reset) begin
	 nege_negp_clk_1 = 0;
	 nege_negp_clk_3 = 0;
	 nege_negp_clk_5 = 0;
      end
      else begin
	 nege_negp_clk_1 = pose_negp_clk_0;
	 nege_negp_clk_3 = pose_negp_clk_2;
	 nege_negp_clk_5 = pose_negp_clk_4;
      end
   end

   //Negative Phase Interrupt Generation
   assign negp_int = pose_negp_clk_0 &&
		     nege_negp_clk_1 &&
		     pose_negp_clk_2 &&
		     nege_negp_clk_3 &&
		     pose_negp_clk_4 &&
		     nege_negp_clk_5;

   //Interrupt Generation
   assign INT = negp_int ^ posp_int;

   //Interrupt Check & Clear
   assign int_resetn = RESETn && INT_FLAG_RESETn;
   
   always @(posedge INT or negedge int_resetn) begin
      if (~int_resetn) begin
	 INT_FLAG = 0;
      end
      else begin
	 INT_FLAG = 1;
      end
   end

   //////////////////////////////////////////
   // Last Seen Clock
   //////////////////////////////////////////

   always @(posedge INT or negedge RESETn) begin
      if (~RESETn) begin
	 LAST_CLK = 0;
      end
      else begin
	 LAST_CLK = CLK;
      end
   end
   
endmodule // ulpb_swapper
