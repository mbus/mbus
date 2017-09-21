//*******************************************************************************************
//Author:         Yejoong Kim, Ye-sheng Kuo
//Last Modified:  Aug 23 2017
//Description:    (Testbench) Wrapper for MBus Member Layer
//Update History: May 21 2016 - Updated for MBus r03 (Yejoong Kim)
//                Dec 16 2016 - Updated for MBus r04 (Yejoong Kim)
//                Aug 23 2017 - Checked for mbus_testbench
//******************************************************************************************* 

`include "include/mbus_def_testbench.v"

module mbus_member_wrapper_testbench (
    input     RESETn, 
    input     CIN, 
    input     DIN, 
    output    COUT,
    output    DOUT, 
    input     [`MBUSTB_ADDR_WIDTH-1:0] TX_ADDR, 
    input     [`MBUSTB_DATA_WIDTH-1:0] TX_DATA, 
    input     TX_REQ, 
    input     TX_PEND, 
    input     TX_PRIORITY,
    input     TX_RESP_ACK,
    input     RX_ACK, 

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

    input      WAKEUP_REQ,

    output     [`MBUSTB_DYNA_WIDTH-1:0] PREFIX_ADDR_OUT
);

parameter ADDRESS = 20'h12345;

//---------------------------------------------
// Internal Wire Declaration
//---------------------------------------------

// From Sleep Ctrl
wire    mbc_sleep, mbc_isolate, mbc_reset; 

// From MBus Ctrl
wire    lc_sleep_uniso, lc_clkenb_uniso, lc_reset_uniso, lc_isolate_uniso;
reg     lc_sleep_uniso_pg, lc_clkenb_uniso_pg, lc_reset_uniso_pg, lc_isolate_uniso_pg;

