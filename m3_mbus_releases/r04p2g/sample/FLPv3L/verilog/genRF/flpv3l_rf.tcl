set top_level flpv3l_rf

create_qtm_model $top_level

create_qtm_port { RESETn ISOLATE ADDR_IN[71:0] DATA_IN[23:0] } -type input
create_qtm_port { Tcyc_read[4:0] T3us[5:0] T5us[5:0] T10us[6:0] Tcyc_prog[15:0] Tprog[7:0] Terase[15:0] Thvcp_en[13:0] Tben[9:0] Tmvcp_en[11:0] Tsc_en[11:0] Tcap[19:0] Tvref[16:0] VREF_SLEEP COMP_SLEEP COMP_CLKENB COMP_CLKEN COMP_ISOL WRAP_EXT UPDATE_ADDR_EXT BIT_EN_EXT[1:0] TIMEOUT_EXT[19:0] SRAM_START_ADDR_EXT[12:0] INT_RPLY_SHORT_ADDR[7:0] INT_RPLY_REG_ADDR[7:0] BOOT_FLAG_SLEEP BOOT_FLAG_ECC_ERROR BOOT_FLAG_WRONG_HEADER BOOT_FLAG_PWDN BOOT_FLAG_INVALID_CMND BOOT_FLAG_CHKSUM_ERROR BOOT_FLAG_SUCCESS BOOT_REG_PATTERN[1:0] FLASH_POWER_DO_VREFCOMP FLASH_POWER_DO_FLSH FLASH_POWER_IRQ_EN FLASH_POWER_SEL_ON FLASH_POWER_GO IRQ_PWR_ON_WUP SEL_PWR_ON_WUP[2:0] FLASH_AUTO_USE_CUSTOM FLASH_AUTO_OFF FLASH_AUTO_ON PP_NO_ERR_DETECTION PP_USE_FAST_PROG PP_WRAP PP_BIT_EN_EXT[1:0] PP_FLSH_ADDR[17:0] CLK_RING_SEL[3:0] CLK_DIV_SEL[1:0] DISABLE_BYPASS_MIRROR COMP_CTRL_I_1STG[3:0] COMP_CTRL_I_2STG_BAR[3:0] COMP_CTRL_VOUT[2:0] FORCE_RESETN FLSH_SET0[4:0] FLSH_SET1[4:0] FLSH_SNT[4:0] FLSH_SPT0[4:0] FLSH_SPT1[4:0] FLSH_SPT2[4:0] FLSH_SYT0[4:0] FLSH_SYT1[4:0] FLSH_SRT0[4:0] FLSH_SRT1[4:0] FLSH_SRT2[4:0] FLSH_SRT3[4:0] FLSH_SRT4[4:0] FLSH_SRT5[4:0] FLSH_SRT6[4:0] FLSH_SPIG[3:0] FLSH_SRIG[3:0] FLSH_SVR0[3:0] FLSH_SVR1[3:0] FLSH_SVR2[3:0] FLSH_SHVE[4:0] FLSH_SHVP[4:0] FLSH_SHVCT[4:0] FLSH_SMV[5:0] FLSH_SMVCT0[4:0] FLSH_SMVCT1[4:0] FLSH_SAB[5:0] STR_WR_CH1_ALT_ADDR[7:0] STR_WR_CH1_ALT_REG_WR[7:0] STR_WR_CH1_EN STR_WR_CH1_WRP STR_WR_CH1_DBLB STR_WR_CH1_BUF_LEN[12:0] STR_WR_CH1_BUF_OFF[12:0] STR_WR_CH0_ALT_ADDR[7:0] STR_WR_CH0_ALT_REG_WR[7:0] STR_WR_CH0_EN STR_WR_CH0_WRP STR_WR_CH0_DBLB STR_WR_CH0_BUF_LEN[12:0] STR_WR_CH0_BUF_OFF[12:0] BLK_WR_EN ACT_RST } -type output

set_qtm_port_load [get_qtm_ports  { RESETn ISOLATE ADDR_IN[71:0] DATA_IN[23:0] } ] -value 0.001

save_qtm_model -output $top_level -format {lib db} -library_cell

exit
