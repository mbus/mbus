//*******************************************************************************************
//Author:         Yejoong Kim, Ye-sheng Kuo
//Last Modified:  Aug 23 2017
//Description:    (Testbench) Wrapper for MBus Master Layer
//Update History: May 21 2016 - Updated for MBus r03 (Yejoong Kim)
//                Dec 16 2016 - Updated for MBus r04 (Yejoong Kim)
//                May 24 2017 - Updated for MBus r04p1 (Yejoong Kim)
//                                  Added FORCE_IDLE_WHEN_DONE to fix DIN sync issue between
//                                      master layer and member layer at the end of message
//                                      that requires a reply.
//                                  Changed some variable names to be consistent with lname_mbus_master_node_ctrl.v
//                                      THRESHOLD          -> NUM_BITS_THRESHOLD
//                Aug 23 2017 - Checked for mbus_testbench
//******************************************************************************************* 

`include "include/mbus_def_testbench.v"

module mbus_master_wrapper_testbench(
    input      CLK_MBC,
    output     MBC_CLKENB,
    input      RESETn, 
    input      CIN, 
    input      DIN, 
    output     COUT,
    output     DOUT, 
    input      [`MBUSTB_ADDR_WIDTH-1:0] TX_ADDR, 
    input      [`MBUSTB_DATA_WIDTH-1:0] TX_DATA, 
    input      TX_REQ, 
    input      TX_PEND, 
    input      TX_PRIORITY,
    input      TX_RESP_ACK,
    input      RX_ACK, 

    output reg TX_ACK, 
    output reg TX_SUCC, 
    output reg TX_FAIL, 
    output reg [`MBUSTB_ADDR_WIDTH-1:0] RX_ADDR, 
    output reg [`MBUSTB_DATA_WIDTH-1:0] RX_DATA, 
    output reg RX_REQ, 
    output reg RX_PEND, 
    output reg RX_BROADCAST,
    output reg RX_FAIL,

    output     LRC_SLEEP,
    output     LRC_RESET,
    output     LRC_ISOLATE,
    output     LRC_CLKENB,

    output     MBC_IN_FWD,

	input [`MBUSTB_BITS_WD_WIDTH-1:0] NUM_BITS_THRESHOLD,
    input WAKEUP_REQ
);

parameter ADDRESS = 20'haaaaa;

//---------------------------------------------
// Internal Wire Declaration
//---------------------------------------------

// From Sleep Ctrl
wire    mbc_isolate, mbc_reset, mbc_reset_b, mbc_sleep, mbc_sleep_b;
wire    wakeup_req_ored;

// From MBus Ctrl
wire    lc_sleep_uniso, lc_clkenb_uniso, lc_reset_uniso, lc_isolate_uniso;
reg     lc_sleep_uniso_pg, lc_clkenb_uniso_pg, lc_reset_uniso_pg, lc_isolate_uniso_pg;

// MBus Ctrl <--> MBus Master Ctrl
wire    mbc2mc_mbus_busy;
reg     mbc2mc_mbus_busy_pg;
wire    mbc2mc_sleep_req;
reg     mbc2mc_sleep_req_pg;
wire    mbc2mc_clr_ext_int, mc2mbc_external_int;
wire    mbc2mc_cout, mbc2mc_dout;

// MBus Ctrl <--> Layer Ctrl
wire    [`MBUSTB_ADDR_WIDTH-1:0] mbc2lc_rx_addr;
wire    [`MBUSTB_DATA_WIDTH-1:0] mbc2lc_rx_data;
wire    mbc2lc_rx_req, mbc2lc_rx_pend, mbc2lc_rx_broadcast, mbc2lc_rx_fail, mbc2lc_tx_ack, mbc2lc_tx_succ, mbc2lc_tx_fail;

wire    [`MBUSTB_ADDR_WIDTH-1:0] lc2mbc_tx_addr;
wire    [`MBUSTB_DATA_WIDTH-1:0] lc2mbc_tx_data;
wire    lc2mbc_tx_req, lc2mbc_tx_pend, lc2mbc_tx_priority, lc2mbc_rx_ack, lc2mbc_tx_resp_ack;

reg     [`MBUSTB_ADDR_WIDTH-1:0] lc2mbc_tx_addr_uniso_pg;
reg     [`MBUSTB_DATA_WIDTH-1:0] lc2mbc_tx_data_uniso_pg;
reg     lc2mbc_tx_req_uniso_pg, lc2mbc_tx_pend_uniso_pg, lc2mbc_tx_priority_uniso_pg, lc2mbc_rx_ack_uniso_pg, lc2mbc_tx_resp_ack_uniso_pg;

// Broadcast ACK
reg     rx_ack_bcast;


//---------------------------------------------
// MBus Clock Enable
//---------------------------------------------
assign MBC_CLKENB = mbc_sleep;


