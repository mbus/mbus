//*******************************************************************************************
//Author:         Yejoong Kim, Ye-sheng Kuo
//Last Modified:  May 24 2017
//Description:    MBus Node Control for Master Layer
//Update History: Apr 08 2013 - Added glitch reset (Ye-sheng Kuo)
//                May 25 2015 - Added double latch for DIN (Ye-sheng Kuo, Yejoong Kim)
//                May 21 2016 - Updated for MBus r03 (Yejoong Kim)
//                                  Added "BUS_SWITCH_ROLE: DOUT=1" in "case (bus_state_neg)"
//                                  Changed module name:
//                                      lname_mbus_master_ctrl -> lname_mbus_master_node_ctrl
//                                  Added MBus Watchdog Counter
//                Dec 16 2016 - Updated for MBus r04 (Yejoong Kim)
//                                  Added MBus Flag (MSG_INTERRUPTED)
//                May 24 2017 - Updated for MBus r04p1 (Yejoong Kim)
//                                  Added FORCE_IDLE_WHEN_DONE to fix DIN sync issue between
//                                      master layer and member layer at the end of message
//                                      that requires a reply.
//******************************************************************************************* 

`include "include/lname_mbus_def.v"

module lname_mbus_master_node_ctrl (
    //Input
    input   CLK_EXT,
    input   RESETn,
    input   CIN,
    input   DIN,
    input   [`MBUS_BITS_WD_WIDTH-1:0] NUM_BITS_THRESHOLD,
    input   [`MBUS_IDLE_WD_WIDTH-1:0] WATCHDOG_THRESHOLD,
    input      WATCHDOG_RESET,
    input      WATCHDOG_RESET_REQ,
    output reg WATCHDOG_RESET_ACK,
    
    //Output
    output      COUT,
    output reg  DOUT,
    //MBus Watchdog
    input  [`MBUS_ADDR_WIDTH-1:0] TX_ADDR_IN,
    input  [`MBUS_DATA_WIDTH-1:0] TX_DATA_IN,
    input  TX_PRIORITY_IN,
    input  TX_ACK_IN,
    input  TX_SUCC_IN,
    input  TX_FAIL_IN,
    input  TX_REQ_IN,
    input  TX_PEND_IN,
    input  TX_RESP_ACK_IN,
    
    output [`MBUS_ADDR_WIDTH-1:0] TX_ADDR_OUT,
    output [`MBUS_DATA_WIDTH-1:0] TX_DATA_OUT,
    output TX_PRIORITY_OUT,
    output TX_ACK_OUT,
    output TX_SUCC_OUT,
    output TX_FAIL_OUT,
    output TX_REQ_OUT,
    output TX_PEND_OUT,
    output TX_RESP_ACK_OUT,

    // FSM Configuration
    input  FORCE_IDLE_WHEN_DONE,

    // MBus Msg Interrupted Flag
    input      MBC_IN_FWD,
    input      GOCEP_ACTIVE,
    input      CLEAR_FLAG,
    output reg MSG_INTERRUPTED
);

`include "include/lname_mbus_func.v"

parameter BUS_IDLE = 0;
parameter BUS_WAIT_START = 3;
parameter BUS_START = 4;
parameter BUS_ARBITRATE = 1;
parameter BUS_PRIO = 2;
parameter BUS_ACTIVE = 5;
parameter BUS_INTERRUPT = 7;
parameter BUS_SWITCH_ROLE = 6;
parameter BUS_CONTROL0 = 8;
parameter BUS_CONTROL1 = 9;
parameter BUS_BACK_TO_IDLE = 10;

parameter NUM_OF_BUS_STATE = 11;
parameter START_CYCLES = 10;
parameter GUARD_BAND_NUM_CYCLES = 20;
parameter BUS_INTERRUPT_COUNTER = 6;

reg [log2(START_CYCLES-1)-1:0]          start_cycle_cnt, next_start_cycle_cnt;
reg [log2(NUM_OF_BUS_STATE-1)-1:0]      bus_state, next_bus_state, bus_state_neg;
reg [log2(BUS_INTERRUPT_COUNTER-1)-1:0] bus_interrupt_cnt, next_bus_interrupt_cnt;
reg clk_en, next_clk_en;

reg clkin_sampled; 
reg [2:0] din_sampled_neg, din_sampled_pos;

reg [`MBUS_BITS_WD_WIDTH-1:0] num_bits_threshold_cnt, next_num_bits_threshold_cnt;
reg din_dly_1, din_dly_2;

// DIN double-latch
always @(posedge CLK_EXT or negedge RESETn) begin
    if (~RESETn) begin
        din_dly_1 <= `SD 1'b1;
        din_dly_2 <= `SD 1'b1;
    end
    else if (FORCE_IDLE_WHEN_DONE) begin
        if ((bus_state == BUS_IDLE) | (bus_state == BUS_WAIT_START)) begin
            din_dly_1 <= `SD DIN;
            din_dly_2 <= `SD din_dly_1;
        end
        else begin
            din_dly_1 <= `SD 1'b1;
            din_dly_2 <= `SD 1'b1;
        end
    end
    else begin
        din_dly_1 <= `SD DIN;
        din_dly_2 <= `SD din_dly_1;
    end
end

wire [1:0] CONTROL_BITS = `MBUS_CONTROL_SEQ;    // EOM?, ~ACK?

//---------------------- Watch-Dog Implementation ----------------------------------//
reg WATCHDOG_RESET_REQ_DL1, WATCHDOG_RESET_REQ_DL2;
reg next_watchdog_reset_ack;
reg WATCHDOG_RESET_DL1, WATCHDOG_RESET_DL2;
reg [`MBUS_IDLE_WD_WIDTH-1:0] watchdog_cnt, next_watchdog_cnt;
reg watchdog_tx_req, next_watchdog_tx_req; 
reg watchdog_tx_resp_ack, next_watchdog_tx_resp_ack;
reg watchdog_expired, next_watchdog_expired; 

always @ (posedge CLK_EXT or negedge RESETn) begin
    if (~RESETn) begin
        watchdog_cnt           <= `SD 0;
        watchdog_tx_req        <= `SD 0;
        watchdog_tx_resp_ack   <= `SD 0;
        watchdog_expired       <= `SD 0;
        WATCHDOG_RESET_ACK     <= `SD 0;
        WATCHDOG_RESET_REQ_DL1 <= `SD 0;
        WATCHDOG_RESET_REQ_DL2 <= `SD 0;
        WATCHDOG_RESET_DL1     <= `SD 0;
        WATCHDOG_RESET_DL2     <= `SD 0;
    end
    else begin
        watchdog_cnt           <= `SD next_watchdog_cnt;
        watchdog_tx_req        <= `SD next_watchdog_tx_req;
        watchdog_tx_resp_ack   <= `SD next_watchdog_tx_resp_ack;
        watchdog_expired       <= `SD next_watchdog_expired;
        WATCHDOG_RESET_ACK     <= `SD next_watchdog_reset_ack;
        WATCHDOG_RESET_REQ_DL1 <= `SD WATCHDOG_RESET_REQ;
        WATCHDOG_RESET_REQ_DL2 <= `SD WATCHDOG_RESET_REQ_DL1;
        WATCHDOG_RESET_DL1     <= `SD WATCHDOG_RESET;
        WATCHDOG_RESET_DL2     <= `SD WATCHDOG_RESET_DL1;
    end
end

always @* begin
    next_watchdog_cnt         = watchdog_cnt;
    next_watchdog_tx_req      = watchdog_tx_req;
    next_watchdog_tx_resp_ack = watchdog_tx_resp_ack;
    next_watchdog_expired     = watchdog_expired;
    next_watchdog_reset_ack   = WATCHDOG_RESET_ACK;

    if (watchdog_expired) begin
        if (watchdog_tx_req) begin
            if (TX_ACK_IN)
                next_watchdog_tx_req = 0;

            if (TX_FAIL_IN & (~watchdog_tx_resp_ack))
                next_watchdog_tx_req = 0;
        end

        if (TX_SUCC_IN | TX_FAIL_IN)
            next_watchdog_tx_resp_ack = 1;

        if ((~(TX_SUCC_IN | TX_FAIL_IN)) & watchdog_tx_resp_ack)
            next_watchdog_tx_resp_ack = 0;
    end

    if (WATCHDOG_RESET_REQ_DL2 & (~WATCHDOG_RESET_ACK)) next_watchdog_reset_ack = 1;
    if ((~WATCHDOG_RESET_REQ_DL2) & WATCHDOG_RESET_ACK) next_watchdog_reset_ack = 0;

    if (WATCHDOG_RESET_REQ_DL2 & (~WATCHDOG_RESET_ACK)) // Reset requested by CPU
        next_watchdog_cnt = 0;
    else if (WATCHDOG_RESET_DL2) // Pause Watchdog
        next_watchdog_cnt = 0;
    else if ((bus_state != BUS_IDLE) | (bus_state != BUS_IDLE)) // Reset due to non-idle state
        next_watchdog_cnt = 0;
    else 
        next_watchdog_cnt = watchdog_cnt + 1'b1;

    if ((bus_state == BUS_IDLE) & (next_bus_state == BUS_IDLE)) begin
        if ((WATCHDOG_THRESHOLD != 0) & (watchdog_cnt == WATCHDOG_THRESHOLD)) begin
            if (~watchdog_expired) next_watchdog_tx_req  = 1;
            next_watchdog_expired = 1;
        end
    end

end

// Watch-Dog: Layer Ctrl --> MBus Node
assign TX_REQ_OUT  = (watchdog_expired) ? watchdog_tx_req  : TX_REQ_IN;
assign TX_PEND_OUT = (watchdog_expired) ? 1'b0             : TX_PEND_IN;
assign TX_ADDR_OUT = (watchdog_expired) ? 32'h0000_0001    : TX_ADDR_IN; // All Selective Sleep msg if watchdog expires
assign TX_DATA_OUT = (watchdog_expired) ? 32'h2FFF_F000    : TX_DATA_IN; // All Selective Sleep msg if watchdog expires
assign TX_RESP_ACK_OUT  = (watchdog_expired) ? watchdog_tx_resp_ack  : TX_RESP_ACK_IN;
assign TX_PRIORITY_OUT  = (watchdog_expired) ? 1'b0                  : TX_PRIORITY_IN;

// Watch-Dog: MBus Node --> Layer Ctrl
assign TX_ACK_OUT  = (watchdog_expired) ? 1'b0 : TX_ACK_IN;
assign TX_FAIL_OUT = (watchdog_expired) ? 1'b0 : TX_FAIL_IN;
assign TX_SUCC_OUT = (watchdog_expired) ? 1'b0 : TX_SUCC_IN;

//--------------- End of Watch-Dog Implementation ----------------------------------//

//--------------- Start of MBus Message Interrupted Flag ---------------//
reg gocep_active_dl1, gocep_active_dl2;
reg tx_req_in_dl1, tx_req_in_dl2;
reg [4:0] guard_band_cnt, next_guard_band_cnt;
reg very_first_msg, next_very_first_msg;

always @ (posedge CLK_EXT or negedge RESETn) begin
    if (~RESETn) begin
        gocep_active_dl1 <= `SD 0;
        gocep_active_dl2 <= `SD 0;
        tx_req_in_dl1    <= `SD 0;
        tx_req_in_dl2    <= `SD 0;
        guard_band_cnt   <= `SD 0;
        very_first_msg   <= `SD 1;
    end
    else begin
        gocep_active_dl1 <= `SD GOCEP_ACTIVE;
        gocep_active_dl2 <= `SD gocep_active_dl1;
        tx_req_in_dl1    <= `SD TX_REQ_IN;
        tx_req_in_dl2    <= `SD tx_req_in_dl1;
        guard_band_cnt   <= `SD next_guard_band_cnt;
        very_first_msg   <= `SD next_very_first_msg;
    end
end

always @* begin
    next_guard_band_cnt = guard_band_cnt;

    if ((bus_state != BUS_IDLE) & (next_bus_state == BUS_IDLE))
        next_guard_band_cnt = GUARD_BAND_NUM_CYCLES;
    else if (guard_band_cnt > 0) next_guard_band_cnt = guard_band_cnt - 1;
end

always @* begin
    next_very_first_msg = very_first_msg;
    if ((guard_band_cnt > 0) & (next_guard_band_cnt == 0)) 
        next_very_first_msg = 0;
end

wire RESETn_FLAG = RESETn & ~CLEAR_FLAG;

// MSG_INTERRUPTED is set when GOC becomes activated while there is an on-going MBus message only if:
//      - The MBus message is NOT the first message (usually this is a wake-up message)
//      - The MBus message is either Tx or Rx for PRC/PRE
//          If it is a forwarding message, the flag is not set.
//          However, since the 'forward' message cannot be identified until it
//          receives the whole MBus ADDR section, it is possible that the 
//          flag becomes set even if the MBus message is a forwarding message. 
//          This could happen if GOC becomes activated while PRC/PRE is receiving 
//          the ADDR section of the forwarding message.
//      - The MBus message finishes, but the Guard Band counter (guard_band_cnt) is not zero.
//          This is to provide some margin to cover the last RX_REQ/RX_ACK in
//          a long MBus message.
//      - There is an un-cleared TX_REQ
always @ (posedge CLK_EXT or negedge RESETn_FLAG) begin
    if (~RESETn_FLAG) MSG_INTERRUPTED <= `SD 0;
    else if (gocep_active_dl1 & ~gocep_active_dl2) begin
        if (~very_first_msg & ~MBC_IN_FWD) begin    
            if ((bus_state != BUS_IDLE) | (guard_band_cnt > 0)) MSG_INTERRUPTED <= `SD 1;
        end
        else if (tx_req_in_dl2 & ~TX_ACK_IN) MSG_INTERRUPTED <= `SD 1;
    end
end

//--------------- End of MBus Message Interrupted Flag ---------------//


always @ (posedge CLK_EXT or negedge RESETn) begin
    if (~RESETn) begin
        bus_state              <= `SD BUS_IDLE;
        start_cycle_cnt        <= `SD START_CYCLES - 1'b1;
        clk_en                 <= `SD 0;
        bus_interrupt_cnt      <= `SD BUS_INTERRUPT_COUNTER - 1'b1;
        num_bits_threshold_cnt <= `SD 0;
    end
    else begin
        bus_state              <= `SD next_bus_state;
        start_cycle_cnt        <= `SD next_start_cycle_cnt;
        clk_en                 <= `SD next_clk_en;
        bus_interrupt_cnt      <= `SD next_bus_interrupt_cnt;
        num_bits_threshold_cnt <= `SD next_num_bits_threshold_cnt;
    end
end

always @* begin
    next_bus_state              = bus_state;
    next_start_cycle_cnt        = start_cycle_cnt;
    next_clk_en                 = clk_en;
    next_bus_interrupt_cnt      = bus_interrupt_cnt;
    next_num_bits_threshold_cnt = num_bits_threshold_cnt;

    case (bus_state)
        BUS_IDLE: begin
                    if (FORCE_IDLE_WHEN_DONE) begin
                        if (~din_dly_2) begin
                            next_bus_state = BUS_WAIT_START;    
                            if (watchdog_cnt < 4) next_start_cycle_cnt = 0;
                            else next_start_cycle_cnt = START_CYCLES - 1'b1;
                        end
                    end
                    else begin
                        if (~din_dly_2) next_bus_state = BUS_WAIT_START;    
                        next_start_cycle_cnt = START_CYCLES - 1'b1;
                    end
                end

        BUS_WAIT_START: begin
                    next_num_bits_threshold_cnt = 0;
                    if (start_cycle_cnt) next_start_cycle_cnt = start_cycle_cnt - 1'b1;
                    else begin
                        if (~din_dly_2) begin
                            next_clk_en = 1;
                            next_bus_state = BUS_START;
                        end
                        else next_bus_state = BUS_IDLE;
                    end
                end

        BUS_START: next_bus_state = BUS_ARBITRATE;

        BUS_ARBITRATE: begin
                    next_bus_state = BUS_PRIO;
                    if (DIN) next_num_bits_threshold_cnt = NUM_BITS_THRESHOLD; // Glitch, reset bus immediately
                end

        BUS_PRIO: next_bus_state = BUS_ACTIVE;

        BUS_ACTIVE: begin
                    if ((num_bits_threshold_cnt<NUM_BITS_THRESHOLD)&&(~clkin_sampled)) 
                        next_num_bits_threshold_cnt = num_bits_threshold_cnt + 1'b1;
                    else begin
                        next_clk_en = 0;
                        next_bus_state = BUS_INTERRUPT;
                    end
                    next_bus_interrupt_cnt = BUS_INTERRUPT_COUNTER - 1'b1;
                end

        BUS_INTERRUPT: begin
                    if (bus_interrupt_cnt) next_bus_interrupt_cnt = bus_interrupt_cnt - 1'b1;
                    else begin
                        if ({din_sampled_neg, din_sampled_pos}==6'b111_000) begin
                            next_bus_state = BUS_SWITCH_ROLE;
                            next_clk_en = 1;
                        end
                    end
                end

        BUS_SWITCH_ROLE: next_bus_state = BUS_CONTROL0;

        BUS_CONTROL0: next_bus_state = BUS_CONTROL1;

        BUS_CONTROL1: next_bus_state = BUS_BACK_TO_IDLE;

        BUS_BACK_TO_IDLE: begin
                    if (FORCE_IDLE_WHEN_DONE) begin
                        next_bus_state = BUS_IDLE;
                        next_clk_en = 0;
                    end
                    else begin
                        if (~DIN) begin
                            next_bus_state = BUS_WAIT_START;
                            next_start_cycle_cnt = 1;
                        end
                        else begin
                            next_bus_state = BUS_IDLE;
                        end
                        next_clk_en = 0;
                    end
                end
    endcase
end

always @ (negedge CLK_EXT or negedge RESETn) begin
    if (~RESETn) begin
        din_sampled_neg <= `SD 0;
        bus_state_neg <= `SD BUS_IDLE;
    end
    else begin
        if (bus_state==BUS_INTERRUPT) din_sampled_neg <= `SD {din_sampled_neg[1:0], DIN};
        bus_state_neg <= `SD bus_state;
    end
end

always @ (posedge CLK_EXT or negedge RESETn) begin
    if (~RESETn) begin
        din_sampled_pos <= `SD 0;
        clkin_sampled <= `SD 0;
    end
    else begin
        if (bus_state==BUS_INTERRUPT) din_sampled_pos <= `SD {din_sampled_pos[1:0], DIN};
        clkin_sampled <= `SD CIN;
    end
end

assign COUT = (clk_en)? CLK_EXT : 1'b1;

always @* begin
    DOUT = DIN;
    case (bus_state_neg)
        BUS_IDLE:         DOUT = 1;
        BUS_WAIT_START:   DOUT = 1; 
        BUS_START:        DOUT = 1;
        BUS_INTERRUPT:    DOUT = CLK_EXT;
        BUS_SWITCH_ROLE:  DOUT = 1;
        BUS_CONTROL0:     if (num_bits_threshold_cnt==NUM_BITS_THRESHOLD) DOUT = (~CONTROL_BITS[1]);
        BUS_BACK_TO_IDLE: DOUT = 1;
    endcase

end
endmodule // lname_mbus_master_node_ctrl
