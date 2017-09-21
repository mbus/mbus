//******************************************************************************
//Author:         Ye-sheng Kuo, Yejoong Kim
//Last Modified:  Jun 20 2017
//Description:    MBus Pre-Defined Constants
//Update History: May 21 2016 - Updated for MBus r03 (Yejoong Kim)
//                                  Renamed each directives with prefix "MBUS_"
//                Dec 16 2016 - Included in MBus r04 (Yejoong Kim)
//                Jun 20 2017 - Added compiler directives __MBUS_DEF__ to prevent 
//                              redundant 'define' warning
//******************************************************************************
// !!! -------------------------  [WARNING]  -------------------------- !!! //
// !!! DO NOT CHANGE THIS FILE UNLESS YOU KNOW WHAT YOU ARE ABOUT TO DO !!! //
//************************************************************************* //

`ifndef __MBUS_DEF__
//----------------------------------------------
`define __MBUS_DEF__

`define MBUS_ADDR_WIDTH             32
`define MBUS_DATA_WIDTH             32
`define MBUS_FUNC_WIDTH             4
`define MBUS_DYNA_WIDTH             4
`define MBUS_RSVD_WIDTH             8
`define MBUS_BROADCAST_CMD_WIDTH    4

`define MBUS_PRFIX_WIDTH            (`MBUS_ADDR_WIDTH - `MBUS_RSVD_WIDTH - `MBUS_FUNC_WIDTH)
`define MBUS_SHORT_ADDR_WIDTH       (`MBUS_DYNA_WIDTH + `MBUS_FUNC_WIDTH)

// Watch dog counter width
`define MBUS_BITS_WD_WIDTH 20
`define MBUS_IDLE_WD_WIDTH 24

`define MBUS_CONTROL_SEQ    2'b10
`define MBUS_BROADCAST_ADDR 32'hf000_0000

// MBus Node generates power-gated signals
`define MBUS_NODE_POWER_GATING

`define MBUS_IO_HOLD    1'b1
`define MBUS_IO_RELEASE 1'b0

// A broadcast message consists of two segaments,
// 0x0A            0xBB_XXXXXX for short address or
// 0xf0000_000A 0xBB_XXXXXX for long address
// Where 0x0A is address field and 0xBB is data field
// "A" is broadcast "channels"
// "BB" is broadcast "commands"

// Broadcast channel, the width should be consistant with `MBUS_FUNC_WIDTH
`define MBUS_CHANNEL_ENUM           4'h0
`define MBUS_CHANNEL_POWER          4'h1
`define MBUS_CHANNEL_CTRL           4'h2
`define MBUS_CHANNEL_MEMBER_EVENT   4'h3

// Broadcast commands, the width should be consistant with `MBUS_BROADCAST_CMD_WIDTH
// Commands for MBUS_CHANNEL_ENUM
`define MBUS_CMD_CHANNEL_ENUM_QUERRY        4'h0
`define MBUS_CMD_CHANNEL_ENUM_RESPONSE      4'h1
`define MBUS_CMD_CHANNEL_ENUM_ENUMERATE     4'h2
`define MBUS_CMD_CHANNEL_ENUM_INVALIDATE    4'h3

// Commands for MBUS_CHANNEL_POWER
`define MBUS_CMD_CHANNEL_POWER_ALL_SLEEP        4'h0
`define MBUS_CMD_CHANNEL_POWER_ALL_WAKE         4'h1
`define MBUS_CMD_CHANNEL_POWER_SEL_SLEEP        4'h2
`define MBUS_CMD_CHANNEL_POWER_SEL_WAKE         4'h3
`define MBUS_CMD_CHANNEL_POWER_SEL_SLEEP_FULL   4'h4

// Layer Controller RF Address/Data Widths
`define LAYERCTRL_RF_DATA_WIDTH     24
`define LAYERCTRL_RF_ADDR_WIDTH     8

// Commands for Layer controller, the width should match `MBUS_FUNC_WIDTH
`define LAYERCTRL_CMD_RF_WRITE      4'h0
`define LAYERCTRL_CMD_RF_READ       4'h1
`define LAYERCTRL_CMD_MEM_WRITE     4'h2
`define LAYERCTRL_CMD_MEM_READ      4'h3
`define LAYERCTRL_CMD_MEM_STREAM    2'b01

// Power-Gating Aware Sims (Only for Developer's MBus Verilog Testbench)
`define MBUS_POWER_GATING_AWARE_SIM

//----------------------------------------------
`endif // __MBUS_DEF__
