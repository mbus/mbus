//******************************************************************************
//Author:         Ye-sheng Kuo, Yejoong Kim
//Last Modified:  Aug 23 2017
//Description:    MBus Pre-Defined Constants
//Update History: May 21 2016 - Updated for MBus r03 (Yejoong Kim)
//                                  Renamed each directives with prefix "MBUS_"
//                Dec 16 2016 - Included in MBus r04 (Yejoong Kim)
//                Jun 20 2017 - Added compiler directives __MBUS_DEF__ to prevent 
//                              redundant 'define' warning
//                Aug 23 2017 - Checked for mbus_testbench
//                              Fixed various bugs (typos)
//******************************************************************************
// !!! -------------------------  [WARNING]  -------------------------- !!! //
// !!! DO NOT CHANGE THIS FILE UNLESS YOU KNOW WHAT YOU ARE ABOUT TO DO !!! //
//************************************************************************* //

`ifndef __MBUSTB_DEF__
//----------------------------------------------
`define __MBUSTB_DEF__

`define MBUSTB_SD #1
`define MBUSTB_LD #5

`define MBUSTB_ADDR_WIDTH 32
`define MBUSTB_DATA_WIDTH 32
`define MBUSTB_FUNC_WIDTH 4
`define MBUSTB_DYNA_WIDTH 4
`define MBUSTB_RSVD_WIDTH 8
`define MBUSTB_BROADCAST_CMD_WIDTH 4

`define MBUSTB_PRFIX_WIDTH			(`MBUSTB_ADDR_WIDTH - `MBUSTB_RSVD_WIDTH - `MBUSTB_FUNC_WIDTH)
`define MBUSTB_SHORT_ADDR_WIDTH 	(`MBUSTB_DYNA_WIDTH + `MBUSTB_FUNC_WIDTH)

// Watch dog counter width
`define MBUSTB_BITS_WD_WIDTH 20

`define MBUSTB_CONTROL_SEQ    2'b10
`define MBUSTB_BROADCAST_ADDR 32'hf000_0000

// MBus Node generates power-gated signals
`define MBUSTB_NODE_POWER_GATING

`define MBUSTB_IO_HOLD 1'b1
`define MBUSTB_IO_RELEASE 1'b0

// A broadcast message consists of two segaments,
// 0x0A			0xBB_XXXXXX for short address or
// 0xf0000_000A 0xBB_XXXXXX for long address
// Where 0x0A is address field and 0xBB is data field
// "A" is broadcast "channels"
// "BB" is broadcast "commands"

// Broadcast channel, the width should be consistant with `MBUSTB_FUNC_WIDTH
`define MBUSTB_CHANNEL_ENUM	4'h0
`define MBUSTB_CHANNEL_POWER 	4'h1
`define MBUSTB_CHANNEL_CTRL	4'h2
`define MBUSTB_CHANNEL_MEMBER_EVENT 4'h3

// Broadcast commands, the width should be consistant with `MBUSTB_BROADCAST_CMD_WIDTH
// Commands for MBUSTB_CHANNEL_ENUM
`define MBUSTB_CMD_CHANNEL_ENUM_QUERRY				4'h0
`define MBUSTB_CMD_CHANNEL_ENUM_RESPONSE			4'h1
`define MBUSTB_CMD_CHANNEL_ENUM_ENUMERATE			4'h2
`define MBUSTB_CMD_CHANNEL_ENUM_INVALIDATE			4'h3


// Commands for MBUSTB_CHANNEL_POWER
`define MBUSTB_CMD_CHANNEL_POWER_ALL_SLEEP			4'h0
`define MBUSTB_CMD_CHANNEL_POWER_ALL_WAKE			4'h1
`define MBUSTB_CMD_CHANNEL_POWER_SEL_SLEEP			4'h2
`define MBUSTB_CMD_CHANNEL_POWER_SEL_WAKE			4'h3
`define MBUSTB_CMD_CHANNEL_POWER_SEL_SLEEP_FULL	    4'h4

// Commands for Layer controller, the width should match `MBUSTB_FUNC_WIDTH
`define MBUSTB_LC_CMD_RF_WRITE		4'h0
`define MBUSTB_LC_CMD_RF_READ		4'h1
`define MBUSTB_LC_CMD_MEM_WRITE	    4'h2
`define MBUSTB_LC_CMD_MEM_READ		4'h3
`define MBUSTB_LC_CMD_MEM_STREAM	2'b01

//----------------------------------------------
`endif // __MBUSTB_DEF__