// MBus Ctrl <--> MBus Member Ctrl
wire    mbc2mc_sleep_req; 
reg     mbc2mc_sleep_req_pg;
wire    mbc2mc_mbus_busy; 
reg     mbc2mc_mbus_busy_pg;
wire    mbc2mc_clr_ext_int, mc2mbc_external_int;
wire    mbc2mc_cout, mbc2mc_dout;
wire    [`MBUSTB_DYNA_WIDTH-1:0] mc2mbc_addr, mbc2mc_addr;
wire    mc2mbc_valid, mbc2mc_write, mbc2mc_resetn;
assign  PREFIX_ADDR_OUT = mc2mbc_addr;

// MBus Ctrl <--> Layer Ctrl
wire    [`MBUSTB_ADDR_WIDTH-1:0] mbc2lc_rx_addr;
wire    [`MBUSTB_DATA_WIDTH-1:0] mbc2lc_rx_data;
wire    mbc2lc_tx_ack, mbc2lc_rx_req, mbc2lc_rx_broadcast, mbc2lc_rx_fail, mbc2lc_rx_pend, mbc2lc_tx_fail, mbc2lc_tx_succ;

wire    [`MBUSTB_ADDR_WIDTH-1:0] lc2mbc_tx_addr;
wire    [`MBUSTB_DATA_WIDTH-1:0] lc2mbc_tx_data;
wire    lc2mbc_tx_req, lc2mbc_tx_pend, lc2mbc_tx_priority, lc2mbc_rx_ack, lc2mbc_tx_resp_ack;

reg     [`MBUSTB_ADDR_WIDTH-1:0] lc2mbc_tx_addr_uniso_pg;
reg     [`MBUSTB_DATA_WIDTH-1:0] lc2mbc_tx_data_uniso_pg;
reg     lc2mbc_tx_req_uniso_pg, lc2mbc_tx_pend_uniso_pg, lc2mbc_tx_priority_uniso_pg, lc2mbc_rx_ack_uniso_pg, lc2mbc_tx_resp_ack_uniso_pg;

   
//---------------------------------------------
// MBus Isolation
//---------------------------------------------
mbus_isolation_testbench mbus_isolation_testbench_0 (
    // MBus Isolation Signal
    .MBC_ISOLATE       (mbc_isolate),

    // Layer Ctrl --> MBus Ctrl
    .TX_ADDR_uniso     (lc2mbc_tx_addr_uniso_pg), 
    .TX_DATA_uniso     (lc2mbc_tx_data_uniso_pg), 
    .TX_REQ_uniso      (lc2mbc_tx_req_uniso_pg), 
    .TX_PEND_uniso     (lc2mbc_tx_pend_uniso_pg), 
    .TX_PRIORITY_uniso (lc2mbc_tx_priority_uniso_pg),
    .RX_ACK_uniso      (lc2mbc_rx_ack_uniso_pg), 
    .TX_RESP_ACK_uniso (lc2mbc_tx_resp_ack_uniso_pg),

    .TX_ADDR     (lc2mbc_tx_addr), 
    .TX_DATA     (lc2mbc_tx_data), 
    .TX_REQ      (lc2mbc_tx_req), 
    .TX_PEND     (lc2mbc_tx_pend), 
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
// MBus Ctrl (Member Node)
//---------------------------------------------
mbus_node_testbench#(.ADDRESS(ADDRESS)) mbus_node_testbench_0 (
    .RESETn (RESETn), 
    .CIN    (CIN), 
    .DIN    (DIN), 
    .COUT   (mbc2mc_cout), 
    .DOUT   (mbc2mc_dout), 

    // MBus Tx (Layer Ctrl --> MBus Ctrl)
    .TX_ADDR        (lc2mbc_tx_addr), 
    .TX_DATA        (lc2mbc_tx_data), 
    .TX_REQ         (lc2mbc_tx_req), 
    .TX_PEND        (lc2mbc_tx_pend), 
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
    .MBC_IN_FWD(), // not used in member layers

    // Reset signal coming from Sleep Ctrl
    .MBC_RESET      (mbc_reset), 

    // Power gating signals for Layer Ctrl
    .LRC_SLEEP      (lc_sleep_uniso), 
    .LRC_CLKENB     (lc_clkenb_uniso), 
    .LRC_RESET      (lc_reset_uniso), 
    .LRC_ISOLATE    (lc_isolate_uniso),

    // Sleep Request going into Sleep Ctrl
    .SLEEP_REQUEST_TO_SLEEP_CTRL(mbc2mc_sleep_req), // Need to be isolated in mbus_sleep_ctrl

    // External Interrupt
    .EXTERNAL_INT   (mc2mbc_external_int), 
    .CLR_EXT_INT    (mbc2mc_clr_ext_int),   // Need to be isolated in mbus_int_ctrl
    .MBUS_BUSY      (mbc2mc_mbus_busy),      // Need to be isolated in mbus_int_ctrl

    // Short-Address Register File
    .ASSIGNED_ADDR_IN       (mc2mbc_addr), 
    .ASSIGNED_ADDR_VALID    (mc2mbc_valid), 
    .ASSIGNED_ADDR_OUT      (mbc2mc_addr),
    .ASSIGNED_ADDR_WRITE    (mbc2mc_write),    // Need to be isolated in mbus_addr_rf
    .ASSIGNED_ADDR_INVALIDn (mbc2mc_resetn)    // Need to be isolated in mbus_addr_rf
);

//---------------------------------------------
// MBus Member Ctrl
//---------------------------------------------
mbus_member_ctrl_testbench mbus_member_ctrl_testbench_0 (
    .RESETn        (RESETn), 

    .CIN           (CIN), 
    .DIN           (DIN),
    .COUT_FROM_BUS (mbc2mc_cout),
    .DOUT_FROM_BUS (mbc2mc_dout), 
    .COUT          (COUT),
    .DOUT          (DOUT),

    .SLEEP_REQ     (mbc2mc_sleep_req_pg), 
    .WAKEUP_REQ    (WAKEUP_REQ), 

    .MBC_ISOLATE   (mbc_isolate), 
    .MBC_ISOLATE_B (), // unused
    .MBC_RESET     (mbc_reset), 
    .MBC_RESET_B   (), // unused
    .MBC_SLEEP     (mbc_sleep), 
    .MBC_SLEEP_B   (), // unused

    .CLR_EXT_INT   (mbc2mc_clr_ext_int),
    .EXTERNAL_INT  (mc2mbc_external_int), 

    .ADDR_WR_EN    (mbc2mc_write),
    .ADDR_CLR_B    (mbc2mc_resetn),
    .ADDR_IN       (mbc2mc_addr),
    .ADDR_OUT      (mc2mbc_addr),
    .ADDR_VALID    (mc2mbc_valid),

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

endmodule // mbus_member_wrapper_testbench