//---------------------------------------------
// MBus Isolation
//---------------------------------------------
mbus_isolation_testbench mbus_isolation_testbench_0 (
    // MBus Isolation Signal
    .MBC_ISOLATE       (mbc_isolate),

    // Layer Ctrl --> MBus Ctrl
    .TX_ADDR_uniso     (lc2mbc_tx_addr_uniso_pg), 
    .TX_DATA_uniso     (lc2mbc_tx_data_uniso_pg), 
    .TX_PEND_uniso     (lc2mbc_tx_pend_uniso_pg), 
    .TX_REQ_uniso      (lc2mbc_tx_req_uniso_pg), 
    .TX_PRIORITY_uniso (lc2mbc_tx_priority_uniso_pg),
    .RX_ACK_uniso      (lc2mbc_rx_ack_uniso_pg), 
    .TX_RESP_ACK_uniso (lc2mbc_tx_resp_ack_uniso_pg),

    .TX_ADDR     (lc2mbc_tx_addr), 
    .TX_DATA     (lc2mbc_tx_data), 
    .TX_PEND     (lc2mbc_tx_pend), 
    .TX_REQ      (lc2mbc_tx_req), 
    .TX_PRIORITY (lc2mbc_tx_priority),
    .RX_ACK      (lc2mbc_rx_ack), 
    .TX_RESP_ACK (lc2mbc_tx_resp_ack),

    // MBus Ctrl --> Other
    .LRC_SLEEP_uniso   (lc_sleep_uniso_pg), 
    .LRC_CLKENB_uniso  (lc_clkenb_uniso_pg), 
    .LRC_RESET_uniso   (lc_reset_uniso_pg), 
    .LRC_ISOLATE_uniso (lc_isolate_uniso_pg), 

    .LRC_SLEEP   (LRC_SLEEP), 
    .LRC_SLEEPB  (), // unused
    .LRC_CLKENB  (LRC_CLKENB), 
    .LRC_CLKEN   (), // unused
    .LRC_RESET   (LRC_RESET),
    .LRC_RESETB  (), // unused
    .LRC_ISOLATE (LRC_ISOLATE)
);

//---------------------------------------------
// MBus Node (Master)
//---------------------------------------------
mbus_master_node_testbench #(.ADDRESS(ADDRESS)) mbus_master_node_testbench_0 (
    .CLK_EXT    (CLK_MBC), 
    .RESETn     (RESETn), 
    .CIN        (CIN), 
    .DIN        (DIN), 
    .COUT       (mbc2mc_cout), 
    .DOUT       (mbc2mc_dout),

    // MBus Tx (Layer Ctrl --> MBus Ctrl)
    .TX_ADDR        (lc2mbc_tx_addr), 
    .TX_DATA        (lc2mbc_tx_data), 
    .TX_PEND        (lc2mbc_tx_pend), 
    .TX_REQ         (lc2mbc_tx_req), 
    .TX_PRIORITY    (lc2mbc_tx_priority), 
    .TX_RESP_ACK    (lc2mbc_tx_resp_ack), 
    // MBus Tx (MBus Ctrl --> Layer Ctrl)
    .TX_ACK         (mbc2lc_tx_ack), 
    .TX_SUCC        (mbc2lc_tx_succ), 
    .TX_FAIL        (mbc2lc_tx_fail), 

    // MBus Rx (MBus Ctrl --> Layer Ctrl)
    .RX_ADDR        (mbc2lc_rx_addr), 
    .RX_DATA        (mbc2lc_rx_data), 
    .RX_REQ         (mbc2lc_rx_req), 
    .RX_PEND        (mbc2lc_rx_pend), 
    .RX_BROADCAST   (mbc2lc_rx_broadcast),
    .RX_FAIL        (mbc2lc_rx_fail), 
    // MBus Rx (Layer Ctrl --> MBus Ctrl)
    .RX_ACK         (lc2mbc_rx_ack), 

    // FWD notifier
    .MBC_IN_FWD     (MBC_IN_FWD),

    // Broadcast ACK
    .RX_ACK_BCAST   (rx_ack_bcast),

    // Reset signal coming from Sleep Ctrl
    .MBC_RESET      (mbc_reset),

    // Power gating signals for Layer Ctrl
    .LRC_SLEEP      (lc_sleep_uniso),
    .LRC_CLKENB     (lc_clkenb_uniso),
    .LRC_RESET      (lc_reset_uniso),
    .LRC_ISOLATE    (lc_isolate_uniso),

    // Sleep Request going into Sleep Ctrl
    .SLEEP_REQUEST_TO_SLEEP_CTRL(mbc2mc_sleep_req),

    // External Interrupt
    .EXTERNAL_INT   (mc2mbc_external_int), 
    .CLR_EXT_INT    (mbc2mc_clr_ext_int),
    .MBUS_BUSY      (mbc2mc_mbus_busy),

    // FMS Configuration
    .FORCE_IDLE_WHEN_DONE (1'b1),

    // MBus Threshold
    .NUM_BITS_THRESHOLD (NUM_BITS_THRESHOLD)
);

