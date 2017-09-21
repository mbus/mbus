//*******************************************************************************************
//Author:         Yejoong Kim, Ye-sheng Kuo
//Last Modified:  Aug 23 2017
//Description:    (Testbench) MBus Control Wrapper for Master Layer
//Update History: Apr 08 2013 - Added glitch reset (Ye-sheng Kuo)
//                May 25 2015 - Added double latch for DIN (Ye-sheng Kuo, Yejoong Kim)
//                May 21 2016 - Updated for MBus r03 (Yejoong Kim)
//                                  Changed module name:
//                                      mbus_master_ctrl_wrapper_testbench -> mbus_master_node_testbench
//                                  Added MBus Watchdog Counter
//                Dec 13 2016 - Updated for MBus r04 (Yejoong Kim)
//                              Removed CLR_BUSY, and added MBUS_BUSY
//                              Fixed bug where MBUS_FULL_PREFIX is fixed at the default value
//                May 24 2017 - Updated for MBus r04p1 (Yejoong Kim)
//                                  Added FORCE_IDLE_WHEN_DONE to fix DIN sync issue between
//                                      master layer and member layer at the end of message
//                                      that requires a reply.
//                                  Changed some variable names to be consistent with lname_mbus_master_node_ctrl.v
//                                      THRESHOLD          -> NUM_BITS_THRESHOLD
//                Aug 23 2017 - Checked for mbus_testbench
//******************************************************************************************* 

`include "include/mbus_def_testbench.v"

module mbus_master_node_testbench (
    input   CLK_EXT,
    input   RESETn,
    input   CIN,
    output  COUT,
    input   DIN,
    output  DOUT,
    input   [`MBUSTB_ADDR_WIDTH-1:0] TX_ADDR,
    input   [`MBUSTB_DATA_WIDTH-1:0] TX_DATA, 
    input   TX_PEND, 
    input   TX_REQ, 
    input   TX_PRIORITY,
    output  TX_ACK, 
    output  [`MBUSTB_ADDR_WIDTH-1:0] RX_ADDR, 
    output  [`MBUSTB_DATA_WIDTH-1:0] RX_DATA, 
    output  RX_REQ, 
    input   RX_ACK, 
    output  RX_BROADCAST,
    output  RX_FAIL,
    output  RX_PEND, 
    output  TX_FAIL, 
    output  TX_SUCC, 
    input   TX_RESP_ACK,
    input   [`MBUSTB_BITS_WD_WIDTH-1:0] NUM_BITS_THRESHOLD,
    output MBC_IN_FWD, // FWD notifier
    input  RX_ACK_BCAST, // RX_ACK for Broadcast Messages
    // power gated signals from sleep controller
    input   MBC_RESET,
    // power gated signals to layer controller
    output  LRC_SLEEP,
    output  LRC_CLKENB,
    output  LRC_RESET,
    output  LRC_ISOLATE,
    // wake up bus controller
    input   EXTERNAL_INT,
    output  CLR_EXT_INT,
    output  MBUS_BUSY,
    // FMS Configuration
    input FORCE_IDLE_WHEN_DONE,
    // wake up processor
    output  reg SLEEP_REQUEST_TO_SLEEP_CTRL
);

parameter ADDRESS = 20'haaaaa;

wire    ctr2mbc_clk;
wire    ctr2mbc_data;
wire    mbc2ctr_rx_req;
wire    ctr2mbc_rx_ack;
wire    mbc2ctr_sleep_req;

wire    RESETn_local = (RESETn & (~MBC_RESET));

assign RX_REQ = mbc2ctr_rx_req;

// Delay 1 cycle
always @ (posedge CLK_EXT or negedge RESETn_local) begin
    if (~RESETn_local) SLEEP_REQUEST_TO_SLEEP_CTRL <= `MBUSTB_SD 0;
    else               SLEEP_REQUEST_TO_SLEEP_CTRL <= `MBUSTB_SD mbc2ctr_sleep_req;
end

assign ctr2mbc_rx_ack = RX_ACK | (RX_BROADCAST & RX_ACK_BCAST);

mbus_master_node_ctrl_testbench mbus_master_node_ctrl_testbench_0 (
    .CLK_EXT    (CLK_EXT),
    .RESETn     (RESETn_local),
    .CIN        (CIN),
    .COUT       (ctr2mbc_clk),
    .DIN        (DIN),
    .DOUT       (ctr2mbc_data),
    .NUM_BITS_THRESHOLD  (NUM_BITS_THRESHOLD),
    .FORCE_IDLE_WHEN_DONE(FORCE_IDLE_WHEN_DONE)
    );

mbus_node_testbench#(.ADDRESS(ADDRESS), .MASTER_NODE(1'b1)) mbus_node_testbench_0 (
    .RESETn         (RESETn), 
    .CIN            (ctr2mbc_clk), 
    .DIN            (ctr2mbc_data), 
    .COUT           (COUT),
    .DOUT           (DOUT), 
    .TX_ADDR        (TX_ADDR), 
    .TX_DATA        (TX_DATA), 
    .TX_PEND        (TX_PEND), 
    .TX_REQ         (TX_REQ), 
    .TX_PRIORITY    (TX_PRIORITY),
    .TX_RESP_ACK    (TX_RESP_ACK),
    .TX_ACK         (TX_ACK), 
    .TX_FAIL        (TX_FAIL), 
    .TX_SUCC        (TX_SUCC), 
    .RX_ADDR        (RX_ADDR), 
    .RX_DATA        (RX_DATA), 
    .RX_REQ         (mbc2ctr_rx_req), 
    .RX_ACK         (ctr2mbc_rx_ack), 
    .RX_BROADCAST   (RX_BROADCAST),
    .RX_FAIL        (RX_FAIL),
    .RX_PEND        (RX_PEND), 
    .MBC_IN_FWD     (MBC_IN_FWD),
    .MBC_RESET      (MBC_RESET),
    .LRC_SLEEP      (LRC_SLEEP),
    .LRC_CLKENB     (LRC_CLKENB),
    .LRC_RESET      (LRC_RESET),
    .LRC_ISOLATE    (LRC_ISOLATE),
    .SLEEP_REQUEST_TO_SLEEP_CTRL(mbc2ctr_sleep_req),
    .EXTERNAL_INT   (EXTERNAL_INT),
    .CLR_EXT_INT    (CLR_EXT_INT),
    .MBUS_BUSY      (MBUS_BUSY),
    .ASSIGNED_ADDR_IN       (4'h1),
    .ASSIGNED_ADDR_OUT      (),
    .ASSIGNED_ADDR_VALID    (1'b1),
    .ASSIGNED_ADDR_WRITE    (),
    .ASSIGNED_ADDR_INVALIDn ()
);

endmodule // mbus_master_node_testbench
