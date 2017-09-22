//********************************************************************************************************************************
// POWER DEBUG DISPLAY
//********************************************************************************************************************************

`ifdef DEBUG_POWER

    ///////////////////////////////
    // MBus Power-On
    ///////////////////////////////
    always @(negedge `TB_INSTNAME.mbc_sleep) if (checking & ~(`TB_INSTNAME.mbc_isolate & `TB_INSTNAME.mbc_reset & `TB_INSTNAME.lc_sleep & `TB_INSTNAME.lc_isolate & ~`TB_INSTNAME.lc_reset_b & ~`TB_INSTNAME.lc_clken))
        begin `_RED_B; $display("\n*** Time %0dns: [ERROR] MBC POWER-ON FAILURE... ", $time); `_RESET; failure; end

    always @(negedge `TB_INSTNAME.mbc_isolate) if (checking & ~(~`TB_INSTNAME.mbc_sleep & `TB_INSTNAME.mbc_reset & `TB_INSTNAME.lc_sleep & `TB_INSTNAME.lc_isolate & ~`TB_INSTNAME.lc_reset_b & ~`TB_INSTNAME.lc_clken)) 
        begin `_RED_B; $display("\n*** Time %0dns: [ERROR] MBC UN-ISOLATE FAILURE... ", $time); `_RESET; failure; end

    always @(negedge `TB_INSTNAME.mbc_reset) begin 
        `_GREEN; $display("\n*** Time %0dns: MBC POWERED-ON... ", $time); `_RESET;
        if (checking & ~(~`TB_INSTNAME.mbc_sleep & ~`TB_INSTNAME.mbc_isolate & `TB_INSTNAME.lc_sleep & `TB_INSTNAME.lc_isolate & ~`TB_INSTNAME.lc_reset_b & ~`TB_INSTNAME.lc_clken)) 
        begin `_RED_B; $display("\n*** Time %0dns: [ERROR] MBC RESET RELEASE FAILURE... ", $time); `_RESET; failure; end
    end

    ///////////////////////////////
    // Layer Controller Power-On
    ///////////////////////////////
    always @(negedge `TB_INSTNAME.lc_sleep) if (checking & ~(~`TB_INSTNAME.mbc_sleep & ~`TB_INSTNAME.mbc_isolate & ~`TB_INSTNAME.mbc_reset & `TB_INSTNAME.lc_isolate & ~`TB_INSTNAME.lc_reset_b & ~`TB_INSTNAME.lc_clken)) 
        begin `_RED_B; $display("\n*** Time %0dns: [ERROR] LAYER_CTRL POWER-ON FAILURE... ", $time); `_RESET; failure; end
    
    always @(negedge `TB_INSTNAME.lc_isolate) if (checking & ~(~`TB_INSTNAME.mbc_sleep & ~`TB_INSTNAME.mbc_isolate & ~`TB_INSTNAME.mbc_reset & ~`TB_INSTNAME.lc_sleep & ~`TB_INSTNAME.lc_reset_b & ~`TB_INSTNAME.lc_clken)) 
        begin `_RED_B; $display("\n*** Time %0dns: [ERROR] LAYER_CTRL UN-ISOLATE FAILURE... ", $time); `_RESET; failure; end
    
    always @(posedge `TB_INSTNAME.lc_reset_b) if (checking & ~(~`TB_INSTNAME.mbc_sleep & ~`TB_INSTNAME.mbc_isolate & ~`TB_INSTNAME.mbc_reset & ~`TB_INSTNAME.lc_sleep & ~`TB_INSTNAME.lc_isolate & ~`TB_INSTNAME.lc_clken)) 
        begin `_RED_B; $display("\n*** Time %0dns: [ERROR] LAYER_CTRL RESET RELEASE FAILURE... ", $time); `_RESET; failure; end
    
    always @(posedge `TB_INSTNAME.lc_clken) begin 
        `_GREEN; $display("\n*** Time %0dns: LAYER_CTRL POWERED-ON AND CLOCK STARTED RUNNING... ", $time); `_RESET;
        if (checking & ~(~`TB_INSTNAME.mbc_sleep & ~`TB_INSTNAME.mbc_isolate & ~`TB_INSTNAME.mbc_reset & ~`TB_INSTNAME.lc_sleep & ~`TB_INSTNAME.lc_isolate & `TB_INSTNAME.lc_reset_b)) 
        begin `_RED_B; $display("\n*** Time %0dns: [ERROR] LAYER_CTRL CLOCK START FAILURE... ", $time); `_RESET; failure; end
    end

    ///////////////////////////////
    // MBus Power-Off
    ///////////////////////////////
    always @(posedge `TB_INSTNAME.mbc_isolate) if (checking & ~(~`TB_INSTNAME.mbc_sleep & ~`TB_INSTNAME.mbc_reset & ~`TB_INSTNAME.lc_sleep & `TB_INSTNAME.lc_isolate & `TB_INSTNAME.lc_reset_b & `TB_INSTNAME.lc_clken)) 
        begin `_RED_B; $display("\n*** Time %0dns: [ERROR] MBC ISOLATE FAILURE... ", $time); `_RESET; failure; end

    always @(posedge `TB_INSTNAME.mbc_reset) if (checking & ~(`TB_INSTNAME.mbc_isolate & `TB_INSTNAME.lc_isolate)) 
        begin `_RED_B; $display("\n*** Time %0dns: [ERROR] MBC RESET FAILURE... ", $time); `_RESET; failure; end

    always @(posedge `TB_INSTNAME.mbc_sleep) begin 
        `_MAGENTA; $display("\n*** Time %0dns: MBC POWERED-OFF... ", $time); `_RESET;
        if (checking & ~(`TB_INSTNAME.mbc_isolate & `TB_INSTNAME.lc_isolate)) 
        begin `_RED_B; $display("\n*** Time %0dns: [ERROR] MBC POWER-OFF FAILURE... ", $time); `_RESET; failure; end
    end

    ///////////////////////////////
    // Layer Controller Power-Off
    ///////////////////////////////
    always @(posedge `TB_INSTNAME.lc_isolate) if (checking & ~(~`TB_INSTNAME.mbc_sleep & ~`TB_INSTNAME.mbc_isolate & ~`TB_INSTNAME.mbc_reset & ~`TB_INSTNAME.lc_sleep & `TB_INSTNAME.lc_reset_b & `TB_INSTNAME.lc_clken)) 
        begin `_RED_B; $display("\n*** Time %0dns: [ERROR] LAYER_CTRL ISOLATE FAILURE... ", $time); `_RESET; failure; end
    
    always @(negedge `TB_INSTNAME.lc_reset_b) if (checking & ~(`TB_INSTNAME.mbc_isolate & `TB_INSTNAME.lc_isolate)) 
        begin `_RED_B; $display("\n*** Time %0dns: [ERROR] LAYER_CTRL RESET FAILURE... ", $time); `_RESET; failure; end

    always @(negedge `TB_INSTNAME.lc_clken) if (checking & ~(`TB_INSTNAME.mbc_isolate & `TB_INSTNAME.lc_isolate)) 
        begin `_RED_B; $display("\n*** Time %0dns: [ERROR] LAYER_CTRL CLOCK STOP FAILURE... ", $time); `_RESET; failure; end

    always @(posedge `TB_INSTNAME.lc_sleep) begin 
        `_MAGENTA; $display("\n*** Time %0dns: LAYER_CTRL POWERED-OFF... ", $time); `_RESET;
        if (checking & ~(`TB_INSTNAME.mbc_isolate & `TB_INSTNAME.lc_isolate)) 
        begin `_RED_B; $display("\n*** Time %0dns: [ERROR] LAYER_CTRL POWER-OFF FAILURE... ", $time); `_RESET; failure; end
    end

`endif

//********************************************************************************************************************************
// MBUS REGISTER FILE DEBUG DISPLAY
//********************************************************************************************************************************

`ifdef DEBUG_RF
    `ifdef FLPv3L
        `include "/afs/eecs.umich.edu/vlsida/projects/m3_hdk/layer/FLP/FLPv3L/verilog/genRF/FLPv3L_rf_debug.v"
    `elsif FLPv3S
        `include "/afs/eecs.umich.edu/vlsida/projects/m3_hdk/layer/FLP/FLPv3S/verilog/genRF/FLPv3S_rf_debug.v"
    `endif
`endif

//********************************************************************************************************************************
// FLP CTRL DEBUG DISPLAY
//********************************************************************************************************************************

`ifdef DEBUG_CTRL
`ifndef APR
wire                        db_clk, db_resetn, db_is_reg_wr_fls;
wire [`STATE_WIDTH-1:0]     db_state, db_next_state;
wire [31:0]                 db_flsh_rd_dout_32, db_bt_reg_chksum, db_bt_mem_chksum, db_bt_mem_addr;
wire [`OP_ECC_EFF_WIDTH-1:0]db_flsh_rd_dout_32_ecc;
wire [23:0]                 db_bt_reg_data;
wire [7:0]                  db_bt_reg_addr;
wire [3:0]                  db_bt_short_prefix, db_enum_short_prefix;
wire [19:0]                 db_bt_layer_addr;
wire [17:0]                 db_bt_cnt, db_bt_mem_length_1;
wire [`SRAM_ADDR_WIDTH-1:0] db_bt_sram_addr;

