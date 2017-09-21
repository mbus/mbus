//*******************************************************************************************
//Author:         Yejoong Kim
//Last Modified:  Dec 16 2016
//Description:    MBus Member Controller for PMU
//                Structural verilog netlist using sc_x_hvt_tsmc180
//Update History: May 21 2016 - Updated for MBus r03 (Yejoong Kim)
//                              Combined the following three modules into one:
//                                  lname_mbus_master_sleep_ctrl
//                                  lname_mbus_master_wire_ctrl
//                                  lname_mbus_member_addr_rf
//                                  lname_mbus_int_ctrl
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
//                              Added PMU DIN Glitch Filtering
//                              SLEEP_REQ* and MBUS_BUSY are isolated here, rather than in mbus_isolation.
//******************************************************************************************* 

module lname_mbus_member_ctrl (
    input        RESETn,

    // MBus Clock & Data
    input        CIN,
    input        DIN,
    input        COUT_FROM_BUS,
    input        DOUT_FROM_BUS,
    output       COUT,
    output       DOUT,

    // Sleep & Wakeup Requests
    input        SLEEP_REQ,
    input        WAKEUP_REQ, 

    // Power-Gating Signals
    output       MBC_ISOLATE,
    output       MBC_ISOLATE_B,
    output       MBC_RESET,
    output       MBC_RESET_B,
    output       MBC_SLEEP,
    output       MBC_SLEEP_B,

    // Handshaking with MBus Ctrl
    input        CLR_EXT_INT,
    output       EXTERNAL_INT, 

    // Short-Prefix
    input        ADDR_WR_EN,
    input        ADDR_CLR_B,
    input  [3:0] ADDR_IN,
    output [3:0] ADDR_OUT,
    output       ADDR_VALID,

    // Interface with PMU
    input        EN_GLITCH_FILT,
    input        PMU_ACTIVE,
    output       PMU_WAKEUP_REQ,

    // Misc
    input        LRC_SLEEP,
    input        MBUS_BUSY
);

//****************************************************************************
// Internal Wire Declaration
//****************************************************************************

    wire cin_b;
    wire cin_buf;
    wire mbc_sleep_b_int;
    wire mbc_isolate_b_int;
    wire mbc_reset_b_int;
    wire next_mbc_isolate;
    wire next_mbc_isolate_b;
    wire sleep_req_isol;
    wire sleep_req_b_isol;
    wire mbc_isolate_int;
    wire mbc_sleep_int;
    wire goingsleep;
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
    wire din_int;
    wire setn_pmu_wakeup_req;
    wire pmu_wakeup_req_unbuf;
    wire addr_clr_b_iso;
    wire [3:0] addr_in_iso;
    wire RESETn_local3;
    wire addr_update;

    wire resetn_pmu_wakeup_req;
    wire resetn_din_sampled;
    wire din_sampled;
    wire din_sampled_dly;
    wire din_sampled_dly0;
    wire din_sampled_dly1;
    wire din_glitch_detected;
    wire din_glitch_detected_b;

// ---------------------------------------------
// NOTE: Functional Relationship:
// ---------------------------------------------
//           MBC_ISOLATE   = mbc_isolate_int
//           MBC_ISOLATE_B = mbc_isolate_b_int
//           MBC_RESET     = mbc_reset_int
//           MBC_RESET_B   = mbc_reset_b_int
//           MBC_SLEEP     = mbc_sleep_int
//           MBC_SLEEP_B   = mbc_sleep_b_int
// ---------------------------------------------
//           clr_ext_int_b = ~clr_ext_int_iso
// ---------------------------------------------
    

//****************************************************************************
// GLOBAL
//****************************************************************************

    // CIN Buffer
    INVX1HVT  INV_cin_b   (.Y(cin_b), .A(CIN));
    INVX2HVT  INV_cin_buf (.Y(cin_buf), .A(cin_b));


