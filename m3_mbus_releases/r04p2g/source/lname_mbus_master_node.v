//*******************************************************************************************
//Author:         Yejoong Kim, Ye-sheng Kuo
//Last Modified:  May 24 2017
//Description:    MBus Control Wrapper for Master Layer
//Update History: Apr 08 2013 - Added glitch reset (Ye-sheng Kuo)
//                May 25 2015 - Added double latch for DIN (Ye-sheng Kuo, Yejoong Kim)
//                May 21 2016 - Updated for MBus r03 (Yejoong Kim)
//                                  Changed module name:
//                                      lname_mbus_master_ctrl_wrapper -> lname_mbus_master_node
//                                  Added MBus Watchdog Counter
//                Dec 13 2016 - Updated for MBus r04 (Yejoong Kim)
//                              Removed CLR_BUSY, and added MBUS_BUSY
//                              Added MBus Flag
//                              Fixed bug where MBUS_FULL_PREFIX is fixed at the default value
//                May 24 2017 - Updated for MBus r04p1 (Yejoong Kim)
//                                  Added FORCE_IDLE_WHEN_DONE to fix DIN sync issue between
//                                      master layer and member layer at the end of message
//                                      that requires a reply.
//******************************************************************************************* 

`include "include/lname_mbus_def.v"

module lname_mbus_master_node (
    input  CLK_EXT,
    input  RESETn,
    input  CIN,
    output COUT,
    input  DIN,
    output DOUT,
    input  [`MBUS_ADDR_WIDTH-1:0] TX_ADDR,
    input  [`MBUS_DATA_WIDTH-1:0] TX_DATA, 
    input  TX_PEND, 
    input  TX_REQ, 
    input  TX_PRIORITY,
    output TX_ACK, 
    output [`MBUS_ADDR_WIDTH-1:0] RX_ADDR, 
    output [`MBUS_DATA_WIDTH-1:0] RX_DATA, 
    output RX_REQ, 
    input  RX_ACK, 
    output RX_BROADCAST,
    output RX_FAIL,
    output RX_PEND, 
    output TX_FAIL, 
    output TX_SUCC, 
    input  TX_RESP_ACK,
    input  [`MBUS_BITS_WD_WIDTH-1:0] NUM_BITS_THRESHOLD,
    input  [`MBUS_IDLE_WD_WIDTH-1:0] WATCHDOG_THRESHOLD,
    input  WATCHDOG_RESET,
    input  WATCHDOG_RESET_REQ,
    output WATCHDOG_RESET_ACK,
    output MBC_IN_FWD,  // FWD notifier
    input  RX_ACK_BCAST, // RX_ACK for Broadcast Messages
    // power gated signals from sleep controller
    input  MBC_RESET,
    // power gated signals to layer controller
    output LRC_SLEEP,
    output LRC_CLKENB,
    output LRC_RESET,
    output LRC_ISOLATE,
    // wake up bus controller
    input  EXTERNAL_INT,
    output CLR_EXT_INT,
    output MBUS_BUSY,
    // FMS Configuration
    input FORCE_IDLE_WHEN_DONE,
    // MBus Msg Interrupted Flag
    input  GOCEP_ACTIVE,
    input  CLEAR_FLAG,
    output MSG_INTERRUPTED,
    // wake up processor
    output reg SLEEP_REQUEST_TO_SLEEP_CTRL
);

parameter ADDRESS = 20'haaaaa;

wire ctr2mbc_clk;
wire ctr2mbc_data;
wire mbc2ctr_rx_req;
wire ctr2mbc_rx_ack;
wire mbc2ctr_sleep_req;

wire [`MBUS_ADDR_WIDTH-1:0] ctr2mbc_tx_addr;
wire [`MBUS_DATA_WIDTH-1:0] ctr2mbc_tx_data;
wire ctr2mbc_tx_req, ctr2mbc_tx_pend, ctr2mbc_tx_priority, ctr2mbc_tx_resp_ack;
wire mbc2ctr_tx_ack, mbc2ctr_tx_succ, mbc2ctr_tx_fail;

wire RESETn_local = (RESETn & (~MBC_RESET));

assign RX_REQ = mbc2ctr_rx_req;

// Delay 1 cycle
always @ (posedge CLK_EXT or negedge RESETn_local) begin
    if (~RESETn_local) SLEEP_REQUEST_TO_SLEEP_CTRL <= `SD 0;
    else               SLEEP_REQUEST_TO_SLEEP_CTRL <= `SD mbc2ctr_sleep_req;
end

assign ctr2mbc_rx_ack = RX_ACK | (RX_BROADCAST & RX_ACK_BCAST);

lname_mbus_master_node_ctrl lname_mbus_master_node_ctrl_0 (
    .CLK_EXT    (CLK_EXT),
    .RESETn     (RESETn_local),
    .CIN        (CIN),
    .COUT       (ctr2mbc_clk),
    .DIN        (DIN),
    .DOUT       (ctr2mbc_data),
    .NUM_BITS_THRESHOLD (NUM_BITS_THRESHOLD),
    .WATCHDOG_THRESHOLD (WATCHDOG_THRESHOLD),
    .WATCHDOG_RESET     (WATCHDOG_RESET),
    .WATCHDOG_RESET_REQ (WATCHDOG_RESET_REQ),
    .WATCHDOG_RESET_ACK (WATCHDOG_RESET_ACK),
    .TX_ADDR_IN         (TX_ADDR),
    .TX_DATA_IN         (TX_DATA),
    .TX_PRIORITY_IN     (TX_PRIORITY),
    .TX_REQ_IN          (TX_REQ),
    .TX_PEND_IN         (TX_PEND),
    .TX_RESP_ACK_IN     (TX_RESP_ACK),
    .TX_ACK_IN          (mbc2ctr_tx_ack),
    .TX_SUCC_IN         (mbc2ctr_tx_succ),
    .TX_FAIL_IN         (mbc2ctr_tx_fail),
    .TX_ADDR_OUT        (ctr2mbc_tx_addr),
    .TX_DATA_OUT        (ctr2mbc_tx_data),
    .TX_PRIORITY_OUT    (ctr2mbc_tx_priority),
    .TX_REQ_OUT         (ctr2mbc_tx_req),
    .TX_PEND_OUT        (ctr2mbc_tx_pend),
    .TX_RESP_ACK_OUT    (ctr2mbc_tx_resp_ack),
    .TX_ACK_OUT         (TX_ACK),
    .TX_SUCC_OUT        (TX_SUCC),
    .TX_FAIL_OUT        (TX_FAIL),
    .FORCE_IDLE_WHEN_DONE(FORCE_IDLE_WHEN_DONE),
    .MBC_IN_FWD         (MBC_IN_FWD),
    .GOCEP_ACTIVE       (GOCEP_ACTIVE),
    .CLEAR_FLAG         (CLEAR_FLAG),
    .MSG_INTERRUPTED    (MSG_INTERRUPTED)
    );

lname_mbus_node #(.ADDRESS(ADDRESS), .MASTER_NODE(1'b1)) lname_mbus_node_0 (
    .RESETn         (RESETn), 
    .CIN            (ctr2mbc_clk), 
    .DIN            (ctr2mbc_data), 
    .COUT           (COUT),
    .DOUT           (DOUT), 
    .TX_ADDR        (ctr2mbc_tx_addr), 
    .TX_DATA        (ctr2mbc_tx_data), 
    .TX_PEND        (ctr2mbc_tx_pend), 
    .TX_REQ         (ctr2mbc_tx_req), 
    .TX_PRIORITY    (ctr2mbc_tx_priority),
    .TX_RESP_ACK    (ctr2mbc_tx_resp_ack),
    .TX_ACK         (mbc2ctr_tx_ack), 
    .TX_FAIL        (mbc2ctr_tx_fail), 
    .TX_SUCC        (mbc2ctr_tx_succ), 
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

endmodule // lname_mbus_master_node
