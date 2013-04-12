
`define ADDR_WIDTH 32
`define DATA_WIDTH 32
`define FUNC_WIDTH 4
`define DYNA_WIDTH 4
`define RSVD_WIDTH 8
`define BROADCAST_CMD_WIDTH 4

`define PRFIX_WIDTH			(`ADDR_WIDTH - `RSVD_WIDTH - `FUNC_WIDTH)
`define SHORT_ADDR_WIDTH 	(`DYNA_WIDTH + `FUNC_WIDTH)

// Watch don counter width
`define WATCH_DOG_WIDTH 20

`define CONTROL_SEQ 2'b10
`define BROADCAST_ADDR 32'hf000_0000

`define IO_HOLD 1'b1
`define IO_RELEASE 1'b0

// A broadcast message consists of two segaments,
// 0x0A			0xBB_XXXXXX for short address or
// 0xf0000_000A 0xBB_XXXXXX for long address
// Where 0x0A is address field and 0xBB is data field
// "A" is broadcast "channels"
// "BB" is broadcast "commands"

// Broadcast channel, the width should be consistant with `FUNC_WIDTH
`define CHANNEL_ENUM	4'h0
`define CHANNEL_POWER 	4'h1
`define CHANNEL_DATA	4'hf

// Broadcast commands, the width should be consistant with `BROADCAST_CMD_WIDTH
// Commands for CHANNEL_ENUM
`define CMD_CHANNEL_ENUM_QUERRY				4'h0
`define CMD_CHANNEL_ENUM_RESPONSE			4'h1
`define CMD_CHANNEL_ENUM_ENUMERATE			4'h2
`define CMD_CHANNEL_ENUM_INVALID			4'h3


// Commands for CHANNEL_POWER
`define CMD_CHANNEL_POWER_ALL_SLEEP			4'h0
`define CMD_CHANNEL_POWER_ALL_WAKE			4'h1
`define CMD_CHANNEL_POWER_SEL_SLEEP			4'h2
`define CMD_CHANNEL_POWER_SEL_WAKE			4'h3
