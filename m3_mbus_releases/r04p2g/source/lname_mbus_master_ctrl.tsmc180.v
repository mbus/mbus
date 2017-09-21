//*******************************************************************************************
//Author:         Yejoong Kim
//Last Modified:  Dec 16 2016
//Description:    MBus Master Controller
//                Structural verilog netlist using sc_x_hvt_tsmc180
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
    input  CLK,
    input  RESETn,

    // MBus Clock & Data
    input  CIN,
    input  DIN,
    input  COUT_FROM_BUS,
    input  DOUT_FROM_BUS,
    output COUT,
    output DOUT,

    // Sleep & Wakeup Requests
    input  SLEEP_REQ0,
    input  SLEEP_REQ1,
    input  WAKEUP_REQ0,
    input  WAKEUP_REQ1,
    input  WAKEUP_REQ2,
    input  WAKEUP_REQ3,

    // Power-Gating Signals
    output MBC_ISOLATE, 
    output MBC_ISOLATE_B,
    output MBC_RESET,
    output MBC_RESET_B,
    output MBC_SLEEP,
    output MBC_SLEEP_B,

    // Handshaking with MBus Ctrl
    input  CLR_EXT_INT,
    output EXTERNAL_INT, 

    // Misc
    input  LRC_SLEEP,
    input  MBUS_BUSY
);

//****************************************************************************
// Internal Wire Declaration
//****************************************************************************

    wire reset;
    wire reset_b;
    wire din_b;
    wire mbc_isolate_b_int;
    wire mbc_reset_b_int;
    wire mbc_sleep_b_int;
    wire mbc_sleep_b_unbuf;
    wire mbc_sleep_unbuf;
    wire wr01_nor;
    wire wr23_nor;
    wire wakeup_req_ored_b;
    wire wakeup_req_ored;
    wire sleep_req0_b;
    wire sleep_req1_b;
    wire sleep_req;
    wire sleep_req_b;
    wire set_tran_to_wake_in_sleep;
    wire going_sleep;
    wire setn_tran_to_wake;
    wire rstn_tran_to_wake;
    wire tran_to_wake_int;
    wire tran_to_wake_b;
    wire tran_to_wake;
    wire next_mbc_isolate;
    wire next_mbc_sleep_int;
    wire mbc_isolate_int;
    wire mbc_sleep_int;
    wire mbc_reset_int;
    wire clr_ext_int_iso;
    wire clr_ext_int_b;
    wire RESETn_local;
    wire RESETn_local2;
    wire mbus_busy_b_isol;
    wire int_busy;
    wire int_busy_b;
    wire ext_int_dout;
    wire cout_from_bus_iso;
    wire cout_int;
    wire cout_unbuf;
    wire dout_from_bus_iso;
    wire dout_int_1;
    wire dout_int_0;
    wire dout_unbuf;

// ---------------------------------------------
// NOTE: Functional Relationship:
// ---------------------------------------------
//           MBC_ISOLATE   = mbc_isolate_int
//           MBC_ISOLATE_B = mbc_isolate_b_int
//           MBC_RESET     = mbc_reset_int
//           MBC_SLEEP     = mbc_sleep_unbuf
//           MBC_SLEEP_B   = mbc_sleep_b_unbuf
// ---------------------------------------------
//           clr_ext_int_b = ~clr_ext_int_iso
// ---------------------------------------------
//           MBC_SLEEP    != mbc_sleep_int
//           MBC_SLEEP_B  != mbc_sleep_b)int
// ---------------------------------------------
    

//****************************************************************************
// GLOBAL
//****************************************************************************

    // Global Reset Buffer
    INVX1HVT INV_reset   (.Y(reset),   .A(RESETn));
    INVX1HVT INV_reset_b (.Y(reset_b), .A(reset));

    // din_b = ~DIN
    INVX1HVT  INV_din_b (.A(DIN), .Y(din_b));


