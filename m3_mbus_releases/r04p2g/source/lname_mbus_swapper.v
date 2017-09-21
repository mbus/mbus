//*******************************************************************************************
//Author:         Zhiyoong Foo, Yejoong Kim
//Last Modified:  Dec 16 2016
//Description:    MBus CLK/DATA Swapper
//                    - Generates Data & Clock Flip Interrupt;
//                    - Maintains Last seen Clock State
//Update History: Mar 06 2013 - First Commit (Zhiyoong Foo)
//                May 21 2016 - Included in MBus r03 (Yejoong Kim)
//                Dec 16 2016 - Included in MBus r04 (Yejoong Kim)
//******************************************************************************************* 

module lname_mbus_swapper (
    //Inputs
    input      CLK,
    input      RESETn,
    input      DATA,
    input      INT_FLAG_RESETn,
    //Outputs
    output reg LAST_CLK,
    output reg INT_FLAG
    );

    //Internal Declerations
    wire negp_reset;
    wire posp_reset;
    //Negative Phase Clock Resets
    reg  pose_negp_clk_0; //Positive Edge
    reg  nege_negp_clk_1; //Negative Edge
    reg  pose_negp_clk_2;
    reg  nege_negp_clk_3;
    reg  pose_negp_clk_4;
    reg  nege_negp_clk_5;
    wire negp_int;        //Negative Phase Interrupt
    //Interrupt Reset
    wire int_resetn;
 
    assign negp_reset = ~( CLK && RESETn);
    
    //////////////////////////////////////////
    // Interrupt Generation
    //////////////////////////////////////////
    
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
    assign negp_int = pose_negp_clk_0 && nege_negp_clk_1 &&
                      pose_negp_clk_2 && nege_negp_clk_3 &&
                      pose_negp_clk_4 && nege_negp_clk_5;
 
    //Interrupt Check & Clear
    assign int_resetn = RESETn && INT_FLAG_RESETn;
    
    always @(posedge negp_int or negedge int_resetn) begin
        if (~int_resetn) INT_FLAG = 0;
        else             INT_FLAG = 1;
    end
 
    //////////////////////////////////////////
    // Last Seen Clock
    //////////////////////////////////////////
 
    always @(posedge negp_int or negedge RESETn) begin
        if (~RESETn) LAST_CLK = 0;
        else         LAST_CLK = CLK;
    end
    
 endmodule // lname_mbus_swapper
