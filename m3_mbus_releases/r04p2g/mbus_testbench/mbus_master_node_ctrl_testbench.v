//*******************************************************************************************
//Author:         Yejoong Kim, Ye-sheng Kuo
//Last Modified:  Aug 23 2017
//Description:    (Testbench) MBus Node Control for Master Layer
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
//                                  Changed some variable names to be consistent with lname_mbus_master_node_ctrl.v
//                                      THRESHOLD          -> NUM_BITS_THRESHOLD
//                                      threshold_cnt      -> num_bits_threshold_cnt
//                                      next_threshold_cnt -> next_num_bits_threshold_cnt
//                Aug 23 2017 - Checked for mbus_testbench
//******************************************************************************************* 

`include "include/mbus_def_testbench.v"

module mbus_master_node_ctrl_testbench (
    //Input
    input   CLK_EXT,
    input   RESETn,
    input   CIN,
    input   DIN,
    input   [`MBUSTB_BITS_WD_WIDTH-1:0] NUM_BITS_THRESHOLD,
    //Output
    output      COUT,
    output reg  DOUT,

    // FSM Configuration
    input  FORCE_IDLE_WHEN_DONE

);

`include "include/mbus_func_testbench.v"

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

reg [`MBUSTB_BITS_WD_WIDTH-1:0] num_bits_threshold_cnt, next_num_bits_threshold_cnt;
reg din_dly_1, din_dly_2;

// DIN double-latch
always @(posedge CLK_EXT or negedge RESETn) begin
    if (~RESETn) begin
        din_dly_1 <= `MBUSTB_SD 1'b1;
        din_dly_2 <= `MBUSTB_SD 1'b1;
    end
    else if (FORCE_IDLE_WHEN_DONE) begin
        if ((bus_state == BUS_IDLE) | (bus_state == BUS_WAIT_START)) begin
            din_dly_1 <= `MBUSTB_SD DIN;
            din_dly_2 <= `MBUSTB_SD din_dly_1;
        end
        else begin
            din_dly_1 <= `MBUSTB_SD 1'b1;
            din_dly_2 <= `MBUSTB_SD 1'b1;
        end
    end
    else begin
        din_dly_1 <= `MBUSTB_SD DIN;
        din_dly_2 <= `MBUSTB_SD din_dly_1;
    end
end

wire [1:0] CONTROL_BITS = `MBUSTB_CONTROL_SEQ;    // EOM?, ~ACK?

always @ (posedge CLK_EXT or negedge RESETn) begin
    if (~RESETn) begin
        bus_state               <= `MBUSTB_SD BUS_IDLE;
        start_cycle_cnt         <= `MBUSTB_SD START_CYCLES - 1'b1;
        clk_en                  <= `MBUSTB_SD 0;
        bus_interrupt_cnt       <= `MBUSTB_SD BUS_INTERRUPT_COUNTER - 1'b1;
        num_bits_threshold_cnt  <= `MBUSTB_SD 0;
    end
    else begin
        bus_state               <= `MBUSTB_SD next_bus_state;
        start_cycle_cnt         <= `MBUSTB_SD next_start_cycle_cnt;
        clk_en                  <= `MBUSTB_SD next_clk_en;
        bus_interrupt_cnt       <= `MBUSTB_SD next_bus_interrupt_cnt;
        num_bits_threshold_cnt  <= `MBUSTB_SD next_num_bits_threshold_cnt;
    end
end

always @* begin
    next_bus_state          = bus_state;
    next_start_cycle_cnt    = start_cycle_cnt;
    next_clk_en             = clk_en;
    next_bus_interrupt_cnt  = bus_interrupt_cnt;
    next_num_bits_threshold_cnt      = num_bits_threshold_cnt;

    case (bus_state)
        BUS_IDLE: begin
                    if (~din_dly_2) next_bus_state = BUS_WAIT_START;    
                    next_start_cycle_cnt = START_CYCLES - 1'b1;
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
        din_sampled_neg <= `MBUSTB_SD 0;
        bus_state_neg <= `MBUSTB_SD BUS_IDLE;
    end
    else begin
        if (bus_state==BUS_INTERRUPT) din_sampled_neg <= `MBUSTB_SD {din_sampled_neg[1:0], DIN};
        bus_state_neg <= `MBUSTB_SD bus_state;
    end
end

always @ (posedge CLK_EXT or negedge RESETn) begin
    if (~RESETn) begin
        din_sampled_pos <= `MBUSTB_SD 0;
        clkin_sampled <= `MBUSTB_SD 0;
    end
    else begin
        if (bus_state==BUS_INTERRUPT) din_sampled_pos <= `MBUSTB_SD {din_sampled_pos[1:0], DIN};
        clkin_sampled <= `MBUSTB_SD CIN;
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