//****************************************************************************
// SLEEP CONTROLLER
//****************************************************************************

    // assign MBC_ISOLATE_B = ~MBC_ISOLATE;
    INVX8HVT INV_MBC_ISOLATE_B     (.Y(MBC_ISOLATE_B),     .A(mbc_isolate_int));
    INVX8HVT INV_MBC_ISOLATE       (.Y(MBC_ISOLATE),       .A(mbc_isolate_b_int));
    INVX8HVT INV_mbc_isolate_b_int (.Y(mbc_isolate_b_int), .A(mbc_isolate_int));

    // assign MBC_RESET_B = ~MBC_RESET;
    INVX1HVT INV_mbc_reset_b_int (.Y(mbc_reset_b_int), .A(mbc_reset_int));
    INVX8HVT INV_MBC_RESET       (.Y(MBC_RESET),       .A(mbc_reset_b_int));
    INVX8HVT INV_MBC_RESET_B     (.Y(MBC_RESET_B),     .A(mbc_reset_int));

    // assign MBC_SLEEP_B = ~MBC_SLEEP;
    INVX8HVT INV_mbc_sleep_b_int   (.Y(mbc_sleep_b_int),   .A(mbc_sleep_int));
    INVX1HVT INV_mbc_sleep_b_unbuf (.Y(mbc_sleep_b_unbuf), .A(mbc_sleep_unbuf));
    INVX8HVT INV_MBC_SLEEP_B       (.Y(MBC_SLEEP_B),       .A(mbc_sleep_unbuf));
    INVX8HVT INV_MBC_SLEEP         (.Y(MBC_SLEEP),         .A(mbc_sleep_b_unbuf));

    // assign MBC_SLEEP = mbc_sleep_int & DIN;
    AND2X1HVT AND2_mbc_sleep_unbuf (.A(DIN), .B(mbc_sleep_int), .Y(mbc_sleep_unbuf));

    // wire wakeup_req_ored = WAKEUP_REQ0 | WAKEUP_REQ1 | WAKEUP_REQ2 | WAKEUP_REQ3;
    NOR2X1HVT NOR2_wr01_nor (.A(WAKEUP_REQ0), .B(WAKEUP_REQ1), .Y(wr01_nor));
    NOR2X1HVT NOR2_wr23_nor (.A(WAKEUP_REQ2), .B(WAKEUP_REQ3), .Y(wr23_nor));
    AND2X1HVT AND2_wakeup_req_ored_b (.A(wr01_nor), .B(wr23_nor), .Y(wakeup_req_ored_b));
    INVX1HVT  INV_wakeup_req_ored    (.Y(wakeup_req_ored), .A(wakeup_req_ored_b));

    // wire sleep_req = (~MBC_ISOLATE) & (SLEEP_REQ0 | SLEEP_REQ1);
    NAND2X1HVT NAND2_sleep_req0_b (.Y(sleep_req0_b), .A(SLEEP_REQ0),   .B(mbc_isolate_b_int));
    NAND2X1HVT NAND2_sleep_req1_b (.Y(sleep_req1_b), .A(SLEEP_REQ1),   .B(mbc_isolate_b_int));
    NAND2X1HVT NAND2_sleep_req    (.Y(sleep_req),    .A(sleep_req1_b), .B(sleep_req0_b));
    INVX1HVT   INV_sleep_req_b    (.Y(sleep_req_b),  .A(sleep_req));

    // wire set_tran_to_wake_in_sleep = mbc_sleep_int & ~DIN;
    AND2X1HVT AND2_set_tran_to_wake_in_sleep (.A(din_b), .B(mbc_sleep_int), .Y(set_tran_to_wake_in_sleep));

    // wire going_sleep = ~set_tran_to_wake_in_sleep & sleep_req;
    NOR2X1HVT NOR2_going_sleep (.B(sleep_req_b), .A(set_tran_to_wake_in_sleep), .Y(going_sleep));

    // setn_tran_to_wake (= ~set_tran_to_wake)
    NAND2X1HVT NAND2_setn_tran_to_wake (.B(reset_b), .A(set_tran_to_wake_in_sleep), .Y(setn_tran_to_wake));
    
    // rstn_tran_to_wake (= ~rst_tran_to_wake)
    NOR2X1HVT  NOR2_rstn_tran_to_wake (.Y(rstn_tran_to_wake), .A(reset), .B(going_sleep));

    // tran_to_wake
    NAND2X1HVT NAND2_tran_to_wake_int (.A(setn_tran_to_wake), .B(tran_to_wake_b),   .Y(tran_to_wake_int));
    NAND2X1HVT NAND2_tran_to_wake_b   (.A(rstn_tran_to_wake), .B(tran_to_wake_int), .Y(tran_to_wake_b));
    INVX2HVT   INV_tran_to_wake       (.A(tran_to_wake_b),    .Y(tran_to_wake));

    // wire next_mbc_isolate = mbc_sleep_int | ~tran_to_wake;
    NAND2X1HVT NAND2_next_mbc_isolate (.Y(next_mbc_isolate), .A(mbc_sleep_b_int), .B(tran_to_wake));

    // wire next_mbc_sleep_int = MBC_ISOLATE & ~tran_to_wake;
    NOR2X1HVT  NOR2_next_mbc_sleep_int (.B(tran_to_wake), .A(mbc_isolate_b_int), .Y(next_mbc_sleep_int));

    // MBC_ISOLATE, mbc_sleep_int, MBC_RESET
    DFFSX1HVT DFFS_mbc_isolate_int (.SN(reset_b), .CK(CLK), .Q(mbc_isolate_int), .D(next_mbc_isolate));
    DFFSX1HVT DFFS_mbc_sleep_int   (.SN(reset_b), .CK(CLK), .Q(mbc_sleep_int),   .D(next_mbc_sleep_int));
    DFFSX1HVT DFFS_mbc_reset_int   (.SN(reset_b), .CK(CLK), .Q(mbc_reset_int),   .D(mbc_isolate_int));


