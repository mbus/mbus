`ifndef FLPv3L
//----------------------------------------------
`define FLPv3L
`define SD #1

//**********************************************
// MBus Node
//**********************************************

//-- Node Full Prefix
`define FLPv3L_MBUS_FULL_PREFIX 20'h12303


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
`define FLPv3L_LAYERCTRL_INT_DEPTH 1

//-- "Number of Bits in Memory Address Input + 2"
//-- VALID only when FLPv3L_LAYERCTRL_MEM_ENABLE is defined
`define FLPv3L_LAYERCTRL_MEM_ADDR_WIDTH 32

//-- Number of Data I/O in memory
//-- VALID only when FLPv3L_LAYERCTRL_MEM_ENABLE is defined
`define FLPv3L_LAYERCTRL_MEM_DATA_WIDTH 32

//-- Number of Memory Streaming Channels
//-- VALID only when FLPv3L_LAYERCTRL_MEM_ENABLE is defined
`define FLPv3L_LAYERCTRL_MEM_STREAM_CHANNELS 2

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
`define FLPv3L_MBUS_RF_SIZE      72
`define FLPv3L_MBUS_RF_READ_ONLY ((i==27)|(i==30))
`define FLPv3L_MBUS_RF_EMPTY     ((i==11)|(i==26)|(i==28)|(i==29)|(i==37)|(i==41)|(i==43)|(i==44)|(i==45)|(i==46)|(i==47)|(i==56)|(i==57)|(i==59)|(i==60)|(i==61)|(i==62)|(i==63)|(i==64)|(i==65)|(i==66)|(i==67)|(i==68)|(i==69)|(i==70))
//---- genRF End of Compiler Directives ----//

//**********************************************
// FLPv3L Configurations
//**********************************************

    
//----------------------------------------------
`endif // FLPv3L
