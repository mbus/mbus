//*************************
// LAYER DEFINITIONS
//*************************

`include "/afs/eecs.umich.edu/vlsida/projects/m3_hdk/layer/FLP/FLPv3L/verilog/FLPv3L_def.v"

//*********************
// List of Tests
//*********************
`define TEST_POWER
`define TEST_SRAM
`define TEST_FLASH_PAGE_OPER
`define TEST_FLASH_WHOLE_OPER
`define TEST_EXT_STR
`define TEST_PP_EXT
`define TEST_PP_MBUS

//`define TEST_REF_ERASE  // Make sure FLS_AUTO_BOOT_DISABLE=1, and IGNORE_ERASE_REF_CELL is commented out.
`define FLS_AUTO_BOOT_DISABLE   1'b0 // 1'b1: Auto-Boot-Up Disabled. 1'b0: Auto-Boot-Up Enabled.

//*********************
// GENERAL
//*********************
`ifdef FLPv3L
    `define TB_MODULE_NAME      FLPv3L
    `define TB_INST_PREFIX      flpv3l
    `define TB_SRAM_NUM_WORDS   8192
    `define TB_SRAM_LENGTH      16'h1FFF
    `define TB_FLASH_NUM_WORDX  1048576 // Numb of 8-bit words in total
    `define TB_FLASH_NUM_WORD   262144 // Num of 32-bit words in total
    `define TB_FLASH_NUM_WORDP  256 // Num of 32-bit words in a Page
    `define TB_FLASH_NUM_PAGES_MTH 64 // Number of Pages in MBus Threhsold (~524288 bits)
    `define TB_FLASH_NUM_ITER_0    16 // (FLASH_NUM_PAGES / FLASH_NUM_PAGES_MTH).
    `define TB_NUM_PAGES_SRAM   32
    `define TB_MBUS_FULL_PREFIX `FLPv3L_MBUS_FULL_PREFIX
`elsif FLPv3S
    `define TB_MODULE_NAME      FLPv3S
    `define TB_INST_PREFIX      flpv3s
    `define TB_SRAM_NUM_WORDS   2048
    `define TB_SRAM_LENGTH      16'h07FF
    `define TB_FLASH_NUM_WORDX  131072 // Numb of 8-bit words in total
    `define TB_FLASH_NUM_WORD   32768 // Num of 32-bit words in total
    `define TB_FLASH_NUM_WORDP  256 // Num of 32-bit words in a Page
    `define TB_FLASH_NUM_PAGES_MTH 64 // Number of Pages in MBus Threhsold (~524288 bits)
    `define TB_FLASH_NUM_ITER_0    2 // (FLASH_NUM_PAGES / FLASH_NUM_PAGES_MTH).
    `define TB_NUM_PAGES_SRAM   8
    `define TB_MBUS_FULL_PREFIX `FLPv3S_MBUS_FULL_PREFIX
`endif

`define TB_FLASH_NUM_WORD2  (`TB_FLASH_NUM_WORD * 16)
`define TB_INSTNAME         `TB_MODULE_NAME``_0
`define TB_RF_NAME          `TB_INST_PREFIX``_rf_0
`define TB_LCRF_NAME        `TB_INST_PREFIX``_layer_ctrl_rf_0
`define TB_CTRL_NAME        `TB_INST_PREFIX``_ctrl_0
`define TB_FLS_HEADER_NAME  `TB_INST_PREFIX``_header_fls_0
`define TB_CLK_GEN_NAME     `TB_INST_PREFIX``_clk_gen_v4_0
`define TB_SRAM_ADDR_WIDTH  `SRAM_ADDR_WIDTH
`define TB_FLASH_ADDR_WIDTH `OP_FLASH_ADDR_WIDTH
`define TB_FLASH_PAGE_WIDTH `OP_FLASH_PAGE_WIDTH
`define TB_FLASH_NUM_PAGES  `FLASH_NUM_PAGES
`define TB_LENGTH_WIDTH     `OP_LENGTH_WIDTH
`define TB_PAGE_WIDTH       `OP_PAGE_WIDTH
`define TB_LENGTH_EXT_WIDTH `LENGTH_EXT_WIDTH
`define TB_TIMEPAR_WIDTH    `OP_TIMEPAR_WIDTH
`define MBUS_HALF_PERIOD    #2500
`define MBUS_THRESHOLD      20'hFFFFF
`define RESET_TIME          #10000
`define TEST_SD             #1
`define TEST_WAIT           #100000

`ifdef APR
    `define TEST_LD             #5  // This is to prevent $display in DEBUG_RF during signal transitions. (Only for APR)
`else
    `define TEST_LD             #0  // This is to prevent $display in DEBUG_RF during signal transitions. (Only for APR)
`endif

