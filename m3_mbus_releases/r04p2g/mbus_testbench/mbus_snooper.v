//*************************************************************************************************
// MBUS Snooper Verilog
//
// <DESCRIPTION> 
//             Just hook up this module with your existing M3 layer. 
//             It parses and display every MBus messages on the bus.
//
// <PIN CONNECTIONS> 
//             RESETn:    Usually the reset signal from your reset detector. 
//                        Or whatever reset signal your testbench has.
//             CIN/DIN:   MBus CIN/DIN signal of your DUT.
//             COUT/DOUT: MBus COUT/DOUT signal of your DUT.
//
// <PARAMETER>
//             SHORT_PREFIX: Short-prefix of the layer. 
//                           You can use multiple MBus Snoopers in a test bench. Just assign different Short Prefixes.
//
// <USAGE EXAMPLE>
//
//             `ifdef MBUS_SNOOPER
//                 mbus_snooper #(.SHORT_PREFIX(1))
//                 mbus_snooper_1 (
//                     .RESETn(RESETn),
//                     .CIN(MBUS_CLK_A2B),
//                     .DIN(MBUS_DATA_A2B),
//                     .COUT(MBUS_CLK_B2A),
//                     .DOUT(MBUS_DATA_B2A)
//                     );
//             `endif
//
// <NOTE> 
//             - SNOOP_MAX_NUM_WORDS defines the maximum buffer size in words(=32bits), 
//               where bits Data (a multiple of 32 bits) are stored.
//
// <UPDATE HISTORY>
// 12/23/2016 - Major revision. 
//                  - Now MBus Snooper is based on 'mbus_node' implementation, which significantly improves snooping speed, 
//                    so you do not have to disable the snooper because of the simulation speed degradation observed 
//                    in the previous MBus Snooper version.
//                  - Now MBus Snooper does not display whether the message is TX/RX/FWD.
//                  - Removed 'Invalid Num Bits' warning. Now MBus Snooper just displays 'MBUS MSG RX FAIL'
// 06/25/2015 - Added 'FWD' mode display. Also added displaying 'SHORT_PREFIX' of the current node.
// 06/24/2015 - Added 'Invalid Num Bits' warning. Also it now detects a TX message immediately following an RX message.
// 06/22/2015 - Now it can handle any arbitrary length MBus msgs (limited by SNOOP_MAX_NUM_WORDS)
// 06/16/2016 - First Commit by Yejoong Kim
//
// Author: Yejoong Kim
// Last Updated: December 23, 2016
//*************************************************************************************************

`define SNOOP_MAX_NUM_WORDS 16500
`define SNOOP_COLOR_SET 	$write("%c[0;36m", 27) // Cyan Color
`define SNOOP_COLOR_RESET	$write("%c[0m", 27)

`include "include/mbus_def_testbench.v"

module mbus_snooper #(
        parameter SHORT_PREFIX = 1  // This layer's short prefix
)
(
    input RESETn, 
    input DISABLE,
    input CIN, 
    input DIN, 
    input COUT,
    input DOUT
);

