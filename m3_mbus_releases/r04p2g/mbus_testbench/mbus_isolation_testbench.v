//*******************************************************************************************
//Author:         Yejoong Kim, Ye-sheng Kuo
//Last Modified:  Aug 23 2017
//Description:    (Testbench) MBus Isolation for Master/Member Layer
//Update History: Mar 16 2013 - First committed (Ye-sheng Kuo)
//                May 21 2016 - Updated for MBus r03 (Yejoong Kim)
//                Dec 16 2016 - Updated for MBus r04 (Yejoong Kim)
//                              Added MBUS_BUSY isolation
//                Apr 28 2017 - Updated for MBus r04p1
//                              Removed SLEEP_REQ* and MBUS_BUSY isolation. 
//                                  These should be isolated in mbus_master_ctrl or mbus_member_ctrl.
//                Aug 23 2017 - Checked for mbus_testbench
//******************************************************************************************* 

`include "include/mbus_def_testbench.v"

module mbus_isolation_testbench(

	input 	MBC_ISOLATE,

    // Layer Ctrl --> MBus Ctrl
	input 	[`MBUSTB_ADDR_WIDTH-1:0] TX_ADDR_uniso, 
	input 	[`MBUSTB_DATA_WIDTH-1:0] TX_DATA_uniso, 
	input 	TX_PEND_uniso, 
	input 	TX_REQ_uniso, 
	input 	TX_PRIORITY_uniso,
	input 	RX_ACK_uniso, 
	input 	TX_RESP_ACK_uniso,

	output reg [`MBUSTB_ADDR_WIDTH-1:0] TX_ADDR, 
	output reg [`MBUSTB_DATA_WIDTH-1:0] TX_DATA, 
	output reg TX_PEND, 
	output reg TX_REQ, 
	output reg TX_PRIORITY,
	output reg RX_ACK, 
	output reg TX_RESP_ACK,

    // NOTE: This testbench does not include Layer Controller
    // Layer Ctrl --> Other
    //`ifdef LNAME_LAYERCTRL_INT_ENABLE
    //input      [`LNAME_LAYERCTRL_INT_DEPTH-1:0] LC_CLR_INT_uniso,
    //output reg [`LNAME_LAYERCTRL_INT_DEPTH-1:0] LC_CLR_INT,
    //`endif

    // MBus Ctrl --> Other
	input 	LRC_SLEEP_uniso,
	input	LRC_CLKENB_uniso,
	input	LRC_RESET_uniso,
	input 	LRC_ISOLATE_uniso,

	output	reg LRC_SLEEP,
	output	    LRC_SLEEPB,
	output	reg LRC_CLKENB,
	output	    LRC_CLKEN,
	output	reg LRC_RESET,
	output	    LRC_RESETB,
	output	reg LRC_ISOLATE

);

    assign LRC_SLEEPB = ~LRC_SLEEP;
    assign LRC_CLKEN  = ~LRC_CLKENB;
    assign LRC_RESETB = ~LRC_RESET;

//********************************************
// Isolated using MBC_ISOLATE
//********************************************
    always @* begin
    	if (MBC_ISOLATE) begin
    		LRC_SLEEP      = 1;
    		LRC_CLKENB     = 1;
    		LRC_RESET      = 1;
            LRC_ISOLATE    = 1;
    	end
    	else begin
    		LRC_SLEEP      = LRC_SLEEP_uniso;
    		LRC_CLKENB     = LRC_CLKENB_uniso;
    		LRC_RESET      = LRC_RESET_uniso;
            LRC_ISOLATE    = LRC_ISOLATE_uniso;
    	end
    end
    
//********************************************
// Isolated using LRC_ISOLATE
//********************************************
    always @* begin
    	if (LRC_ISOLATE) begin
    		TX_ADDR     = 0;
    		TX_DATA	    = 0;
    		TX_PEND	    = 0;
    		TX_REQ	    = 0;
    		TX_PRIORITY	= 0;
    		RX_ACK	    = 0;
    		TX_RESP_ACK = 0;
        //`ifdef LNAME_LAYERCTRL_INT_ENABLE
        //    LC_CLR_INT  = 0;
        //`endif
    	end
    	else begin
    		TX_ADDR     = TX_ADDR_uniso;
    		TX_DATA	    = TX_DATA_uniso;
    		TX_PEND	    = TX_PEND_uniso;
    		TX_REQ	    = TX_REQ_uniso;
    		TX_PRIORITY	= TX_PRIORITY_uniso;
    		RX_ACK	    = RX_ACK_uniso;
    		TX_RESP_ACK = TX_RESP_ACK_uniso;
        //`ifdef LNAME_LAYERCTRL_INT_ENABLE
        //    LC_CLR_INT  = LC_CLR_INT_uniso;
        //`endif
    	end
    end
    
endmodule // mbus_isolation_testbench
