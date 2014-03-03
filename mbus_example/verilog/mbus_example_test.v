//*******************************************************************************************
//Author:         ZhiYoong Foo (zhiyoong@umich.edu)
//Last Modified:  Feb 25 2014
//Description: 	  MBUS Example Testbench
//Update History: Feb 25 2014 - First commit
//******************************************************************************************* 

`timescale 1ns/1ps

module mbus_example_test();

   reg         MBUS_CLKIN;
   reg 	       RESETn;
   wire	       CTRL_CLKOUT;
   wire	       CTRL_DOUT;
   wire	       CTRL_CLKOUT_FROM_BUS;
   wire	       CTRL_DOUT_FROM_BUS;
   wire        MBUS_EXAMPLE_CLKOUT;
   wire        MBUS_EXAMPLE_DOUT;
   reg 	       TX_REQ;
   wire        TX_ACK;
   reg [31:0]  TX_ADDR;
   reg [31:0]  TX_DATA;
   wire        TX_FAIL;
   wire        TX_SUCC;
   wire        RX_REQ;
   reg 	       RX_ACK;
   wire [31:0] RX_ADDR;
   wire [31:0] RX_DATA;
   wire        RX_BROADCAST;
   wire        RX_FAIL;
   wire        RX_PEND;
   
   mbus_ctrl_wrapper mbus_ctrl_wrapper_test
     (
      .CLK_EXT			(MBUS_CLKIN),
      .RESETn			(RESETn),
      .CLKIN			(MBUS_EXAMPLE_CLKOUT),
      .CLKOUT			(CTRL_CLKOUT_FROM_BUS),
      .DIN			(MBUS_EXAMPLE_DOUT),
      .DOUT			(CTRL_DOUT_FROM_BUS),
      .TX_ADDR			(TX_ADDR),
      .TX_DATA			(TX_DATA), 
      .TX_PEND			(1'b0), 
      .TX_REQ			(TX_REQ), 
      .TX_PRIORITY		(1'b0),
      .TX_ACK			(TX_ACK), 	// just for monitor
      .RX_ADDR			(RX_ADDR), 
      .RX_DATA			(RX_DATA), 
      .RX_REQ			(RX_REQ), 
      .RX_ACK			(RX_ACK), 
      .RX_BROADCAST		(RX_BROADCAST),
      .RX_FAIL			(RX_FAIL),
      .RX_PEND			(RX_PEND), 
      .TX_FAIL			(TX_FAIL), 
      .TX_SUCC			(TX_SUCC), 
      .TX_RESP_ACK		(1'b0),
      .THRESHOLD		(20'hFFFFF), //don't care
      // power gated signals from sleep controller
      .MBC_RESET		(~RESETn),
      // power gated signals to layer controller
      .LRC_SLEEP		(),
      .LRC_CLKENB		(),
      .LRC_RESET		(),
      .LRC_ISOLATE		(),
      // wake up bus controller
      .EXTERNAL_INT		(1'b0),
      .CLR_EXT_INT		(),
      .CLR_BUSY			(),
      // wake up processor
      .SLEEP_REQUEST_TO_SLEEP_CTRL()
      );

   //   mbus_wire_ctrl_wresetn_TEST mbus_wire_ctrl_wresetn_0
   mbus_wire_ctrl mbus_wire_ctrl_test
     (
      .RESETn				(RESETn),
      .DIN				(MBUS_EXAMPLE_DOUT),
      .CLKIN				(MBUS_EXAMPLE_CLKOUT),
      .DOUT_FROM_BUS			(CTRL_DOUT_FROM_BUS),
      .CLKOUT_FROM_BUS			(CTRL_CLKOUT_FROM_BUS),
      .RELEASE_ISO_FROM_SLEEP_CTRL 	(1'b0),
      .DOUT				(CTRL_DOUT),
      .CLKOUT				(CTRL_CLKOUT),
      .EXTERNAL_INT			(1'b0)
      );

   mbus_example mbus_example_0
     (
      .CIN			(CTRL_CLKOUT),
      .DIN			(CTRL_DOUT),
      .COUT			(MBUS_EXAMPLE_CLKOUT),
      .DOUT			(MBUS_EXAMPLE_DOUT)
      );
   
   //****************************************************
   // CLOCKS
   //****************************************************
   // MBUS runs at 400KHz
   initial begin
      MBUS_CLKIN = 1'b0;
   end
   always begin
      #1250 MBUS_CLKIN = ~MBUS_CLKIN;
   end
   
   //****************************************************
   // RESET
   //****************************************************
   initial begin
      RESETn = 1'b0;
      `RESET_TIME;
      @(negedge MBUS_CLKIN);
      #1;
      RESETn = 1'b1;
   end

   //****************************************************
   // RUNAWAY
   //****************************************************
   initial begin
      #1000000000;
      $display("Runaway Timer");
      failure;
   end

   //****************************************************
   // EVERYTHING ELSE
   //****************************************************
   initial begin
      TX_REQ = 1'b0;
      TX_ADDR = 32'h00000000;
      TX_DATA = 32'h00000000;
      RX_ACK = 1'b0;

      //****************************************************
      // Start Testing
      //****************************************************
      @(posedge RESETn);
      $display("");
      $display("***********************************************");
      $display("***********************************************");
      $display("***************Simulation Start****************");
      $display("***********************************************");
      $display("***********************************************");
      $display("");

      check_reset;
      enumerate;
      #1000000;
      load_rf;
      #1000000;
      start_timer;
      #1000000;
      target_sleep_long;
      #1000000;
      success;
   end
   
`include "mbus_example_task.v"

endmodule // mbus_example_test