//****************************************************************************
// SLEEP CONTROLLER
//****************************************************************************

    //assign MBC_SLEEP_B   = ~MBC_SLEEP;
    INVX1HVT INV_mbc_sleep_b_int (.Y(mbc_sleep_b_int), .A(mbc_sleep_int));
    INVX8HVT INV_MBC_SLEEP       (.Y(MBC_SLEEP),       .A(mbc_sleep_b_int));
    INVX8HVT INV_MBC_SLEEP_B     (.Y(MBC_SLEEP_B),     .A(mbc_sleep_int));
    
    //assign MBC_ISOLATE_B = ~MBC_ISOLATE;
    INVX1HVT INV_mbc_isolate_b_int (.Y(mbc_isolate_b_int), .A(mbc_isolate_int));
    INVX8HVT INV_MBC_ISOLATE       (.Y(MBC_ISOLATE),       .A(mbc_isolate_b_int));
    INVX8HVT INV_MBC_ISOLATE_B     (.Y(MBC_ISOLATE_B),     .A(mbc_isolate_int));

    //assign MBC_RESET_B   = ~MBC_RESET;
    INVX1HVT INV_mbc_reset_b_int (.Y(mbc_reset_b_int), .A(mbc_reset_int));
    INVX8HVT INV_MBC_RESET       (.Y(MBC_RESET),       .A(mbc_reset_b_int));
    INVX8HVT INV_MBC_RESET_B     (.Y(MBC_RESET_B),     .A(mbc_reset_int));

    //assign next_mbc_isolate = goingsleep | sleep_req_isol | MBC_SLEEP;
    INVX1HVT  INV_next_mbc_isolate    (.Y(next_mbc_isolate), .A(next_mbc_isolate_b));
    NOR3X1HVT NOR3_next_mbc_isolate_b (.C(goingsleep), .B(sleep_req_isol), .A(mbc_sleep_int), .Y(next_mbc_isolate_b));
    
    //assign sleep_req_isol  = SLEEP_REQ & MBC_ISOLATE_B;
    INVX1HVT   INV_next_goingsleep      (.Y(sleep_req_isol), .A(sleep_req_b_isol));
    NAND2X1HVT NAND2_next_goingsleep_b  (.Y(sleep_req_b_isol), .A(SLEEP_REQ), .B(mbc_isolate_b_int));

    // goingsleep, mbc_sleep_int, mbc_isolate_int, mbc_reset_int
    DFFSRX1HVT DFFSR_mbc_isolate_int (.SN(RESETn), .RN(1'b1),   .CK(cin_buf), .Q(mbc_isolate_int), .D(next_mbc_isolate));
    DFFSRX1HVT DFFSR_mbc_sleep_int   (.SN(RESETn), .RN(1'b1),   .CK(cin_buf), .Q(mbc_sleep_int),   .D(goingsleep));
    DFFSRX1HVT DFFSR_goingsleep      (.SN(1'b1),   .RN(RESETn), .CK(cin_buf), .Q(goingsleep),      .D(sleep_req_isol));
    DFFSRX1HVT DFFSR_mbc_reset_int   (.SN(RESETn), .RN(1'b1),   .CK(cin_b),   .Q(mbc_reset_int),   .D(mbc_isolate_int));

    
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
    NAND2X1HVT NAND2_mbus_busy_b_isol (.A(MBUS_BUSY), .B(mbc_reset_b_int), .Y(mbus_busy_b_isol));

    //wire int_busy = (WAKEUP_REQ & mbus_busy_b_isol & LRC_SLEEP)
    NAND3X1HVT NAND3_int_busy_b (.A(WAKEUP_REQ), .B(mbus_busy_b_isol), .C(LRC_SLEEP), .Y(int_busy_b));
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
    MUX2GFX1HVT MUX2_cout_int         (.S(MBC_ISOLATE), .A(cout_from_bus_iso), .Y(cout_int), .B(CIN));
    MUX2GFX1HVT MUX2_cout_unbuf       (.S(RESETn), .A(1'b1), .Y(cout_unbuf), .B(cout_int));
    BUFX4HVT    BUF_COUT              (.A(cout_unbuf), .Y(COUT));

    // DOUT
    OR2X1HVT    OR2_dout_from_bus_iso (.Y(dout_from_bus_iso), .A(DOUT_FROM_BUS), .B(MBC_ISOLATE));
    MUX2GFX1HVT MUX2_din_int          (.S(PMU_ACTIVE), .A(1'b1), .B(DIN), .Y(din_int));
    MUX2GFX1HVT MUX2_dout_int_1       (.S(MBC_ISOLATE), .A(dout_from_bus_iso), .B(din_int), .Y(dout_int_1));
    MUX2GFX1HVT MUX2_dout_int_0       (.S(ext_int_dout), .A(dout_int_1), .Y(dout_int_0), .B(1'b0));
    MUX2GFX1HVT MUX2_dout_unbuf       (.S(RESETn), .A(1'b1), .Y(dout_unbuf), .B(dout_int_0));
    BUFX4HVT    BUF_DOUT              (.A(dout_unbuf), .Y(DOUT));

    // Interface with PMU w/ DIN glitch prevention
    OR2X1HVT    OR2_setn_pmu_wakeup_req    (.A(DIN), .B(MBC_SLEEP_B), .Y(setn_pmu_wakeup_req));
    DFFSRX1HVT  DFFSR_pmu_wakeup_req_unbuf (.D(1'b0), .CK(MBC_SLEEP), .SN(setn_pmu_wakeup_req), .RN(resetn_pmu_wakeup_req), .Q(pmu_wakeup_req_unbuf));
    BUFX4HVT    BUF_PMU_WAKEUP_REQ         (.A(pmu_wakeup_req_unbuf), .Y(PMU_WAKEUP_REQ));
    DFFRX1HVT   DFFR_din_sampled           (.D(DIN), .CK(PMU_ACTIVE), .RN(resetn_din_sampled), .Q(din_sampled));
    AND2X1HVT   AND_din_sampled_masked     (.A(EN_GLITCH_FILT), .B(PMU_WAKEUP_REQ), .Y(resetn_din_sampled));
    BUFX1HVT    BUF_din_sampled_dly0       (.A(din_sampled), .Y(din_sampled_dly0));
    BUFX1HVT    BUF_din_sampled_dly1       (.A(din_sampled_dly0), .Y(din_sampled_dly1));
    BUFX1HVT    BUF_din_sampled_dly        (.A(din_sampled_dly1), .Y(din_sampled_dly));
    NAND2X1HVT  NAND2_din_glitch_detected_b(.A(PMU_ACTIVE), .B(din_sampled_dly), .Y(din_glitch_detected_b));
    AND2X1HVT   AND2_resetn_pmu_wakeup_req (.A(din_glitch_detected_b), .B(RESETn), .Y(resetn_pmu_wakeup_req));


//****************************************************************************
// SHORT-PREFIX ADDRESS REGISTER
//****************************************************************************

    // Isolation
    OR2X1HVT  AND2_addr_clr_b_iso (.A(MBC_ISOLATE),   .B(ADDR_CLR_B), .Y(addr_clr_b_iso));
    AND2X1HVT AND2_addr_in_iso_0  (.A(MBC_ISOLATE_B), .B(ADDR_IN[0]), .Y(addr_in_iso[0]));
    AND2X1HVT AND2_addr_in_iso_1  (.A(MBC_ISOLATE_B), .B(ADDR_IN[1]), .Y(addr_in_iso[1]));
    AND2X1HVT AND2_addr_in_iso_2  (.A(MBC_ISOLATE_B), .B(ADDR_IN[2]), .Y(addr_in_iso[2]));
    AND2X1HVT AND2_addr_in_iso_3  (.A(MBC_ISOLATE_B), .B(ADDR_IN[3]), .Y(addr_in_iso[3]));
    
    //wire    RESETn_local3 = (RESETn & ADDR_CLR_B); 
    AND2X1HVT AND2_RESETn_local3 (.A(RESETn),      .B(addr_clr_b_iso), .Y(RESETn_local3));

    //wire    addr_update = (ADDR_WR_EN & (~MBC_ISOLATE));
    AND2X1HVT AND2_addr_update (.A(MBC_ISOLATE_B), .B(ADDR_WR_EN), .Y(addr_update));
    
    // ADDR_OUT, ADDR_VALID
    DFFSX1HVT DFFS_ADDR_OUT_0 (.CK(addr_update), .D(addr_in_iso[0]), .SN(RESETn_local3), .Q(ADDR_OUT[0]));
    DFFSX1HVT DFFS_ADDR_OUT_1 (.CK(addr_update), .D(addr_in_iso[1]), .SN(RESETn_local3), .Q(ADDR_OUT[1]));
    DFFSX1HVT DFFS_ADDR_OUT_2 (.CK(addr_update), .D(addr_in_iso[2]), .SN(RESETn_local3), .Q(ADDR_OUT[2]));
    DFFSX1HVT DFFS_ADDR_OUT_3 (.CK(addr_update), .D(addr_in_iso[3]), .SN(RESETn_local3), .Q(ADDR_OUT[3]));
    DFFRX1HVT DFFR_ADDR_VALID (.CK(addr_update), .D(1'b1),           .RN(RESETn_local3), .Q(ADDR_VALID));

endmodule // lname_mbus_member_ctrl
