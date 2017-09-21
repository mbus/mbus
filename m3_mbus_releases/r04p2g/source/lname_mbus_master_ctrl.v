//*******************************************************************************************
//Author:         Yejoong Kim
//Last Modified:  Dec 16 2016
//Description:    MBus Master Controller
//Update History: May 21 2016 - Updated for MBus r03 (Yejoong Kim)
//                              Combined the following three modules into one:
//                                  lname_mbus_master_sleep_ctrl
//                                  lname_mbus_master_wire_ctrl
//                                  lname_mbus_int_ctrl
//                              Fixed potential hold-time violation in ext_int_dout & EXTERNAL_INT
//                                  OLD: int_busy = wakeup_req_ored & mbus_busy_b
//                                       ext_int_dout and EXTERNAL_INT set to mbus_busy_b @ (posedge int_busy)
//                                  NEW: int_busy = wakeup_req_ored & mbus_busy_b & LRC_SLEEP
//                                       ext_int_dout and EXTERNAL_INT set to 1 @ (posedge int_busy)
//                Dec 16 2016 - Updated for MBus r04
//                              Fixed CIN glitch issue
//                                  Now MBUS_BUSY_B is generated in mbus_node
//                Apr 28 2017 - Updated for MBus r04p1
//                              SLEEP_REQ* and MBUS_BUSY are isolated here, rather than in mbus_isolation.
//******************************************************************************************* 

module lname_mbus_master_ctrl ( 
    input      CLK,
    input      RESETn,

    // MBus Clock & Data
    input      CIN,
    input      DIN,
    input      COUT_FROM_BUS,
    input      DOUT_FROM_BUS,
    output reg COUT,
    output reg DOUT,

    // Sleep & Wakeup Requests
    input      SLEEP_REQ0,
    input      SLEEP_REQ1,
    input      WAKEUP_REQ0,
    input      WAKEUP_REQ1,
    input      WAKEUP_REQ2,
    input      WAKEUP_REQ3,

    // Power-Gating Signals
    output reg MBC_ISOLATE, 
    output     MBC_ISOLATE_B,
    output reg MBC_RESET,
    output     MBC_RESET_B,
    output     MBC_SLEEP,
    output     MBC_SLEEP_B,

    // Handshaking with MBus Ctrl
    input      CLR_EXT_INT,
    output reg EXTERNAL_INT, 

    // Misc
    input      LRC_SLEEP,
    input      MBUS_BUSY
);

//****************************************************************************
// SLEEP CONTROLLER
//****************************************************************************

    reg     set_tran_to_wake;
    reg     rst_tran_to_wake;   // act as tran to "sleep"
    reg     tran_to_wake;
    reg     mbc_sleep_int;

    assign  MBC_ISOLATE_B = ~MBC_ISOLATE;
    assign  MBC_RESET_B   = ~MBC_RESET;
    assign  MBC_SLEEP_B   = ~MBC_SLEEP;

    wire wakeup_req_ored = WAKEUP_REQ0 | WAKEUP_REQ1 | WAKEUP_REQ2 | WAKEUP_REQ3;
    wire sleep_req = (~MBC_ISOLATE) & (SLEEP_REQ0 | SLEEP_REQ1);

    wire set_tran_to_wake_in_sleep = mbc_sleep_int & ~DIN;
    wire going_sleep = ~set_tran_to_wake_in_sleep & sleep_req;

    // set_tran_to_wake
    always @* begin
        if (~RESETn) set_tran_to_wake <= 1'b0;
        else if (set_tran_to_wake_in_sleep) 
             set_tran_to_wake <= 1'b1;
        else set_tran_to_wake <= 1'b0;
    end

    // rst_tran_to_wake
    always @* begin
        if (~RESETn) rst_tran_to_wake <= 1'b1; // NOTE: It was 1'b0 in original mbus verilog
        else if (going_sleep)
             rst_tran_to_wake <= 1'b1;
        else rst_tran_to_wake <= 1'b0;
    end

    // tran_to_wake
    always @ ( posedge rst_tran_to_wake or posedge set_tran_to_wake ) begin
        if (rst_tran_to_wake)       tran_to_wake <= 1'b0;
        else if (set_tran_to_wake)  tran_to_wake <= 1'b1;
        else                        tran_to_wake <= tran_to_wake;
    end

    // MBC_ISOLATE, MBC_SLEEP, MBC_RESET
    wire next_mbc_isolate = mbc_sleep_int | ~tran_to_wake;
    wire next_mbc_sleep_int = MBC_ISOLATE & ~tran_to_wake;

    always @ (posedge CLK or negedge RESETn) begin
        if (~RESETn) begin
            MBC_ISOLATE     <= `SD 1'b1;
            mbc_sleep_int   <= `SD 1'b1;
            MBC_RESET       <= `SD 1'b1;
        end 
        else begin
            MBC_ISOLATE     <= `SD next_mbc_isolate;
            mbc_sleep_int   <= `SD next_mbc_sleep_int;
            MBC_RESET       <= `SD MBC_ISOLATE;
        end
    end

    assign MBC_SLEEP = mbc_sleep_int & DIN;

//****************************************************************************
// INTERRUPT CONTROLLER
//****************************************************************************

    wire clr_ext_int_b = ~(MBC_ISOLATE_B & CLR_EXT_INT);

    wire RESETn_local = RESETn & CIN;
    wire RESETn_local2 = RESETn & clr_ext_int_b;

    // mbus_busy_b_isol
    wire mbus_busy_b_isol = ~(MBUS_BUSY & MBC_RESET_B);

    // int_busy
    wire int_busy = (wakeup_req_ored & mbus_busy_b_isol & LRC_SLEEP);

    // ext_int_dout
    reg ext_int_dout;
    always @ (posedge int_busy or negedge RESETn_local) begin
        if (~RESETn_local) ext_int_dout <= `SD 0;
        else ext_int_dout <= `SD 1;
    end

    // EXTERNAL_INT
    always @ (posedge int_busy or negedge RESETn_local2) begin
        if (~RESETn_local2) EXTERNAL_INT <= `SD 0;
        else EXTERNAL_INT <= `SD 1;
    end
   
//****************************************************************************
// WIRE CONTROLLER
//****************************************************************************

always @* begin
    if (!RESETn)          COUT <= `SD 1'b1;
    else if (MBC_ISOLATE) COUT <= `SD 1'b1;
    else                  COUT <= `SD COUT_FROM_BUS;

    if (!RESETn)           DOUT <= `SD 1'b1;
    else if (ext_int_dout) DOUT <= `SD 0;
    else if (MBC_ISOLATE)  DOUT <= `SD 1'b1;
    else                   DOUT <= `SD DOUT_FROM_BUS;
end

endmodule // lname_mbus_master_ctrl
