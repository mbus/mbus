//*******************************************************************************************
//Author:         Yejoong Kim
//Last Modified:  August 21 2017
//Description:    Netlist for FLPv3L / FLPv3S layer
//Update History: Jul 31 2015   FLPv1L / FLPv2S
//                              - First Commit by Yejoong Kim
//                Apr 30 2016   FLPv2L / FLPv2S / FLPv2LL / FLPv2SL
//                Aug 21 2017   FLPv3L / FLPv3S
//                              - MBus updated to r04p2
//                              - ESD_PAD_TSMC90_rev1
//                              - Removed VREF_EXT pad
//                              - Changes in MBus Register File
//                                  - Following signals are hard-wired (Total 117 bits)
//                                      sram_tsel (2'h1), flsh_hv_mode (2'h0), flsh_mv_mode (2'h0),
//                                      flsh_sscht0 (5'h0F), flsh_sscht1 (5'h0F), flsh_sscht2 (5'h0F),
//                                      flsh_ssch (5'h04), flsh_sscl (5'h07), flsh_vref_ext_en (1'h0),
//                                      str_wr_ch1_wr_buf_lower (16'h0), str_wr_ch1_wr_buf_upper (16'h0),
//                                      str_wr_ch0_wr_buf_lower (16'h0), str_wr_ch0_wr_buf_upper (16'h0),
//                                      blk_wr_cact (1'h0), blk_wr_length_limit (20'h0)
//                                  - Bit-width of the following signals reduced (Total 28 / 36 bits)
//                                      str_wr_ch1_buf_len: 20 bits -> 13 / 11 bits
//                                      str_wr_ch1_buf_off: 20 bits -> 13 / 11 bits
//                                      str_wr_ch0_buf_len: 20 bits -> 13 / 11 bits
//                                      str_wr_ch0_buf_off: 20 bits -> 13 / 11 bits
//                                  - Following registers were moved to Layer Ctrl RF (Total 111 / 95 bits)
//                                      length (13 / 11 bits), irq_en (1 bit), cmd (4 bits), go (1 bit),
//                                      sram_start_addr (13 / 11 bits), flsh_start_addr (18 / 15 bits),
//                                      pp_str_limit (19 / 16 bits), pp_str_en (1 bit),
//                                      pp_length_streamed (19 / 16 bits), pp_flag_end_of_flash (1 bit),
//                                      pp_flag_str_limit (1 bit), pp_flag_copy_limit (1 bit),
//                                      pp_length_copied (19 / 16 bits),
//                                  - Default values of the following flash tuning bits changed
//                                    based on prc_v14/software/MOD_motion_img_v9/MOD_motion_img_v9.c
//                                      flsh_spig: 4'h7 -> 4'hD, flsh_shve: 5'h03 -> 5'h01
//                                  - Some of MBus RF registers were re-arranged.
//                                      SRAM_START_ADDR: 0x08 -> 0x07
//                                      FLSH_START_ADDR: 0x09 -> 0x08
//                                      GO Register    : 0x07 -> 0x09
//******************************************************************************************* 