assign db_clk                   = `TB_INSTNAME.`TB_CTRL_NAME.CLK;
assign db_resetn                = `TB_INSTNAME.`TB_CTRL_NAME.RESETn;
assign db_state                 = `TB_INSTNAME.`TB_CTRL_NAME.state;
assign db_next_state            = `TB_INSTNAME.`TB_CTRL_NAME.next_state;
assign db_flsh_rd_dout_32       = `TB_INSTNAME.`TB_CTRL_NAME.flsh_rd_dout_32;
assign db_flsh_rd_dout_32_ecc   = `TB_INSTNAME.`TB_CTRL_NAME.flsh_rd_dout_32_ecc;
assign db_bt_reg_addr           = `TB_INSTNAME.`TB_CTRL_NAME.bt_reg_addr;
assign db_bt_reg_data           = `TB_INSTNAME.`TB_CTRL_NAME.bt_reg_data;
assign db_bt_short_prefix       = `TB_INSTNAME.`TB_CTRL_NAME.bt_short_prefix;
assign db_bt_reg_chksum         = `TB_INSTNAME.`TB_CTRL_NAME.bt_reg_chksum;
assign db_bt_mem_chksum         = `TB_INSTNAME.`TB_CTRL_NAME.bt_mem_chksum;
assign db_bt_layer_addr         = `TB_INSTNAME.`TB_CTRL_NAME.bt_layer_addr;
assign db_bt_mem_addr           = `TB_INSTNAME.`TB_CTRL_NAME.bt_mem_addr;
assign db_bt_sram_addr          = `TB_INSTNAME.`TB_CTRL_NAME.bt_sram_addr;
assign db_enum_short_prefix     = `TB_INSTNAME.`TB_CTRL_NAME.enum_short_prefix;
assign db_is_reg_wr_fls         = `TB_INSTNAME.`TB_CTRL_NAME.is_reg_wr_fls;
assign db_bt_cnt                = `TB_INSTNAME.`TB_CTRL_NAME.bt_cnt;
assign db_bt_mem_length_1       = `TB_INSTNAME.`TB_CTRL_NAME.bt_mem_length_1;

