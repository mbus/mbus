//*******************************************************************************************
//Author:         Yejoong Kim
//Last Modified:  Jul 26 2017
//Description:    MBus Member Controller
//                Structural verilog netlist using sc_x_hvt_tsmc90
//Update History: Jul 26 2017 - First added in MBus r04p2
//******************************************************************************************* 

module flpv3l_mbus_member_ctrl (
    input      RESETn,

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
    wire addr_clr_b_iso;
    wire [3:0] addr_in_iso;
    wire RESETn_local3;
    wire addr_update;


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
    INVX1HVT_TSMC90  INV_cin_b   (.Y(cin_b), .A(CIN));
    INVX2HVT_TSMC90  INV_cin_buf (.Y(cin_buf), .A(cin_b));


//****************************************************************************
// SLEEP CONTROLLER
//****************************************************************************

    //assign MBC_SLEEP_B   = ~MBC_SLEEP;
    INVX1HVT_TSMC90 INV_mbc_sleep_b_int (.Y(mbc_sleep_b_int), .A(mbc_sleep_int));
    INVX8HVT_TSMC90 INV_MBC_SLEEP       (.Y(MBC_SLEEP),       .A(mbc_sleep_b_int));
    INVX8HVT_TSMC90 INV_MBC_SLEEP_B     (.Y(MBC_SLEEP_B),     .A(mbc_sleep_int));
    
    //assign MBC_ISOLATE_B = ~MBC_ISOLATE;
    INVX1HVT_TSMC90 INV_mbc_isolate_b_int (.Y(mbc_isolate_b_int), .A(mbc_isolate_int));
    INVX8HVT_TSMC90 INV_MBC_ISOLATE       (.Y(MBC_ISOLATE),       .A(mbc_isolate_b_int));
    INVX8HVT_TSMC90 INV_MBC_ISOLATE_B     (.Y(MBC_ISOLATE_B),     .A(mbc_isolate_int));

    //assign MBC_RESET_B   = ~MBC_RESET;
    INVX1HVT_TSMC90 INV_mbc_reset_b_int (.Y(mbc_reset_b_int), .A(mbc_reset_int));
    INVX8HVT_TSMC90 INV_MBC_RESET       (.Y(MBC_RESET),       .A(mbc_reset_b_int));
    INVX8HVT_TSMC90 INV_MBC_RESET_B     (.Y(MBC_RESET_B),     .A(mbc_reset_int));

    //assign next_mbc_isolate = goingsleep | sleep_req_isol | MBC_SLEEP;
    INVX1HVT_TSMC90  INV_next_mbc_isolate    (.Y(next_mbc_isolate), .A(next_mbc_isolate_b));
    NOR3X1HVT_TSMC90 NOR3_next_mbc_isolate_b (.C(goingsleep), .B(sleep_req_isol), .A(mbc_sleep_int), .Y(next_mbc_isolate_b));
    
    //assign sleep_req_isol  = SLEEP_REQ & MBC_ISOLATE_B;
    INVX1HVT_TSMC90   INV_next_goingsleep      (.Y(sleep_req_isol), .A(sleep_req_b_isol));
    NAND2X1HVT_TSMC90 NAND2_next_goingsleep_b  (.Y(sleep_req_b_isol), .A(SLEEP_REQ), .B(mbc_isolate_b_int));

    // goingsleep, mbc_sleep_int, mbc_isolate_int, mbc_reset_int
    DFFRNSNX1HVT_TSMC90 DFFSR_mbc_isolate_int (.SN(RESETn), .RN(1'b1),   .CLK(cin_buf), .Q(mbc_isolate_int), .QN(), .D(next_mbc_isolate));
    DFFRNSNX1HVT_TSMC90 DFFSR_mbc_sleep_int   (.SN(RESETn), .RN(1'b1),   .CLK(cin_buf), .Q(mbc_sleep_int),   .QN(), .D(goingsleep));
    DFFRNSNX1HVT_TSMC90 DFFSR_goingsleep      (.SN(1'b1),   .RN(RESETn), .CLK(cin_buf), .Q(goingsleep),      .QN(), .D(sleep_req_isol));
    DFFRNSNX1HVT_TSMC90 DFFSR_mbc_reset_int   (.SN(RESETn), .RN(1'b1),   .CLK(cin_b),   .Q(mbc_reset_int),   .QN(), .D(mbc_isolate_int));

    
//****************************************************************************
// INTERRUPT CONTROLLER
//****************************************************************************

    //wire clr_ext_int_b = ~(MBC_ISOLATE_B & CLR_EXT_INT);
    AND2X1HVT_TSMC90 AND2_clr_ext_int_iso (.Y(clr_ext_int_iso), .A(MBC_ISOLATE_B), .B(CLR_EXT_INT));
    INVX1HVT_TSMC90  INV_clr_ext_int_b    (.Y(clr_ext_int_b),   .A(clr_ext_int_iso));

    //wire RESETn_local = RESETn & CIN;
    AND2X1HVT_TSMC90 AND2_RESETn_local (.Y(RESETn_local), .A(CIN), .B(RESETn));

    //wire RESETn_local2 = RESETn & clr_ext_int_b;
    AND2X1HVT_TSMC90 AND2_RESETn_local2 (.Y(RESETn_local2), .A(clr_ext_int_b), .B(RESETn));

    //wire mbus_busy_b_isol = ~(MBUS_BUSY & MBC_RESET_B);
    NAND2X1HVT_TSMC90 NAND2_mbus_busy_b_isol (.A(MBUS_BUSY), .B(mbc_reset_b_int), .Y(mbus_busy_b_isol));

    //wire int_busy = (WAKEUP_REQ & mbus_busy_b_isol & LRC_SLEEP)
    NAND3X1HVT_TSMC90 NAND3_int_busy_b (.A(WAKEUP_REQ), .B(mbus_busy_b_isol), .C(LRC_SLEEP), .Y(int_busy_b));
    INVX2HVT_TSMC90   INV_int_busy     (.Y(int_busy), .A(int_busy_b));

    // ext_int_dout
    DFFRNX1HVT_TSMC90 DFFR_ext_int_dout (.RN(RESETn_local), .CLK(int_busy), .Q(ext_int_dout), .QN(), .D(1'b1));

    // EXTERNAL_INT
    DFFRNX1HVT_TSMC90 DFFR_EXTERNAL_INT (.RN(RESETn_local2), .CLK(int_busy), .Q(EXTERNAL_INT), .QN(), .D(1'b1));


//****************************************************************************
// WIRE CONTROLLER
//****************************************************************************

    // COUT
    OR2X1HVT_TSMC90  OR2_cout_from_bus_iso (.Y(cout_from_bus_iso), .A(COUT_FROM_BUS), .B(MBC_ISOLATE));
    MUX2X1HVT_TSMC90 MUX2_cout_int         (.S0(MBC_ISOLATE), .A(cout_from_bus_iso), .Y(cout_int), .B(CIN));
    MUX2X1HVT_TSMC90 MUX2_cout_unbuf       (.S0(RESETn), .A(1'b1), .Y(cout_unbuf), .B(cout_int));
    BUFX4HVT_TSMC90  BUF_COUT              (.A(cout_unbuf), .Y(COUT));

    // DOUT
    OR2X1HVT_TSMC90  OR2_dout_from_bus_iso (.Y(dout_from_bus_iso), .A(DOUT_FROM_BUS), .B(MBC_ISOLATE));
    MUX2X1HVT_TSMC90 MUX2_dout_int_1       (.S0(MBC_ISOLATE), .A(dout_from_bus_iso), .Y(dout_int_1),    .B(DIN));
    MUX2X1HVT_TSMC90 MUX2_dout_int_0       (.S0(ext_int_dout), .A(dout_int_1), .Y(dout_int_0), .B(1'b0));
    MUX2X1HVT_TSMC90 MUX2_dout_unbuf       (.S0(RESETn), .A(1'b1), .Y(dout_unbuf), .B(dout_int_0));
    BUFX4HVT_TSMC90  BUF_DOUT              (.A(dout_unbuf), .Y(DOUT));


//****************************************************************************
// SHORT-PREFIX ADDRESS REGISTER
//****************************************************************************

    // Isolation
    OR2X1HVT_TSMC90  AND2_addr_clr_b_iso (.A(MBC_ISOLATE),   .B(ADDR_CLR_B),  .Y(addr_clr_b_iso));
    AND2X1HVT_TSMC90 AND2_addr_in_iso_0  (.A(MBC_ISOLATE_B), .B(ADDR_IN[0]), .Y(addr_in_iso[0]));
    AND2X1HVT_TSMC90 AND2_addr_in_iso_1  (.A(MBC_ISOLATE_B), .B(ADDR_IN[1]), .Y(addr_in_iso[1]));
    AND2X1HVT_TSMC90 AND2_addr_in_iso_2  (.A(MBC_ISOLATE_B), .B(ADDR_IN[2]), .Y(addr_in_iso[2]));
    AND2X1HVT_TSMC90 AND2_addr_in_iso_3  (.A(MBC_ISOLATE_B), .B(ADDR_IN[3]), .Y(addr_in_iso[3]));
    
    //wire    RESETn_local3 = (RESETn & ADDR_CLR_B); 
    AND2X1HVT_TSMC90 AND2_RESETn_local3 (.A(RESETn),      .B(addr_clr_b_iso), .Y(RESETn_local3));

    //wire    addr_update = (ADDR_WR_EN & (~MBC_ISOLATE));
    AND2X1HVT_TSMC90 AND2_addr_update (.A(MBC_ISOLATE_B), .B(ADDR_WR_EN), .Y(addr_update));
    
    // ADDR_OUT, ADDR_VALID
    DFFSNX1HVT_TSMC90 DFFS_ADDR_OUT_0 (.CLK(addr_update), .D(addr_in_iso[0]), .SN(RESETn_local3), .Q(ADDR_OUT[0]), .QN());
    DFFSNX1HVT_TSMC90 DFFS_ADDR_OUT_1 (.CLK(addr_update), .D(addr_in_iso[1]), .SN(RESETn_local3), .Q(ADDR_OUT[1]), .QN());
    DFFSNX1HVT_TSMC90 DFFS_ADDR_OUT_2 (.CLK(addr_update), .D(addr_in_iso[2]), .SN(RESETn_local3), .Q(ADDR_OUT[2]), .QN());
    DFFSNX1HVT_TSMC90 DFFS_ADDR_OUT_3 (.CLK(addr_update), .D(addr_in_iso[3]), .SN(RESETn_local3), .Q(ADDR_OUT[3]), .QN());
    DFFRNX1HVT_TSMC90 DFFR_ADDR_VALID (.CLK(addr_update), .D(1'b1),           .RN(RESETn_local3), .Q(ADDR_VALID),  .QN());

endmodule // flpv3l_mbus_member_ctrl
