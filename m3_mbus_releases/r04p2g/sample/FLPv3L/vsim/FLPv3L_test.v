//*******************************************************************************************
//Author:         Yejoong Kim
//Last Modified:  Aug 23 2017
//Description:    Testbench for FLPv3L/S
//Update History: Aug 23 2017 - First Commit by Yejoong
//******************************************************************************************* 
`timescale 1ns/1ps
`include "FLPv3L_test_def.v"

module FLPv3L_test();

    reg RESETn;
    reg check;
    reg [31:0]  sram_mem[`TB_SRAM_NUM_WORDS-1:0];
    reg [31:0]  flsh_mem[`TB_FLASH_NUM_WORD-1:0];

    // MBus Wires
    wire        MBUS_CLK_M2FLS;
    wire        MBUS_CLK_FLS2A;
    wire        MBUS_CLK_A2M;
    wire        MBUS_DATA_M2FLS;
    wire        MBUS_DATA_FLS2A;
    wire        MBUS_DATA_A2M;

    // Flash Layer
    reg         FLS_PAD_CLK_EXT;
    reg         FLS_PAD_DATA_EXT_0;
    reg         FLS_PAD_DATA_EXT_1;

    // NODE_M (Master Node)
    reg         CLK_MBC;
    wire        MBC_CLKENB;
    reg [31:0]  N_M_TX_ADDR;
    reg [31:0]  N_M_TX_DATA;
    reg         N_M_TX_PEND;
    reg         N_M_TX_REQ;
    reg         N_M_TX_PRIORITY;
    wire        N_M_TX_ACK; 
    wire [31:0] N_M_RX_ADDR; 
    wire [31:0] N_M_RX_DATA; 
    wire        N_M_RX_REQ; 
    reg         N_M_RX_ACK; 
    wire        N_M_RX_BROADCAST;
    wire        N_M_RX_FAIL;
    wire        N_M_RX_PEND; 
    wire        N_M_TX_FAIL; 
    wire        N_M_TX_SUCC; 
    reg         N_M_TX_RESP_ACK;
    wire        N_M_LRC_SLEEP;
    wire        N_M_LRC_CLKENB;
    wire        N_M_LRC_RESET;
    wire        N_M_LRC_ISOLATE;
    reg         N_M_WAKEUP_REQ;
    reg [19:0]  N_M_NUM_BITS_THRESHOLD;
    wire        N_M_MBC_IN_FWD;

    // NODE_A (Member Node)
    reg [31:0]  N_A_TX_ADDR;
    reg [31:0]  N_A_TX_DATA;
    reg         N_A_TX_PEND;
    reg         N_A_TX_REQ;
    reg         N_A_TX_PRIORITY;
    wire        N_A_TX_ACK; 
    wire [31:0] N_A_RX_ADDR; 
    wire [31:0] N_A_RX_DATA; 
    wire        N_A_RX_REQ; 
    reg         N_A_RX_ACK; 
    wire        N_A_RX_BROADCAST;
    wire        N_A_RX_FAIL;
    wire        N_A_RX_PEND; 
    wire        N_A_TX_FAIL; 
    wire        N_A_TX_SUCC; 
    reg         N_A_TX_RESP_ACK;
    wire        N_A_LRC_SLEEP;
    wire        N_A_LRC_CLKENB;
    wire        N_A_LRC_RESET;
    wire        N_A_LRC_ISOLATE;
    reg         N_A_WAKEUP_REQ;
    wire [3:0]  N_A_PREFIX_ADDR_OUT;

    //****************************************************
    // MODULE INSTANTIATIONS
    //****************************************************
    mbus_master_wrapper_testbench N_M 
    (
        .CLK_MBC        (CLK_MBC),
        .MBC_CLKENB     (MBC_CLKENB),
        .RESETn         (RESETn), 
        .CIN            (MBUS_CLK_A2M), 
        .DIN            (MBUS_DATA_A2M), 
        .COUT           (MBUS_CLK_M2FLS),
        .DOUT           (MBUS_DATA_M2FLS), 
        .TX_ADDR        (N_M_TX_ADDR), 
        .TX_DATA        (N_M_TX_DATA), 
        .TX_PEND        (N_M_TX_PEND), 
        .TX_REQ         (N_M_TX_REQ), 
        .TX_PRIORITY    (N_M_TX_PRIORITY),
        .TX_ACK         (N_M_TX_ACK), 
        .RX_ADDR        (N_M_RX_ADDR), 
        .RX_DATA        (N_M_RX_DATA), 
        .RX_REQ         (N_M_RX_REQ), 
        .RX_ACK         (N_M_RX_ACK), 
        .RX_BROADCAST   (N_M_RX_BROADCAST),
        .RX_FAIL        (N_M_RX_FAIL),
        .RX_PEND        (N_M_RX_PEND), 
        .TX_FAIL        (N_M_TX_FAIL), 
        .TX_SUCC        (N_M_TX_SUCC), 
        .TX_RESP_ACK    (N_M_TX_RESP_ACK),
        .LRC_SLEEP      (N_M_LRC_SLEEP),
        .LRC_CLKENB     (N_M_LRC_CLKENB),
        .LRC_RESET      (N_M_LRC_RESET),
        .LRC_ISOLATE    (N_M_LRC_ISOLATE),
        .WAKEUP_REQ     (N_M_WAKEUP_REQ),
        .NUM_BITS_THRESHOLD(N_M_NUM_BITS_THRESHOLD),
        .MBC_IN_FWD     (N_M_MBC_IN_FWD)
    );

    `TB_MODULE_NAME `TB_INSTNAME 
    (
        .PAD_CIN        (MBUS_CLK_M2FLS), 
        .PAD_DIN        (MBUS_DATA_M2FLS), 
        .PAD_COUT       (MBUS_CLK_FLS2A),
        .PAD_DOUT       (MBUS_DATA_FLS2A), 
        .PAD_BOOT_DIS   (`FLS_AUTO_BOOT_DISABLE),
        .PAD_CLK_EXT    (FLS_PAD_CLK_EXT),
        .PAD_DATA_EXT_0 (FLS_PAD_DATA_EXT_0),
        .PAD_DATA_EXT_1 (FLS_PAD_DATA_EXT_1)
    );

    mbus_member_wrapper_testbench #(.ADDRESS(20'h0000A)) N_A 
    (
        .RESETn         (RESETn), 
        .CIN            (MBUS_CLK_FLS2A), 
        .DIN            (MBUS_DATA_FLS2A), 
        .COUT           (MBUS_CLK_A2M),
        .DOUT           (MBUS_DATA_A2M), 
        .TX_ADDR        (N_A_TX_ADDR), 
        .TX_DATA        (N_A_TX_DATA), 
        .TX_PEND        (N_A_TX_PEND), 
        .TX_REQ         (N_A_TX_REQ), 
        .TX_PRIORITY    (N_A_TX_PRIORITY),
        .TX_ACK         (N_A_TX_ACK), 
        .RX_ADDR        (N_A_RX_ADDR), 
        .RX_DATA        (N_A_RX_DATA), 
        .RX_REQ         (N_A_RX_REQ), 
        .RX_ACK         (N_A_RX_ACK), 
        .RX_BROADCAST   (N_A_RX_BROADCAST),
        .RX_FAIL        (N_A_RX_FAIL),
        .RX_PEND        (N_A_RX_PEND), 
        .TX_FAIL        (N_A_TX_FAIL),
        .TX_SUCC        (N_A_TX_SUCC), 
        .TX_RESP_ACK    (N_A_TX_RESP_ACK),
        .LRC_SLEEP      (N_A_LRC_SLEEP),
        .LRC_CLKENB     (N_A_LRC_CLKENB),
        .LRC_RESET      (N_A_LRC_RESET),
        .LRC_ISOLATE    (N_A_LRC_ISOLATE),
        .WAKEUP_REQ     (N_A_WAKEUP_REQ),
        .PREFIX_ADDR_OUT(N_A_PREFIX_ADDR_OUT)
    );

    //****************************************************
    // RESETS
    //****************************************************
    initial begin
        RESETn      <= 1'b0;
        check       <= 1'b0;
        `RESET_TIME;
        RESETn      <= 1'b1;
        #10;
        check       <= 1'b1;
    end
   
    //****************************************************
    // CLOCKS
    //****************************************************
    // MBUS runs at 400KHz
    always @ (RESETn or MBC_CLKENB or CLK_MBC) begin
        if (~RESETn | MBC_CLKENB) 
            CLK_MBC <= `TEST_SD 1'b0;
        else begin
            `MBUS_HALF_PERIOD;
            CLK_MBC <= `TEST_SD ~CLK_MBC;
        end
    end

    //****************************************************
    // TEST HARNESS
    //****************************************************
    initial begin
        // Node M (Master Node)
        N_M_TX_ADDR         <= 32'b0;
        N_M_TX_DATA         <= 32'b0;
        N_M_TX_PEND         <= 1'b0;
        N_M_TX_REQ          <= 1'b0;
        N_M_TX_PRIORITY     <= 1'b0;
        N_M_TX_RESP_ACK     <= 1'b0;
        N_M_WAKEUP_REQ      <= 1'b0;
        N_M_NUM_BITS_THRESHOLD   <= `MBUS_THRESHOLD;
        // Node A (Member Node)
        N_A_TX_ADDR         <= 32'b0;
        N_A_TX_DATA         <= 32'b0;
        N_A_TX_PEND         <= 1'b0;
        N_A_TX_REQ          <= 1'b0;
        N_A_TX_PRIORITY     <= 1'b0;
        N_A_TX_RESP_ACK     <= 1'b0;
        N_A_WAKEUP_REQ      <= 1'b0;
    end

    // Always Acknowledge RX_REQ
    always @ (posedge MBUS_CLK_FLS2A or negedge RESETn) begin
        if (~RESETn) N_A_RX_ACK <= `TEST_SD 1'b0;
        else         N_A_RX_ACK <= `TEST_SD N_A_RX_REQ;
    end
    always @ (posedge CLK_MBC or negedge RESETn) begin
        if (~RESETn) N_M_RX_ACK <= `TEST_SD 1'b0;
        else         N_M_RX_ACK <= `TEST_SD N_M_RX_REQ;
    end

    //****************************************************
    // FLASH EXTERNAL STREAMING
    //****************************************************
    reg [31:0]  k;
    wire [31:0] ext_num_words;
    reg         CLK_EXT_int;
    reg         CLK_EXT_release;
    reg         CLK_EXT_release_synch;
    reg [1:0]   data_width_2 [`TB_FLASH_NUM_WORD2-1:0];

    assign ext_num_words = k >> 4;

    initial begin
        k = 0;
        CLK_EXT_int             = 1'b0;
        CLK_EXT_release         = 1'b0;
        CLK_EXT_release_synch   = 1'b0;
        FLS_PAD_DATA_EXT_1      = 1'b0;
        FLS_PAD_DATA_EXT_0      = 1'b0;
    end

    always begin
        `FLS_EXT_HALF_PERIOD_EQ CLK_EXT_int = ~CLK_EXT_int;
    end

    always @(negedge CLK_EXT_int) begin
        CLK_EXT_release_synch = CLK_EXT_release;
    end

    assign FLS_PAD_CLK_EXT = CLK_EXT_release_synch ? CLK_EXT_int: 1'b1;

    always @(negedge FLS_PAD_CLK_EXT) begin
        FLS_PAD_DATA_EXT_1 = `TEST_SD data_width_2[k][1];
        FLS_PAD_DATA_EXT_0 = `TEST_SD data_width_2[k][0];
        if (~CLK_EXT_release_synch) k = 0;
        else k = k + 1;
    end

    always @ (ext_num_words[10]) begin // every 2048 words = 4kB
        if (CLK_EXT_release_synch) begin
            $write ("*** Time %0dns: EXT STREAMING (%0d words)\n", $time, ext_num_words);
        end
    end

    //****************************************************
    // MEMORY INITIAL VALUES
    //****************************************************
    integer idx_mem;
    initial begin
        #100;
        `ifdef FLS_INITIALIZE_FLASH
            $readmemh(`FLS_INITIAL_DATA, `TB_INSTNAME.`TB_CTRL_NAME.Flash_0.main_mem);
        `elsif
            for (idx_mem=0; idx_mem<`TB_FLASH_NUM_WORDX; idx_mem++) begin 
                `TB_INSTNAME.`TB_CTRL_NAME.Flash_0.main_mem[idx_mem] = {$random, $random};
            end
        `endif
    end

    //****************************************************
    // VCD Dump
    //****************************************************
`ifdef VCD_DUMP
    initial begin
        $dumpfile(`VCD_FILE_NAME);
        `START_VCD_DUMP_FROM;
        `ifdef VCD_DUMP_ALL
            $dumpvars();
        `else
            $dumpvars(0, `TB_INSTNAME);
        `endif
    end
`elsif VPD_DUMP
    initial begin
        $vcdplusfile(`VPD_FILE_NAME);
        `START_VCD_DUMP_FROM;
        `ifdef VCD_DUMP_ALL
            $vcdpluson();
        `else
            $vcdpluson(0, `TB_INSTNAME);
        `endif
    end
`endif

    //****************************************************
    // SDF
    //****************************************************
    initial begin
`ifdef APR
    `ifdef SDFMAX
        $sdf_annotate(`SDF_FILE_NAME, `TB_INSTNAME,,, "MAXIMUM");
    `else 
        $sdf_annotate(`SDF_FILE_NAME, `TB_INSTNAME,,, "MINIMUM");
    `endif
`endif
   end

    //****************************************************
    // DEBUG DISPLAY
    //****************************************************
    `include "FLPv3L_debug.v"

    //****************************************************
    // MBUS_SNOOPER
    //****************************************************
    reg SNOOPER_DISABLE;
    initial SNOOPER_DISABLE = 1'b0;
   `ifdef MBUS_SNOOPER
    mbus_snooper #(.SHORT_PREFIX(`FLS_ADDR))
    mbus_snooper_0 (
        .RESETn(RESETn),
        .DISABLE(SNOOPER_DISABLE),
        .CIN(MBUS_CLK_M2FLS),
        .DIN(MBUS_DATA_M2FLS),
        .COUT(MBUS_CLK_FLS2A),
        .DOUT(MBUS_DATA_FLS2A)
        );
    `endif

    //****************************************************
    // TASKS
    //****************************************************
    `include "FLPv3L_task.v"

    //****************************************************
    // EVERYTHING ELSE
    //****************************************************
    initial begin
      
    //****************************************************
    // Start Testing
    //****************************************************
        @(posedge RESETn);
        $display("");
        $display("***********************************************");
        $display("***********************************************");
        $display("***************Simulation Start****************");
        $display("***********************************************");
        $display("***********************************************");
        $display("");

        // Auto Boot-Up
        test_auto_boot;

        // Wake-Up and Enumeration
        test_wakeup_enum;

        //Flash (Auto/Manual) Power On/Off Test
    `ifdef TEST_POWER
        test_flash_power_on_off;
        test_power_on_wakeup; // See Note in task
    `endif

        //From This Point, Power-On-WakeUp is disabled, but Flash Auto-On/Off is enabled.
        write_reg (`FLS_ADDR, `REGID_FPWRCNF, {18'h0, /*IRQ:*/1'h0, /*SEL:*/3'h0, /*AUTO-OFF:*/1'h1, /*AUTO-ON:*/1'h1});
        // Also speed up the operation by reducing Tcyc & Ben
        write_reg (`FLS_ADDR, `REGID_TCYR, {/*Tcyc_read:*/5'h01, /*T3us:*/6'h02, /*T5us:*/6'h04, /*T10us:*/7'h09});
        write_reg (`FLS_ADDR, `REGID_TCYP, {/*Tcyc_prog:*/16'h0001, /*Tprog:*/8'h09});
        write_reg (`FLS_ADDR, `REGID_TBEN, {/*Thvcp_en:*/14'h0, /*Tben:*/10'h4});
        write_reg (`FLS_ADDR, `REGID_TMVS, {/*Tmvcp_en:*/12'h0, /*Tsc_en:*/12'h0});
        target_sleep_full_prefix;
  
//    `ifdef TEST_REF_ERASE
//        test_flash_ref_erase;
//    `endif

    `ifdef TEST_SRAM
        test_sram_function;
    `endif

    `ifdef TEST_FLASH_PAGE_OPER
        test_flash_page_oper;
    `endif

    `ifdef TEST_FLASH_WHOLE_OPER
        test_flash_whole_oper;
    `endif

        //External Streaming
    `ifdef TEST_EXT_STR
        test_ext_stream;
    `endif

    `ifdef TEST_PP_EXT
        test_pp_ext_stream;
    `endif

    `ifdef TEST_PP_MBUS
        test_pp_mbus_stream;
    `endif

        //Finish
        `TEST_WAIT;
        success;
    end

endmodule // FLPv3L_test