`include "FLPv3L_def.v"

module FLPv3L
    (
    PAD_CIN,
    PAD_COUT,
    PAD_DIN,
    PAD_DOUT,

    PAD_BOOT_DIS,   // BOOT DISABLE (PULL-DOWN PAD)

    PAD_CLK_EXT,
    PAD_DATA_EXT_0,
    PAD_DATA_EXT_1

    );

    //******************************
    // Top IO & Power
    //******************************
    //VDD_3P6
    //VDD_1P2
    //VDD_0P6
    //VDD_1P2_MBC
    //VDD_1P2_LC
    //VDD_0P6_LC
    //VDD_1P2_FLS
    //VDD_2P5_FLS
    //VREF_COMP
    //VSS

    input       PAD_CIN;
    output      PAD_COUT;
    input       PAD_DIN;
    output      PAD_DOUT;
    
    input       PAD_BOOT_DIS;

    wire        boot_dis;

    input       PAD_CLK_EXT;
    input       PAD_DATA_EXT_0;
    input       PAD_DATA_EXT_1;

    wire        CLK_EXT;
    wire        DATA_EXT_0;
    wire        DATA_EXT_1;
    
    //******************************
    // Internal Wire Declarations
    //******************************

    wire        resetn;
    wire        reset_3p6;

    //Pads
    wire        cin, cout;
    wire        din, dout;
    wire        esd_detect;

    //MBUS
    wire        mbc_sleep;
    wire        mbc_isolate;
    wire        mbc_reset;
    wire        mbc_reset_b;

    wire [31:0] lc2mbc_tx_addr, lc2mbc_tx_addr_uniso;
    wire [31:0] lc2mbc_tx_data, lc2mbc_tx_data_uniso;
    wire        lc2mbc_tx_pend, lc2mbc_tx_pend_uniso;
    wire        lc2mbc_tx_req, lc2mbc_tx_req_uniso;
    wire        lc2mbc_tx_priority, lc2mbc_tx_priority_uniso;
    wire        lc2mbc_tx_resp_ack, lc2mbc_tx_resp_ack_uniso;
    wire        lc2mbc_rx_ack, lc2mbc_rx_ack_uniso;

    wire        mbc2lc_tx_ack;
    wire [31:0] mbc2lc_rx_addr;
    wire [31:0] mbc2lc_rx_data;
    wire        mbc2lc_rx_pend;
    wire        mbc2lc_rx_req;
    wire        mbc2lc_rx_broadcast;
    
    wire        mbc2lc_rx_fail;
    wire        mbc2lc_tx_fail;
    wire        mbc2lc_tx_succ;
    
    wire        lc_sleep, lc_sleep_uniso;
    wire        lc_clken, lc_clkenb_uniso;
    wire        lc_reset, lc_reset_uniso,  lc_reset_b;
    wire        lc_isolate, lc_isolate_uniso;

    wire [3:0]  mbc2mc_addr;
    wire        mc2mbc_valid;
    wire        mbc2mc_write;
    wire        mbc2mc_resetn;
    wire [3:0]  mc2mbc_addr;
    wire        mbc2mc_cout;
    wire        mbc2mc_dout;
    wire        mc2mbc_wakeup_req;
    wire        mbc2mc_clr_wakeup_req;
    wire        mbc2mc_mbus_busy;
    wire        mbc2mc_sleep_req;

    // Layer Controller <--> Flash Module
    wire            lc2fls_mem_req;
    wire            lc2fls_mem_write;
    wire    [31:0]  lc2fls_mem_addr;
    wire    [31:0]  lc2fls_mem_wr_data;
    wire            lc2fls_mem_pend;
    wire            lc2fls_clr_irq;

    wire            fls2lc_mem_ack;
    wire    [31:0]  fls2lc_mem_rd_data;
    wire            fls2lc_irq;
    wire    [3:0]   fls2lc_int_fu_id;
    wire    [95:0]  fls2lc_int_cmd;
    wire    [1:0]   fls2lc_int_cmd_len;

    // Boot Interrupt Request
    wire        boot_wakeup_req;

    // Clocks
    wire        clk_lc;
    wire        clk_comp;

    //---- genRF Beginning of Wire Declaration ----//
    wire [71:0] lc2rf_addr_in;
    wire [23:0] lc2rf_data_in;
    //Register 0x00 (  0)
    wire [ 4:0] tcyc_read;
    wire [ 5:0] t3us;
    wire [ 5:0] t5us;
    wire [ 6:0] t10us;
    //Register 0x01 (  1)
    wire [15:0] tcyc_prog;
    wire [ 7:0] tprog;
    //Register 0x02 (  2)
    wire [15:0] terase;
    //Register 0x03 (  3)
    wire [13:0] thvcp_en;
    wire [ 9:0] tben;
    //Register 0x04 (  4)
    wire [11:0] tmvcp_en;
    wire [11:0] tsc_en;
    //Register 0x05 (  5)
    wire [19:0] tcap;
    //Register 0x06 (  6)
    wire [16:0] tvref;
    //Register 0x07 (  7)
    wire [12:0] sram_start_addr;
    //Register 0x08 (  8)
    wire [17:0] flsh_start_addr;
    //Register 0x09 (  9)
    wire [12:0] length;
    wire        irq_en;
    wire [ 3:0] cmd;
    wire        go;
    //Register 0x0A ( 10)
    wire        vref_sleep;
    wire        comp_sleep;
    wire        comp_clkenb;
    wire        comp_clken; // Inverted Signal of comp_clkenb
    wire        comp_isol;
    //Register 0x0C ( 12)
    wire        wrap_ext;
    wire        update_addr_ext;
    wire [ 1:0] bit_en_ext;
    //Register 0x0D ( 13)
    wire [19:0] timeout_ext;
    //Register 0x0E ( 14)
    wire [12:0] sram_start_addr_ext;
    //Register 0x0F ( 15)
    wire [ 7:0] int_rply_short_addr;
    wire [ 7:0] int_rply_reg_addr;
    //Register 0x10 ( 16)
    wire        boot_flag_sleep;
    wire        boot_flag_ecc_error;
    wire        boot_flag_wrong_header;
    wire        boot_flag_pwdn;
    wire        boot_flag_invalid_cmnd;
    wire        boot_flag_chksum_error;
    wire        boot_flag_success;
    wire [ 1:0] boot_reg_pattern;
    //Register 0x11 ( 17)
    wire        flash_power_do_vrefcomp;
    wire        flash_power_do_flsh;
    wire        flash_power_irq_en;
    wire        flash_power_sel_on;
    wire        flash_power_go;
    //Register 0x12 ( 18)
    wire        irq_pwr_on_wup;
    wire [ 2:0] sel_pwr_on_wup;
    wire        flash_auto_use_custom;
    wire        flash_auto_off;
    wire        flash_auto_on;
    //Register 0x13 ( 19)
    wire [18:0] pp_str_limit;
    wire        pp_str_en;
    //Register 0x14 ( 20)
    wire        pp_no_err_detection;
    wire        pp_use_fast_prog;
    wire        pp_wrap;
    wire [ 1:0] pp_bit_en_ext;
    //Register 0x15 ( 21)
    wire [17:0] pp_flsh_addr;
    //Register 0x16 ( 22)
    wire [18:0] pp_length_streamed;
    //Register 0x17 ( 23)
    wire        pp_flag_end_of_flash;
    wire        pp_flag_str_limit;
    wire        pp_flag_copy_limit;
    wire [18:0] pp_length_copied;
    //Register 0x18 ( 24)
    wire [ 3:0] clk_ring_sel;
    wire [ 1:0] clk_div_sel;
    //Register 0x19 ( 25)
    wire        disable_bypass_mirror;
    wire [ 3:0] comp_ctrl_i_1stg;
    wire [ 3:0] comp_ctrl_i_2stg_bar;
    wire [ 2:0] comp_ctrl_vout;
    //Register 0x1B ( 27)
    wire [ 7:0] irq_payload;
    //Register 0x1E ( 30)
    wire [23:0] fls2lc_reg_wr_data;
    //Register 0x1F ( 31)
    wire        force_resetn;
    //Register 0x20 ( 32)
    wire [ 4:0] flsh_set0;
    wire [ 4:0] flsh_set1;
    wire [ 4:0] flsh_snt;
    //Register 0x21 ( 33)
    wire [ 4:0] flsh_spt0;
    wire [ 4:0] flsh_spt1;
    wire [ 4:0] flsh_spt2;
    //Register 0x22 ( 34)
    wire [ 4:0] flsh_syt0;
    wire [ 4:0] flsh_syt1;
    //Register 0x23 ( 35)
    wire [ 4:0] flsh_srt0;
    wire [ 4:0] flsh_srt1;
    wire [ 4:0] flsh_srt2;
    wire [ 4:0] flsh_srt3;
    //Register 0x24 ( 36)
    wire [ 4:0] flsh_srt4;
    wire [ 4:0] flsh_srt5;
    wire [ 4:0] flsh_srt6;
    //Register 0x26 ( 38)
    wire [ 3:0] flsh_spig;
    wire [ 3:0] flsh_srig;
    wire [ 3:0] flsh_svr0;
    wire [ 3:0] flsh_svr1;
    wire [ 3:0] flsh_svr2;
    //Register 0x27 ( 39)
    wire [ 4:0] flsh_shve;
    wire [ 4:0] flsh_shvp;
    wire [ 4:0] flsh_shvct;
    wire [ 5:0] flsh_smv;
    //Register 0x28 ( 40)
    wire [ 4:0] flsh_smvct0;
    wire [ 4:0] flsh_smvct1;
    //Register 0x2A ( 42)
    wire [ 5:0] flsh_sab;
    //Register 0x30 ( 48)
    wire [ 7:0] str_wr_ch1_alt_addr;
    //Register 0x31 ( 49)
    wire [ 7:0] str_wr_ch1_alt_reg_wr;
    //Register 0x32 ( 50)
    wire        str_wr_ch1_en;
    wire        str_wr_ch1_wrp;
    wire        str_wr_ch1_dblb;
    wire [12:0] str_wr_ch1_buf_len;
    //Register 0x33 ( 51)
    wire [12:0] str_wr_ch1_buf_off;
    //Register 0x34 ( 52)
    wire [ 7:0] str_wr_ch0_alt_addr;
    //Register 0x35 ( 53)
    wire [ 7:0] str_wr_ch0_alt_reg_wr;
    //Register 0x36 ( 54)
    wire        str_wr_ch0_en;
    wire        str_wr_ch0_wrp;
    wire        str_wr_ch0_dblb;
    wire [12:0] str_wr_ch0_buf_len;
    //Register 0x37 ( 55)
    wire [12:0] str_wr_ch0_buf_off;
    //Register 0x3A ( 58)
    wire        blk_wr_en;
    //Register 0x47 ( 71)
    wire        act_rst;
    //---- genRF End of Wire Declaration ----//

    //******************************
    // Pads 
    //******************************
    // Power
    PAD_100x60_DVDD_TP_TP_TSMC90    PAD_VDD_3P6_0       (.DETECT(esd_detect)); // DVDD(VDD_3P6), DVSS(VSS)
    PAD_100x60_VDD_TP_TP_TSMC90     PAD_VDD_1P2_0       (); // DVDD(VDD_3P6), DVSS(VSS), VDD(VDD_1P2)
    PAD_100x60_VDD_TP_TP_TSMC90     PAD_VDD_0P6_0       (); // DVDD(VDD_3P6), DVSS(VSS), VDD(VDD_0P6)
    PAD_100x60_DVSS_TP_TP_TSMC90    PAD_VSS_0           (.DETECT(esd_detect)); // DVDD(VDD_3P6), DVSS(VSS)
    PAD_50x60_VDD_TP_TP_TSMC90      PAD_VDD_CAP_0       (); // DVDD(VDD_3P6), DVSS(VSS), VDD(VDD_0P6)
    
    // MBus
    PAD_50x60_DI_ST_TP_TSMC90       PAD_DIN_CIN_0       (.PAD(PAD_CIN),  .Y(cin) ); // DVDD(VDD_3P6), DVSS(VSS), DIO_VDD(VDD_1P2)
    PAD_50x60_DO_TP_TP_TSMC90       PAD_DOUT_COUT_0     (.PAD(PAD_COUT), .A(cout)); // DVDD(VDD_3P6), DVSS(VSS), DIO_VDD(VDD_1P2)
    PAD_50x60_DI_TP_TP_TSMC90       PAD_DIN_DIN_0       (.PAD(PAD_DIN),  .Y(din) ); // DVDD(VDD_3P6), DVSS(VSS), DIO_VDD(VDD_1P2)
    PAD_50x60_DO_TP_TP_TSMC90       PAD_DOUT_DOUT_0     (.PAD(PAD_DOUT), .A(dout)); // DVDD(VDD_3P6), DVSS(VSS), DIO_VDD(VDD_1P2)

    // External Input
    PAD_50x60_DI_PDST_TP_TSMC90     PAD_DIN_CLK_EXT     (.PAD(PAD_CLK_EXT),    .Y(CLK_EXT)   );// DVDD(VDD_3P6), DVSS(VSS), DIO_VDD(VDD_1P2)
    PAD_50x60_DI_PD_TP_TSMC90       PAD_DIN_DATA_EXT_0  (.PAD(PAD_DATA_EXT_0), .Y(DATA_EXT_0));// DVDD(VDD_3P6), DVSS(VSS), DIO_VDD(VDD_1P2)
    PAD_50x60_DI_PD_TP_TSMC90       PAD_DIN_DATA_EXT_1  (.PAD(PAD_DATA_EXT_1), .Y(DATA_EXT_1));// DVDD(VDD_3P6), DVSS(VSS), DIO_VDD(VDD_1P2)

    // BOOT_DISABLE
    PAD_50x60_DI_PD_TP_TSMC90       PAD_DIN_BOOT_DIS    (.PAD(PAD_BOOT_DIS),   .Y(boot_dis)   );// DVDD(VDD_3P6), DVSS(VSS), DIO_VDD(VDD_1P2)

    // ESD Detector
    DETECTION_TSMC90                DETECTION_0         (.DETECT(esd_detect));  // DVDD(VDD_3P6), DVSS(VSS)

    //******************************
    // Reset Detector (Dual)
    //******************************
    RSTDTCTRG_DUAL_TSMC90 flpv3l_rstdtctrg_dual_0 (
        //Power
        //.VDD_3P6 (VDD_3P6)
        //.VDD_1P2 (VDD_1P2)
        //.VDD_0P6 (VDD_0P6)
        //.VSS     (VSS)
        .RESETn_V1P2    (resetn),
        .RESETn_V3P6    (),
        .RESET_V3P6     (reset_3p6)
        );

    //******************************
    // MBC Power Gate Header
    //******************************
    HEADER_1P2_PH60_TSMC90 flpv3l_header_1p2_mbc_0 (
        //Power
        //.VDD  (VDD_1P2)
        //.VVDD (VDD_1P2_MBC)
        .SLEEP  (mbc_sleep)
        );

    //******************************
    // LC Power Gate Header
    //******************************
    HEADER_1P2_PH60_TSMC90 flpv3l_header_1p2_lc_0 (
        //Power
        //.VDD  (VDD_1P2)
        //.VVDD (VDD_1P2_LC)
        .SLEEP  (lc_sleep)
        );

    HEADER_0P6_PS9_TSMC90 flpv3l_header_0p6_lc_0 (
        //Power
        //.VDD  (VDD_0P6)
        //.VVDD (VDD_0P6_LC)
        .SLEEP  (lc_sleep)
        );

    //******************************
    // Flash Module V1P2 Header
    //******************************
    HEADER_1P2_PH75_TSMC90 flpv3l_header_1p2_fls_0 (
        //Power
        //.VDD  (VDD_1P2)
        //.VVDD (VDD_1P2_FLS)
        .SLEEP  (vref_sleep)
        );

    //******************************
    // Clock Generator
    //******************************
    CLK_GEN_V4_TSMC90 flpv3l_clk_gen_0 (
        //Power
        //.VDD_1P2  (VDD_1P2_LC)
        //.VDD_0P6  (VDD_1P2_LC)
        //.VSS      (VSS)
        //Inputs
        .CLKEN_L    (lc_clken),
        .CLKEN_H    (comp_clken),
        .RESETn     (lc_reset_b),
        .SEL        ({clk_ring_sel[3:0], clk_div_sel[1:0]}),

        //Outputs
        .CLK_L      (clk_lc),
        .CLK_H      (clk_comp)
        );

    //******************************
    // Boot-Up Interrupt Generation
    //******************************
    FLPv3L_BOOT_IRQ_GEN flpv3l_boot_irq_gen_0 (
        //Power
        //.VDD  (VDD_1P2)
        //.VSS  (VSS)
        //Input
        .POR_RN     (resetn),
        .CLR_REQ    (mbc2mc_clr_wakeup_req),
        .BOOT_DIS   (boot_dis),
        
        //Outputs
        .WAKEUP_REQ (boot_wakeup_req)
        );

    //******************************
    // Bus Controller (MBC)
    //******************************
    flpv3l_mbus_node  #(.ADDRESS(`FLPv3L_MBUS_FULL_PREFIX))
    flpv3l_mbus_node_0 (
        //Power
        //.VDD  (VDD_1P2_MBC)
        //.VSS  (VSS)
       .RESETn       (mbc_reset_b),
       .CIN          (cin),
       .DIN          (din),
       .COUT         (mbc2mc_cout),
       .DOUT         (mbc2mc_dout),
       .TX_ADDR      (lc2mbc_tx_addr),
       .TX_DATA      (lc2mbc_tx_data),
       .TX_PEND      (lc2mbc_tx_pend),
       .TX_REQ       (lc2mbc_tx_req),
       .TX_ACK       (mbc2lc_tx_ack),
       .TX_PRIORITY  (lc2mbc_tx_priority),
       .RX_ADDR      (mbc2lc_rx_addr),
       .RX_DATA      (mbc2lc_rx_data),
       .RX_PEND      (mbc2lc_rx_pend),
       .RX_REQ       (mbc2lc_rx_req),
       .RX_ACK       (lc2mbc_rx_ack),
       .RX_BROADCAST (mbc2lc_rx_broadcast),
       .RX_FAIL      (mbc2lc_rx_fail),
       .TX_FAIL      (mbc2lc_tx_fail),
       .TX_SUCC      (mbc2lc_tx_succ),
       .TX_RESP_ACK  (lc2mbc_tx_resp_ack),
       .MBC_IN_FWD   (), // Not used
       .MBC_RESET    (mbc_reset),
       .LRC_SLEEP    (lc_sleep_uniso),
       .LRC_CLKENB   (lc_clkenb_uniso),
       .LRC_RESET    (lc_reset_uniso),
       .LRC_ISOLATE  (lc_isolate_uniso),
       .SLEEP_REQUEST_TO_SLEEP_CTRL(mbc2mc_sleep_req),
       .EXTERNAL_INT (mc2mbc_wakeup_req),
       .CLR_EXT_INT  (mbc2mc_clr_wakeup_req),
       .MBUS_BUSY    (mbc2mc_mbus_busy),
       .ASSIGNED_ADDR_IN       (mc2mbc_addr),
       .ASSIGNED_ADDR_OUT      (mbc2mc_addr),
       .ASSIGNED_ADDR_VALID    (mc2mbc_valid),
       .ASSIGNED_ADDR_WRITE    (mbc2mc_write),
       .ASSIGNED_ADDR_INVALIDn (mbc2mc_resetn)
       );
   
    //******************************
    // MBus Member Control
    //******************************
    flpv3l_mbus_member_ctrl flpv3l_mbus_member_ctrl_0 (
        // Power
        //.VDD  (VDD_1P2)
        //.VSS  (VSS)
        .RESETn         (resetn),
        .CIN            (cin),
        .DIN            (din),
        .COUT_FROM_BUS  (mbc2mc_cout),
        .DOUT_FROM_BUS  (mbc2mc_dout),
        .COUT           (cout),
        .DOUT           (dout),
        .SLEEP_REQ      (mbc2mc_sleep_req),
        .WAKEUP_REQ     (boot_wakeup_req), 
        .MBC_ISOLATE    (mbc_isolate),
        .MBC_ISOLATE_B  (), // Not Used
        .MBC_RESET      (mbc_reset),
        .MBC_RESET_B    (mbc_reset_b),
        .MBC_SLEEP      (mbc_sleep),
        .MBC_SLEEP_B    (), // Not Used
        .CLR_EXT_INT    (mbc2mc_clr_wakeup_req),
        .EXTERNAL_INT   (mc2mbc_wakeup_req), 
        .ADDR_WR_EN     (mbc2mc_write),
        .ADDR_CLR_B     (mbc2mc_resetn),
        .ADDR_IN        (mbc2mc_addr),
        .ADDR_OUT       (mc2mbc_addr),
        .ADDR_VALID     (mc2mbc_valid),
        .LRC_SLEEP      (lc_sleep),
        .MBUS_BUSY      (mbc2mc_mbus_busy)
    );

    //******************************
    // Power-Gated Layer Controller
    //******************************
    flpv3l_layer_ctrl #(.LC_INT_DEPTH(`FLPv3L_LAYERCTRL_INT_DEPTH),
                        .LC_RF_DEPTH (`FLPv3L_MBUS_RF_SIZE)
                        )
    flpv3l_layer_ctrl_0 (
        //Power
        //.VDD  (VDD_1P2_LC)
        //.VSS  (VSS)
        .CLK          (clk_lc),
        .RESETn       (lc_reset_b),
        // Interface with MBus
        .TX_ADDR      (lc2mbc_tx_addr_uniso),
        .TX_DATA      (lc2mbc_tx_data_uniso),
        .TX_PEND      (lc2mbc_tx_pend_uniso),
        .TX_REQ       (lc2mbc_tx_req_uniso),
        .TX_ACK       (mbc2lc_tx_ack),
        .TX_PRIORITY  (lc2mbc_tx_priority_uniso),

        .RX_ADDR      (mbc2lc_rx_addr),
        .RX_DATA      (mbc2lc_rx_data),
        .RX_PEND      (mbc2lc_rx_pend),
        .RX_REQ       (mbc2lc_rx_req),
        .RX_ACK       (lc2mbc_rx_ack_uniso),
        .RX_BROADCAST (mbc2lc_rx_broadcast),

        .RX_FAIL      (mbc2lc_rx_fail),
        .TX_FAIL      (mbc2lc_tx_fail),
        .TX_SUCC      (mbc2lc_tx_succ),
        .TX_RESP_ACK  (lc2mbc_tx_resp_ack_uniso),
        // End of interface
       
        // Interface with Registers
        .REG_RD_DATA(
                //---- genRF Beginning of RF_DATA ----//
                 {
                  //Register 0x47 (71)
                  act_rst,
                  23'h0,
                  //Register 0x46 (70)
                  24'h0,
                  //Register 0x45 (69)
                  24'h0,
                  //Register 0x44 (68)
                  24'h0,
                  //Register 0x43 (67)
                  24'h0,
                  //Register 0x42 (66)
                  24'h0,
                  //Register 0x41 (65)
                  24'h0,
                  //Register 0x40 (64)
                  24'h0,
                  //Register 0x3F (63)
                  24'h0,
                  //Register 0x3E (62)
                  24'h0,
                  //Register 0x3D (61)
                  24'h0,
                  //Register 0x3C (60)
                  24'h0,
                  //Register 0x3B (59)
                  24'h0,
                  //Register 0x3A (58)
                  blk_wr_en,
                  23'h0,
                  //Register 0x39 (57)
                  24'h0,
                  //Register 0x38 (56)
                  24'h0,
                  //Register 0x37 (55)
                  11'h0,
                  str_wr_ch0_buf_off,
                  //Register 0x36 (54)
                  str_wr_ch0_en,
                  str_wr_ch0_wrp,
                  str_wr_ch0_dblb,
                  8'h0,
                  str_wr_ch0_buf_len,
                  //Register 0x35 (53)
                  str_wr_ch0_alt_reg_wr,
                  16'h0,
                  //Register 0x34 (52)
                  str_wr_ch0_alt_addr,
                  16'h0,
                  //Register 0x33 (51)
                  11'h0,
                  str_wr_ch1_buf_off,
                  //Register 0x32 (50)
                  str_wr_ch1_en,
                  str_wr_ch1_wrp,
                  str_wr_ch1_dblb,
                  8'h0,
                  str_wr_ch1_buf_len,
                  //Register 0x31 (49)
                  str_wr_ch1_alt_reg_wr,
                  16'h0,
                  //Register 0x30 (48)
                  str_wr_ch1_alt_addr,
                  16'h0,
                  //Register 0x2F (47)
                  24'h0,
                  //Register 0x2E (46)
                  24'h0,
                  //Register 0x2D (45)
                  24'h0,
                  //Register 0x2C (44)
                  24'h0,
                  //Register 0x2B (43)
                  24'h0,
                  //Register 0x2A (42)
                  18'h0,
                  flsh_sab,
                  //Register 0x29 (41)
                  24'h0,
                  //Register 0x28 (40)
                  14'h0,
                  flsh_smvct0,
                  flsh_smvct1,
                  //Register 0x27 (39)
                  3'h0,
                  flsh_shve,
                  flsh_shvp,
                  flsh_shvct,
                  flsh_smv,
                  //Register 0x26 (38)
                  4'h0,
                  flsh_spig,
                  flsh_srig,
                  flsh_svr0,
                  flsh_svr1,
                  flsh_svr2,
                  //Register 0x25 (37)
                  24'h0,
                  //Register 0x24 (36)
                  9'h0,
                  flsh_srt4,
                  flsh_srt5,
                  flsh_srt6,
                  //Register 0x23 (35)
                  4'h0,
                  flsh_srt0,
                  flsh_srt1,
                  flsh_srt2,
                  flsh_srt3,
                  //Register 0x22 (34)
                  14'h0,
                  flsh_syt0,
                  flsh_syt1,
                  //Register 0x21 (33)
                  9'h0,
                  flsh_spt0,
                  flsh_spt1,
                  flsh_spt2,
                  //Register 0x20 (32)
                  9'h0,
                  flsh_set0,
                  flsh_set1,
                  flsh_snt,
                  //Register 0x1F (31)
                  23'h0,
                  force_resetn,
                  //Register 0x1E (30)
                  fls2lc_reg_wr_data,
                  //Register 0x1D (29)
                  24'h0,
                  //Register 0x1C (28)
                  24'h0,
                  //Register 0x1B (27)
                  16'h0,
                  irq_payload,
                  //Register 0x1A (26)
                  24'h0,
                  //Register 0x19 (25)
                  12'h0,
                  disable_bypass_mirror,
                  comp_ctrl_i_1stg,
                  comp_ctrl_i_2stg_bar,
                  comp_ctrl_vout,
                  //Register 0x18 (24)
                  18'h0,
                  clk_ring_sel,
                  clk_div_sel,
                  //Register 0x17 (23)
                  pp_flag_end_of_flash,
                  pp_flag_str_limit,
                  pp_flag_copy_limit,
                  2'h0,
                  pp_length_copied,
                  //Register 0x16 (22)
                  5'h0,
                  pp_length_streamed,
                  //Register 0x15 (21)
                  6'h0,
                  pp_flsh_addr,
                  //Register 0x14 (20)
                  19'h0,
                  pp_no_err_detection,
                  pp_use_fast_prog,
                  pp_wrap,
                  pp_bit_en_ext,
                  //Register 0x13 (19)
                  4'h0,
                  pp_str_limit,
                  pp_str_en,
                  //Register 0x12 (18)
                  17'h0,
                  irq_pwr_on_wup,
                  sel_pwr_on_wup,
                  flash_auto_use_custom,
                  flash_auto_off,
                  flash_auto_on,
                  //Register 0x11 (17)
                  18'h0,
                  flash_power_do_vrefcomp,
                  1'h0,
                  flash_power_do_flsh,
                  flash_power_irq_en,
                  flash_power_sel_on,
                  flash_power_go,
                  //Register 0x10 (16)
                  1'h0,
                  boot_flag_sleep,
                  boot_flag_ecc_error,
                  boot_flag_wrong_header,
                  boot_flag_pwdn,
                  boot_flag_invalid_cmnd,
                  boot_flag_chksum_error,
                  boot_flag_success,
                  14'h0,
                  boot_reg_pattern,
                  //Register 0x0F (15)
                  8'h0,
                  int_rply_short_addr,
                  int_rply_reg_addr,
                  //Register 0x0E (14)
                  11'h0,
                  sram_start_addr_ext,
                  //Register 0x0D (13)
                  4'h0,
                  timeout_ext,
                  //Register 0x0C (12)
                  20'h0,
                  wrap_ext,
                  update_addr_ext,
                  bit_en_ext,
                  //Register 0x0B (11)
                  24'h0,
                  //Register 0x0A (10)
                  19'h0,
                  vref_sleep,
                  comp_sleep,
                  comp_clkenb,
                  comp_isol,
                  1'h0,
                  //Register 0x09 (9)
                  5'h0,
                  length,
                  irq_en,
                  cmd,
                  go,
                  //Register 0x08 (8)
                  6'h0,
                  flsh_start_addr,
                  //Register 0x07 (7)
                  11'h0,
                  sram_start_addr,
                  //Register 0x06 (6)
                  7'h0,
                  tvref,
                  //Register 0x05 (5)
                  4'h0,
                  tcap,
                  //Register 0x04 (4)
                  tmvcp_en,
                  tsc_en,
                  //Register 0x03 (3)
                  thvcp_en,
                  tben,
                  //Register 0x02 (2)
                  8'h0,
                  terase,
                  //Register 0x01 (1)
                  tcyc_prog,
                  tprog,
                  //Register 0x00 (0)
                  tcyc_read,
                  t3us,
                  t5us,
                  t10us
                 }
                //---- genRF End of RF_DATA ----//
                ),
        .REG_WR_DATA(lc2rf_data_in),
        .REG_WR_EN  (lc2rf_addr_in),
        // End of interface

		// Interface with MEM
		.MEM_REQ_OUT	(lc2fls_mem_req),
		.MEM_WRITE		(lc2fls_mem_write),
		.MEM_ACK_IN		(fls2lc_mem_ack),
		.MEM_PEND		(lc2fls_mem_pend),
		.MEM_WR_DATA	(lc2fls_mem_wr_data),
		.MEM_RD_DATA	(fls2lc_mem_rd_data),
		.MEM_ADDR		(lc2fls_mem_addr[31:2]),
        .PREFIX_ADDR_IN (mc2mbc_addr),
		// End of interface

		// Interrupt
		.INT_VECTOR		(fls2lc_irq),
		.CLR_INT		(lc2fls_clr_irq),
		.INT_FU_ID		(fls2lc_int_fu_id),
		.INT_CMD		(fls2lc_int_cmd),
		.INT_CMD_LEN	(fls2lc_int_cmd_len)
        );

    //******************************
    // MBUS Isolation
    //******************************
    flpv3l_mbus_isolation flpv3l_mbus_isolation_0 (
        //Power
        //.VDD  (VDD_1P2)
        //.VSS  (VSS)
        .MBC_ISOLATE        (mbc_isolate),
        
        // Layer Ctrl --> MBus Ctrl
        .TX_ADDR_uniso      (lc2mbc_tx_addr_uniso),
        .TX_DATA_uniso      (lc2mbc_tx_data_uniso),
        .TX_PEND_uniso      (lc2mbc_tx_pend_uniso),
        .TX_REQ_uniso       (lc2mbc_tx_req_uniso),
        .TX_PRIORITY_uniso  (lc2mbc_tx_priority_uniso),
        .RX_ACK_uniso       (lc2mbc_rx_ack_uniso),
        .TX_RESP_ACK_uniso  (lc2mbc_tx_resp_ack_uniso),

        .TX_ADDR            (lc2mbc_tx_addr),
        .TX_DATA            (lc2mbc_tx_data),
        .TX_PEND            (lc2mbc_tx_pend),
        .TX_REQ             (lc2mbc_tx_req),
        .TX_PRIORITY        (lc2mbc_tx_priority),
        .RX_ACK             (lc2mbc_rx_ack),
        .TX_RESP_ACK        (lc2mbc_tx_resp_ack),

        // MBus Ctrl --> Other
        .LRC_SLEEP_uniso    (lc_sleep_uniso),
        .LRC_CLKENB_uniso   (lc_clkenb_uniso),
        .LRC_RESET_uniso    (lc_reset_uniso),
        .LRC_ISOLATE_uniso  (lc_isolate_uniso),

        .LRC_SLEEP          (lc_sleep),
        .LRC_SLEEPB         (),
        .LRC_CLKENB         (),
        .LRC_CLKEN          (lc_clken),
        .LRC_RESET          (lc_reset),
        .LRC_RESETB         (lc_reset_b),
        .LRC_ISOLATE        (lc_isolate)
        );

    //******************************
    // MBus Register File
    // & Layer Ctrl Register File
    //******************************
    //---- genRF Beginning of Register File ----//
    flpv3l_rf flpv3l_rf_0
       (
        //Power
        //.VDD	(VDD_1P2),
        //.VSS	(VSS),
        //Input
        .RESETn	(resetn),
        .ISOLATE	(lc_isolate),
        .ADDR_IN	(lc2rf_addr_in),
        .DATA_IN	(lc2rf_data_in),
        //Output
        //Register 0x00 (0)
        .Tcyc_read	(tcyc_read),
        .T3us	(t3us),
        .T5us	(t5us),
        .T10us	(t10us),
        //Register 0x01 (1)
        .Tcyc_prog	(tcyc_prog),
        .Tprog	(tprog),
        //Register 0x02 (2)
        .Terase	(terase),
        //Register 0x03 (3)
        .Thvcp_en	(thvcp_en),
        .Tben	(tben),
        //Register 0x04 (4)
        .Tmvcp_en	(tmvcp_en),
        .Tsc_en	(tsc_en),
        //Register 0x05 (5)
        .Tcap	(tcap),
        //Register 0x06 (6)
        .Tvref	(tvref),
        //Register 0x07 (7)
        //.SRAM_START_ADDR	(sram_start_addr),
        //Register 0x08 (8)
        //.FLSH_START_ADDR	(flsh_start_addr),
        //Register 0x09 (9)
        //.LENGTH	(length),
        //.IRQ_EN	(irq_en),
        //.CMD	(cmd),
        //.GO	(go),
        //Register 0x0A (10)
        .VREF_SLEEP	(vref_sleep),
        .COMP_SLEEP	(comp_sleep),
        .COMP_CLKENB	(comp_clkenb),
        .COMP_CLKEN	(comp_clken),
        .COMP_ISOL	(comp_isol),
        //Register 0x0B (11)
        //--- Empty Register
        //Register 0x0C (12)
        .WRAP_EXT	(wrap_ext),
        .UPDATE_ADDR_EXT	(update_addr_ext),
        .BIT_EN_EXT	(bit_en_ext),
        //Register 0x0D (13)
        .TIMEOUT_EXT	(timeout_ext),
        //Register 0x0E (14)
        .SRAM_START_ADDR_EXT	(sram_start_addr_ext),
        //Register 0x0F (15)
        .INT_RPLY_SHORT_ADDR	(int_rply_short_addr),
        .INT_RPLY_REG_ADDR	(int_rply_reg_addr),
        //Register 0x10 (16)
        .BOOT_FLAG_SLEEP	(boot_flag_sleep),
        .BOOT_FLAG_ECC_ERROR	(boot_flag_ecc_error),
        .BOOT_FLAG_WRONG_HEADER	(boot_flag_wrong_header),
        .BOOT_FLAG_PWDN	(boot_flag_pwdn),
        .BOOT_FLAG_INVALID_CMND	(boot_flag_invalid_cmnd),
        .BOOT_FLAG_CHKSUM_ERROR	(boot_flag_chksum_error),
        .BOOT_FLAG_SUCCESS	(boot_flag_success),
        .BOOT_REG_PATTERN	(boot_reg_pattern),
        //Register 0x11 (17)
        .FLASH_POWER_DO_VREFCOMP	(flash_power_do_vrefcomp),
        .FLASH_POWER_DO_FLSH	(flash_power_do_flsh),
        .FLASH_POWER_IRQ_EN	(flash_power_irq_en),
        .FLASH_POWER_SEL_ON	(flash_power_sel_on),
        .FLASH_POWER_GO	(flash_power_go),
        //Register 0x12 (18)
        .IRQ_PWR_ON_WUP	(irq_pwr_on_wup),
        .SEL_PWR_ON_WUP	(sel_pwr_on_wup),
        .FLASH_AUTO_USE_CUSTOM	(flash_auto_use_custom),
        .FLASH_AUTO_OFF	(flash_auto_off),
        .FLASH_AUTO_ON	(flash_auto_on),
        //Register 0x13 (19)
        //.PP_STR_LIMIT	(pp_str_limit),
        //.PP_STR_EN	(pp_str_en),
        //Register 0x14 (20)
        .PP_NO_ERR_DETECTION	(pp_no_err_detection),
        .PP_USE_FAST_PROG	(pp_use_fast_prog),
        .PP_WRAP	(pp_wrap),
        .PP_BIT_EN_EXT	(pp_bit_en_ext),
        //Register 0x15 (21)
        .PP_FLSH_ADDR	(pp_flsh_addr),
        //Register 0x16 (22)
        //.PP_LENGTH_STREAMED	(pp_length_streamed),
        //Register 0x17 (23)
        //.PP_FLAG_END_OF_FLASH	(pp_flag_end_of_flash),
        //.PP_FLAG_STR_LIMIT	(pp_flag_str_limit),
        //.PP_FLAG_COPY_LIMIT	(pp_flag_copy_limit),
        //.PP_LENGTH_COPIED	(pp_length_copied),
        //Register 0x18 (24)
        .CLK_RING_SEL	(clk_ring_sel),
        .CLK_DIV_SEL	(clk_div_sel),
        //Register 0x19 (25)
        .DISABLE_BYPASS_MIRROR	(disable_bypass_mirror),
        .COMP_CTRL_I_1STG	(comp_ctrl_i_1stg),
        .COMP_CTRL_I_2STG_BAR	(comp_ctrl_i_2stg_bar),
        .COMP_CTRL_VOUT	(comp_ctrl_vout),
        //Register 0x1A (26)
        //--- Empty Register
        //Register 0x1B (27)
        //.IRQ_PAYLOAD	(irq_payload),
        //Register 0x1C (28)
        //--- Empty Register
        //Register 0x1D (29)
        //--- Empty Register
        //Register 0x1E (30)
        //.FLS2LC_REG_WR_DATA	(fls2lc_reg_wr_data),
        //Register 0x1F (31)
        .FORCE_RESETN	(force_resetn),
        //Register 0x20 (32)
        .FLSH_SET0	(flsh_set0),
        .FLSH_SET1	(flsh_set1),
        .FLSH_SNT	(flsh_snt),
        //Register 0x21 (33)
        .FLSH_SPT0	(flsh_spt0),
        .FLSH_SPT1	(flsh_spt1),
        .FLSH_SPT2	(flsh_spt2),
        //Register 0x22 (34)
        .FLSH_SYT0	(flsh_syt0),
        .FLSH_SYT1	(flsh_syt1),
        //Register 0x23 (35)
        .FLSH_SRT0	(flsh_srt0),
        .FLSH_SRT1	(flsh_srt1),
        .FLSH_SRT2	(flsh_srt2),
        .FLSH_SRT3	(flsh_srt3),
        //Register 0x24 (36)
        .FLSH_SRT4	(flsh_srt4),
        .FLSH_SRT5	(flsh_srt5),
        .FLSH_SRT6	(flsh_srt6),
        //Register 0x25 (37)
        //--- Empty Register
        //Register 0x26 (38)
        .FLSH_SPIG	(flsh_spig),
        .FLSH_SRIG	(flsh_srig),
        .FLSH_SVR0	(flsh_svr0),
        .FLSH_SVR1	(flsh_svr1),
        .FLSH_SVR2	(flsh_svr2),
        //Register 0x27 (39)
        .FLSH_SHVE	(flsh_shve),
        .FLSH_SHVP	(flsh_shvp),
        .FLSH_SHVCT	(flsh_shvct),
        .FLSH_SMV	(flsh_smv),
        //Register 0x28 (40)
        .FLSH_SMVCT0	(flsh_smvct0),
        .FLSH_SMVCT1	(flsh_smvct1),
        //Register 0x29 (41)
        //--- Empty Register
        //Register 0x2A (42)
        .FLSH_SAB	(flsh_sab),
        //Register 0x2B (43)
        //--- Empty Register
        //Register 0x2C (44)
        //--- Empty Register
        //Register 0x2D (45)
        //--- Empty Register
        //Register 0x2E (46)
        //--- Empty Register
        //Register 0x2F (47)
        //--- Empty Register
        //Register 0x30 (48)
        .STR_WR_CH1_ALT_ADDR	(str_wr_ch1_alt_addr),
        //Register 0x31 (49)
        .STR_WR_CH1_ALT_REG_WR	(str_wr_ch1_alt_reg_wr),
        //Register 0x32 (50)
        .STR_WR_CH1_EN	(str_wr_ch1_en),
        .STR_WR_CH1_WRP	(str_wr_ch1_wrp),
        .STR_WR_CH1_DBLB	(str_wr_ch1_dblb),
        .STR_WR_CH1_BUF_LEN	(str_wr_ch1_buf_len),
        //Register 0x33 (51)
        .STR_WR_CH1_BUF_OFF	(str_wr_ch1_buf_off),
        //Register 0x34 (52)
        .STR_WR_CH0_ALT_ADDR	(str_wr_ch0_alt_addr),
        //Register 0x35 (53)
        .STR_WR_CH0_ALT_REG_WR	(str_wr_ch0_alt_reg_wr),
        //Register 0x36 (54)
        .STR_WR_CH0_EN	(str_wr_ch0_en),
        .STR_WR_CH0_WRP	(str_wr_ch0_wrp),
        .STR_WR_CH0_DBLB	(str_wr_ch0_dblb),
        .STR_WR_CH0_BUF_LEN	(str_wr_ch0_buf_len),
        //Register 0x37 (55)
        .STR_WR_CH0_BUF_OFF	(str_wr_ch0_buf_off),
        //Register 0x38 (56)
        //--- Empty Register
        //Register 0x39 (57)
        //--- Empty Register
        //Register 0x3A (58)
        .BLK_WR_EN	(blk_wr_en),
        //Register 0x3B (59)
        //--- Empty Register
        //Register 0x3C (60)
        //--- Empty Register
        //Register 0x3D (61)
        //--- Empty Register
        //Register 0x3E (62)
        //--- Empty Register
        //Register 0x3F (63)
        //--- Empty Register
        //Register 0x40 (64)
        //--- Empty Register
        //Register 0x41 (65)
        //--- Empty Register
        //Register 0x42 (66)
        //--- Empty Register
        //Register 0x43 (67)
        //--- Empty Register
        //Register 0x44 (68)
        //--- Empty Register
        //Register 0x45 (69)
        //--- Empty Register
        //Register 0x46 (70)
        //--- Empty Register
        //Register 0x47 (71)
        .ACT_RST	(act_rst)
       );

    flpv3l_layer_ctrl_rf flpv3l_layer_ctrl_rf_0
       (
        //Power
        //.VDD	(VDD_*_LC),
        //.VSS	(VSS),
        //Input
        .RESETn	(lc_reset_b),
        .ADDR_IN	(lc2rf_addr_in),
        .DATA_IN	(lc2rf_data_in),
        //Output
        //Register 0x07 (7)
        .SRAM_START_ADDR	(sram_start_addr),
        //Register 0x08 (8)
        .FLSH_START_ADDR	(flsh_start_addr),
        //Register 0x09 (9)
        .LENGTH	(length),
        .IRQ_EN	(irq_en),
        .CMD	(cmd),
        .GO	(go),
        //Register 0x13 (19)
        .PP_STR_LIMIT	(pp_str_limit),
        .PP_STR_EN	(pp_str_en),
        //Register 0x16 (22)
        .PP_LENGTH_STREAMED	(pp_length_streamed),
        //Register 0x17 (23)
        .PP_FLAG_END_OF_FLASH	(pp_flag_end_of_flash),
        .PP_FLAG_STR_LIMIT	(pp_flag_str_limit),
        .PP_FLAG_COPY_LIMIT	(pp_flag_copy_limit),
        .PP_LENGTH_COPIED	(pp_length_copied)
       );
    //---- genRF End of Register File ----//

    //******************************
    // Flash Controller
    //******************************
    FLPv3L_CTRL flpv3l_ctrl_0 (
        //Power
        //.VDD  (VDD_1P2_LC)
        //.VSS  (VSS)

        //Flash Power
        //.VDD_CORE (VDD_1P2_FLS)
        //.VDD_IO   (VDD_2P5_FLS)
        //.VSS      (VSS)
        //.VREF_OUT (VREF_COMP)

        //Inputs
        //Globals
        .CLK                (clk_lc),
        .RESETn             (lc_reset_b),
        .FORCE_RESETn       (force_resetn),
        //Boot Register
        .DISABLE_BOOT       (boot_dis),
        .BOOT_REG_PATTERN   (boot_reg_pattern),
        .INT_RPLY_SHORT_ADDR(int_rply_short_addr),
        .INT_RPLY_REG_ADDR  (int_rply_reg_addr),
        //Power Configuration
        .SEL_PWR_ON_WUP     (sel_pwr_on_wup),
        .IRQ_PWR_ON_WUP     (irq_pwr_on_wup),
        .FLASH_PWR_DO_VREFCOMP (flash_power_do_vrefcomp),
        .FLASH_PWR_DO_FLSH  (flash_power_do_flsh),
        .FLASH_PWR_IRQ_EN   (flash_power_irq_en),
        .FLASH_PWR_SEL_ON   (flash_power_sel_on),
        .FLASH_PWR_GO       (flash_power_go),
        .FLASH_AUTO_USE_CUSTOM      (flash_auto_use_custom),
        .FLASH_AUTO_ON      (flash_auto_on),
        .FLASH_AUTO_OFF     (flash_auto_off),
        .REG_COMP           ({19'b0, vref_sleep, comp_sleep, comp_clkenb, comp_isol, 1'b0}),
        .REG_VCTUNE         ({12'b0, disable_bypass_mirror, comp_ctrl_i_1stg, comp_ctrl_i_2stg_bar, comp_ctrl_vout}),
        //Ping-Pong Streaming
        .PP_STR_EN          (pp_str_en),
        .PP_NO_ERR_DETECTION(pp_no_err_detection),
        .PP_WRAP            (pp_wrap),
        .PP_USE_FAST_PROG   (pp_use_fast_prog),
        .PP_FLSH_ADDR       (pp_flsh_addr),
        .PP_STR_LIMIT       (pp_str_limit),
        .PP_BIT_EN_EXT      (pp_bit_en_ext),
        //Layer Controller
        .LC_MEM_REQ         (lc2fls_mem_req),
        .LC_MEM_WRITE       (lc2fls_mem_write),
        .LC_MEM_ADDR        (lc2fls_mem_addr[31:2]),
        .LC_MEM_WR_DATA     (lc2fls_mem_wr_data),
        .LC_MEM_PEND        (lc2fls_mem_pend),
        .LC_RX_ADDR         (mbc2lc_rx_addr), // NOTE: This is NOT synced with clk_lc. Be careful to use this.
        .LC_CLR_IRQ         (lc2fls_clr_irq),
        //Timing Config
        .T3us               (t3us),
        .T5us               (t5us),
        .T10us              (t10us),
        .Tben               (tben),
        .Thvcp_en           (thvcp_en),
        .Tmvcp_en           (tmvcp_en),
        .Tsc_en             (tsc_en),
        .Tprog              (tprog),
        .Terase             (terase),
        .Tcap               (tcap),
        .Tcyc_prog          (tcyc_prog),
        .Tcyc_read          (tcyc_read),
        .Tvref              (tvref),
        //External
        .CLK_EXT            (CLK_EXT),
        .DATA_EXT           ({DATA_EXT_1,DATA_EXT_0}),
        .BIT_EN_EXT         (bit_en_ext),
        .WRAP_EXT           (wrap_ext),
        .UPDATE_ADDR_EXT    (update_addr_ext),
        .TIMEOUT_EXT        (timeout_ext),
        .SRAM_START_ADDR_EXT(sram_start_addr_ext),
        //FSM
        .GO                 (go),
        .CMD                (cmd),
        .LENGTH             (length),
        .IRQ_EN             (irq_en),
        .SRAM_START_ADDR    (sram_start_addr),
        .FLSH_START_ADDR    (flsh_start_addr),
        //Flash Tuning Bits
        .FLSH_SET0          (flsh_set0),
        .FLSH_SET1          (flsh_set1),
        .FLSH_SNT           (flsh_snt),
        .FLSH_SPT0          (flsh_spt0),
        .FLSH_SPT1          (flsh_spt1),
        .FLSH_SPT2          (flsh_spt2),
        .FLSH_SYT0          (flsh_syt0),
        .FLSH_SYT1          (flsh_syt1),
        .FLSH_SRT0          (flsh_srt0),
        .FLSH_SRT1          (flsh_srt1),
        .FLSH_SRT2          (flsh_srt2),
        .FLSH_SRT3          (flsh_srt3),
        .FLSH_SRT4          (flsh_srt4),
        .FLSH_SRT5          (flsh_srt5),
        .FLSH_SRT6          (flsh_srt6),
        .FLSH_SPIG          (flsh_spig),
        .FLSH_SRIG          (flsh_srig),
        .FLSH_SVR0          (flsh_svr0),
        .FLSH_SVR1          (flsh_svr1),
        .FLSH_SVR2          (flsh_svr2),
        .FLSH_SHVE          (flsh_shve),
        .FLSH_SHVP          (flsh_shvp),
        .FLSH_SHVCT         (flsh_shvct),
        .FLSH_SMV           (flsh_smv),
        .FLSH_SMVCT0        (flsh_smvct0),
        .FLSH_SMVCT1        (flsh_smvct1),
        .FLSH_SAB           (flsh_sab),

        //Outputs
        //Layer Controller
        .LC_MEM_ACK_OUT     (fls2lc_mem_ack),
        .LC_MEM_RD_DATA     (fls2lc_mem_rd_data),
        .LC_IRQ             (fls2lc_irq),
        .LC_INT_FU_ID       (fls2lc_int_fu_id),
        .LC_INT_CMD         (fls2lc_int_cmd),
        .LC_INT_CMD_LEN     (fls2lc_int_cmd_len),
        .LC_IRQ_PAYLOAD     (irq_payload),
        .LC_REG_WR_DATA     (fls2lc_reg_wr_data)
        );

    //******************************
    // Voltage & Current Limiter 
    //******************************
    VCLAMP_FLP_TSMC90 flpv3l_vclamp_0 (
        //Power
        //.VDD_3P6  (VDD_3P6)
        //.VDD_1P2  (VDD_1P2)
        //.CAP      (VDD_2P5_FLS)
        //.VSS      (VSS)
        //.VREF     (VREF_COMP)

        //Inputs
        .CLK                    (clk_comp),
        .ISOL                   (comp_isol),
        .ISOL_VDD_3P6           (reset_3p6),
        .DISABLE_BYPASS_MIRROR  (disable_bypass_mirror),
        .SLEEP                  (comp_sleep),
        .CTRL_I_1STG            (comp_ctrl_i_1stg),
        .CTRL_I_2STG_BAR        (comp_ctrl_i_2stg_bar),
        .CTRL_VOUT              (comp_ctrl_vout)
    );

endmodule // FLPv3L