`include "include/mbus_func_testbench.v"

parameter ADDRESS = 20'habcde;
parameter ADDRESS_MASK = {(`MBUSTB_PRFIX_WIDTH){1'b1}};
parameter ADDRESS_MASK_SHORT = {`MBUSTB_DYNA_WIDTH{1'b1}};

// Node mode
parameter MODE_TX_NON_PRIO = 2'd0;
parameter MODE_TX = 2'd1;
parameter MODE_RX = 2'd2;
parameter MODE_FWD = 2'd3;

// BUS state
parameter BUS_IDLE = 0;
parameter BUS_ARBITRATE = 1;
parameter BUS_PRIO = 2;
parameter BUS_ADDR = 3;
parameter BUS_DATA_RX_ADDI = 4;
parameter BUS_DATA = 5;
parameter BUS_DATA_RX_CHECK = 6;
parameter BUS_REQ_INTERRUPT = 7;
parameter BUS_CONTROL0 = 8;
parameter BUS_CONTROL1 = 9;
parameter BUS_BACK_TO_IDLE = 10;
parameter NUM_OF_BUS_STATE = 11;

// Address enumeration response type
parameter ADDR_ENUM_RESPOND_T1 = 2'b00;
parameter ADDR_ENUM_RESPOND_T2 = 2'b10;
parameter ADDR_ENUM_RESPOND_NONE = 2'b11;

// TX broadcast data length
parameter LENGTH_1BYTE = 2'b00;
parameter LENGTH_2BYTE = 2'b01;
parameter LENGTH_3BYTE = 2'b10;
parameter LENGTH_4BYTE = 2'b11;

parameter RX_ABOVE_TX = 1'b1;
parameter RX_BELOW_TX = 1'b0;

wire [1:0] CONTROL_BITS = `MBUSTB_CONTROL_SEQ; // EOM?, ~ACK?

//************************************************************
// MBus Snooper Modifications
//************************************************************

// In MBus Snooper, MASTER_NODE must be 1 to display broadcast messages
parameter MASTER_NODE = 1'b1;

// Unused inputs in MBus Snooper
reg  [`MBUSTB_ADDR_WIDTH-1:0] TX_ADDR = 0;
reg  [`MBUSTB_DATA_WIDTH-1:0] TX_DATA = 0;
reg  TX_PEND = 0;
reg  TX_REQ = 0;
reg  TX_PRIORITY = 0;
reg  TX_RESP_ACK = 0;

// Short Prefix
wire  [`MBUSTB_DYNA_WIDTH-1:0] ASSIGNED_ADDR_IN = SHORT_PREFIX;
wire  ASSIGNED_ADDR_VALID = 1;

// Previous Outputs (Unused)
reg  TX_ACK; 
reg  TX_FAIL; 
reg  TX_SUCC; 
reg  ASSIGNED_ADDR_WRITE;
reg  ASSIGNED_ADDR_INVALIDn;

// Previous Outputs (In use)
reg  RX_FAIL;
reg  [`MBUSTB_ADDR_WIDTH-1:0] RX_ADDR; 
reg  [`MBUSTB_DATA_WIDTH-1:0] RX_DATA; 
reg  RX_PEND; 
reg  RX_REQ; 
wire RX_BROADCAST;
wire MBC_IN_FWD;

// RX_ACK Modeling
reg  RX_ACK;
always @* RX_ACK = `MBUSTB_LD RX_REQ;

// Reset 
wire RESETn_local = RESETn & ~DISABLE;

// Node priority
// MBus Snooper does not have a priority. It is only listening (RX)
wire [1:0] mode_temp = MODE_RX;

// End of MBus Snooper Modifications
//------------------------------------------------------------

// general registers
reg     [1:0] mode, next_mode, mode_neg;
reg     [log2(NUM_OF_BUS_STATE-1)-1:0] bus_state, next_bus_state, bus_state_neg;
reg     [log2(`MBUSTB_DATA_WIDTH-1)-1:0] bit_position, next_bit_position; 
reg     req_interrupt, next_req_interrupt;

// Pat Fix
reg     req_interrupt_because_error, next_req_interrupt_because_error;

reg     out_reg_pos, next_out_reg_pos, out_reg_neg;

// tx registers
reg     [`MBUSTB_ADDR_WIDTH-1:0] ADDR, next_addr;
reg     [`MBUSTB_DATA_WIDTH-1:0] DATA, next_data;
reg     tx_pend, next_tx_pend;
reg     tx_underflow, next_tx_underflow;
reg     ctrl_bit_buf, next_ctrl_bit_buf;

// rx registers
reg     [`MBUSTB_ADDR_WIDTH-1:0] next_rx_addr;
reg     [`MBUSTB_DATA_WIDTH-1:0] next_rx_data; 
reg     [`MBUSTB_DATA_WIDTH+1:0] rx_data_buf, next_rx_data_buf;
reg     next_rx_fail;

// address enumation registers
reg     [1:0] enum_addr_resp, next_enum_addr_resp;
reg     next_assigned_addr_write;
reg     next_assigned_addr_invalidn;

// interrupt register
reg     BUS_INT_RSTn;
wire    BUS_INT;

// interface registers
reg     next_tx_ack;
reg     next_tx_fail;
reg     next_tx_success;
reg     next_rx_req;
reg     next_rx_pend;

wire    addr_bit_extract = ((ADDR  & (1'b1<<bit_position))==0)? 1'b0 : 1'b1;
wire    data_bit_extract = ((DATA & (1'b1<<bit_position))==0)? 1'b0 : 1'b1;
reg     [1:0] addr_match_temp;
wire    address_match = (addr_match_temp[1] | addr_match_temp[0]);

// Broadcast processing
reg     [`MBUSTB_BROADCAST_CMD_WIDTH -1:0] rx_broadcast_command;
wire    rx_long_addr_en = (RX_ADDR[`MBUSTB_ADDR_WIDTH-1:`MBUSTB_ADDR_WIDTH-4]==4'hf)? 1'b1 : 1'b0;
wire    tx_long_addr_en = (TX_ADDR[`MBUSTB_ADDR_WIDTH-1:`MBUSTB_ADDR_WIDTH-4]==4'hf)? 1'b1 : 1'b0;
wire    tx_long_addr_en_latched = (ADDR[`MBUSTB_ADDR_WIDTH-1:`MBUSTB_ADDR_WIDTH-4]==4'hf)? 1'b1 : 1'b0;
reg     tx_broadcast_latched;
reg     [1:0] tx_dat_length, rx_dat_length;
reg     rx_position, rx_dat_length_valid;
reg     wakeup_req;
wire    [`MBUSTB_DATA_WIDTH-1:0] broadcast_addr = `MBUSTB_BROADCAST_ADDR;
wire    [`MBUSTB_DATA_WIDTH-1:0] rx_data_buf_proc = (rx_dat_length_valid)? (rx_position==RX_BELOW_TX)? rx_data_buf[`MBUSTB_DATA_WIDTH-1:0] : rx_data_buf[`MBUSTB_DATA_WIDTH+1:2] : {`MBUSTB_DATA_WIDTH{1'b0}};

// Assignments
assign RX_BROADCAST = addr_match_temp[0];
assign MBC_IN_FWD = (mode == MODE_FWD);

// TX Broadcast
// For some boradcast message, TX node should take apporiate action, ex: all node sleep
// determined by ADDR flops, not TX_ADDR
always @ *
begin
    tx_broadcast_latched = 0;
    if (tx_long_addr_en_latched)
    begin
        if (ADDR[`MBUSTB_DATA_WIDTH-1:`MBUSTB_FUNC_WIDTH]==broadcast_addr[`MBUSTB_DATA_WIDTH-1:`MBUSTB_FUNC_WIDTH])
            tx_broadcast_latched = 1;
    end
    else
    begin
        if (ADDR[`MBUSTB_SHORT_ADDR_WIDTH-1:`MBUSTB_FUNC_WIDTH]==broadcast_addr[`MBUSTB_SHORT_ADDR_WIDTH-1:`MBUSTB_FUNC_WIDTH])
            tx_broadcast_latched = 1;
    end
end
// End of TX broadcast

// Wake up control
// What type of message should wake up the layer controller (LC)
always @ *
begin
    wakeup_req = 0;
    // normal messages
    if (~RX_BROADCAST)
        wakeup_req = address_match;
    else
    begin
        // master node should wake up for every broadcast message
        if (MASTER_NODE==1'b1)
            wakeup_req = address_match;
        // which channels should wake up
        case (RX_ADDR[`MBUSTB_FUNC_WIDTH-1:0])
            `MBUSTB_CHANNEL_POWER:
            begin
                case (rx_data_buf[`MBUSTB_BROADCAST_CMD_WIDTH-1:0])
                    `MBUSTB_CMD_CHANNEL_POWER_ALL_WAKE: begin wakeup_req = 1; end
                endcase
            end
            default: begin end
        endcase
    end
end
// End of Wake up control

// Address compare
// This block determine the incoming message has match the address or not
always @ *
begin
    addr_match_temp = 2'b00;
    if (rx_long_addr_en)
    begin
        if (RX_ADDR[`MBUSTB_DATA_WIDTH-1:`MBUSTB_FUNC_WIDTH]==broadcast_addr[`MBUSTB_DATA_WIDTH-1:`MBUSTB_FUNC_WIDTH])
            addr_match_temp[0] = 1;

        if (((RX_ADDR[`MBUSTB_DATA_WIDTH-`MBUSTB_RSVD_WIDTH-1:`MBUSTB_FUNC_WIDTH] ^ ADDRESS) & ADDRESS_MASK)==0)
            addr_match_temp[1] = 1;
        
    end
    // short address assigned
    else
    begin
        if (RX_ADDR[`MBUSTB_SHORT_ADDR_WIDTH-1:`MBUSTB_FUNC_WIDTH]==broadcast_addr[`MBUSTB_SHORT_ADDR_WIDTH-1:`MBUSTB_FUNC_WIDTH])
            addr_match_temp[0] = 1;

        if (ASSIGNED_ADDR_VALID)
        begin
            // In MBus Snooper, Address is always valid
                addr_match_temp[1] = 1;
        end
        
    end
end
// End of address compare

// TX broadcast command length
// This only take care the broadcast command issued from layer controller
// CANNOT use this in self generate enumerate response
always @ *
begin
    tx_dat_length = LENGTH_4BYTE;
    if (tx_broadcast_latched)
    begin
        case (ADDR[`MBUSTB_FUNC_WIDTH-1:0])
            `MBUSTB_CHANNEL_ENUM:
            begin
                case (DATA[`MBUSTB_DATA_WIDTH-1:`MBUSTB_DATA_WIDTH-`MBUSTB_BROADCAST_CMD_WIDTH])
                    `MBUSTB_CMD_CHANNEL_ENUM_QUERRY:       begin tx_dat_length = LENGTH_1BYTE; end
                    `MBUSTB_CMD_CHANNEL_ENUM_RESPONSE:     begin tx_dat_length = LENGTH_4BYTE; end
                    `MBUSTB_CMD_CHANNEL_ENUM_ENUMERATE:    begin tx_dat_length = LENGTH_1BYTE; end
                    `MBUSTB_CMD_CHANNEL_ENUM_INVALIDATE:   begin tx_dat_length = LENGTH_1BYTE; end
                endcase
            end

            `MBUSTB_CHANNEL_POWER:
            begin
                case (DATA[`MBUSTB_DATA_WIDTH-1:`MBUSTB_DATA_WIDTH-`MBUSTB_BROADCAST_CMD_WIDTH])
                    `MBUSTB_CMD_CHANNEL_POWER_ALL_SLEEP:       begin tx_dat_length = LENGTH_1BYTE; end
                    `MBUSTB_CMD_CHANNEL_POWER_ALL_WAKE:        begin tx_dat_length = LENGTH_1BYTE; end
                    `MBUSTB_CMD_CHANNEL_POWER_SEL_SLEEP:       begin tx_dat_length = LENGTH_3BYTE; end
                    `MBUSTB_CMD_CHANNEL_POWER_SEL_SLEEP_FULL:  begin tx_dat_length = LENGTH_4BYTE; end
                    `MBUSTB_CMD_CHANNEL_POWER_SEL_WAKE:        begin tx_dat_length = LENGTH_3BYTE; end 
                endcase
            end
        endcase
    end
end

// This block used to determine the received data length.
// only broadcast can be any byte aligned
// otherwise, regular message has to be word aligned
always @ *
begin
    rx_dat_length = LENGTH_4BYTE;
    rx_dat_length_valid = 0;
    rx_position = RX_ABOVE_TX;
    case (bit_position)
        1: begin rx_dat_length = LENGTH_4BYTE; rx_dat_length_valid = 1; rx_position = RX_BELOW_TX; end
        (`MBUSTB_DATA_WIDTH-1'b1): begin rx_dat_length = LENGTH_4BYTE; rx_dat_length_valid = 1; rx_position = RX_ABOVE_TX; end

        9: begin rx_dat_length = LENGTH_3BYTE; if (RX_BROADCAST) rx_dat_length_valid = 1; rx_position = RX_BELOW_TX; end
        7: begin rx_dat_length = LENGTH_3BYTE; if (RX_BROADCAST) rx_dat_length_valid = 1; rx_position = RX_ABOVE_TX; end

        17: begin rx_dat_length = LENGTH_2BYTE; if (RX_BROADCAST) rx_dat_length_valid = 1; rx_position = RX_BELOW_TX; end
        15: begin rx_dat_length = LENGTH_2BYTE; if (RX_BROADCAST) rx_dat_length_valid = 1; rx_position = RX_ABOVE_TX; end

        25: begin rx_dat_length = LENGTH_1BYTE; if (RX_BROADCAST) rx_dat_length_valid = 1; rx_position = RX_BELOW_TX; end
        23: begin rx_dat_length = LENGTH_1BYTE; if (RX_BROADCAST) rx_dat_length_valid = 1; rx_position = RX_ABOVE_TX; end
    endcase
end

always @ *
begin
    rx_broadcast_command = rx_data_buf_proc[`MBUSTB_DATA_WIDTH-1:`MBUSTB_DATA_WIDTH-`MBUSTB_BROADCAST_CMD_WIDTH];
    case (rx_dat_length)
        LENGTH_4BYTE: begin rx_broadcast_command = rx_data_buf_proc[`MBUSTB_DATA_WIDTH-1:`MBUSTB_DATA_WIDTH-`MBUSTB_BROADCAST_CMD_WIDTH]; end
        LENGTH_3BYTE: begin rx_broadcast_command = rx_data_buf_proc[`MBUSTB_DATA_WIDTH-9:`MBUSTB_DATA_WIDTH-`MBUSTB_BROADCAST_CMD_WIDTH-8]; end
        LENGTH_2BYTE: begin rx_broadcast_command = rx_data_buf_proc[`MBUSTB_DATA_WIDTH-17:`MBUSTB_DATA_WIDTH-`MBUSTB_BROADCAST_CMD_WIDTH-16]; end
        LENGTH_1BYTE: begin rx_broadcast_command = rx_data_buf_proc[`MBUSTB_DATA_WIDTH-25:`MBUSTB_DATA_WIDTH-`MBUSTB_BROADCAST_CMD_WIDTH-24]; end
    endcase
 
end

always @ (posedge CIN or negedge RESETn_local)
begin
    if (~RESETn_local)
    begin
        bus_state <= `MBUSTB_SD BUS_IDLE;
        BUS_INT_RSTn <= `MBUSTB_SD 1;
    end
    else
    begin
        if (BUS_INT)
        begin
            bus_state <= `MBUSTB_SD BUS_CONTROL0;
            BUS_INT_RSTn <= `MBUSTB_SD 0;
        end
        else
        begin
            bus_state <= `MBUSTB_SD next_bus_state;
            BUS_INT_RSTn <= `MBUSTB_SD 1;
        end
    end
end

wire TX_RESP_RSTn = RESETn_local & (~TX_RESP_ACK);

always @ (posedge CIN or negedge TX_RESP_RSTn)
begin
    if (~TX_RESP_RSTn)
    begin
        TX_FAIL <= `MBUSTB_SD 0;
        TX_SUCC <= `MBUSTB_SD 0;
    end
    else
    begin
        TX_FAIL <= `MBUSTB_SD next_tx_fail;
        TX_SUCC <= `MBUSTB_SD next_tx_success;
    end
end

wire RX_ACK_RSTn = RESETn_local & (~RX_ACK);

always @ (posedge CIN or negedge RX_ACK_RSTn)
begin
    if (~RX_ACK_RSTn)
    begin
        RX_REQ <= `MBUSTB_SD 0;
        RX_PEND <= `MBUSTB_SD 0;
        RX_FAIL <= `MBUSTB_SD 0;
    end
    else if (~BUS_INT)
    begin
        RX_REQ <= `MBUSTB_SD next_rx_req;
        RX_PEND <= `MBUSTB_SD next_rx_pend;
        RX_FAIL <= `MBUSTB_SD next_rx_fail;
    end
end


always @ (posedge CIN or negedge RESETn_local)
begin
    if (~RESETn_local)
    begin
        // general registers
        mode <= `MBUSTB_SD MODE_RX;
        bit_position <= `MBUSTB_SD `MBUSTB_ADDR_WIDTH - 1'b1;
        req_interrupt <= `MBUSTB_SD 0;

        // Pat Fix
        req_interrupt_because_error <= `MBUSTB_SD 0;

        out_reg_pos <= `MBUSTB_SD 0;
        // Transmitter registers
        ADDR <= `MBUSTB_SD 0;
        DATA <= `MBUSTB_SD 0;
        tx_pend <= `MBUSTB_SD 0;
        tx_underflow <= `MBUSTB_SD 0;
        ctrl_bit_buf <= `MBUSTB_SD 0;
        // Receiver register
        RX_ADDR <= `MBUSTB_SD 0;
        RX_DATA <= `MBUSTB_SD 0;
        rx_data_buf <= `MBUSTB_SD 0;
        // Interface registers
        TX_ACK <= `MBUSTB_SD 0;
        // address enumeration
        enum_addr_resp <= `MBUSTB_SD ADDR_ENUM_RESPOND_NONE;
        // address enumeration interface
        ASSIGNED_ADDR_WRITE <= `MBUSTB_SD 0;
        ASSIGNED_ADDR_INVALIDn <= `MBUSTB_SD 1;
    end
    else
    begin
        // general registers
        mode <= `MBUSTB_SD next_mode;
        if (~BUS_INT)
        begin
            bit_position <= `MBUSTB_SD next_bit_position;
            rx_data_buf <= `MBUSTB_SD next_rx_data_buf;
            // Receiver register
            RX_ADDR <= `MBUSTB_SD next_rx_addr;
            RX_DATA <= `MBUSTB_SD next_rx_data;
        end
        req_interrupt <= `MBUSTB_SD next_req_interrupt;

        // Pat Fix
        req_interrupt_because_error <= `MBUSTB_SD next_req_interrupt_because_error;

        out_reg_pos <= `MBUSTB_SD next_out_reg_pos;
        // Transmitter registers
        ADDR <= `MBUSTB_SD next_addr;
        DATA <= `MBUSTB_SD next_data;
        tx_pend <= `MBUSTB_SD next_tx_pend;
        tx_underflow <= `MBUSTB_SD next_tx_underflow;
        ctrl_bit_buf <= `MBUSTB_SD next_ctrl_bit_buf;
        // Interface registers
        TX_ACK <= `MBUSTB_SD next_tx_ack;
        // address enumeration
        enum_addr_resp <= `MBUSTB_SD next_enum_addr_resp;
        // address enumeration interface
        ASSIGNED_ADDR_WRITE <= `MBUSTB_SD next_assigned_addr_write;
        ASSIGNED_ADDR_INVALIDn <= `MBUSTB_SD next_assigned_addr_invalidn;
    end
end

always @ *
begin
    // general registers
    next_mode = mode;
    next_bus_state = bus_state;
    next_bit_position = bit_position;
    next_req_interrupt = req_interrupt;

    // Pat Fix
    next_req_interrupt_because_error = req_interrupt_because_error;

    next_out_reg_pos = out_reg_pos;

    // Transmitter registers
    next_addr = ADDR;
    next_data = DATA;
    next_tx_pend = tx_pend;
    next_tx_underflow = tx_underflow;
    next_ctrl_bit_buf = ctrl_bit_buf;

    // Receiver register
    next_rx_addr = RX_ADDR;
    next_rx_data = RX_DATA;
    next_rx_fail = RX_FAIL;
    next_rx_data_buf = rx_data_buf;

    // Interface registers
    next_rx_req = RX_REQ;
    next_rx_pend = RX_PEND;
    next_tx_fail = TX_FAIL;
    next_tx_success = TX_SUCC;
    next_tx_ack = TX_ACK;

    // Address enumeration
    next_enum_addr_resp = enum_addr_resp;

    // Address enumeratio interface
    next_assigned_addr_write = 0;
    next_assigned_addr_invalidn = 1;

    // Asynchronous interface
    if (TX_ACK & (~TX_REQ))
        next_tx_ack = 0;

    case (bus_state)
        BUS_IDLE:
        begin
            if (DIN^DOUT)
                next_mode = MODE_TX_NON_PRIO;
            else
                next_mode = MODE_RX;
            // general registers
            next_bus_state = BUS_ARBITRATE;
            next_bit_position = `MBUSTB_ADDR_WIDTH - 1'b1;
        end

        BUS_ARBITRATE:
        begin
            next_bus_state = BUS_PRIO;
        end

        BUS_PRIO:
        begin
            next_mode = mode_temp;
            next_bus_state = BUS_ADDR;
            // no matter this node wins the arbitration or not, must clear
            // type T1
            if (enum_addr_resp== ADDR_ENUM_RESPOND_T1)
                next_enum_addr_resp = ADDR_ENUM_RESPOND_NONE;

            if (mode_temp==MODE_TX)
            begin
                case (enum_addr_resp)
                    // respond to enumeration
                    ADDR_ENUM_RESPOND_T1:
                    begin
                        next_bit_position = `MBUSTB_SHORT_ADDR_WIDTH - 1'b1;
                        next_assigned_addr_write = 1;
                    end

                    // respond to query
                    ADDR_ENUM_RESPOND_T2:
                    begin
                        next_bit_position = `MBUSTB_SHORT_ADDR_WIDTH - 1'b1;
                        next_enum_addr_resp = ADDR_ENUM_RESPOND_NONE;
                    end

                    // TX initiated from layer controller
                    default:
                    begin
                        next_addr = TX_ADDR;
                        next_data = TX_DATA;
                        next_tx_ack = 1;
                        next_tx_pend = TX_PEND;
                        if (tx_long_addr_en)
                            next_bit_position = `MBUSTB_ADDR_WIDTH - 1'b1;
                        else
                            next_bit_position = `MBUSTB_SHORT_ADDR_WIDTH - 1'b1;
                    end
                endcase
            end
            else
            // RX mode
            begin
                next_rx_data_buf = 0;
                next_rx_addr = 0;
            end
        end

        BUS_ADDR:
        begin
            case (mode)
                MODE_TX:
                begin
                    if (bit_position)
                        next_bit_position = bit_position - 1'b1;
                    else
                    begin
                        next_bit_position = `MBUSTB_DATA_WIDTH - 1'b1;
                        next_bus_state = BUS_DATA;
                    end
                end

                MODE_RX:
                begin
                    // short address
                    if ((bit_position==`MBUSTB_ADDR_WIDTH-3'd5)&&(RX_ADDR[3:0]!=4'hf))
                        next_bit_position = `MBUSTB_SHORT_ADDR_WIDTH - 3'd6;
                    else
                    begin
                        if (bit_position)
                            next_bit_position = bit_position - 1'b1;
                        else
                        begin
                            next_bit_position = `MBUSTB_DATA_WIDTH - 1'b1;
                            next_bus_state = BUS_DATA_RX_ADDI;
                        end
                    end
                    next_rx_addr = {RX_ADDR[`MBUSTB_ADDR_WIDTH-2:0], DIN};
                end
            endcase
        end

        BUS_DATA_RX_ADDI:
        begin
            next_rx_data_buf = {rx_data_buf[`MBUSTB_DATA_WIDTH:0], DIN};
            next_bit_position = bit_position - 1'b1;
            if (bit_position==(`MBUSTB_DATA_WIDTH-2'b10))
            begin
                next_bus_state = BUS_DATA;
                next_bit_position = `MBUSTB_DATA_WIDTH - 1'b1;
            end
            if (address_match==0)
                next_mode = MODE_FWD;
        end

        BUS_DATA:
        begin
            case (mode)
                MODE_TX:
                begin
                    // support variable tx length for broadcast messages
                    if (((tx_dat_length==LENGTH_4BYTE)&&(bit_position>0))||((tx_dat_length==LENGTH_3BYTE)&&(bit_position>8))||((tx_dat_length==LENGTH_2BYTE)&&(bit_position>16))||((tx_dat_length==LENGTH_1BYTE)&&(bit_position>24)))
                    //if (bit_position)
                        next_bit_position = bit_position - 1'b1;
                    else
                    begin
                        next_bit_position = `MBUSTB_DATA_WIDTH - 1'b1;
                        case ({tx_pend, TX_REQ})
                            // continue next word
                            2'b11:
                            begin
                                next_tx_pend = TX_PEND;
                                next_data = TX_DATA;
                                next_tx_ack = 1;
                            end
                            
                            // underflow
                            2'b10:
                            begin
                                next_bus_state = BUS_REQ_INTERRUPT;
                                next_tx_underflow = 1;
                                next_req_interrupt = 1;

                                // Pat Fix
                                next_req_interrupt_because_error = 1;

                                next_tx_fail = 1;
                            end

                            default:
                            begin
                                next_bus_state = BUS_REQ_INTERRUPT;
                                next_req_interrupt = 1;
                            end
                        endcase
                    end
                end

                MODE_RX:
                begin
                    next_rx_data_buf = {rx_data_buf[`MBUSTB_DATA_WIDTH:0], DIN};
                    if (bit_position)
                        next_bit_position = bit_position - 1'b1;
                    else
                    begin
                        if (RX_REQ)
                        begin
                            // RX overflow
                            next_bus_state = BUS_REQ_INTERRUPT;
                            next_req_interrupt = 1;

                            // Pat Fix
                            next_req_interrupt_because_error = 1;

                            next_rx_fail = 1;
                        end
                        else
                        begin
                            next_bus_state = BUS_DATA_RX_CHECK;
                            next_bit_position = `MBUSTB_DATA_WIDTH - 1'b1;
                        end
                    end
                end

            endcase
        end

        BUS_DATA_RX_CHECK:
        begin
            next_bit_position = bit_position - 1'b1;
            next_rx_data_buf = {rx_data_buf[`MBUSTB_DATA_WIDTH:0], DIN};
            if (RX_BROADCAST)
            begin
                if (MASTER_NODE==1'b1)
                    next_rx_req = 1;
                else
                    next_rx_req = 0;
            end
            else
                next_rx_req = 1;
            next_rx_pend = 1;
            next_rx_data = rx_data_buf[`MBUSTB_DATA_WIDTH+1:2];
            next_bus_state = BUS_DATA;
        end

        BUS_REQ_INTERRUPT:
        begin
        end

        BUS_CONTROL0:
        begin
            next_bus_state = BUS_CONTROL1;
            next_ctrl_bit_buf = DIN;

            case (mode)
                MODE_TX:
                begin
                    if (req_interrupt)
                    begin
                        // Prevent wire floating
                        next_out_reg_pos = ~CONTROL_BITS[0];
                    end
                    else
                    begin
                        next_tx_fail = 1;
                    end
                end

                MODE_RX:
                begin
                    if (req_interrupt)
                        next_out_reg_pos = ~CONTROL_BITS[0];
                    else
                    begin
                        // End of Message
                        // correct ending state
                        // rx above tx = 31
                        // rx below tx = 1
                        if ((DIN==CONTROL_BITS[1])&&(rx_dat_length_valid))
                        begin
                            // rx overflow
                            if (RX_REQ)
                            begin
                                next_out_reg_pos = ~CONTROL_BITS[0];
                                next_rx_fail = 1;
                            end
                            else
                            // assert rx_req if not a broadcast
                            begin
                                next_rx_data = rx_data_buf_proc;
                                next_out_reg_pos = CONTROL_BITS[0];
                                if (~RX_BROADCAST)
                                    next_rx_req = 1;
                                next_rx_pend = 0;
                            end

                            // broadcast message 
                            if (RX_BROADCAST)
                            begin
                                // assert broadcast rx_req only in CPU layer
                                if ((MASTER_NODE==1'b1)&&(~RX_REQ))
                                    next_rx_req = 1;
                                // broadcast channel
                                case (RX_ADDR[`MBUSTB_FUNC_WIDTH-1:0])
                                    `MBUSTB_CHANNEL_ENUM:
                                    begin
                                        case (rx_broadcast_command)
                                            // any node should report its full prefix and short prefix (dynamic allocated address)
                                            // Pad "0" if the dynamic address is invalid
                                            `MBUSTB_CMD_CHANNEL_ENUM_QUERRY:
                                            begin
                                                // this node doesn't have a valid short address, active low
                                                next_enum_addr_resp = ADDR_ENUM_RESPOND_T2;
                                                next_addr = broadcast_addr[`MBUSTB_SHORT_ADDR_WIDTH-1:0];
                                                next_data = ((`MBUSTB_CMD_CHANNEL_ENUM_RESPONSE<<(`MBUSTB_DATA_WIDTH-`MBUSTB_BROADCAST_CMD_WIDTH)) | (ADDRESS<<`MBUSTB_DYNA_WIDTH) | ASSIGNED_ADDR_IN);
                                            end

                                            // request arbitration, set short prefix if successed
                                            `MBUSTB_CMD_CHANNEL_ENUM_ENUMERATE:
                                            begin
                                                if (~ASSIGNED_ADDR_VALID)
                                                begin
                                                    next_enum_addr_resp = ADDR_ENUM_RESPOND_T1;
                                                    next_addr = broadcast_addr[`MBUSTB_SHORT_ADDR_WIDTH-1:0];
                                                    next_data = ((`MBUSTB_CMD_CHANNEL_ENUM_RESPONSE<<(`MBUSTB_DATA_WIDTH-`MBUSTB_BROADCAST_CMD_WIDTH)) | (ADDRESS<<`MBUSTB_DYNA_WIDTH) | rx_data_buf_proc[`MBUSTB_DYNA_WIDTH-1:0]);
                                                end
                                            end

                                            `MBUSTB_CMD_CHANNEL_ENUM_INVALIDATE:
                                            begin
                                                case (rx_data_buf_proc[`MBUSTB_DYNA_WIDTH-1:0])
                                                    {`MBUSTB_DYNA_WIDTH{1'b1}}: begin next_assigned_addr_invalidn  = 0; end
                                                    ASSIGNED_ADDR_IN: begin next_assigned_addr_invalidn  = 0; end
                                                    default: begin end
                                                endcase
                                            end
                                        endcase
                                    end

                                    // shoud only be active at master
                                    `MBUSTB_CHANNEL_CTRL:
                                    begin
                                        if (MASTER_NODE==1'b1)
                                            next_rx_req = 1;
                                    end
                                endcase
                            end // endif rx_broadcast
                        end // endif valid reception
                        else
                        // invalid data length or invalid EOM
                        begin
                            next_out_reg_pos = ~CONTROL_BITS[0];
                                next_rx_fail = 1;
                        end
                    end
                end

            endcase

        end

        BUS_CONTROL1:
        begin
            next_bus_state = BUS_BACK_TO_IDLE;
            if (req_interrupt)
            begin
                if ((mode==MODE_TX)&&(~tx_underflow))
                begin
                    // ACK received
                    if ({ctrl_bit_buf, DIN}==CONTROL_BITS)
                        next_tx_success = 1;
                    else
                        next_tx_fail = 1;
                end
            end
        end

        BUS_BACK_TO_IDLE:
        begin
            next_bus_state = BUS_IDLE;
            next_req_interrupt = 0;

            // Pat Fix
            next_req_interrupt_because_error = 0;

            next_mode = MODE_RX;
            next_tx_underflow = 0;
        end
    endcase
end

always @ (negedge CIN or negedge RESETn_local)
begin
    if (~RESETn_local)
    begin
        out_reg_neg <= `MBUSTB_SD 1;
        bus_state_neg <= `MBUSTB_SD BUS_IDLE;
        mode_neg <= `MBUSTB_SD MODE_RX;
    end
    else
    begin
        if (req_interrupt & BUS_INT)
            bus_state_neg <= `MBUSTB_SD BUS_CONTROL0;
        else
            bus_state_neg <= `MBUSTB_SD bus_state;

        mode_neg <= `MBUSTB_SD mode;

        case (bus_state)
            BUS_ADDR:
            begin
                if (mode==MODE_TX)
                    out_reg_neg <= `MBUSTB_SD addr_bit_extract;
            end

            BUS_DATA:
            begin
                if (mode==MODE_TX)
                    out_reg_neg <= `MBUSTB_SD data_bit_extract;
            end

            BUS_CONTROL0:
            begin
                if (req_interrupt)
                begin
                    if (mode==MODE_TX)
                    begin
                        if (tx_underflow)
                            out_reg_neg <= `MBUSTB_SD ~CONTROL_BITS[1];
                        else
                            out_reg_neg <= `MBUSTB_SD CONTROL_BITS[1];
                    end
                    else
                        out_reg_neg <= `MBUSTB_SD ~CONTROL_BITS[1];
                end
            end

            BUS_CONTROL1:
            begin
                out_reg_neg <= `MBUSTB_SD out_reg_pos;
            end

        endcase
    end
end

mbus_swapper_testbench mbus_swapper_testbench_0 (
    // inputs
    .CLK(CIN),
    .RESETn(RESETn_local),
    .DATA(DIN),
    .INT_FLAG_RESETn(BUS_INT_RSTn),
    //Outputs
    .LAST_CLK(),
    .INT_FLAG(BUS_INT));


//*********************************************************************************
// MBUS SNOOPER IMPLEMENTATION
//*********************************************************************************

integer idx_i;
reg msg_pending, next_msg_pending;
reg get_addr;
reg RX_REQ_dly;
reg RX_REQ_dly2;
reg [7:0] snoop_rx_addr;
reg [31:0] snoop_rx_data [`SNOOP_MAX_NUM_WORDS-1:0];
reg [31:0] snoop_num_rx_word;
reg [1:0] snoop_rx_ctrl;
always @ (RX_REQ) RX_REQ_dly  = #2 RX_REQ;
always @ (RX_REQ) RX_REQ_dly2 = #4 RX_REQ;

// DETECT LONG (>32 bit) MESSAGES
always @ (posedge RX_REQ_dly or negedge RESETn_local) begin
    if (~RESETn_local) begin
        msg_pending <= `MBUSTB_SD 0;
    end
    else begin
        msg_pending <= `MBUSTB_SD next_msg_pending;
    end
end

always @* begin
    next_msg_pending = msg_pending;

    if (RX_REQ) begin
        if (RX_PEND) begin
            next_msg_pending = 1;
        end
        else begin
            next_msg_pending = 0;
        end
    end
end

// RX_ADDR
always @ (posedge RX_REQ or negedge RESETn_local) begin
    if (~RESETn_local) get_addr <= 0;
    else if (~msg_pending) get_addr <= 1;
    else get_addr <= 0;
end
always @ (negedge RX_REQ_dly or negedge RESETn_local) begin
    if (~RESETn_local) snoop_rx_addr <= 0;
    else if (get_addr) snoop_rx_addr <= RX_ADDR;
end

// RX_DATA
always @ (negedge RX_REQ_dly or negedge RESETn_local) begin
    snoop_rx_data[snoop_num_rx_word] <= RX_DATA;
end

// NUM_WORD RECEIVED
always @ (negedge RX_REQ or negedge RESETn_local) begin
    if (~RESETn_local) snoop_num_rx_word <= 0;
    else if (get_addr) snoop_num_rx_word <= 0;
    else snoop_num_rx_word <= snoop_num_rx_word + 1;
end

// CTRL BITS
always @ (posedge CIN or negedge RESETn_local) begin
    if (~RESETn_local) snoop_rx_ctrl <= 0;
    else if (bus_state == BUS_CONTROL0) snoop_rx_ctrl <= {DOUT, snoop_rx_ctrl[0]};
    else if (bus_state == BUS_CONTROL1) snoop_rx_ctrl <= {snoop_rx_ctrl[1], DIN};
end

// DISPLAY
reg display_event;
reg RESETn_display_event;
always @* RESETn_display_event = `MBUSTB_LD RESETn_local & ~display_event;
always @ (posedge CIN or negedge RESETn_display_event) begin
    if (~RESETn_display_event) display_event <= 0;
    else if (bus_state == BUS_BACK_TO_IDLE) display_event <= 1;
end

always @ (posedge CIN) begin
    if (bus_state == BUS_BACK_TO_IDLE) begin
        if (RX_FAIL) begin
            `SNOOP_COLOR_SET;
            $write("\n*** Time %0dns: [NODE_%0d] MBUS MSG RX FAIL", $time, SHORT_PREFIX); 
            $write(" ");
            `SNOOP_COLOR_RESET;
            $write("\n");
        end
        else begin
            `SNOOP_COLOR_SET;
            $write("\n*** Time %0dns: [NODE_%0d] ADDR=0x%h, DATA=0x", $time, SHORT_PREFIX, snoop_rx_addr); 

            for (idx_i = 0; idx_i < snoop_num_rx_word + 1; idx_i=idx_i+1) begin
                $write("%08h", snoop_rx_data[idx_i]);
                if (idx_i != snoop_num_rx_word) begin
                    $write ("_");
                end

            end
            $write(" %0s", snoop_rx_ctrl[1] ? (/*EOM*/ snoop_rx_ctrl[0] ? "[NAK]" : "[ACK]") : (/*NoEOM*/ snoop_rx_ctrl[0] ? "[TRX Error]" : "[Gen Error]"));
            $write(" ");
            `SNOOP_COLOR_RESET;

            // MBus Message Parser
            // Broadcast Channel 0
            if (snoop_rx_addr == 8'b0) begin 
                // These are all 8-bit messages
                if      ((snoop_rx_data[0] & 32'hFFFFFFF0) == 32'h00000000) begin $write("(QRY)");           end
                else if ((snoop_rx_data[0] & 32'hFFFFFFF0) == 32'h00000020) begin $write("(ENUM)");          end
                else if ((snoop_rx_data[0] & 32'hFFFFFFF0) == 32'h00000030) begin $write("(INVLD_PREFIX)");  end
                // These are 32-bit messages
                else if ((snoop_rx_data[0] & 32'hF0000000) == 32'h10000000) begin $write("(QRY/ENUM_RESP)"); end
            end
            // Broadcast Channel 1
            else if (snoop_rx_addr == 8'b1) begin
                // These are 32-bit messages
                if      ((snoop_rx_data[0] & 32'hF0000000) == 32'h40000000) begin $write("(SEL_SLEEP_FULL)");  end
                else if ((snoop_rx_data[0] & 32'hF0000000) == 32'h50000000) begin $write("(SEL_WAKE_FULL)");   end
                // These are 24-bit messages
                else if ((snoop_rx_data[0] & 32'hFFF00000) == 32'h00200000) begin $write("(SEL_SLEEP_SHORT)"); end
                else if ((snoop_rx_data[0] & 32'hFFF00000) == 32'h00300000) begin $write("(SEL_WAKE_SHORT)");  end
                // These are 8-bit messages
                else if ((snoop_rx_data[0] & 32'hFFFFFFF0) == 32'h00000000) begin $write("(ALL_SLEEP)"); end
                else if ((snoop_rx_data[0] & 32'hFFFFFFF0) == 32'h00000010) begin $write("(ALL_WAKE)");  end
            end
            // Normal Messages
            else if ((snoop_rx_addr & 8'h0F) == 8'h0) begin $write("(REG_WRITE)");   end
            else if ((snoop_rx_addr & 8'h0F) == 8'h1) begin $write("(REG_READ)");    end
            else if ((snoop_rx_addr & 8'h0F) == 8'h2) begin $write("(MEM WRITE)");   end
            else if ((snoop_rx_addr & 8'h0F) == 8'h3) begin $write("(MEM_READ)");    end
            else if ((snoop_rx_addr & 8'h0F) == 8'h4) begin $write("(MEM_STR_CH0)"); end
            else if ((snoop_rx_addr & 8'h0F) == 8'h5) begin $write("(MEM_STR_CH1)"); end
            else if ((snoop_rx_addr & 8'h0F) == 8'h6) begin $write("(MEM_STR_CH2)"); end
            else if ((snoop_rx_addr & 8'h0F) == 8'h7) begin $write("(MEM_STR_CH3)"); end

            $write("\n");
        end
    end
end

endmodule
