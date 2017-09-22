//********************************************
// MBus Sub-Tasks
//********************************************

task send_MBus;
    input [31:0] target_addr;
    input [127:0] target_data;
    input [31:0] num_words;
    reg [31:0] mbus_data [3:0];
    integer idx_i;
    begin
        mbus_data[0] = target_data[31:0];
        mbus_data[1] = target_data[63:32];
        mbus_data[2] = target_data[95:64];
        mbus_data[3] = target_data[127:96];

        idx_i = num_words;

        if      (num_words == 1) $display("*** Time %0dns: [PRC] [MBus Tx] ADDR = 0x%2h  DATA = 0x%8h", $time, target_addr, mbus_data[0]);
        else if (num_words == 2) $display("*** Time %0dns: [PRC] [MBus Tx] ADDR = 0x%2h  DATA = 0x%8h_%8h", $time, target_addr, mbus_data[1], mbus_data[0]);
        else if (num_words == 3) $display("*** Time %0dns: [PRC] [MBus Tx] ADDR = 0x%2h  DATA = 0x%8h_%8h_%8h", $time, target_addr, mbus_data[2], mbus_data[1], mbus_data[0]);
        else if (num_words == 4) $display("*** Time %0dns: [PRC] [MBus Tx] ADDR = 0x%2h  DATA = 0x%8h_%8h_%8h_%8h", $time, target_addr, mbus_data[3], mbus_data[2], mbus_data[1], mbus_data[0]);

        // Section A
        @(negedge CLK_MBC);
        N_M_TX_ADDR = target_addr;
        N_M_TX_DATA = mbus_data[idx_i-1];
        @(posedge CLK_MBC);
        if (idx_i>1) N_M_TX_PEND = 1'b1;
        N_M_TX_REQ = 1'b1;
        while (~N_M_TX_ACK) begin
            @(posedge CLK_MBC);
        end
        if (idx_i<3) N_M_TX_PEND = 1'b0;
        N_M_TX_REQ = 1'b0;
        @(posedge CLK_MBC);
        idx_i--;

        // Section B
        while (idx_i > 1) begin
            @(negedge CLK_MBC);
            N_M_TX_DATA = mbus_data[idx_i-1];
            @(posedge CLK_MBC);
            N_M_TX_REQ = 1'b1;
            while (~N_M_TX_ACK) begin
                @(posedge CLK_MBC);
            end
            N_M_TX_REQ = 1'b0;
            if (idx_i == 2) N_M_TX_PEND = 1'b0;
            @(posedge CLK_MBC);
            idx_i--;
        end

        // Section C
        if (idx_i == 1) begin
            @(negedge CLK_MBC);
            N_M_TX_DATA = mbus_data[idx_i-1];
            @(posedge CLK_MBC);
            N_M_TX_REQ = 1'b1;
            while (~N_M_TX_ACK) begin
                @(posedge CLK_MBC);
            end
            N_M_TX_REQ = 1'b0;
            N_M_TX_ADDR = 32'h0;
            N_M_TX_DATA = 32'h0;
            @(posedge CLK_MBC);
        end
    end
endtask // send_MBus

