`ifndef FLPv3L
//----------------------------------------------
`define FLPv3L
`define SD #1

//**********************************************
// MBus Node
//**********************************************

//-- Node Full Prefix
`define FLPv3L_MBUS_FULL_PREFIX 20'h00000


//**********************************************
// Layer Controller
//**********************************************

//-- Only three configurations are supported
//-- 1. Both INT and MEM are enabled
//-- 2. Only INT is enabled
//-- 3. Both are disabled
`define FLPv3L_LAYERCTRL_INT_ENABLE
`define FLPv3L_LAYERCTRL_MEM_ENABLE

//-- Interrupt Depth (Number of Interrupts)
//-- VALID only when FLPv3L_LAYERCTRL_INT_ENABLE is defined
`define FLPv3L_LAYERCTRL_INT_DEPTH 13

//-- "Number of Bits in Memory Address Input (+2 if word aligned)"
//-- VALID only when FLPv3L_LAYERCTRL_MEM_ENABLE is defined
`define FLPv3L_LAYERCTRL_MEM_ADDR_WIDTH 32

//-- Number of Data I/O in memory
//-- VALID only when FLPv3L_LAYERCTRL_MEM_ENABLE is defined
`define FLPv3L_LAYERCTRL_MEM_DATA_WIDTH 32

//-- Number of Memory Streaming Channels
//-- VALID only when FLPv3L_LAYERCTRL_MEM_ENABLE is defined
`define FLPv3L_LAYERCTRL_MEM_STREAM_CHANNELS 4

//-- Define FLPv3L_LAYERCTRL_MEM_USE_SAME_CLOCK 
//-- if layer controller and the memory reside in the same clock domain
`define FLPv3L_LAYERCTRL_MEM_USE_SAME_CLOCK

//-- Define FLPv3L_LAYERCTRL_ARB_SUPPORT to add a few more outputs
//-- to be used in Arbitrator (generally in PRC/PRE layers)
//`define FLPv3L_LAYERCTRL_ARB_SUPPORT

//-- Provide list of MBus RF Size and IDs that are read-only or empty.
//-- Do NOT remove/modify comment lines starting with '//---- genRF' below.
//-- It is recommended to use m3_genRF to update these settings.
//---- genRF Beginning of Compiler Directives ----//
`define FLPv3L_MBUS_RF_SIZE      256
`define FLPv3L_MBUS_RF_READ_ONLY 1'b0
`define FLPv3L_MBUS_RF_EMPTY     1'b0
//---- genRF End of Compiler Directives ----//

//**********************************************
// FLPv3L Configurations
//**********************************************

//----------------------------------------------
`endif // FLPv3L