//****************************************************************************
// INTERRUPT CONTROLLER
//****************************************************************************

    //wire clr_ext_int_b = ~(MBC_ISOLATE_B & CLR_EXT_INT);
    AND2X1HVT AND2_clr_ext_int_iso (.Y(clr_ext_int_iso), .A(MBC_ISOLATE_B), .B(CLR_EXT_INT));
    INVX1HVT  INV_clr_ext_int_b    (.Y(clr_ext_int_b),   .A(clr_ext_int_iso));

    //wire RESETn_local = RESETn & CIN;
    AND2X1HVT AND2_RESETn_local (.Y(RESETn_local), .A(CIN), .B(RESETn));

    //wire RESETn_local2 = RESETn & clr_ext_int_b;
    AND2X1HVT AND2_RESETn_local2 (.Y(RESETn_local2), .A(clr_ext_int_b), .B(RESETn));

    //wire mbus_busy_b_isol = ~(MBUS_BUSY & MBC_RESET_B);
    NAND2X1HVT NAND2_mbus_busy_b_isol (.A(MBUS_BUSY), .B(MBC_RESET_B), .Y(mbus_busy_b_isol));

    //wire int_busy = (wakeup_req_ored & mbus_busy_b_isol & LRC_SLEEP)
    NAND3X1HVT NAND3_int_busy_b (.A(wakeup_req_ored), .B(mbus_busy_b_isol), .C(LRC_SLEEP), .Y(int_busy_b));
    INVX2HVT   INV_int_busy     (.Y(int_busy), .A(int_busy_b));

    // ext_int_dout
    DFFRX1HVT DFFR_ext_int_dout (.RN(RESETn_local), .CK(int_busy), .Q(ext_int_dout), .D(1'b1));

    // EXTERNAL_INT
    DFFRX1HVT DFFR_EXTERNAL_INT (.RN(RESETn_local2), .CK(int_busy), .Q(EXTERNAL_INT), .D(1'b1));


//****************************************************************************
// WIRE CONTROLLER
//****************************************************************************

    // COUT
    OR2X1HVT    OR2_cout_from_bus_iso (.Y(cout_from_bus_iso), .A(COUT_FROM_BUS), .B(MBC_ISOLATE));
    MUX2GFX1HVT MUX2_cout_int         (.S(MBC_ISOLATE), .A(cout_from_bus_iso), .Y(cout_int), .B(1'b1));
    MUX2GFX1HVT MUX2_cout_unbuf       (.S(RESETn), .A(1'b1), .Y(cout_unbuf), .B(cout_int));
    BUFX4HVT    BUF_COUT              (.A(cout_unbuf), .Y(COUT));

    // DOUT
    OR2X1HVT    OR2_dout_from_bus_iso (.Y(dout_from_bus_iso), .A(DOUT_FROM_BUS), .B(MBC_ISOLATE));
    MUX2GFX1HVT MUX2_dout_int_1       (.S(MBC_ISOLATE), .A(dout_from_bus_iso), .Y(dout_int_1),    .B(1'b1));
    MUX2GFX1HVT MUX2_dout_int_0       (.S(ext_int_dout), .A(dout_int_1), .Y(dout_int_0), .B(1'b0));
    MUX2GFX1HVT MUX2_dout_unbuf       (.S(RESETn), .A(1'b1), .Y(dout_unbuf), .B(dout_int_0));
    BUFX4HVT    BUF_DOUT              (.A(dout_unbuf), .Y(DOUT));

endmodule // lname_mbus_master_ctrl
