//*******************************************************************************************
//Author:         Yejoong Kim
//Last Modified:  Aug 23 2017
//Description:    (Testbench) MBus Member Controller
//Update History: May 21 2016 - Updated for MBus r03 (Yejoong Kim)
//                              Combined the following three modules into one:
//                                  mbus_member_sleep_ctrl_testbench
//                                  mbus_member_wire_ctrl_testbench
//                                  mbus_member_addr_rf_testbench
//                                  mbus_int_ctrl_testbench
//                              Fixed potential hold-time violation in ext_int_dout & EXTERNAL_INT
//                                  OLD: int_busy = WAKEUP_REQ & mbus_busy_b
//                                       ext_int_dout and EXTERNAL_INT set to mbus_busy_b @ (posedge int_busy)
//                                  NEW: int_busy = WAKEUP_REQ & mbus_busy_b & LRC_SLEEP
//                                       ext_int_dout and EXTERNAL_INT set to 1 @ (posedge int_busy)
//                Dec 16 2016 - Updated for MBus r04
//                              Fixed CIN glitch issue
//                                  Now MBUS_BUSY_B is generated in mbus_node
//                Apr 28 2017 - Updated for MBus r04p1
//                              More explicit isolation for SLEEP_REQ
//                              SLEEP_REQ* and MBUS_BUSY are isolated here, rather than in mbus_isolation.
//                Aug 23 2017 - Checked for mbus_testbench
//******************************************************************************************* 

`include "include/mbus_def_testbench.v"

module mbus_member_ctrl_testbench (
    input      RESETn,

    // MBus Clock & Data
    input      CIN,
    input      DIN,
    input      COUT_FROM_BUS,
    input      DOUT_FROM_BUS,
    output reg COUT,
    output reg DOUT,

    // Sleep & Wakeup Requests
    input      SLEEP_REQ,
    input      WAKEUP_REQ, 

    // Power-Gating Signals
    output reg MBC_ISOLATE,
    output     MBC_ISOLATE_B,
    output reg MBC_RESET,
    output     MBC_RESET_B,
    output reg MBC_SLEEP,
    output     MBC_SLEEP_B,

    // Handshaking with MBus Ctrl
    input      CLR_EXT_INT,
    output reg EXTERNAL_INT, 

    // Short-Prefix
    input      ADDR_WR_EN,
    input      ADDR_CLR_B,
    input      [`MBUSTB_DYNA_WIDTH-1:0] ADDR_IN,
    output reg [`MBUSTB_DYNA_WIDTH-1:0] ADDR_OUT,
    output reg ADDR_VALID,

    // Misc
    input      LRC_SLEEP,
    input      MBUS_BUSY
);

//****************************************************************************
// SLEEP CONTROLLER
//****************************************************************************
    
    wire next_mbc_isolate;
    wire sleep_req_isol;
    reg  goingsleep;
    
    assign MBC_SLEEP_B   = ~MBC_SLEEP;
    assign MBC_ISOLATE_B = ~MBC_ISOLATE;
    assign MBC_RESET_B   = ~MBC_RESET;

    assign next_mbc_isolate = goingsleep | sleep_req_isol | MBC_SLEEP;
    assign sleep_req_isol  = SLEEP_REQ & MBC_ISOLATE_B;

    always @ (posedge CIN or negedge RESETn) begin
        if (~RESETn) begin
            goingsleep  <= `MBUSTB_SD 1'b0;
            MBC_SLEEP   <= `MBUSTB_SD 1'b1;
            MBC_ISOLATE <= `MBUSTB_SD 1'b1;
        end
        else begin
            goingsleep  <= `SD sleep_req_isol;
            MBC_SLEEP   <= `MBUSTB_SD goingsleep;
            MBC_ISOLATE <= `MBUSTB_SD next_mbc_isolate;
        end
    end

    always @ (negedge CIN or negedge RESETn) begin
        if (~RESETn) MBC_RESET <= `MBUSTB_SD 1'b1;
        else         MBC_RESET <= `MBUSTB_SD MBC_ISOLATE;
    end

//****************************************************************************
// INTERRUPT CONTROLLER
//****************************************************************************

    wire clr_ext_int_b = ~(MBC_ISOLATE_B & CLR_EXT_INT);

    wire RESETn_local = RESETn & CIN;
    wire RESETn_local2 = RESETn & clr_ext_int_b;

    // mbus_busy_b_isol
    wire mbus_busy_b_isol = ~(MBUS_BUSY & MBC_RESET_B);

    // int_busy
    wire int_busy = (WAKEUP_REQ & mbus_busy_b_isol & LRC_SLEEP);

    // ext_int_dout
    reg ext_int_dout;
    always @ (posedge int_busy or negedge RESETn_local) begin
        if (~RESETn_local) ext_int_dout <= `MBUSTB_SD 0;
        else ext_int_dout <= `MBUSTB_SD 1;
    end

    // EXTERNAL_INT
    always @ (posedge int_busy or negedge RESETn_local2) begin
        if (~RESETn_local2) EXTERNAL_INT <= `MBUSTB_SD 0;
        else EXTERNAL_INT <= `MBUSTB_SD 1;
    end
   
//****************************************************************************
// WIRE CONTROLLER
//****************************************************************************

always @* begin
    if (~RESETn)          COUT <= `MBUSTB_SD 1'b1;
    else if (MBC_ISOLATE) COUT <= `MBUSTB_SD CIN;
    else                  COUT <= `MBUSTB_SD COUT_FROM_BUS;

    if (~RESETn)           DOUT <= `MBUSTB_SD 1'b1;
    else if (ext_int_dout) DOUT <= `MBUSTB_SD 0;
    else if (MBC_ISOLATE)  DOUT <= `MBUSTB_SD DIN;
    else                   DOUT <= `MBUSTB_SD DOUT_FROM_BUS;
end


//****************************************************************************
// SHORT ADDRESS (SHORT PREFIX) REGISTER
//****************************************************************************

wire    RESETn_local3 = (RESETn & ADDR_CLR_B); 
wire    addr_update = (ADDR_WR_EN & (~MBC_ISOLATE));

always @ (posedge addr_update or negedge RESETn_local3) begin
    if (~RESETn_local3) begin
        ADDR_OUT   <= `MBUSTB_SD {`MBUSTB_DYNA_WIDTH{1'b1}};
        ADDR_VALID <= `MBUSTB_SD 0;
    end
    else begin
        ADDR_OUT   <= `MBUSTB_SD ADDR_IN;
        ADDR_VALID <= `MBUSTB_SD 1;
    end
end

endmodule // mbus_member_ctrl_testbench
