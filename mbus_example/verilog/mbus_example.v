//*******************************************************************************************
//Author:         ZhiYoong Foo (zhiyoong@umich.edu)
//Last Modified:  Feb 25 2014
//Description: 	  MBUS Example
//Update History: Feb 25 2014 - First commit
//******************************************************************************************* 
//Naming Conventions:
// XXXXn:	Active Low Signal
// XXXXuniso	Unisolated Signal (Check Isolations)
//******************************************************************************************* 

module mbus_example
  (
   CIN,
   DIN,
   COUT,
   DOUT
   );

   //Pad Input
   input CIN;
   input DIN;

   //Pad Output
   output COUT;
   output DOUT;


   //Internal Wire Declerations
   wire   resetn;
   
   //MBUS
   //mbc0 <--> sc_0
   wire   mbc2sc_sleep_req_uniso;
   wire   mbc2sc_sleep_req;
   wire   mbc_sleep;
   wire   mbc_isolate;
   wire   mbc_reset;
   
   //mbc_0 <--> lc_0
   wire [31:0] lc2mbc_tx_addr_uniso;
   wire [31:0] lc2mbc_tx_data_uniso;
   wire        lc2mbc_tx_pend_uniso;
   wire        lc2mbc_tx_req_uniso;
   wire        mbc2lc_tx_ack;
   wire        lc2mbc_tx_priority_uniso;
   
   wire [31:0] lc2mbc_tx_addr;
   wire [31:0] lc2mbc_tx_data;
   wire        lc2mbc_tx_pend;
   wire        lc2mbc_tx_req;
   wire        lc2mbc_tx_priority;
   
   wire        lc2mbc_rx_ack_uniso;
   
   wire [31:0] mbc2lc_rx_addr;
   wire [31:0] mbc2lc_rx_data;
   wire        mbc2lc_rx_pend;
   wire        mbc2lc_rx_req;
   wire        lc2mbc_rx_ack;
   wire        mbc2lc_rx_broadcast;
   
   wire        lc2mbc_tx_resp_ack_uniso;
   
   wire        mbc2lc_rx_fail;
   wire        mbc2lc_tx_fail;
   wire        mbc2lc_tx_succ;
   wire        lc2mbc_tx_resp_ack;
   
   wire        lc_sleep_uniso;
   wire        lc_reset_uniso;
   wire        lc_isolate_uniso;

   wire        lc_sleep;
   wire        lc_reset;
   wire        lc_isolate;
   
   //mbc_0 <--> arf_0
   wire [3:0]  mbc2arf_write;
   wire        mbc2arf_valid;
   wire        mbc2arf_load;
   wire        mbc2arf_rstn;
   wire [3:0]  arf2mbc_read;
   
   //mbc_0 -- > wc_0
   wire        mbc2wc_cout;
   wire        mbc2wc_dout;
   
   //mbc_0 -- > ic_0
   wire        ic2mbc_external_int;
   wire        mbc2ic_clr_ext_int;
   wire        mbc2ic_clr_busy;
   
   //wc_0 -- > ic_0
   wire        ic2wc_external_int;
   
   //lc_0 <--> rf_0
   wire [18:0] lc2rf_data_in;
   wire [3:0]  lc2rf_address_in;
   wire [7:0]  rf2lc_mbus_reply_address_timer;

   //clkgen
   wire [3:0]  clk_tune;
   wire        lc_clk;

   //ablk
   wire        ablk_pg;
   wire        ablk_resetn;
   wire        ablk_en;
   wire [3:0]  ablk_config_0;
   wire [3:0]  ablk_config_1;

   //timer
   wire        timer_resetn;
   wire        timer_en;
   wire [7:0]  timer_sat;
   wire        timer_roi;
   wire        timer_clr_irq;
   wire [7:0]  timer_val;
   wire        timer_irq;


   //******************************
   //******************************
   // Blocks (Custom)
   //******************************
   //******************************

   
   //******************************
   // Reset Detector
   //******************************
   rstdtctr rstdtctr_0
     (
      //**************************************
      //Power Domain
      //Input  - Always On
      //Output - N/A
      //**************************************
      //Signals
      //Input
      //Output
      .RESETn		(resetn)
      );

   
   //******************************
   // MBUS Bus Controller (MBC)
   // Power Gate Header
   //******************************
   mbc_header mbc_header_0
     (
      //**************************************
      //Power Domain
      //Input  - Always On
      //Output - MBUS Bus Controller Domain
      //**************************************
      //Signals
      //Input
      .SLEEP(mbc_sleep)
      //Output
      );

   //******************************
   // Layer Controller (LC)
   // Power Gate Header
   //******************************
   lc_header lc_header_0
     (
      //**************************************
      //Power Domain
      //Input  - Always On
      //Output - Layer Controller Domain
      //**************************************
      //Signals
      //Input
      .SLEEP(lc_sleep)
      //Output
      );

   //******************************
   // Clock Generator for
   // Layer Controller
   //******************************
   clkgen clkgen_0
     (
      //**************************************
      //Power Domain
      //Input  - Layer Controller Domain
      //Output - N/A
      //**************************************
      //Signals
      //Input
      .CLK_RING_ENn	(lc_reset),
      .CLK_GATE		(lc_isolate),
      .CLK_TUNE		(clk_tune),
      //Output
      .CLK_OUT		(lc_clk)
      );
   
   //******************************
   // Example Analog Block
   // Controlled by MBUS
   //******************************
   ablk ablk_0
     (
      //**************************************
      //Power Domain
      //Input  - ablk
      //Output - N/A
      //**************************************
      //Signals
      //Input
      .ABLK_PG		(ablk_pg),
      .ABLK_RESETn	(ablk_resetn),
      .ABLK_EN		(ablk_en),
      .ABLK_CONFIG_0	(ablk_config_0),
      .ABLK_CONFIG_1	(ablk_config_1)
      //Output
      );

   //******************************
   //******************************
   // Blocks (Semi Custom)
   // HandWritten Netlists / Synthesized
   //******************************
   //******************************

   //******************************
   // MBUS Short Address Register
   //******************************
   mbus_addr_rf arf_0 
     (
      //**************************************
      //Power Domain
      //Input  - Always On
      //Output - N/A
      //**************************************
      //Signals
      //Input
      .RESETn				(resetn),
      .RELEASE_ISO_FROM_SLEEP_CTRL	(mbc_isolate),
      .ADDR_IN				(mbc2arf_write),
      .ADDR_WR_EN			(mbc2arf_load),
      .ADDR_CLRn			(mbc2arf_rstn),
      //Output
      .ADDR_VALID			(mbc2arf_valid),
      .ADDR_OUT				(arf2mbc_read)
      );

   //******************************
   // Register File
   //******************************
   rf rf_0
     ( 
       //**************************************
       //Power Domain
       //Input  - Always On
       //Output - N/A
       //**************************************
       //Signals
       //Input
       .RESETn			(resetn),
       .ISOLATE			(lc_isolate),
       .DATA_IN			(lc2rf_data_in),
       .ADDRESS_IN		(lc2rf_address_in),
       //Output
       //Register 0
       .clk_tune		(clk_tune),
       //Register 1
       .timer_resetn		(timer_resetn),
       .timer_en		(timer_en),
       .timer_roi		(timer_roi),
       .timer_sat		(timer_sat),
       .rf2lc_mbus_reply_address_timer	(rf2lc_mbus_reply_address_timer),
       //Register 2
       //timer_val
       //timer_irq
       //Register 3
       .ablk_pg			(ablk_pg),
       .ablk_resetn		(ablk_resetn),
       .ablk_en			(ablk_en),
       .ablk_config_0		(ablk_config_0),
       .ablk_config_1		(ablk_config_1)
       );

   
   //******************************
   // Wire Controller
   //******************************
   mbus_wire_ctrl wc_0
     (
      //**************************************
      //Power Domain
      //Input  - Always On
      //Output - N/A
      //**************************************
      //Signals
      .RESETn				(resetn),
      .DIN				(DIN),
      .CLKIN				(CIN),
      .RELEASE_ISO_FROM_SLEEP_CTRL	(mbc_isolate),
      .DOUT_FROM_BUS			(mbc2wc_dout),
      .CLKOUT_FROM_BUS			(mbc2wc_cout),
      .DOUT				(DOUT),
      .CLKOUT				(COUT),
      .EXTERNAL_INT			(ic2wc_external_int)
      );

   //******************************
   // Interrupt Request
   //******************************
   mbus_int_ctrl ic_0
     (
      //**************************************
      //Power Domain
      //Input  - Always On
      //Output - N/A
      //**************************************
      //Signals
      //Input
      .CLKIN			(CIN),
      .RESETn			(resetn),
      .MBC_ISOLATE		(mbc_isolate),
      .SC_CLR_BUSY		(mbc_sleep),
      .MBUS_CLR_BUSY		(mbc2ic_clr_busy),
      .REQ_INT			(timer_irq),
      .MBC_SLEEP		(mbc_sleep),
      .LRC_SLEEP		(lc_sleep),
      //Output
      .EXTERNAL_INT_TO_WIRE	(ic2wc_external_int),
      .EXTERNAL_INT_TO_BUS	(ic2mbc_external_int),
      //Input
      .CLR_EXT_INT		(mbc2ic_clr_ext_int)
      );

   //******************************
   // Sleep Controller
   //******************************
   mbus_regular_sleep_ctrl sc_0
     (
      //**************************************
      //Power Domain
      //Input  - Always On
      //Output - N/A
      //**************************************
      //Signals
      //Input
      .MBUS_CLKIN	(CIN),
      .RESETn		(resetn),
      .SLEEP_REQ	(mbc2sc_sleep_req),
      //Output
      .MBC_SLEEP	(mbc_sleep),
      .MBC_SLEEP_B	(), //unused
      .MBC_ISOLATE	(mbc_isolate),
      .MBC_ISOLATE_B	(), //unused
      .MBC_CLK_EN	(), //unused
      .MBC_CLK_EN_B	(), //unused
      .MBC_RESET	(mbc_reset),
      .MBC_RESET_B	()  //unused
      );

   //******************************
   // Isolation Gates
   //******************************
   lc_mbc_iso lc_mbc_iso_0
     (
      //Input
      .MBC_ISOLATE	(mbc_isolate),
      // LC --> MBC
      //Input
      .ADDROUT_uniso	(lc2mbc_tx_addr_uniso),	
      .DATAOUT_uniso	(lc2mbc_tx_data_uniso),	
      .PENDOUT_uniso	(lc2mbc_tx_pend_uniso),	
      .REQOUT_uniso	(lc2mbc_tx_req_uniso),	
      .PRIORITYOUT_uniso(lc2mbc_tx_priority_uniso),	
      .ACKOUT_uniso	(lc2mbc_rx_ack_uniso),	
      .RESPOUT_uniso	(lc2mbc_tx_resp_ack_uniso),	
      //Output
      .ADDROUT		(lc2mbc_tx_addr),	// ISOL value = Low
      .DATAOUT		(lc2mbc_tx_data),	// ISOL value = Low
      .PENDOUT		(lc2mbc_tx_pend),	// ISOL value = Low
      .REQOUT		(lc2mbc_tx_req), 	// ISOL value = Low
      .PRIORITYOUT	(lc2mbc_tx_priority),	// ISOL value = Low
      .ACKOUT		(lc2mbc_rx_ack),	// ISOL value = Low
      .RESPOUT		(lc2mbc_tx_resp_ack),	// ISOL value = Low
      // MBC --> LC
      //Input
      .LRC_SLEEP_uniso	(lc_sleep_uniso),
      .LRC_RESET_uniso	(lc_reset_uniso),
      .LRC_ISOLATE_uniso(lc_isolate_uniso),
      //Output
      .LRC_SLEEP	(lc_sleep),		// ISOL value = High
      .LRC_RESET	(lc_reset),		// ISOL value = High
      .LRC_ISOLATE	(lc_isolate),		// ISOL value = High
      // MBC --> SC
      //Input
      .SLEEP_REQ_uniso	(mbc2sc_sleep_req_uniso),
      //Output
      .SLEEP_REQ	(mbc2sc_sleep_req)	// ISOL value = Low
      );

   //******************************
   //******************************
   // Blocks (Synthesized)
   //******************************
   //******************************

   //******************************
   // Bus Controller (MBC)
   //******************************
   mbus_node  #(.ADDRESS(20'h`MBC_ADDR))
     mbc_0
       (
	//**************************************
	//Power Domain
	//Input  - MBUS Bus Controller
	//Output - N/A
	//**************************************
	//Signals
	.CLKIN				(CIN),
	.RESETn				(resetn),
	.DIN				(DIN),
	.CLKOUT				(mbc2wc_cout),
	.DOUT				(mbc2wc_dout),
       
	.TX_ADDR			(lc2mbc_tx_addr),
	.TX_DATA			(lc2mbc_tx_data),
	.TX_PEND			(lc2mbc_tx_pend),
	.TX_REQ				(lc2mbc_tx_req),
	.TX_ACK				(mbc2lc_tx_ack),
	.TX_PRIORITY			(lc2mbc_tx_priority),
       
	.RX_ADDR			(mbc2lc_rx_addr),
	.RX_DATA			(mbc2lc_rx_data),
	.RX_PEND			(mbc2lc_rx_pend),
	.RX_REQ				(mbc2lc_rx_req),
	.RX_ACK				(lc2mbc_rx_ack),
	.RX_BROADCAST			(mbc2lc_rx_broadcast),
       
	.RX_FAIL			(mbc2lc_rx_fail),
	.TX_FAIL			(mbc2lc_tx_fail),
	.TX_SUCC			(mbc2lc_tx_succ),
	.TX_RESP_ACK			(lc2mbc_tx_resp_ack),
       
	// power gated signals from sleep controller
	.MBC_RESET			(mbc_reset),
	// power gated signals to layer controller
	.LRC_SLEEP			(lc_sleep_uniso),
	.LRC_CLKENB			(), //unused
	.LRC_RESET			(lc_reset_uniso),
	.LRC_ISOLATE			(lc_isolate_uniso),
	// power gated signal to sleep controller
	.SLEEP_REQUEST_TO_SLEEP_CTRL	(mbc2sc_sleep_req_uniso),
	// External interrupt
	.EXTERNAL_INT			(ic2mbc_external_int),
	.CLR_EXT_INT			(mbc2ic_clr_ext_int),
	.CLR_BUSY			(mbc2ic_clr_busy),
       
	// interface with local register files (RF)
	.ASSIGNED_ADDR_IN		(arf2mbc_read),
	.ASSIGNED_ADDR_OUT		(mbc2arf_write),
	.ASSIGNED_ADDR_VALID		(mbc2arf_valid),
	.ASSIGNED_ADDR_WRITE		(mbc2arf_load),
	.ASSIGNED_ADDR_INVALIDn		(mbc2arf_rstn)
	);
   

   //******************************
   // Layer Controller (LC)
   //******************************
   layer_ctrl #(.LC_RF_DATA_WIDTH(19),
		.LC_RF_DEPTH(4),
		.LC_MEM_ADDR_WIDTH(4),
		.LC_MEM_DATA_WIDTH(4),
		.LC_MEM_DEPTH(4),
		.LC_INT_DEPTH(1)
		)
     lc_0 
       (
	//**************************************
	//Power Domain
	//Input  - Layer Controller
	//Output - N/A
	//**************************************
	//Signals
	.CLK			(lc_clk),
	.RESETn			(resetn),

	// Interface with MBus
	.TX_ADDR		(lc2mbc_tx_addr_uniso),
	.TX_DATA		(lc2mbc_tx_data_uniso),
	.TX_PEND		(lc2mbc_tx_pend_uniso),
	.TX_REQ			(lc2mbc_tx_req_uniso),
	.TX_ACK			(mbc2lc_tx_ack),
	.TX_PRIORITY		(lc2mbc_tx_priority_uniso),

	.RX_ADDR		(mbc2lc_rx_addr),
	.RX_DATA		(mbc2lc_rx_data),
	.RX_PEND		(mbc2lc_rx_pend),
	.RX_REQ			(mbc2lc_rx_req),
	.RX_ACK			(lc2mbc_rx_ack_uniso),
	.RX_BROADCAST		(mbc2lc_rx_broadcast),

	.RX_FAIL		(mbc2lc_rx_fail),
	.TX_FAIL		(mbc2lc_tx_fail),
	.TX_SUCC		(mbc2lc_tx_succ),
	.TX_RESP_ACK		(lc2mbc_tx_resp_ack_uniso),

	.RELEASE_RST_FROM_MBUS	(lc_reset),
	// End of interface
       
	// Interface with Registers
	.REG_RD_DATA		(
				 {
				  //Register 3
				  8'h0,
     				  ablk_config_1,
				  ablk_config_0,
				  ablk_en,
				  ablk_resetn,
				  ablk_pg,
				  //Register 2
				  10'h0,
				  timer_irq,
				  timer_val,
				  //Register 1
				  rf2lc_mbus_reply_address_timer,
				  timer_sat,
				  timer_roi,
				  timer_en,
				  timer_resetn,
				  //Register 0
				  15'h0,
     				  clk_tune
				  }
				 ),
	.REG_WR_DATA		(lc2rf_data_in),
	.REG_WR_EN		(lc2rf_address_in),
	// End of interface
       
	// Interface with MEM
	.MEM_REQ_OUT		(), //unused
	.MEM_WRITE		(), //unused
	.MEM_ACK_IN		(1'b0), //unused
	.MEM_WR_DATA		(), //unused
	.MEM_RD_DATA		(4'b0), //unused
	.MEM_ADDR		(), //unused
	// End of interface
       
	// Interrupt
	.INT_VECTOR		(timer_irq),
	.CLR_INT		(timer_clr_irq),
	.INT_FU_ID		({4'h1}),
	.INT_CMD		({8'h02,8'h00,rf2lc_mbus_reply_address_timer,8'h00,32'h00000000})
	);

   //******************************
   // Timer
   //******************************
   timer timer_0
     (
      //**************************************
      //Power Domain
      //Input  - Layer Controller
      //Output - N/A
      //**************************************
      //Signals
      //Input
      .CLK		(lc_clk),
      .TIMER_RESETn	(timer_resetn),
      .TIMER_EN		(timer_en),
      .TIMER_ROI	(timer_roi),
      .TIMER_SAT	(timer_sat),
      .TIMER_CLR_IRQ	(timer_clr_irq),
      //Output
      .TIMER_VAL	(timer_val),
      .TIMER_IRQ	(timer_irq)
      );

endmodule // mbus_example