always @(posedge db_clk or negedge db_resetn) begin
    if (db_state != db_next_state) begin
        if (db_next_state == `BT_MANUAL_0)                $display ("*** Time %0dns: [NOTE] BOOT-UP   || [MANUAL] STARTING MANUAL BOOT-UP", $time);
        else if ((db_next_state == `BT_RD_FLSH_0) && (db_state == `BT_CHK_HEAD_1))    
                                                               $display ("*** Time %0dns: [NOTE] BOOT-UP   || [HEADER] HEADER PATTERN MATCHED (0x%8h)", $time, `BOOT_HEADER);
        else if (db_next_state == `BT_PS_CMND_0)               $display ("*** Time %0dns: [NOTE] BOOT-UP   || [NEW_COMMAND] CODE:0x%8h ECC_DECODED:0x%8h", $time, db_flsh_rd_dout_32, db_flsh_rd_dout_32_ecc);
        else if (db_next_state == `BT_REG_WR_4)  begin
            if (db_is_reg_wr_fls )               begin $display ("*** Time %0dns: [OPER] BOOT-UP   || [REG_WRITE] REG:0x%2h DATA:0x%6h", $time, db_bt_reg_addr, db_bt_reg_data); end
            else                                 begin $display ("*** Time %0dns: [OPER] BOOT-UP   || [REG_WRITE] PREFIX:0x%1h REG:0x%2h DATA:0x%6h", $time, db_bt_short_prefix, db_bt_reg_addr, db_bt_reg_data); end
        end
        else if (db_next_state == `BT_EOP)       begin $display ("*** Time %0dns: [OPER] BOOT-UP   || [REG_WRITE] BOOT_FLAG_SUCCESS=1 || SUCCESSFUL END OF BOOT-UP SEQUENCE", $time); end
        else if (db_next_state == `BT_EOP_PWDN_0)begin $display ("*** Time %0dns: [OPER] BOOT-UP   || [REG_WRITE] BOOT_FLAG_PWDN=1 BOOT_FLAG_SUCCESS=1 || SUCCESSFUL END OF BOOT-UP SEQUENCE", $time); end
        else if (db_next_state == `BT_EOP_SLP)   begin $display ("*** Time %0dns: [OPER] BOOT-UP   || [REG_WRITE] BOOT_FLAG_SLEEP=1 BOOT_FLAG_SUCCESS=1 || SUCCESSFUL END OF BOOT-UP SEQUENCE", $time); end
        else if (db_next_state == `BT_CHKSUM_ERR)begin 
            if (db_state == `BT_REG_WR_3)        begin $display ("*** Time %0dns: [OPER] BOOT-UP   || [REG_WRITE] BOOT_FLAG_CHKSUM_ERROR=1 || FAILURE: WRONG CHKSUM || EXPECTED:0x%8h CODE:0x%8h", $time, db_bt_reg_chksum, db_flsh_rd_dout_32); end
            else if (db_state == `BT_MEM_WR_6)   begin $display ("*** Time %0dns: [OPER] BOOT-UP   || [MEM_WRITE] BOOT_FLAG_CHKSUM_ERROR=1 || FAILURE: WRONG CHKSUM || EXPECTED:0x%8h CODE:0x%8h", $time, db_bt_mem_chksum, db_flsh_rd_dout_32); end
        end
        else if (db_next_state == `BT_INVLD_CMND)begin $display ("*** Time %0dns: [OPER] BOOT-UP   || [REG_WRITE] BOOT_FLAG_INVALID_CMND=1 || FAILURE: INVALID COMMAND || CODE:0x%8h", $time, db_flsh_rd_dout_32); end
        else if (db_next_state == `BT_WRONG_HEAD)begin $display ("*** Time %0dns: [OPER] BOOT-UP   || [REG_WRITE] BOOT_FLAG_WRONG_HEADER=1 || FAILURE: WRONG HEADER || EXPECTED:0x%8h CODE:0x%8h", $time, `BOOT_HEADER, db_flsh_rd_dout_32); end
        else if (db_next_state == `BT_ECC_ERR)   begin $display ("*** Time %0dns: [OPER] BOOT-UP   || [REG_WRITE] BOOT_FLAG_ECC_ERR=1 || FAILURE: ECC DOUBLE ERROR DETECTED || CODE:0x%8h", $time, db_flsh_rd_dout_32); end
        else if (db_next_state == `SLEEP)                      $display ("*** Time %0dns: [NOTE] BOOT-UP   || [INFO] TURNING OFF FLASH TO GO TO SLEEP", $time);
        else if (db_next_state == `TX_MBUS_SLEEP)begin $display ("*** Time %0dns: [OPER] BOOT-UP   || [MBUS] SENDING MBUS SLEEP MESSAGE", $time); end
        else if ((db_next_state == `BT_MEM_WR_3) && (db_bt_cnt == db_bt_mem_length_1))
                                                               $display ("*** Time %0dns: [NOTE] BOOT-UP   || [MEM_WRITE] SETTING UP || DEST_LAYER:0x%5h DEST_ADDR:0x%8h", $time, db_bt_layer_addr, db_bt_mem_addr);
        else if ((db_next_state == `WR_SRAM_0) && (db_state == `BT_MEM_WR_3))
                                                               $display ("*** Time %0dns: [NOTE] BOOT-UP   || [MEM_WRITE] WRITE INTO SRAM || ADDR: 0x%3h, CODE:0x%8h", $time, db_bt_sram_addr, db_flsh_rd_dout_32);
        else if (db_next_state == `BT_MEM_WR_7)                $display ("*** Time %0dns: [NOTE] BOOT-UP   || [MEM_WRITE] STARTING MEM COPY", $time);
        else if (db_state == `BT_ENUM_0)         begin $display ("*** Time %0dns: [OPER] BOOT-UP   || [MBUS] SENDING ENUMERATE MESSAGE || SHORT_PREFIX = 0x%1h", $time, db_enum_short_prefix); end

        if ((db_next_state == `BT_EOP) || (db_next_state == `BT_EOP_PWDN_0) ||(db_next_state == `BT_EOP_SLP)) begin
                                                `_BLUE;
                                                $display ("*******************************************************");
                                                $display ("*******************************************************");
                                                $display ("*********       BOOT-UP SUCCESSFUL!!       ************");
                                                $display ("*******************************************************");
                                                $display ("*******************************************************");
                                                `_RESET;
        end
        else if ((db_next_state == `BT_CHKSUM_ERR) || (db_next_state == `BT_INVLD_CMND) || (db_next_state == `BT_WRONG_HEAD) || (db_next_state == `BT_ECC_ERR)) begin
                                                `_RED;
                                                $display ("*******************************************************");
                                                $display ("*******************************************************");
                                                $display ("***********       BOOT-UP FAILURE!!       *************");
                                                $display ("*******************************************************");
                                                $display ("*******************************************************");
                                                `_RESET;
        end
    end
    else if (db_state == `BT_NOP_0)             $display ("*** Time %0dns: [NOTE] BOOT-UP   || [NOP]", $time);
end

always @ (`TB_INSTNAME.`TB_CTRL_NAME.flsh_isoln
            or `TB_INSTNAME.`TB_CTRL_NAME.Flash_0.ABUF_EN
            or `TB_INSTNAME.`TB_CTRL_NAME.Flash_0.RESETB
            or `TB_INSTNAME.`TB_CTRL_NAME.Flash_0.HVCP_EN
            or `TB_INSTNAME.`TB_CTRL_NAME.Flash_0.MVCP_EN
            or `TB_INSTNAME.`TB_CTRL_NAME.Flash_0.SC_EN
        ) begin
    if ( `TB_INSTNAME.`TB_CTRL_NAME.flsh_isoln // Unisolated
            & (   ~`TB_INSTNAME.`TB_CTRL_NAME.Flash_0.ABUF_EN
                | ~`TB_INSTNAME.`TB_CTRL_NAME.Flash_0.RESETB
                | ~`TB_INSTNAME.`TB_CTRL_NAME.Flash_0.HVCP_EN
                | ~`TB_INSTNAME.`TB_CTRL_NAME.Flash_0.MVCP_EN
                | ~`TB_INSTNAME.`TB_CTRL_NAME.Flash_0.SC_EN
                )
        ) begin
        `_RED_B;
        $display("*** Time %0dns: [FLASH OPER ERROR] Incorrect Insolation!! ", $time);
        `_RESET;
        failure;
    end
end
`endif // APR
`endif // DEBUG_CTRL