task send_MBus_random_stream;
    input [31:0] target_addr;
    input [31:0] num_words;
    input compare;
    input [`TB_FLASH_ADDR_WIDTH-1:0] flash_start_addr;
    reg [31:0] mbus_data;
    integer idx_i;
    integer idx_j;
    begin
        idx_i = num_words;
        idx_j = 0;
        $display("*** Time %0dns: [PRC] [MBus Tx: Random Streaming] ADDR = 0x%2h  NUM_WORDS = %d", $time, target_addr, num_words);

        // Section A
        @(negedge CLK_MBC);
        N_M_TX_ADDR = target_addr;
        mbus_data = $random;
        if (compare) begin
            flsh_mem[flash_start_addr+idx_j] = mbus_data;
            idx_j++;
        end
        N_M_TX_DATA = mbus_data;
        @(posedge CLK_MBC);
        if (idx_i>1) N_M_TX_PEND = 1'b1;
        N_M_TX_REQ = 1'b1;
        while (~N_M_TX_ACK) begin
            @(posedge CLK_MBC);
        end
        if (idx_i<3) N_M_TX_PEND = 1'b0;
        N_M_TX_REQ = 1'b0;
        @(posedge CLK_MBC);
        idx_i--;

        // Section B
        while (idx_i > 1) begin
            @(negedge CLK_MBC);
            mbus_data = $random;
            if (compare) begin
                flsh_mem[flash_start_addr+idx_j] = mbus_data;
                idx_j++;
            end
            N_M_TX_DATA = mbus_data;
            @(posedge CLK_MBC);
            N_M_TX_REQ = 1'b1;
            while (~N_M_TX_ACK) begin
                @(posedge CLK_MBC);
            end
            N_M_TX_REQ = 1'b0;
            if (idx_i == 2) N_M_TX_PEND = 1'b0;
            @(posedge CLK_MBC);
            idx_i--;
        end

        // Section C
        if (idx_i == 1) begin
            @(negedge CLK_MBC);
            mbus_data = $random;
            if (compare) begin
                flsh_mem[flash_start_addr+idx_j] = mbus_data;
                idx_j++;
            end
            N_M_TX_DATA = mbus_data;
            @(posedge CLK_MBC);
            N_M_TX_REQ = 1'b1;
            while (~N_M_TX_ACK) begin
                @(posedge CLK_MBC);
            end
            N_M_TX_REQ = 1'b0;
            N_M_TX_ADDR = 32'h0;
            N_M_TX_DATA = 32'h0;
            @(posedge CLK_MBC);
        end

        $display("");

    end
endtask // send_MBus_random_stream

task delay_mbc;
    input [31:0] ticks;
    integer idx_i;
    begin
        for(idx_i = 0; idx_i < ticks; idx_i = idx_i + 1) begin
            @ (posedge CLK_MBC);
        end
    end
endtask // delay_mbc


//********************************************
// Master Layer Tasks
//********************************************

task wakeup;
    integer idx_i;
    begin
        $display("");
        $display("***********************************************");
        $display("********************Wake-Up********************");
        $display("***********************************************");
        $display("");

        for (idx_i=0; idx_i<128; idx_i++) begin // wait for a while before asserting the request
            `MBUS_HALF_PERIOD;
        end
        N_M_WAKEUP_REQ = 1'b1;
        @ (negedge N_M_LRC_SLEEP);
        N_M_WAKEUP_REQ = 1'b0;
        delay_mbc (100);
    end
endtask // wakeup

task enumerate;
    input [3:0] short_prefix;
    integer idx_i;
    begin
        $display("");
        $display("***********************************************");
        $display("******************Enumeration******************");
        $display("***********************************************");
        $display("");

        $display("*** Time %0dns: [PRC] Sending Enumeration (0x%4h) Msg", $time, short_prefix);
        send_MBus (32'h00000000, {4'h2, short_prefix, 24'h0}, 1);

        @(posedge N_M_RX_REQ);    // Wait for N_M_RX_REQ (enumeration reply)
        if( N_M_RX_ADDR[7:0] == 8'h00 && N_M_RX_DATA[31:28] == 4'h1 ) begin
            $display("*** Time %0dns: [PRC] Enumeration Response Received", $time);
            $display("*** Time %0dns:       Full prefix : 0x%5h ", $time, N_M_RX_DATA[23:4]);
            $display("*** Time %0dns:       Short prefix: 0x%1h ", $time, N_M_RX_DATA[3:0]);
        end
        else failure;
        @(negedge N_M_RX_REQ);

        delay_mbc (30);
    end
endtask // enumerate

task query;
    input [3:0] num_members;
    integer idx_i;
    begin
        $display("");
        $display("***********************************************");
        $display("*********************Query*********************");
        $display("***********************************************");
        $display("");

        $display("*** Time %0dns: [PRC] Sending Enumeration Query Msg", $time);
        send_MBus(32'h00000000, 32'h00000000, 1);

        for(idx_i = 0; idx_i < num_members; idx_i = idx_i + 1) begin
            @(posedge N_M_RX_REQ);    // Wait for N_M_RX_REQ (query reply)
            if( N_M_RX_ADDR[7:0] == 8'h00 && N_M_RX_DATA[31:28] == 4'h1 ) begin
                $display("*** Time %0dns: [PRC] Query Response Received", $time);
                $display("*** Time %0dns:       Full prefix : 0x%5h ", $time, N_M_RX_DATA[23:4]);
                $display("*** Time %0dns:       Short prefix: 0x%1h ", $time, N_M_RX_DATA[3:0]);
            end
            else failure;
            @(negedge N_M_RX_REQ);
        end

        delay_mbc (30);
    end
endtask // query

task target_sleep_full_prefix;
    begin
        delay_mbc (100);

        $display("");
        $display("***********************************************");
        $display("*********Targeted Sleep (Full Prefix)**********");
        $display("***********************************************");
        $display("");
        
        $display("*** Time %0dns: [PRC] Set Flash layer to sleep mode", $time);
        send_MBus( 32'h01, {8'h40, `TB_MBUS_FULL_PREFIX, 4'h0}, 1);
        delay_mbc (100);

        $display("");
        $display("***** Targeted Sleep (Full Prefix) Done!! *****");
        $display("");
        
    end
endtask // target_sleep_full_prefix

task write_reg;
    input    [3:0]    SHORT_PREFIX;
    input    [7:0]    REG_ID;
    input    [23:0]    REG_VALUE;
    begin
        $display( "*** Time %0dns: [PRC] Sending Register Write: SHORT_PREFIX = 0x%1h   REG_ID = 0x%2h   REG_DATA = 0x%6h", $time, SHORT_PREFIX, REG_ID, REG_VALUE);
        send_MBus( {24'h0, SHORT_PREFIX, 4'h0}, { ({24'b0, REG_ID} << 24) | REG_VALUE }, 1);
    end
endtask

task wait_interrupt;
    input [31:0]    EXPECTED;
    begin
        @(posedge N_M_RX_REQ);
        @(negedge CLK_MBC);
        if (EXPECTED[7:0] == 8'hFF) begin
            $display("*** Time %0dns: [PRC] INTERRUPT RECEIVED: N_M_RX_DATA=0x%8h", $time, N_M_RX_DATA);
        end
        else if (N_M_RX_DATA !== EXPECTED) begin
            $display("*** Time %0dns: [PRC] INCORRECT INTERRUPT FAILURE: EXPECTED=0x%8h, N_M_RX_DATA=0x%8h", $time, EXPECTED, N_M_RX_DATA);
            failure();
        end
        else begin
            $display("*** Time %0dns: [PRC] CORRECT INTERRUPT RECEIVED: N_M_RX_DATA=0x%8h", $time, N_M_RX_DATA);
        end
        @(negedge N_M_RX_REQ);
    end
endtask // wait_interrupt

//********************************************
// SRAM Sub-Tasks
//********************************************

task init_sram;
    input    [31:0]    data;
    integer l;
    integer max;
    begin
        $display("");
        $display("***********************************************");
        $display("*************FLS:Initialize SRAM***************");
        $display("***********************************************");
        $display("");

        l = 0;
        max = `TB_SRAM_NUM_WORDS;

        @(negedge CLK_MBC);
        N_M_TX_ADDR = {24'b0, `FLS_ADDR, 4'h2};
        N_M_TX_DATA = data;
        @(posedge CLK_MBC);
        N_M_TX_PEND = 1'b1;
        N_M_TX_REQ = 1'b1;
        while (~N_M_TX_ACK) begin
            @(posedge CLK_MBC);
        end
        N_M_TX_REQ = 1'b0;
        @(posedge CLK_MBC);
        while(l<max) begin
            if ((l%10==0) | (l==(max-1))) $write ("*** Time %0dns: SRAM ADDR (%0d/%0d)\015", $time, l, `TB_SRAM_NUM_WORDS-1);
            sram_mem[l] = data;
            @(negedge CLK_MBC);
            @(posedge CLK_MBC);
            N_M_TX_REQ = 1'b1;
            while (~N_M_TX_ACK) begin
                @(posedge CLK_MBC);
            end
            l++;
            if (l==(max-1)) N_M_TX_PEND = 1'b0;
            N_M_TX_REQ = 1'b0;
            @(posedge CLK_MBC);
        end
        N_M_TX_ADDR = 32'h0;
        N_M_TX_DATA = 32'h0;

        delay_mbc (30);
        $display("");

    end
endtask // init_sram

task check_sram;
    integer l;
    integer max;
    reg    [15:0]    length;
    begin
        $display("");
        $display("***********************************************");
        $display("***************FLS:Reading SRAM****************");
        $display("***********************************************");
        $display("");

        l = 0;
        max = `TB_SRAM_NUM_WORDS;
        length = `TB_SRAM_LENGTH;

        send_MBus ( {24'b0, `FLS_ADDR, 4'h3}, {16'h1300, length, 32'h0}, 2 ); // MEM READ FROM FLASH LAYER
        @(posedge CLK_MBC);
        @(posedge CLK_MBC);
        while (l<max) begin
            if ((l%10==0) | (l==(max-1))) $write ("*** Time %0dns: SRAM ADDR (%0d/%0d)\015", $time, l, `TB_SRAM_NUM_WORDS-1);
            @(posedge N_M_RX_REQ);
            @(negedge CLK_MBC);
            if(sram_mem[l] !== N_M_RX_DATA) begin
                `_RED; $display("* MEM_CHECK FAILURE: sram_mem[%4d]=0x%8h, N_M_RX_DATA=0x%8h", l, sram_mem[l], N_M_RX_DATA); `_RESET;
                failure();
            end
            @(negedge N_M_RX_REQ);
            @(posedge CLK_MBC);
            l++;
        end

        delay_mbc (30);
        $display("");

    end
endtask // check_sram

task randomize_sram;
    input        sync_sram_mem;
    reg    [31:0]    random_data;
    integer l;
    integer max;
    begin
        $display("");
        $display("***********************************************");
        $display("****************Randomize SRAM*****************");
        $display("***********************************************");
        $display("");

        l = 0;
        max = `TB_SRAM_NUM_WORDS;
        @(negedge CLK_MBC);
        N_M_TX_ADDR = {24'b0, `FLS_ADDR, 4'h2};
        N_M_TX_DATA = 0;
        @(posedge CLK_MBC);
        N_M_TX_PEND = 1'b1;
        N_M_TX_REQ = 1'b1;
        while (~N_M_TX_ACK) begin
            @(posedge CLK_MBC);
        end
        N_M_TX_REQ = 1'b0;
        @(posedge CLK_MBC);
        while(l<max) begin
            if ((l%10==0) | (l==(max-1))) $write ("*** Time %0dns: SRAM ADDR (%0d/%0d)\015", $time, l, `TB_SRAM_NUM_WORDS-1);
            @(negedge CLK_MBC);
            random_data = $random;
            if (sync_sram_mem) sram_mem[l] = random_data;
            N_M_TX_DATA = random_data;
            @(posedge CLK_MBC);
            N_M_TX_REQ = 1'b1;
            while (~N_M_TX_ACK) begin
                @(posedge CLK_MBC);
            end
            l++;
            if(l==(max-1)) begin
                N_M_TX_PEND = 1'b0;
            end
            N_M_TX_REQ = 1'b0;
            @(posedge CLK_MBC);
            @(posedge CLK_MBC);
            N_M_TX_ADDR = 32'h0;
            N_M_TX_DATA = 32'h0;
        end

        delay_mbc (30);
        $display("");

    end
endtask // randomize_sram

//********************************************
// FLP Sub-Tasks
//********************************************

task check_power_status;
    input VRCMP;
    input LCAP;
    input FLSH;
    input [31:0] ID;
    reg dummy;
    begin
        dummy = LCAP; // To prevent UI (Unused Input) lint message
        if (`TB_INSTNAME.`TB_RF_NAME.VREF_SLEEP !== ~VRCMP)   begin $display ("CHECK_POWER_STATUS FAILURE!! (VREF_SLEEP)  ID=%d", ID); failure; end
        if (`TB_INSTNAME.`TB_RF_NAME.COMP_SLEEP !== ~VRCMP)   begin $display ("CHECK_POWER_STATUS FAILURE!! (COMP_SLEEP)  ID=%d", ID); failure; end
        if (`TB_INSTNAME.`TB_RF_NAME.COMP_CLKENB !== ~VRCMP)  begin $display ("CHECK_POWER_STATUS FAILURE!! (COMP_CLKENB)  ID=%d", ID); failure; end
        if (`TB_INSTNAME.`TB_RF_NAME.COMP_ISOL !== ~VRCMP)    begin $display ("CHECK_POWER_STATUS FAILURE!! (COMP_ISOL)  ID=%d", ID); failure; end
        //if (`TB_INSTNAME.`TB_RF_NAME.LCAP_EN !== LCAP)       begin $display ("CHECK_POWER_STATUS FAILURE!! (LCAP_EN)  ID=%d", ID); failure; end
        if (`TB_INSTNAME.`TB_CTRL_NAME.flsh_abuf_en !== VRCMP) begin $display ("CHECK_POWER_STATUS FAILURE!! (flsh_abuf_en)  ID=%d", ID); failure; end
        if (`TB_INSTNAME.`TB_CTRL_NAME.flsh_resetb !== FLSH)  begin $display ("CHECK_POWER_STATUS FAILURE!! (flsh_resetb)  ID=%d", ID); failure; end
        if (`TB_INSTNAME.`TB_CTRL_NAME.flsh_hvcp_en !== FLSH) begin $display ("CHECK_POWER_STATUS FAILURE!! (flsh_hvcp_en)  ID=%d", ID); failure; end
        if (`TB_INSTNAME.`TB_CTRL_NAME.flsh_mvcp_en !== FLSH) begin $display ("CHECK_POWER_STATUS FAILURE!! (flsh_mvcp_en)  ID=%d", ID); failure; end
        if (`TB_INSTNAME.`TB_CTRL_NAME.flsh_sc_en !== FLSH)   begin $display ("CHECK_POWER_STATUS FAILURE!! (flsh_sc_en)  ID=%d", ID); failure; end
        $display ("*** Time %0dns: CHECK_POWER_STATUS PASSED!! ID=%d", $time, ID);
        $display ("");
        delay_mbc (30);
    end
endtask // check_power_status;

task set_flash_start_addr;
    input [`TB_FLASH_ADDR_WIDTH-1:0] flash_start_addr;
    begin
        write_reg (`FLS_ADDR, `REGID_FADR, flash_start_addr);
    end
endtask // set_flash_start_addr

task set_sram_start_addr;
    input [`TB_SRAM_ADDR_WIDTH-1:0] sram_start_addr;
    begin
        write_reg (`FLS_ADDR, `REGID_SADR, sram_start_addr);
    end
endtask // set_sram_start_addr

task go_cmd_erase_ref;
    begin
        write_reg (`FLS_ADDR, `REGID_GO, {{`TB_LENGTH_WIDTH{1'b0}}, 1'b1, `REF_ER_FLSH, 1'b1});
        wait_interrupt ({24'b0, `REF_FLSH_4});
    end
endtask // go_cmd_erase_ref

task go_cmd_erase_page;
    begin
        write_reg (`FLS_ADDR, `REGID_GO, {{`TB_LENGTH_WIDTH{1'b0}}, 1'b1, `ER_FLSH, 1'b1});
        wait_interrupt ({24'b0, `ER_FLSH_6});
    end
endtask // go_cmd_erase_page

task go_cmd_flash2sram;
    input [`TB_LENGTH_WIDTH-1:0] length_1;
    input [7:0] expected_payload;
    begin
        write_reg (`FLS_ADDR, `REGID_GO, {length_1, 1'b1, `CP_FLSH2SRAM, 1'b1});
        wait_interrupt ({24'b0, expected_payload});
    end
endtask // go_cmd_flash2sram

task go_cmd_sram2flash;
    input [`TB_LENGTH_WIDTH-1:0] length_1;
    input [7:0] expected_payload;
    begin
        write_reg (`FLS_ADDR, `REGID_GO, {length_1, 1'b1, `CP_SRAM2FLSH, 1'b1});
        wait_interrupt ({24'b0, expected_payload});
    end
endtask // go_cmd_sram2flash

task go_cmd_sram2flash_fast;
    input [`TB_LENGTH_WIDTH-1:0] length_1;
    input [7:0] expected_payload;
    begin
        write_reg (`FLS_ADDR, `REGID_GO, {length_1, 1'b1, `CP_SRAM2FLSH_FAST, 1'b1});
        wait_interrupt ({24'b0, expected_payload});
    end
endtask // go_cmd_sram2flash_fast

task flash_power_on;
    input VRCMP;
    input LCAP;
    input FLSH;
    begin
        `_GREEN; $display("*** Time %0dns: [PRC] Sending Flash Power ON Msg", $time); `_RESET;

        write_reg (`FLS_ADDR, `REGID_PWRGO, {18'h0, VRCMP, LCAP, FLSH, 1'b1, 2'h3});
        @(posedge N_M_RX_REQ);
        $display("*** Time %0dns: [PRC] Interrupt Received", $time);
        if (N_M_RX_DATA !== {{24{1'b0}},`POWER_ON_5}) begin
            $display("*** Time %0dns: [PRC] INCORRECT PAYLOAD RECEIVED!!!: 0x%h", $time, N_M_RX_DATA);
            failure();
        end
        @(negedge N_M_RX_REQ);

        delay_mbc (30);

        `_GREEN; $display("*** Time %0dns: Flash Powered ON", $time); $display(""); `_RESET;
    end
endtask // flash_power_on

task flash_power_off;
    input VRCMP;
    input LCAP;
    input FLSH;
    begin
        `_MAGENTA; $display("*** Time %0dns: [PRC] Sending Flash Power OFF Msg", $time); `_RESET;

        write_reg (`FLS_ADDR, `REGID_PWRGO, {18'h0, VRCMP, LCAP, FLSH, 1'b1, 2'h1});
        @(posedge N_M_RX_REQ);
        $display("*** Time %0dns: [PRC] Interrupt Received", $time);
        if (N_M_RX_DATA !== {{24{1'b0}},`POWER_OFF_5}) begin
            $display("*** Time %0dns: [PRC] INCORRECT PAYLOAD RECEIVED!!!: 0x%h", $time, N_M_RX_DATA);
            failure();
        end
        @(negedge N_M_RX_REQ);

        delay_mbc (30);

        `_MAGENTA; $display("*** Time %0dns: Flash Powered OFF", $time); $display(""); `_RESET;
    end
endtask // flash_power_off


//********************************************
// FLP Tasks
//********************************************

task erase_flash_ref;
    begin
        $display("");
        $display("***********************************************");
        $display("**************FLS:Erasing Ref Cell*************");
        $display("***********************************************");
        $display("");

        go_cmd_erase_ref;
        delay_mbc (30);
    end
endtask // erase_flash_ref

task erase_flash_page;
    input [31:0] start_page_id;
    input [31:0] num_pages;
    reg [`TB_FLASH_ADDR_WIDTH-1:0] flash_start_addr;
    reg [`TB_FLASH_ADDR_WIDTH-1:0] page_size;
    reg [31:0] page_id;
    begin
        $display("");
        $display("***********************************************");
        $display("***************FLS:Erasing FLSH****************");
        $display("***********************************************");
        $display("");

        page_size = 1 << (`TB_FLASH_PAGE_WIDTH - 1);
        flash_start_addr = start_page_id << (`TB_FLASH_PAGE_WIDTH - 1);
        page_id = 32'h0;

        while (page_id < num_pages) begin
            set_flash_start_addr (flash_start_addr);
            go_cmd_erase_page;
            page_id++;
            flash_start_addr = flash_start_addr + page_size;
        end

        delay_mbc (30);
    end
endtask // erase_flash_page

task erase_flash_whole;
    reg [`TB_FLASH_ADDR_WIDTH-1:0] flash_start_addr;
    reg [`TB_FLASH_ADDR_WIDTH-1:0] page_size;
    reg [31:0] page_id;
    begin
        $display("");
        $display("***********************************************");
        $display("**********FLS:Erasing FLSH - Whole ************");
        $display("***********************************************");
        $display("");

        erase_flash_page (0, `TB_FLASH_NUM_PAGES);
        set_flash_start_addr (0); // Reset Flash Start Address

        delay_mbc (30);
    end
endtask // erase_flash_whole

task cp_flash2sram_page;
    input [31:0] flash_start_page_id;
    input [31:0] sram_start_page_id;
    input [31:0] num_pages;
    reg [`TB_FLASH_ADDR_WIDTH-1:0] flash_start_addr;
    reg [`TB_FLASH_ADDR_WIDTH-1:0] page_size;
    reg [`TB_SRAM_ADDR_WIDTH-1:0]  sram_start_addr;
    reg [31:0] page_id;
    reg [7:0] correct_payload;
    begin
        $display("");
        $display("***********************************************");
        $display("**********FLS:Copying FLSH -> SRAM*************");
        $display("***********************************************");
        $display("");

        page_size = 1 << (`TB_FLASH_PAGE_WIDTH - 1);
        flash_start_addr = flash_start_page_id << (`TB_FLASH_PAGE_WIDTH - 1);
        sram_start_addr = sram_start_page_id << (`TB_FLASH_PAGE_WIDTH - 1);
        page_id = 32'h0;

        correct_payload = `CP_FLSH2SRAM_B;

        while (page_id < num_pages) begin
            set_sram_start_addr (sram_start_addr);
            set_flash_start_addr (flash_start_addr);
            go_cmd_flash2sram ({`TB_PAGE_WIDTH{1'b1}}, correct_payload);
            page_id++;
            flash_start_addr = flash_start_addr + page_size;
            sram_start_addr = sram_start_addr + page_size;
        end

        delay_mbc (30);
    end
endtask // cp_flash2sram_page

task cp_flash2sram_whole;
    input [31:0] flash_start_page_id;
    reg [`TB_FLASH_ADDR_WIDTH-1:0] flash_start_addr;
    reg [7:0] correct_payload;
    begin
        $display("");
        $display("***********************************************");
        $display("**********FLS:Copying FLSH -> SRAM*************");
        $display("**************** (Whole SRAM) *****************");
        $display("***********************************************");
        $display("");
        cp_flash2sram_page (flash_start_page_id, 0, `TB_NUM_PAGES_SRAM);
    end
endtask // cp_flash2sram_whole

task cp_sram2flash_page;
    input [31:0] flash_start_page_id;
    input [31:0] sram_start_page_id;
    input [31:0] num_pages;
    input        fast_prog;
    reg [`TB_FLASH_ADDR_WIDTH-1:0] flash_start_addr;
    reg [`TB_FLASH_ADDR_WIDTH-1:0] page_size;
    reg [`TB_SRAM_ADDR_WIDTH-1:0]  sram_start_addr;
    reg [31:0] page_id;
    reg [7:0] correct_payload;
    begin
        $display("");
        $display("***********************************************");
        $display("**********FLS:Copying SRAM -> FLSH*************");
        if (fast_prog) begin
        $display("************ (FAST PROGRAMMING) ***************");
        end else begin
        $display("********** (STANDARD PROGRAMMING) *************");
        end
        $display("***********************************************");
        $display("");

        if (fast_prog) correct_payload = `CP_SRAM2FLSH_FAST_D;
        else correct_payload = `CP_SRAM2FLSH_F;

        page_size = 1 << (`TB_FLASH_PAGE_WIDTH - 1);
        flash_start_addr = flash_start_page_id << (`TB_FLASH_PAGE_WIDTH - 1);
        sram_start_addr = sram_start_page_id << (`TB_FLASH_PAGE_WIDTH - 1);
        page_id = 32'h0;

        while (page_id < num_pages) begin
            set_sram_start_addr (sram_start_addr);
            set_flash_start_addr (flash_start_addr);
            if (fast_prog) go_cmd_sram2flash_fast ({`TB_PAGE_WIDTH{1'b1}}, correct_payload);
            else           go_cmd_sram2flash      ({`TB_PAGE_WIDTH{1'b1}}, correct_payload);
            page_id++;
            flash_start_addr = flash_start_addr + page_size;
            sram_start_addr = sram_start_addr + page_size;
        end

        delay_mbc (30);
    end
endtask // cp_sram2flash_page

task cp_sram2flash_whole;
    input [31:0] flash_start_page_id;
    input        fast_prog;
    reg [`TB_FLASH_ADDR_WIDTH-1:0] flash_start_addr;
    reg [7:0] correct_payload;
    begin
        $display("");
        $display("***********************************************");
        $display("**********FLS:Copying SRAM -> FLSH*************");
        $display("************ WHOLE SRAM (4 PAGES) *************");
        if (fast_prog) begin
        $display("************ (FAST PROGRAMMING) ***************");
        end else begin
        $display("********** (STANDARD PROGRAMMING) *************");
        end
        $display("***********************************************");
        $display("");

        if (fast_prog) correct_payload = `CP_SRAM2FLSH_FAST_D;
        else correct_payload = `CP_SRAM2FLSH_F;

        flash_start_addr = flash_start_page_id << (`TB_FLASH_PAGE_WIDTH - 1);

        set_sram_start_addr (0); // SRAM START ADDRESS
        set_flash_start_addr (flash_start_addr);
        if (fast_prog) go_cmd_sram2flash_fast ({`TB_LENGTH_WIDTH{1'b1}}, correct_payload);
        else           go_cmd_sram2flash      ({`TB_LENGTH_WIDTH{1'b1}}, correct_payload);

        delay_mbc (30);
    end
endtask // cp_sram2flash_whole


//********************************************
// Flash Test Suite: General
//********************************************

task test_wakeup_enum;
    begin
        `_GREEN_B;
        $display("\n\n");
        $display("***********************************************");
        $display("***********************************************");
        $display("**        TEST: Wake-Up & Enumeration          **");
        $display("***********************************************");
        $display("***********************************************");
        $display("*** Time %0dns: [TB] Start Testing...", $time);
        $display("\n\n");
        `_RESET;

        wakeup;

        query(2);
        enumerate(`FLS_ADDR);
        enumerate(`N_A_ADDR);

        pass;
        `TEST_WAIT;
    end
endtask // test_wakeup_enum

task test_auto_boot;
    begin
        `_GREEN_B;
        $display("\n\n");
        $display("***********************************************");
        $display("***********************************************");
        $display("**            TEST: Auto-Boot-Up             **");
        $display("***********************************************");
        $display("***********************************************");
        $display("*** Time %0dns: [TB] Start Testing...", $time);
        $display("\n\n");
        `_RESET;

        if (`FLS_AUTO_BOOT_DISABLE == 1'b1) begin
            $display ("### SELF-BOOT-UP IS DISABLED ###");
        end
        else begin
            while (1) begin
                @(negedge N_M_RX_REQ);
                if ((N_M_RX_ADDR == 32'h1) && (N_M_RX_DATA == 32'h0)) begin // Sleep Msg Received
                    $display ("*** Time %0dns: [PRC] SLEEP MESSAGE RECEIVED", $time);
                    $display ("*** Time %0dns: ### FINISHING BOOT-UP... ###", $time);
                    pass;
                    break;
                end
            end
        end
        `TEST_WAIT;
    end
endtask // test_auto_boot

task test_flash_whole_oper;
    begin
        `_GREEN_B;
        $display("\n\n");
        $display("***********************************************");
        $display("***********************************************");
        $display("**       TEST: Flash Whole Operations        **");
        $display("***********************************************");
        $display("***********************************************");
        $display("*** Time %0dns: [TB] Start Testing...", $time);
        $display("\n\n");
        `_RESET;

        //Flash Tests with Mass Erase & Fast Prog (Whole SRAM - 4 Pages)
        erase_flash_whole;
        randomize_sram(/*SYNC:*/1);
        cp_sram2flash_whole(0, /*FAST_PROG:*/1);       // Copy SRAM to Flash
        randomize_sram(/*SYNC:*/0);
        cp_flash2sram_whole(/*START_PAGE_ID:*/0);
        check_sram;                // Check SRAM
        target_sleep_full_prefix;

        pass;

        `TEST_WAIT;
    end
endtask // test_flash_whole_oper

task test_flash_page_oper;
    begin
        `_GREEN_B;
        $display("\n\n");
        $display("***********************************************");
        $display("***********************************************");
        $display("**       TEST: Flash Page Operations         **");
        $display("***********************************************");
        $display("***********************************************");
        $display("*** Time %0dns: [TB] Start Testing...", $time);
        $display("\n\n");
        `_RESET;

        // Set Power-On-Wakeup and Disable Auto-On/Off
        write_reg (`FLS_ADDR, `REGID_FPWRCNF, {17'h0, /*IRQ:*/1'h0, /*SEL:*/3'h4, /*CUSTOM:*/1'h0, /*AUTO-OFF:*/1'h0, /*AUTO-ON:*/1'h0});
        write_reg (`FLS_ADDR, `REGID_FADR, 0); // Reset FLSH_START_ADDR
        target_sleep_full_prefix;

        //Flash Tests with Erase
        erase_flash_page(/*START_PAGE_ID:*/0, /*NUM_PAGE:*/`TB_NUM_PAGES_SRAM);
        randomize_sram(/*SYNC:*/1);
        cp_sram2flash_page(/*FLSH_PAGE_ID:*/0, /*SRAM_PAGE_ID:*/0, /*NUM_PAGE:*/`TB_NUM_PAGES_SRAM, /*FAST_PROG:*/0);
        flash_power_off (/*VRCMP:*/1, /*LCAP:*/1, /*FLSH:*/1);
        target_sleep_full_prefix;

        flash_power_on (/*VRCMP:*/1, /*LCAP:*/1, /*FLSH:*/1);
        randomize_sram(/*SYNC:*/0);
        cp_flash2sram_page(/*FLSH_PAGE_ID:*/0, /*SRAM_PAGE_ID:*/0, /*NUM_PAGE:*/`TB_NUM_PAGES_SRAM);
        check_sram;                // Check SRAM
        flash_power_off (/*VRCMP:*/1, /*LCAP:*/1, /*FLSH:*/1);
        write_reg (`FLS_ADDR, `REGID_FADR, 0); // Reset FLSH_START_ADDR
        target_sleep_full_prefix;

        //Flash Tests with Mass Erase
        erase_flash_whole;
        randomize_sram(/*SYNC:*/1);
        cp_sram2flash_page(/*FLSH_PAGE_ID:*/0, /*SRAM_PAGE_ID:*/0, /*NUM_PAGE:*/`TB_NUM_PAGES_SRAM, /*FAST_PROG:*/0);
        flash_power_off (/*VRCMP:*/1, /*LCAP:*/1, /*FLSH:*/1);
        target_sleep_full_prefix;

        flash_power_on (/*VRCMP:*/1, /*LCAP:*/1, /*FLSH:*/1);
        randomize_sram(/*SYNC:*/0);
        cp_flash2sram_page(/*FLSH_PAGE_ID:*/0, /*SRAM_PAGE_ID:*/0, /*NUM_PAGE:*/`TB_NUM_PAGES_SRAM);
        check_sram;                // Check SRAM
        flash_power_off (/*VRCMP:*/1, /*LCAP:*/1, /*FLSH:*/1);
        write_reg (`FLS_ADDR, `REGID_FADR, 0); // Reset FLSH_START_ADDR
        target_sleep_full_prefix;

        //Flash Tests with Erase & Fast Prog
        erase_flash_page(/*START_PAGE_ID:*/0, /*NUM_PAGE:*/`TB_NUM_PAGES_SRAM);
        randomize_sram(/*SYNC:*/1);
        cp_sram2flash_page(/*FLSH_PAGE_ID:*/0, /*SRAM_PAGE_ID:*/0, /*NUM_PAGE:*/`TB_NUM_PAGES_SRAM, /*FAST_PROG:*/1);
        flash_power_off (/*VRCMP:*/1, /*LCAP:*/1, /*FLSH:*/1);
        target_sleep_full_prefix;

        flash_power_on (/*VRCMP:*/1, /*LCAP:*/1, /*FLSH:*/1);
        randomize_sram(/*SYNC:*/0);
        cp_flash2sram_page(/*FLSH_PAGE_ID:*/0, /*SRAM_PAGE_ID:*/0, /*NUM_PAGE:*/`TB_NUM_PAGES_SRAM);
        check_sram;                // Check SRAM
        flash_power_off (/*VRCMP:*/1, /*LCAP:*/1, /*FLSH:*/1);
        write_reg (`FLS_ADDR, `REGID_FADR, 0); // Reset FLSH_START_ADDR
        target_sleep_full_prefix;

        //Flash Tests with Mass Erase & Fast Prog
        erase_flash_whole;
        randomize_sram(/*SYNC:*/1);
        cp_sram2flash_page(/*FLSH_PAGE_ID:*/0, /*SRAM_PAGE_ID:*/0, /*NUM_PAGE:*/`TB_NUM_PAGES_SRAM, /*FAST_PROG:*/1);
        flash_power_off (/*VRCMP:*/1, /*LCAP:*/1, /*FLSH:*/1);
        target_sleep_full_prefix;

        flash_power_on (/*VRCMP:*/1, /*LCAP:*/1, /*FLSH:*/1);
        randomize_sram(/*SYNC:*/0);
        cp_flash2sram_page(/*FLSH_PAGE_ID:*/0, /*SRAM_PAGE_ID:*/0, /*NUM_PAGE:*/`TB_NUM_PAGES_SRAM);
        check_sram;                // Check SRAM
        flash_power_off (/*VRCMP:*/1, /*LCAP:*/1, /*FLSH:*/1);
        write_reg (`FLS_ADDR, `REGID_FADR, 0); // Reset FLSH_START_ADDR

        // Disable Power-On-Wakeup and Enable Auto-On/Off
        write_reg (`FLS_ADDR, `REGID_FPWRCNF, {17'h0, /*IRQ:*/1'h0, /*SEL:*/3'h0, /*CUSTOM:*/1'h0, /*AUTO-OFF:*/1'h1, /*AUTO-ON:*/1'h1});
        target_sleep_full_prefix;

        pass;

        `TEST_WAIT;
    end
endtask // test_flash_page_oper

task test_sram_function;
    begin
        `_GREEN_B;
        $display("\n\n");
        $display("***********************************************");
        $display("***********************************************");
        $display("**           TEST: SRAM Functions            **");
        $display("***********************************************");
        $display("***********************************************");
        $display("*** Time %0dns: [TB] Start Testing...", $time);
        $display("\n\n");
        `_RESET;

        init_sram(/*DATA:*/32'h0);
        check_sram;
        randomize_sram(/*SYNC:*/1);
        check_sram;
        target_sleep_full_prefix;

        pass;

        `TEST_WAIT;
    end
endtask // test_sram_function

task test_flash_ref_erase;
    begin
        `_GREEN_B;
        $display("\n\n");
        $display("***********************************************");
        $display("***********************************************");
        $display("**      TEST: Flash Refrence Cell Erase      **");
        $display("***********************************************");
        $display("***********************************************");
        $display("*** Time %0dns: [TB] Start Testing...", $time);
        $display("\n\n");
        `_RESET;

        erase_flash_ref;
        target_sleep_full_prefix;

        pass;
    end
endtask // test_flash_ref_erase

task test_power_on_wakeup;
    begin
        `_GREEN_B;
        $display("\n\n");
        $display("***********************************************");
        $display("***********************************************");
        $display("**       TEST: Flash Power-On-Wake-Up        **");
        $display("***********************************************");
        $display("***********************************************");
        $display("*** Time %0dns: [TB] Start Testing...", $time);
        $display("\n\n");
        `_RESET;

        //NOTE: Do NOT use MEM-related commands when you wake up the layer
        //      controller if SEL_PWR_ON_WUP is enabled.
        //NOTE: It is recommended that you set IRQ_PWR_ON_WUP=0 and use
        //      "non-memory GO commands or FLASH_POWER_GO" with IRQ enabled.
        
        //-------------------------------------------------------------------
        // SEL_PWR_ON_WUP = 1 (VRCMP Only)
        write_reg (`FLS_ADDR, `REGID_FPWRCNF, {17'h0, /*IRQ:*/1'h1, /*SEL:*/3'h1, /*CUSTOM:*/1'h0, /*AUTO-OFF:*/1'h0, /*AUTO-ON:*/1'h0});
        target_sleep_full_prefix;

        //-------------------------------------------------------------------
        // Wake-up the layer controller by writing into FLSH_START_ADDR.
        write_reg (`FLS_ADDR, `REGID_FADR, 1);
        wait_interrupt ({24'b0, `POWER_ON_5});
        check_power_status (/*VRCMP:*/1, /*LCAP:*/0, /*FLSH:*/0, /*ID:*/0);
        flash_power_off    (/*VRCMP:*/1, /*LCAP:*/1, /*FLSH:*/1);
        check_power_status (/*VRCMP:*/0, /*LCAP:*/0, /*FLSH:*/0, /*ID:*/1);

        //-------------------------------------------------------------------
        // SEL_PWR_ON_WUP = 2 (VRCMP and LCAP)
        write_reg (`FLS_ADDR, `REGID_FPWRCNF, {17'h0, /*IRQ:*/1'h1, /*SEL:*/3'h2, /*CUSTOM:*/1'h0, /*AUTO-OFF:*/1'h0, /*AUTO-ON:*/1'h0});
        target_sleep_full_prefix;

        //-------------------------------------------------------------------
        // Wake-up the layer controller by writing into FLSH_START_ADDR.
        write_reg (`FLS_ADDR, `REGID_FADR, 2);
        wait_interrupt ({24'b0, `POWER_ON_5});
        check_power_status (/*VRCMP:*/1, /*LCAP:*/1, /*FLSH:*/0, /*ID:*/2);
        flash_power_off    (/*VRCMP:*/1, /*LCAP:*/1, /*FLSH:*/1);
        check_power_status (/*VRCMP:*/0, /*LCAP:*/0, /*FLSH:*/0, /*ID:*/3);

        //-------------------------------------------------------------------
        // SEL_PWR_ON_WUP = 3 (VRCMP and FLSH)
        write_reg (`FLS_ADDR, `REGID_FPWRCNF, {17'h0, /*IRQ:*/1'h1, /*SEL:*/3'h3, /*CUSTOM:*/1'h0, /*AUTO-OFF:*/1'h0, /*AUTO-ON:*/1'h0});
        target_sleep_full_prefix;

        //-------------------------------------------------------------------
        // Wake-up the layer controller by writing into FLSH_START_ADDR.
        write_reg (`FLS_ADDR, `REGID_FADR, 3);
        wait_interrupt ({24'b0, `POWER_ON_5});
        check_power_status (/*VRCMP:*/1, /*LCAP:*/0, /*FLSH:*/1, /*ID:*/4);
        flash_power_off    (/*VRCMP:*/1, /*LCAP:*/1, /*FLSH:*/1);
        check_power_status (/*VRCMP:*/0, /*LCAP:*/0, /*FLSH:*/0, /*ID:*/5);

        //-------------------------------------------------------------------
        // SEL_PWR_ON_WUP = 4 (VRCMP and LCAP and FLSH)
        write_reg (`FLS_ADDR, `REGID_FPWRCNF, {17'h0, /*IRQ:*/1'h1, /*SEL:*/3'h4, /*CUSTOM:*/1'h0, /*AUTO-OFF:*/1'h0, /*AUTO-ON:*/1'h0});
        target_sleep_full_prefix;

        //-------------------------------------------------------------------
        // Wake-up the layer controller by writing into FLSH_START_ADDR.
        write_reg (`FLS_ADDR, `REGID_FADR, 4);
        wait_interrupt ({24'b0, `POWER_ON_5});
        check_power_status (/*VRCMP:*/1, /*LCAP:*/1, /*FLSH:*/1, /*ID:*/6);
        flash_power_off    (/*VRCMP:*/1, /*LCAP:*/1, /*FLSH:*/1);
        check_power_status (/*VRCMP:*/0, /*LCAP:*/0, /*FLSH:*/0, /*ID:*/7);

        //-------------------------------------------------------------------
        // SEL_PWR_ON_WUP = 0 (Disabled)
        write_reg (`FLS_ADDR, `REGID_FPWRCNF, {17'h0, /*IRQ:*/1'h0, /*SEL:*/3'h0, /*CUSTOM:*/1'h0, /*AUTO-OFF:*/1'h0, /*AUTO-ON:*/1'h0});
        write_reg (`FLS_ADDR, `REGID_FADR, 0);
        target_sleep_full_prefix;

        pass;

        `TEST_WAIT;
    end
endtask // test_power_on_wakeup

task test_flash_power_on_off;
    begin
        `_GREEN_B;
        $display("\n\n");
        $display("***********************************************");
        $display("***********************************************");
        $display("**     TEST: Flash Power On/Off Sequence     **");
        $display("***********************************************");
        $display("***********************************************");
        $display("*** Time %0dns: [TB] Start Testing...", $time);
        $display("\n\n");
        `_RESET;

        //-------------------------------------------------------------------
        // Make sure everything is off.
        check_power_status (/*VRCMP:*/0, /*LCAP:*/0, /*FLSH:*/0, /*ID:*/0);

        //-------------------------------------------------------------------
        // Turn Everything On and Off
        flash_power_on     (/*VRCMP:*/1, /*LCAP:*/1, /*FLSH:*/1);
        check_power_status (/*VRCMP:*/1, /*LCAP:*/1, /*FLSH:*/1, /*ID:*/1);

        flash_power_off    (/*VRCMP:*/1, /*LCAP:*/1, /*FLSH:*/1);
        check_power_status (/*VRCMP:*/0, /*LCAP:*/0, /*FLSH:*/0, /*ID:*/2);

        //-------------------------------------------------------------------
        // Turn VRCMP and FLSH on/off and keep LCAP off.
        flash_power_on     (/*VRCMP:*/1, /*LCAP:*/0, /*FLSH:*/1);
        check_power_status (/*VRCMP:*/1, /*LCAP:*/0, /*FLSH:*/1, /*ID:*/3);

        flash_power_off    (/*VRCMP:*/1, /*LCAP:*/0, /*FLSH:*/1);
        check_power_status (/*VRCMP:*/0, /*LCAP:*/0, /*FLSH:*/0, /*ID:*/4);

        //-------------------------------------------------------------------
        // Turn VRCMP and FLSH on/off and keep LCAP off. (Different Off option)
        flash_power_on     (/*VRCMP:*/1, /*LCAP:*/0, /*FLSH:*/1);
        check_power_status (/*VRCMP:*/1, /*LCAP:*/0, /*FLSH:*/1, /*ID:*/5);

        flash_power_off    (/*VRCMP:*/1, /*LCAP:*/1, /*FLSH:*/1);
        check_power_status (/*VRCMP:*/0, /*LCAP:*/0, /*FLSH:*/0, /*ID:*/6);

        //-------------------------------------------------------------------
        // Turn everything on/off while LCAP is kept on
        flash_power_on     (/*VRCMP:*/1, /*LCAP:*/1, /*FLSH:*/1);
        check_power_status (/*VRCMP:*/1, /*LCAP:*/1, /*FLSH:*/1, /*ID:*/7);
        
        flash_power_off    (/*VRCMP:*/1, /*LCAP:*/0, /*FLSH:*/1);
        check_power_status (/*VRCMP:*/0, /*LCAP:*/1, /*FLSH:*/0, /*ID:*/8);

        //-------------------------------------------------------------------
        // Turn LCAP off
        flash_power_off    (/*VRCMP:*/0, /*LCAP:*/1, /*FLSH:*/0);
        check_power_status (/*VRCMP:*/0, /*LCAP:*/0, /*FLSH:*/0, /*ID:*/9);

        //-------------------------------------------------------------------
        // Turn on VRCMP only
        flash_power_on     (/*VRCMP:*/1, /*LCAP:*/0, /*FLSH:*/0);
        check_power_status (/*VRCMP:*/1, /*LCAP:*/0, /*FLSH:*/0, /*ID:*/10);
        
        //-------------------------------------------------------------------
        // Turn on FLSH only
        flash_power_on     (/*VRCMP:*/0, /*LCAP:*/0, /*FLSH:*/1);
        check_power_status (/*VRCMP:*/1, /*LCAP:*/0, /*FLSH:*/1, /*ID:*/11);
        
        //-------------------------------------------------------------------
        // Turn on LCAP only
        flash_power_on     (/*VRCMP:*/0, /*LCAP:*/1, /*FLSH:*/0);
        check_power_status (/*VRCMP:*/1, /*LCAP:*/1, /*FLSH:*/1, /*ID:*/12);
        
        //-------------------------------------------------------------------
        // Turn off LCAP only
        flash_power_off    (/*VRCMP:*/0, /*LCAP:*/1, /*FLSH:*/0);
        check_power_status (/*VRCMP:*/1, /*LCAP:*/0, /*FLSH:*/1, /*ID:*/13);
        
        //-------------------------------------------------------------------
        // Turn off FLSH only
        flash_power_off    (/*VRCMP:*/0, /*LCAP:*/0, /*FLSH:*/1);
        check_power_status (/*VRCMP:*/1, /*LCAP:*/0, /*FLSH:*/0, /*ID:*/14);
        
        //-------------------------------------------------------------------
        // Turn off VRCMP only
        flash_power_off    (/*VRCMP:*/1, /*LCAP:*/0, /*FLSH:*/0);
        check_power_status (/*VRCMP:*/0, /*LCAP:*/0, /*FLSH:*/0, /*ID:*/15);

        target_sleep_full_prefix;

        pass;

        `TEST_WAIT;
    end
endtask // test_flash_power_on_off

//********************************************
// External Streaming
//********************************************

task ext_stream;
    input [`TB_LENGTH_EXT_WIDTH:0] num_words;
    integer idx_i;
    reg [31:0] random_data;
    begin
        $display("");
        $display("***********************************************");
        $display("*******************Ext Test********************");
        $display("***********************************************");
        $display("");

      //$readmemb(`FLS_EXT_DATA_WIDTH2, data_width_2);
        for (idx_i=0; idx_i<`FLS_NUM_EXT_DATA_WIDTH2; idx_i++) data_width_2[idx_i] = $random;

        write_reg (`FLS_ADDR, `REGID_CNFEXT, {1'h0, 1'h0, 2'h3});
        write_reg (`FLS_ADDR, `REGID_TMOUTEXT, {`TB_TIMEPAR_WIDTH{1'b1}});
        write_reg (`FLS_ADDR, `REGID_GO, {(num_words-1), 1'b1, `EXT_WR_SRAM, 1'b1});

        delay_mbc (100);
        CLK_EXT_release = 1'b1;

        wait_interrupt ({{24{1'b0}},`RSVD_STATE});

        @(posedge CLK_MBC);
        CLK_EXT_release = 1'b0;

        for (idx_i=0; idx_i<num_words; idx_i++) begin
            sram_mem[idx_i] = { data_width_2[16*idx_i+0],  data_width_2[16*idx_i+1],
                                data_width_2[16*idx_i+2],  data_width_2[16*idx_i+3],
                                data_width_2[16*idx_i+4],  data_width_2[16*idx_i+5],
                                data_width_2[16*idx_i+6],  data_width_2[16*idx_i+7],
                                data_width_2[16*idx_i+8],  data_width_2[16*idx_i+9],
                                data_width_2[16*idx_i+10], data_width_2[16*idx_i+11],
                                data_width_2[16*idx_i+12], data_width_2[16*idx_i+13],
                                data_width_2[16*idx_i+14], data_width_2[16*idx_i+15] };
        end

        delay_mbc (30);
    end
endtask // ext_stream

task test_ext_stream;
    begin
        `_GREEN_B;
        $display("\n\n");
        $display("***********************************************");
        $display("***********************************************");
        $display("**        TEST: External Streaming           **");
        $display("***********************************************");
        $display("***********************************************");
        $display("*** Time %0dns: [TB] Start Testing...", $time);
        $display("\n\n");
        `_RESET;

        ext_stream(`TB_SRAM_NUM_WORDS);
        check_sram;
        target_sleep_full_prefix;
        
        ext_stream(100);
        check_sram;
        
        ext_stream(1000);
        check_sram;
        
        ext_stream(512);
        check_sram;

        ext_stream(`TB_SRAM_NUM_WORDS);
        check_sram;
        target_sleep_full_prefix;

        `TEST_WAIT;
    end
endtask // test_ext_stream

//********************************************
// Ping-Pong Check
//********************************************
task check_pp_flags;
    input [31:0] ID;
    input END_OF_FLASH;
    input STR_LIMIT;
    input COPY_LIMIT;
    input [`PP_COUNTER_WIDTH-1:0] LENGTH_STREAMED; // 20(L), 17(S)
    input [`PP_COUNTER_WIDTH-1:0] LENGTH_COPIED; // 20(L), 17(S)
    input [`OP_FLASH_ADDR_WIDTH-1:0] FLSH_ADDR; // 19(L), 16(S)
    begin
        if (`TB_INSTNAME.`TB_LCRF_NAME.PP_FLAG_END_OF_FLASH !== END_OF_FLASH)  begin $display ("CHECK_PP_FLAGS FAILURE!! (PP_FLAG_END_OF_FLASH)  ID=%d", ID); failure; end
        if (`TB_INSTNAME.`TB_LCRF_NAME.PP_FLAG_STR_LIMIT !== STR_LIMIT)        begin $display ("CHECK_PP_FLAGS FAILURE!! (PP_FLAG_STR_LIMIT)  ID=%d", ID); failure; end
        if (`TB_INSTNAME.`TB_LCRF_NAME.PP_FLAG_COPY_LIMIT !== COPY_LIMIT)      begin $display ("CHECK_PP_FLAGS FAILURE!! (PP_FLAG_COPY_LIMIT)  ID=%d", ID); failure; end
        if (`TB_INSTNAME.`TB_LCRF_NAME.PP_LENGTH_STREAMED !== LENGTH_STREAMED) begin $display ("CHECK_PP_FLAGS FAILURE!! (PP_LENGTH_STREAMED)  ID=%d", ID); failure; end
        if (`TB_INSTNAME.`TB_LCRF_NAME.PP_LENGTH_COPIED !== LENGTH_COPIED)     begin $display ("CHECK_PP_FLAGS FAILURE!! (PP_LENGTH_COPIED)  ID=%d", ID); failure; end
        if (`TB_INSTNAME.`TB_RF_NAME.PP_FLSH_ADDR !== FLSH_ADDR)               begin $display ("CHECK_PP_FLAGS FAILURE!! (PP_FLSH_ADDR)  ID=%d", ID); failure; end
        $display ("*** Time %0dns: CHECK_PP_FLAGS PASSED!! ID=%d", $time, ID);
        $display ("");
        delay_mbc (30);
    end
endtask // check_pp_flags;

//********************************************
// Ping-Pong External Streaming
//********************************************

task pp_ext_stream_start_unlim;
    input [31:0] id;
    input set_flash_start_addr;
    input [31:0] flash_start_page_id;
    input fast_prog;
    input wrap;
    reg [`TB_FLASH_ADDR_WIDTH-1:0] flash_start_addr;
    reg [`TB_FLASH_ADDR_WIDTH-1:0] page_size;
    integer idx_i;
    begin
        $display("");
        $display("***********************************************");
        $display("*************Ping-Pong Ext Test");
        $display("*************Unlimited (ID: %0d)", id); 
        $display("***********************************************");
        $display("");

        page_size = 1 << (`TB_FLASH_PAGE_WIDTH - 1);
        flash_start_addr = flash_start_page_id << (`TB_FLASH_PAGE_WIDTH - 1);

        for (idx_i=0; idx_i<`TB_FLASH_NUM_WORD2; idx_i++) data_width_2[idx_i] = $random;

        write_reg (`FLS_ADDR, `REGID_PPCONF, {fast_prog, wrap, 2'b11});
        write_reg (`FLS_ADDR, `REGID_PPGO,   {31'b0, 1'b1}); // Enable PP_STR_EN
        if (set_flash_start_addr) write_reg (`FLS_ADDR, `REGID_PPFADR, flash_start_addr);
        write_reg (`FLS_ADDR, `REGID_GO, {{`TB_PAGE_WIDTH{1'b1}}, 1'b1, `EXT_WR_SRAM, 1'b1});

        delay_mbc (100);
        CLK_EXT_release = 1'b1;
    end
endtask // pp_ext_stream_start_unlim

task pp_ext_stream_stop_unlim;
    input [7:0] irq_payload;
    reg [`TB_FLASH_ADDR_WIDTH-1:0] flash_start_addr;
    reg [`TB_FLASH_ADDR_WIDTH-1:0] page_size;
    integer idx_i;
    begin

        write_reg (`FLS_ADDR, `REGID_PPGO,   {31'b0, 1'b0}); // Reset PP_STR_EN

        wait_interrupt ({{24{1'b0}}, irq_payload});

        @(posedge CLK_MBC);
        CLK_EXT_release = 1'b0;

        delay_mbc (30);
    end
endtask // pp_ext_stream_stop_unlim

task pp_ext_stream;
    input [31:0] id;
    input set_flash_start_addr;
    input [31:0] flash_start_page_id;
    input [31:0] num_words; // number of words. 0 means no limit. (max: 524288(L), 65536(S))
    input fast_prog;
    input wrap;
    input compare;
    input [7:0] irq_payload;
    reg [`TB_FLASH_ADDR_WIDTH-1:0] flash_start_addr;
    reg [`TB_FLASH_ADDR_WIDTH-1:0] page_size;
    integer idx_i;
    begin
        $display("");
        $display("***********************************************");
        $display("*************Ping-Pong Ext Test (ID: %0d)", id);
        $display("***********************************************");
        $display("");

        page_size = 1 << (`TB_FLASH_PAGE_WIDTH - 1);
        flash_start_addr = flash_start_page_id << (`TB_FLASH_PAGE_WIDTH - 1);

        for (idx_i=0; idx_i<`TB_FLASH_NUM_WORD2; idx_i++) data_width_2[idx_i] = $random;

        write_reg (`FLS_ADDR, `REGID_PPCONF, {fast_prog, wrap, 2'b11});
        write_reg (`FLS_ADDR, `REGID_PPGO,   {num_words, 1'b1}); // Enable PP_STR_EN
        if (set_flash_start_addr) write_reg (`FLS_ADDR, `REGID_PPFADR, flash_start_addr);
        write_reg (`FLS_ADDR, `REGID_GO, {{`TB_PAGE_WIDTH{1'b1}}, 1'b1, `EXT_WR_SRAM, 1'b1});

        delay_mbc (100);
        CLK_EXT_release = 1'b1;

        wait_interrupt ({{24{1'b0}}, irq_payload});

        @(posedge CLK_MBC);
        CLK_EXT_release = 1'b0;

        if (compare) begin
            for (idx_i=0; idx_i<num_words; idx_i++) begin
                flsh_mem[flash_start_addr+idx_i] = { data_width_2[16*idx_i+0],  data_width_2[16*idx_i+1],
                                                     data_width_2[16*idx_i+2],  data_width_2[16*idx_i+3],
                                                     data_width_2[16*idx_i+4],  data_width_2[16*idx_i+5],
                                                     data_width_2[16*idx_i+6],  data_width_2[16*idx_i+7],
                                                     data_width_2[16*idx_i+8],  data_width_2[16*idx_i+9],
                                                     data_width_2[16*idx_i+10], data_width_2[16*idx_i+11],
                                                     data_width_2[16*idx_i+12], data_width_2[16*idx_i+13],
                                                     data_width_2[16*idx_i+14], data_width_2[16*idx_i+15] };
            end
            delay_mbc (30);
            for (idx_i=flash_start_addr; idx_i<(flash_start_addr+num_words); idx_i++) begin
                if ({   `TB_INSTNAME.`TB_CTRL_NAME.Flash_0.main_mem[4*idx_i+3], 
                        `TB_INSTNAME.`TB_CTRL_NAME.Flash_0.main_mem[4*idx_i+2], 
                        `TB_INSTNAME.`TB_CTRL_NAME.Flash_0.main_mem[4*idx_i+1], 
                        `TB_INSTNAME.`TB_CTRL_NAME.Flash_0.main_mem[4*idx_i]} 
                        !== flsh_mem[idx_i]) begin
                    `_RED; $display("* FLSH_CHECK FAILURE: flsh_mem[%5d]=0x%8h, DUT[%5d-%5d]=0x%8h", idx_i, flsh_mem[idx_i], 4*idx_i+3, 4*idx_i, 
                    {   `TB_INSTNAME.`TB_CTRL_NAME.Flash_0.main_mem[4*idx_i+3], 
                        `TB_INSTNAME.`TB_CTRL_NAME.Flash_0.main_mem[4*idx_i+2],
                        `TB_INSTNAME.`TB_CTRL_NAME.Flash_0.main_mem[4*idx_i+1],
                        `TB_INSTNAME.`TB_CTRL_NAME.Flash_0.main_mem[4*idx_i]}
                        ); `_RESET;
                    failure;
                end
            end
        end
        else begin
            delay_mbc (30);
        end
    end
endtask // pp_ext_stream

task test_pp_ext_stream;
    integer tb_nw_whole;
    integer tb_nw_in_page;
    integer tb_nw_0_to_1;
    integer tb_nw_4_to_5;
    integer tb_nw_str_unlim;
    integer idx_i;
    begin
        `_GREEN_B;
        $display("\n\n");
        $display("***********************************************");
        $display("***********************************************");
        $display("**    TEST: External Ping-Pong Streaming     **");
        $display("***********************************************");
        $display("***********************************************");
        $display("*** Time %0dns: [TB] Start Testing...", $time);
        $display("\n\n");
        `_RESET;

        tb_nw_whole   = `TB_FLASH_NUM_WORD;     // # words in a whole flash: 524288(L), 65536(S)
        tb_nw_in_page = `TB_FLASH_NUM_WORDP;    // # words in a page: 2048(L), 512(S)
        tb_nw_0_to_1  = 200;                    // # words larger than 0 page and less than 1 page
        tb_nw_4_to_5  = (4*tb_nw_in_page)+200; // # words larger than 4 pages and less than 5 pages

        tb_nw_str_unlim = 65;

        // Set Auto-Power Configuration
        write_reg (`FLS_ADDR, `REGID_FPWRCNF, {17'h0, /*IRQ:*/1'h0, /*SEL:*/3'h0, /*CUSTOM:*/1'h0, /*AUTO-OFF:*/1'h0, /*AUTO-ON:*/1'h0});
        flash_power_on (/*VRCMP:*/1, /*LCAP:*/1, /*FLSH:*/1);

        erase_flash_whole;

        // Un-limited Listening. User stops the operation. Fast Programming.
        pp_ext_stream_start_unlim(/*ID:*/0, /*SET_FLSH_ADDR:*/1, /*PAGE_ID:*/0, /*FAST-PROG:*/1, /*WRAP:*/0);
        for(idx_i=0; idx_i<2048; idx_i++) begin `FLS_EXT_HALF_PERIOD_EQ; end
        pp_ext_stream_stop_unlim(/*IRQ:*/`PP_STR_EXT_STOPPED_1);
        check_pp_flags(/*ID:*/0, /*EOF:*/0, /*STR_LIMIT:*/0, /*COPY_LIMIT:*/0, /*LENGTH_STR:*/tb_nw_str_unlim, /*LENGTH_CPY:*/tb_nw_str_unlim, /*FLSH_ADDR:*/tb_nw_in_page);

        erase_flash_whole;

        // Un-limited Listening. User stops the operation. Standard Programming.
        pp_ext_stream_start_unlim(/*ID:*/1, /*SET_FLSH_ADDR:*/1, /*PAGE_ID:*/0, /*FAST-PROG:*/0, /*WRAP:*/0);
        for(idx_i=0; idx_i<2048; idx_i++) begin `FLS_EXT_HALF_PERIOD_EQ; end
        pp_ext_stream_stop_unlim(/*IRQ:*/`PP_STR_EXT_STOPPED_1);
        check_pp_flags(/*ID:*/0, /*EOF:*/0, /*STR_LIMIT:*/0, /*COPY_LIMIT:*/0, /*LENGTH_STR:*/tb_nw_str_unlim, /*LENGTH_CPY:*/tb_nw_str_unlim, /*FLSH_ADDR:*/tb_nw_in_page);

        erase_flash_whole;

        // Write a small amount of data (less than 1 page) - Starting from page 0, Fast Programming, No Wrap, Compare
        pp_ext_stream(/*ID:*/0, /*SET_FLSH_ADDR:*/1, /*PAGE_ID:*/0, /*NUM_WORDS:*/tb_nw_0_to_1,    /*FAST-PROG:*/1, /*WRAP:*/0, /*COMPARE:*/1, /*IRQ:*/`PP_STR_2);
        check_pp_flags(/*ID:*/10, /*EOF:*/0, /*STR_LIMIT:*/1, /*COPY_LIMIT:*/1, /*LENGTH_STR:*/tb_nw_0_to_1, /*LENGTH_CPY:*/tb_nw_0_to_1, /*FLSH_ADDR:*/tb_nw_in_page);

        // Write data longer than 4 pages & shorter than 5 pages - Resume from prev addr, Fast Programming, No Wrap, No Compare
        pp_ext_stream(/*ID:*/1, /*SET_FLSH_ADDR:*/0, /*PAGE_ID:*/0, /*NUM_WORDS:*/tb_nw_4_to_5, /*FAST-PROG:*/1, /*WRAP:*/0, /*COMPARE:*/0, /*IRQ:*/`PP_STR_2);
        check_pp_flags(/*ID:*/11, /*EOF:*/0, /*STR_LIMIT:*/1, /*COPY_LIMIT:*/1, /*LENGTH_STR:*/tb_nw_4_to_5, /*LENGTH_CPY:*/tb_nw_4_to_5, /*FLSH_ADDR:*/(6*tb_nw_in_page));
        
        erase_flash_whole;

        // Fill the whole flash - Starting from page 0, Fast Programming, No Wrap, Compare
        pp_ext_stream(/*ID:*/2, /*SET_FLSH_ADDR:*/1, /*PAGE_ID:*/0, /*NUM_WORDS:*/tb_nw_whole,   /*FAST-PROG:*/1, /*WRAP:*/0, /*COMPARE:*/1, /*IRQ:*/`PP_STR_2);
        check_pp_flags(/*ID:*/12, /*EOF:*/1, /*STR_LIMIT:*/1, /*COPY_LIMIT:*/1, /*LENGTH_STR:*/tb_nw_whole, /*LENGTH_CPY:*/tb_nw_whole, /*FLSH_ADDR:*/0);

        erase_flash_whole;

        // Fill the whole flash - Starting from page 1, Fast Programming, Wrap, No Compare
        pp_ext_stream(/*ID:*/3, /*SET_FLSH_ADDR:*/1, /*PAGE_ID:*/1, /*NUM_WORDS:*/tb_nw_whole,   /*FAST-PROG:*/1, /*WRAP:*/1, /*COMPARE:*/0, /*IRQ:*/`PP_STR_2);
        check_pp_flags(/*ID:*/13, /*EOF:*/0, /*STR_LIMIT:*/1, /*COPY_LIMIT:*/1, /*LENGTH_STR:*/tb_nw_whole, /*LENGTH_CPY:*/tb_nw_whole, /*FLSH_ADDR:*/tb_nw_in_page);

        erase_flash_whole;

        // Fill the whole flash - Starting from page 0, Standard Programming, No Wrap, Compare
        pp_ext_stream(/*ID:*/4, /*SET_FLSH_ADDR:*/1, /*PAGE_ID:*/0, /*NUM_WORDS:*/tb_nw_whole,   /*FAST-PROG:*/0, /*WRAP:*/0, /*COMPARE:*/1, /*IRQ:*/`PP_STR_2);
        check_pp_flags(/*ID:*/14, /*EOF:*/1, /*STR_LIMIT:*/1, /*COPY_LIMIT:*/1, /*LENGTH_STR:*/tb_nw_whole, /*LENGTH_CPY:*/tb_nw_whole, /*FLSH_ADDR:*/0);

        erase_flash_whole;

        // Fill the whole flash - Starting from page 1, Standard Programming, Wrap, No Compare
        pp_ext_stream(/*ID:*/5, /*SET_FLSH_ADDR:*/1, /*PAGE_ID:*/1, /*NUM_WORDS:*/tb_nw_whole,   /*FAST-PROG:*/0, /*WRAP:*/1, /*COMPARE:*/0, /*IRQ:*/`PP_STR_2);
        check_pp_flags(/*ID:*/15, /*EOF:*/0, /*STR_LIMIT:*/1, /*COPY_LIMIT:*/1, /*LENGTH_STR:*/tb_nw_whole, /*LENGTH_CPY:*/tb_nw_whole, /*FLSH_ADDR:*/tb_nw_in_page);

        flash_power_off (/*VRCMP:*/1, /*LCAP:*/1, /*FLSH:*/1);
        target_sleep_full_prefix;

        `TEST_WAIT;
    end
endtask // test_pp_ext_stream


//********************************************
// Ping-Pong MBus Streaming
//********************************************

task pp_mbus_stream;
    input [31:0] id;
    input [1:0] str_channel;
    input set_flash_start_addr;
    input [31:0] flash_start_page_id;
    input [31:0] num_words; // number of words. 0 means no limit. (max: 524288(L), 65536(S))
    input fast_prog;
    input wrap;
    input compare;
    input [7:0] irq_payload;
    reg [`TB_FLASH_ADDR_WIDTH-1:0] flash_start_addr;
    reg [`TB_FLASH_ADDR_WIDTH-1:0] page_size;
    integer idx_i;
    begin
        $display("");
        $display("***********************************************");
        $display("*************Ping-Pong MBus Test (ID: %0d)", id);
        $display("***********************************************");
        $display("");

        page_size = 1 << (`TB_FLASH_PAGE_WIDTH - 1);
        flash_start_addr = flash_start_page_id << (`TB_FLASH_PAGE_WIDTH - 1);

        write_reg (`FLS_ADDR, `REGID_PPCONF, {fast_prog, wrap, 2'b0});
        write_reg (`FLS_ADDR, `REGID_PPGO,   {num_words, 1'b1}); // Enable PP_STR_EN
        if      (str_channel == 2'b00) write_reg (`FLS_ADDR, `REGID_CH0OFF, 0);
        else if (str_channel == 2'b01) write_reg (`FLS_ADDR, `REGID_CH1OFF, 0);
        if (set_flash_start_addr) write_reg (`FLS_ADDR, `REGID_PPFADR, flash_start_addr);

        send_MBus_random_stream ({`FLS_ADDR, 2'h1, str_channel}, num_words, compare, flash_start_addr);

        wait_interrupt ({{24{1'b0}}, irq_payload});

        if (compare) begin
            delay_mbc (30);
            for (idx_i=flash_start_addr; idx_i<(flash_start_addr+num_words); idx_i++) begin
                if ({   `TB_INSTNAME.`TB_CTRL_NAME.Flash_0.main_mem[4*idx_i+3], 
                        `TB_INSTNAME.`TB_CTRL_NAME.Flash_0.main_mem[4*idx_i+2], 
                        `TB_INSTNAME.`TB_CTRL_NAME.Flash_0.main_mem[4*idx_i+1], 
                        `TB_INSTNAME.`TB_CTRL_NAME.Flash_0.main_mem[4*idx_i]} 
                        !== flsh_mem[idx_i]) begin
                    `_RED; $display("* FLSH_CHECK FAILURE: flsh_mem[%5d]=0x%8h, DUT[%5d-%5d]=0x%8h", idx_i, flsh_mem[idx_i], 4*idx_i+3, 4*idx_i, 
                    {   `TB_INSTNAME.`TB_CTRL_NAME.Flash_0.main_mem[4*idx_i+3], 
                        `TB_INSTNAME.`TB_CTRL_NAME.Flash_0.main_mem[4*idx_i+2],
                        `TB_INSTNAME.`TB_CTRL_NAME.Flash_0.main_mem[4*idx_i+1],
                        `TB_INSTNAME.`TB_CTRL_NAME.Flash_0.main_mem[4*idx_i]}
                        ); `_RESET;
                    failure;
                end
            end
        end
        else begin
            delay_mbc (30);
        end
    end
endtask // pp_mbus_stream

task test_pp_mbus_stream;
    integer tb_nw_mthresh;
    integer tb_np_whole;
    integer tb_np_mthresh;
    integer tb_num_iter;
    integer tb_nw_in_page;
    integer tb_nw_0_to_1;
    integer tb_nw_4_to_5;
    integer idx_i;
    begin
        `_GREEN_B;
        $display("\n\n");
        $display("***********************************************");
        $display("***********************************************");
        $display("**    TEST: MBus Ping-Pong Streaming         **");
        $display("***********************************************");
        $display("***********************************************");
        $display("*** Time %0dns: [TB] Start Testing...", $time);
        $display("\n\n");
        `_RESET;

        tb_nw_mthresh = 16384;                 // # words in MBus Threshold: 16384 = 8 Pages(L), 32 Pages (S)
        tb_np_whole   = `TB_FLASH_NUM_PAGES;      // # pages in a whole flash
        tb_np_mthresh = `TB_FLASH_NUM_PAGES_MTH;  // # pages in MBus Threshold
        tb_num_iter   = `TB_FLASH_NUM_ITER_0;     // tb_np_whole / tb_np_mthresho
        tb_nw_in_page = `TB_FLASH_NUM_WORDP;   // # words in a page: 2048(L), 512(S)
        tb_nw_0_to_1  = 200;                   // # words larger than 0 page and less than 1 page
        tb_nw_4_to_5  = (4*tb_nw_in_page)+200; // # words larger than 4 pages and less than 5 pages

        // Set Auto-Power Configuration
        write_reg (`FLS_ADDR, `REGID_FPWRCNF, {17'h0, /*IRQ:*/1'h0, /*SEL:*/3'h0, /*CUSTOM:*/1'h0, /*AUTO-OFF:*/1'h0, /*AUTO-ON:*/1'h0});
        flash_power_on (/*VRCMP:*/1, /*LCAP:*/1, /*FLSH:*/1);
        
        erase_flash_whole;

        // Write a small amount of data (less than 1 page) - Starting from page 0, Fast Programming, No Wrap, Compare
        pp_mbus_stream(/*ID:*/0, /*CH:*/0, /*SET_FLSH_ADDR:*/1, /*PAGE_ID:*/0, /*NUM_WORDS:*/tb_nw_0_to_1,    /*FAST-PROG:*/1, /*WRAP:*/0, /*COMPARE:*/1, /*IRQ:*/`PP_STR_2);
        check_pp_flags(/*ID:*/0, /*EOF:*/0, /*STR_LIMIT:*/1, /*COPY_LIMIT:*/1, /*LENGTH_STR:*/tb_nw_0_to_1, /*LENGTH_CPY:*/tb_nw_0_to_1, /*FLSH_ADDR:*/tb_nw_in_page);

        // Write data longer than 4 pages & shorter than 5 pages - Resume from prev addr, Fast Programming, No Wrap, No Compare
        pp_mbus_stream(/*ID:*/1, /*CH:*/0, /*SET_FLSH_ADDR:*/0, /*PAGE_ID:*/0, /*NUM_WORDS:*/tb_nw_4_to_5, /*FAST-PROG:*/1, /*WRAP:*/0, /*COMPARE:*/0, /*IRQ:*/`PP_STR_2);
        check_pp_flags(/*ID:*/1, /*EOF:*/0, /*STR_LIMIT:*/1, /*COPY_LIMIT:*/1, /*LENGTH_STR:*/tb_nw_4_to_5, /*LENGTH_CPY:*/tb_nw_4_to_5, /*FLSH_ADDR:*/(6*tb_nw_in_page));
        
        erase_flash_whole;

        // Fill the whole flash - Starting from page 0, Fast Programming, No Wrap, Compare
        for (idx_i=0; idx_i<tb_num_iter; idx_i++) begin
            if (idx_i == 0) begin
                pp_mbus_stream(/*ID:*/2, /*CH:*/0, /*SET_FLSH_ADDR:*/1, /*PAGE_ID:*/(idx_i*tb_np_mthresh), /*NUM_WORDS:*/tb_nw_mthresh,   /*FAST-PROG:*/1, /*WRAP:*/0, /*COMPARE:*/1, /*IRQ:*/`PP_STR_2);
                check_pp_flags(/*ID:*/(100+idx_i), /*EOF:*/0, /*STR_LIMIT:*/1, /*COPY_LIMIT:*/1, /*LENGTH_STR:*/tb_nw_mthresh, /*LENGTH_CPY:*/tb_nw_mthresh, /*FLSH_ADDR:*/((idx_i+1) * tb_np_mthresh * tb_nw_in_page));
            end 
            else if (idx_i == (tb_num_iter-1)) begin
                pp_mbus_stream(/*ID:*/3, /*CH:*/0, /*SET_FLSH_ADDR:*/0, /*PAGE_ID:*/(idx_i*tb_np_mthresh), /*NUM_WORDS:*/tb_nw_mthresh,   /*FAST-PROG:*/1, /*WRAP:*/0, /*COMPARE:*/1, /*IRQ:*/`PP_STR_2);
                check_pp_flags(/*ID:*/(100+idx_i), /*EOF:*/1, /*STR_LIMIT:*/1, /*COPY_LIMIT:*/1, /*LENGTH_STR:*/tb_nw_mthresh, /*LENGTH_CPY:*/tb_nw_mthresh, /*FLSH_ADDR:*/((idx_i+1) * tb_np_mthresh * tb_nw_in_page));
            end 
            else begin
                pp_mbus_stream(/*ID:*/4, /*CH:*/0, /*SET_FLSH_ADDR:*/0, /*PAGE_ID:*/(idx_i*tb_np_mthresh), /*NUM_WORDS:*/tb_nw_mthresh,   /*FAST-PROG:*/1, /*WRAP:*/0, /*COMPARE:*/1, /*IRQ:*/`PP_STR_2);
                check_pp_flags(/*ID:*/(100+idx_i), /*EOF:*/0, /*STR_LIMIT:*/1, /*COPY_LIMIT:*/1, /*LENGTH_STR:*/tb_nw_mthresh, /*LENGTH_CPY:*/tb_nw_mthresh, /*FLSH_ADDR:*/((idx_i+1) * tb_np_mthresh * tb_nw_in_page));
            end
        end

        erase_flash_whole;

        // Fill the whole flash - Starting from page 1, Fast Programming, Wrap, No Compare
        for (idx_i=0; idx_i<tb_num_iter; idx_i++) begin
            if (idx_i == 0) begin
                pp_mbus_stream(/*ID:*/5, /*CH:*/0, /*SET_FLSH_ADDR:*/1, /*PAGE_ID:*/1, /*NUM_WORDS:*/tb_nw_mthresh,   /*FAST-PROG:*/1, /*WRAP:*/1, /*COMPARE:*/0, /*IRQ:*/`PP_STR_2);
                check_pp_flags(/*ID:*/(200+idx_i), /*EOF:*/0, /*STR_LIMIT:*/1, /*COPY_LIMIT:*/1, /*LENGTH_STR:*/tb_nw_mthresh, /*LENGTH_CPY:*/tb_nw_mthresh, /*FLSH_ADDR:*/(((idx_i+1) * tb_np_mthresh * tb_nw_in_page) + tb_nw_in_page));
            end 
            else if (idx_i == (tb_num_iter-1)) begin
                pp_mbus_stream(/*ID:*/6, /*CH:*/0, /*SET_FLSH_ADDR:*/0, /*PAGE_ID:*/0, /*NUM_WORDS:*/tb_nw_mthresh,   /*FAST-PROG:*/1, /*WRAP:*/1, /*COMPARE:*/0, /*IRQ:*/`PP_STR_2);
                check_pp_flags(/*ID:*/(200+idx_i), /*EOF:*/0, /*STR_LIMIT:*/1, /*COPY_LIMIT:*/1, /*LENGTH_STR:*/tb_nw_mthresh, /*LENGTH_CPY:*/tb_nw_mthresh, /*FLSH_ADDR:*/tb_nw_in_page);
            end 
            else begin
                pp_mbus_stream(/*ID:*/7, /*CH:*/0, /*SET_FLSH_ADDR:*/0, /*PAGE_ID:*/0, /*NUM_WORDS:*/tb_nw_mthresh,   /*FAST-PROG:*/1, /*WRAP:*/1, /*COMPARE:*/0, /*IRQ:*/`PP_STR_2);
                check_pp_flags(/*ID:*/(200+idx_i), /*EOF:*/0, /*STR_LIMIT:*/1, /*COPY_LIMIT:*/1, /*LENGTH_STR:*/tb_nw_mthresh, /*LENGTH_CPY:*/tb_nw_mthresh, /*FLSH_ADDR:*/(((idx_i+1) * tb_np_mthresh * tb_nw_in_page) + tb_nw_in_page));
            end
        end

        erase_flash_whole;

        // Fill the whole flash - Starting from page 0, Standard Programming, No Wrap, Compare
        for (idx_i=0; idx_i<tb_num_iter; idx_i++) begin
            if (idx_i == 0) begin
                pp_mbus_stream(/*ID:*/8, /*CH:*/0, /*SET_FLSH_ADDR:*/1, /*PAGE_ID:*/(idx_i*tb_np_mthresh), /*NUM_WORDS:*/tb_nw_mthresh,   /*FAST-PROG:*/0, /*WRAP:*/0, /*COMPARE:*/1, /*IRQ:*/`PP_STR_2);
                check_pp_flags(/*ID:*/(300+idx_i), /*EOF:*/0, /*STR_LIMIT:*/1, /*COPY_LIMIT:*/1, /*LENGTH_STR:*/tb_nw_mthresh, /*LENGTH_CPY:*/tb_nw_mthresh, /*FLSH_ADDR:*/((idx_i+1) * tb_np_mthresh * tb_nw_in_page));
            end 
            else if (idx_i == (tb_num_iter-1)) begin
                pp_mbus_stream(/*ID:*/9, /*CH:*/0, /*SET_FLSH_ADDR:*/0, /*PAGE_ID:*/(idx_i*tb_np_mthresh), /*NUM_WORDS:*/tb_nw_mthresh,   /*FAST-PROG:*/0, /*WRAP:*/0, /*COMPARE:*/1, /*IRQ:*/`PP_STR_2);
                check_pp_flags(/*ID:*/(300+idx_i), /*EOF:*/1, /*STR_LIMIT:*/1, /*COPY_LIMIT:*/1, /*LENGTH_STR:*/tb_nw_mthresh, /*LENGTH_CPY:*/tb_nw_mthresh, /*FLSH_ADDR:*/((idx_i+1) * tb_np_mthresh * tb_nw_in_page));
            end 
            else begin
                pp_mbus_stream(/*ID:*/10, /*CH:*/0, /*SET_FLSH_ADDR:*/0, /*PAGE_ID:*/(idx_i*tb_np_mthresh), /*NUM_WORDS:*/tb_nw_mthresh,   /*FAST-PROG:*/0, /*WRAP:*/0, /*COMPARE:*/1, /*IRQ:*/`PP_STR_2);
                check_pp_flags(/*ID:*/(300+idx_i), /*EOF:*/0, /*STR_LIMIT:*/1, /*COPY_LIMIT:*/1, /*LENGTH_STR:*/tb_nw_mthresh, /*LENGTH_CPY:*/tb_nw_mthresh, /*FLSH_ADDR:*/((idx_i+1) * tb_np_mthresh * tb_nw_in_page));
            end
        end

        erase_flash_whole;

        // Fill the whole flash - Starting from page 1, Standard Programming, Wrap, No Compare
        for (idx_i=0; idx_i<tb_num_iter; idx_i++) begin
            if (idx_i == 0) begin
                pp_mbus_stream(/*ID:*/11, /*CH:*/0, /*SET_FLSH_ADDR:*/1, /*PAGE_ID:*/1, /*NUM_WORDS:*/tb_nw_mthresh,   /*FAST-PROG:*/0, /*WRAP:*/1, /*COMPARE:*/0, /*IRQ:*/`PP_STR_2);
                check_pp_flags(/*ID:*/(400+idx_i), /*EOF:*/0, /*STR_LIMIT:*/1, /*COPY_LIMIT:*/1, /*LENGTH_STR:*/tb_nw_mthresh, /*LENGTH_CPY:*/tb_nw_mthresh, /*FLSH_ADDR:*/(((idx_i+1) * tb_np_mthresh * tb_nw_in_page) + tb_nw_in_page));
            end 
            else if (idx_i == (tb_num_iter-1)) begin
                pp_mbus_stream(/*ID:*/12, /*CH:*/0, /*SET_FLSH_ADDR:*/0, /*PAGE_ID:*/0, /*NUM_WORDS:*/tb_nw_mthresh,   /*FAST-PROG:*/0, /*WRAP:*/1, /*COMPARE:*/0, /*IRQ:*/`PP_STR_2);
                check_pp_flags(/*ID:*/(400+idx_i), /*EOF:*/0, /*STR_LIMIT:*/1, /*COPY_LIMIT:*/1, /*LENGTH_STR:*/tb_nw_mthresh, /*LENGTH_CPY:*/tb_nw_mthresh, /*FLSH_ADDR:*/tb_nw_in_page);
            end 
            else begin
                pp_mbus_stream(/*ID:*/13, /*CH:*/0, /*SET_FLSH_ADDR:*/0, /*PAGE_ID:*/0, /*NUM_WORDS:*/tb_nw_mthresh,   /*FAST-PROG:*/0, /*WRAP:*/1, /*COMPARE:*/0, /*IRQ:*/`PP_STR_2);
                check_pp_flags(/*ID:*/(400+idx_i), /*EOF:*/0, /*STR_LIMIT:*/1, /*COPY_LIMIT:*/1, /*LENGTH_STR:*/tb_nw_mthresh, /*LENGTH_CPY:*/tb_nw_mthresh, /*FLSH_ADDR:*/(((idx_i+1) * tb_np_mthresh * tb_nw_in_page) + tb_nw_in_page));
            end
        end

        flash_power_off (/*VRCMP:*/1, /*LCAP:*/1, /*FLSH:*/1);
        target_sleep_full_prefix;

        `TEST_WAIT;
    end
endtask // test_pp_mbus_stream

//********************************************
// PASS/FAIL Display
//********************************************

task success;
    begin
        `_BLUE;
        $display("");
        $display("***********************************************");
        $display("*******************!SUCCESS!*******************");
        $display("***************SIMULATION PASSED***************");
        $display("***********************************************");
        $display("");
        `_RESET;
        $finish;
    end
endtask

task failure;
    begin
        `_RED;
        $display("");
        $display("***********************************************");
        $display("*******************!FAILURE!*******************");
        $display("***************SIMULATION FALED****************");
        $display("***********************************************");
        $display("Failure @ Time:", $time);
        $display("");
        `_RESET;
        #1000;
        $finish;
    end
endtask

task pass;
    begin
        `_BLUE;
        $display("");
        $display("***********************************************");
        $display("***************   !!PASSED!!    ***************");
        $display("***********************************************");
        $display("");
        `_RESET;
    end
endtask