// Always ACK broadcast messages
always @ (posedge CLK_MBC or negedge RESETn) begin
    if (~RESETn) rx_ack_bcast <= `MBUSTB_SD 0;
    else         rx_ack_bcast <= `MBUSTB_SD RX_REQ & RX_BROADCAST;
end

//---------------------------------------------
// MBus Master Ctrl
//---------------------------------------------
mbus_master_ctrl_testbench mbus_master_ctrl_testbench_0 (
    // Input
    .CLK           (CLK_MBC),
    .RESETn        (RESETn),

    .CIN           (CIN),
    .DIN           (DIN),
    .COUT_FROM_BUS (mbc2mc_cout),
    .DOUT_FROM_BUS (mbc2mc_dout), 
    .COUT          (COUT),
    .DOUT          (DOUT),

    .SLEEP_REQ0    (mbc2mc_sleep_req_pg),
    .SLEEP_REQ1    (1'b0),     // unused in this testbench
    .WAKEUP_REQ0   (WAKEUP_REQ),
    .WAKEUP_REQ1   (1'b0),     // unused in this testbench
    .WAKEUP_REQ2   (1'b0),     // unused in this testbench
    .WAKEUP_REQ3   (1'b0),     // unused in this testbench

    .MBC_ISOLATE   (mbc_isolate), 
    .MBC_ISOLATE_B (),         // unused
    .MBC_RESET     (mbc_reset),
    .MBC_RESET_B   (mbc_reset_b),
    .MBC_SLEEP     (mbc_sleep),
    .MBC_SLEEP_B   (mbc_sleep_b),

    .CLR_EXT_INT   (mbc2mc_clr_ext_int),
    .EXTERNAL_INT  (mc2mbc_external_int), 

    .LRC_SLEEP     (LRC_SLEEP),
    .MBUS_BUSY     (mbc2mc_mbus_busy_pg)
);

//---------------------------------------------
// Power-Gated Signals
// NOTE: For testbench purpose,
//       output coming out from mbus_master_wrapper_testbench
//       should be isolated with mbc_isolate
//---------------------------------------------
always @* begin
    if (mbc_isolate) begin
        TX_ACK        = 0;
        TX_FAIL       = 0;
        TX_SUCC       = 0;
        RX_ADDR       = 0;
        RX_DATA       = 0;
        RX_REQ        = 0;
        RX_PEND       = 0;
        RX_BROADCAST  = 0;
        RX_FAIL       = 0;
    end
    else begin
        TX_ACK        = mbc2lc_tx_ack;
        TX_FAIL       = mbc2lc_tx_fail;
        TX_SUCC       = mbc2lc_tx_succ;
        RX_ADDR       = mbc2lc_rx_addr;
        RX_DATA       = mbc2lc_rx_data;
        RX_REQ        = mbc2lc_rx_req;
        RX_PEND       = mbc2lc_rx_pend;
        RX_BROADCAST  = mbc2lc_rx_broadcast;
        RX_FAIL       = mbc2lc_rx_fail;
    end
end

always @* begin
    if (mbc_sleep) begin
        mbc2mc_sleep_req_pg     = 1'bx;
        mbc2mc_mbus_busy_pg     = 1'bx;
        lc_sleep_uniso_pg       = 1'bx;
        lc_clkenb_uniso_pg      = 1'bx;
        lc_reset_uniso_pg       = 1'bx;
        lc_isolate_uniso_pg     = 1'bx;
    end
    else begin
        mbc2mc_sleep_req_pg     = mbc2mc_sleep_req;
        mbc2mc_mbus_busy_pg     = mbc2mc_mbus_busy;
        lc_sleep_uniso_pg       = lc_sleep_uniso;
        lc_clkenb_uniso_pg      = lc_clkenb_uniso;
        lc_reset_uniso_pg       = lc_reset_uniso;
        lc_isolate_uniso_pg     = lc_isolate_uniso;
    end
end

always @* begin
    if (LRC_SLEEP) begin
        lc2mbc_tx_addr_uniso_pg     = 32'hxxxxxxxx;
        lc2mbc_tx_data_uniso_pg     = 32'hxxxxxxxx;
        lc2mbc_tx_req_uniso_pg      = 1'bx;
        lc2mbc_tx_pend_uniso_pg     = 1'bx;
        lc2mbc_tx_priority_uniso_pg = 1'bx;
        lc2mbc_rx_ack_uniso_pg      = 1'bx;
        lc2mbc_tx_resp_ack_uniso_pg = 1'bx;
    end
    else begin
        lc2mbc_tx_addr_uniso_pg     = TX_ADDR;
        lc2mbc_tx_data_uniso_pg     = TX_DATA;
        lc2mbc_tx_req_uniso_pg      = TX_REQ;
        lc2mbc_tx_pend_uniso_pg     = TX_PEND;
        lc2mbc_tx_priority_uniso_pg = TX_PRIORITY;
        lc2mbc_rx_ack_uniso_pg      = RX_ACK;
        lc2mbc_tx_resp_ack_uniso_pg = TX_RESP_ACK;
    end
end

endmodule // mbus_master_wrapper_testbench