//*********************
// ENUMERATION
//*********************
`define FLS_ADDR    4'h4
`define N_A_ADDR    4'hA

//*********************
// Debug Display
//*********************
`define DEBUG_RF       // Display when the Register File is written
`define DEBUG_CTRL     // Display useful CTRL functional information
`define DEBUG_HEADER   // Display when headers are turned on/off
`define DEBUG_LMT      // Display when VTG_LMT_CRT_LMT_* have input changes
`define DEBUG_PWR      // Display power-gating-related signals change

`define MBUS_SNOOPER            // Enable MBUS_SNOOPER to display MBus messages on the bus

//*********************
// VCD Dump Setting
//*********************
`define START_VCD_DUMP_FROM #0
`define VCD_DUMP_ALL
`ifdef FLPv3L
    `define VCD_FILE_NAME "FLPv3L.vcd"
    `define VPD_FILE_NAME "FLPv3L.vpd"
`elsif FLPv3S
    `define VCD_FILE_NAME "FLPv3S.vcd"
    `define VPD_FILE_NAME "FLPv3S.vpd"
`endif

//*********************
// SDF Annotation
//*********************
`ifdef FLPv3L
    `define SDF_FILE_NAME "/afs/eecs.umich.edu/vlsida/projects/m3_hdk/layer/FLP/FLPv3L/apr/FLPv3L.apr.sdf"
`elsif FLPv3S
    `define SDF_FILE_NAME "/afs/eecs.umich.edu/vlsida/projects/m3_hdk/layer/FLP/FLPv3S/apr/FLPv3S.apr.sdf"
`endif

//*********************
// FLPv3 Setting
//*********************
`define FLS_EXT_HALF_PERIOD_EQ  #7501
`define END_OF_BT	32'hFF123456

// External Streaming Data
`ifdef FLPv3L
    `define FLS_EXT_DATA_WIDTH2     "/afs/eecs.umich.edu/vlsida/projects/m3_hdk/layer/FLP/FLPv3L/vsim/ini/data_width_2_test.ini"
`elsif FLPv3S
    `define FLS_EXT_DATA_WIDTH2     "/afs/eecs.umich.edu/vlsida/projects/m3_hdk/layer/FLP/FLPv3S/vsim/ini/data_width_2_test.ini"
`endif
`define FLS_NUM_EXT_DATA_WIDTH2  131072

// If FLS_INITIALIZE_FLASH is defined, data given in 'FLS_INITIAL_DATA' will be preloaded to the flash
// Otherwise, the flash will have random data at the beginning.
`define FLS_INITIALIZE_FLASH
`ifdef FLPv3L
    `define FLS_INITIAL_DATA      "/afs/eecs.umich.edu/vlsida/projects/m3_hdk/layer/FLP/FLPv3L/vsim/ini/prog8L.ini"
`elsif FLPv3S
    `define FLS_INITIAL_DATA      "/afs/eecs.umich.edu/vlsida/projects/m3_hdk/layer/FLP/FLPv3S/vsim/ini/prog8S.ini"
`endif

//Set minimum required setting for COMP_CTRL_I_1STG
`define FLS_ENABLE_COMP_CTRL_CHECK
`define FLS_COMP_CTRL_I_1STG_SIGNAL `TB_INSTNAME.comp_ctrl_i_1stg
`define FLS_MIN_COMP_CTRL_I_1STG    4'hA

//************************************************************************************
// Color Display
//************************************************************************************

`include "/afs/eecs.umich.edu/vlsida/projects/m3_hdk/scripts/vsim/color_def.v"
