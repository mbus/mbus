//*******************************************************************************************
//Author:         Yejoong Kim
//Last Modified:  Jul 27 2017
//Description :   Isolation gate interface for LRC & MBUS controller (FLPv3L)
//Update History: Jun 27 2017 - First Commit (Yejoong Kim)
//******************************************************************************************* 

module	flpv3l_mbus_isolation (
	input			MBC_ISOLATE,
     
	// Layer Ctrl --> MBus Ctrl
	input	[31:0]	TX_ADDR_uniso,
	input	[31:0]	TX_DATA_uniso,
	input			TX_PEND_uniso,
	input			TX_REQ_uniso,
	input			TX_PRIORITY_uniso,
	input			RX_ACK_uniso,
	input			TX_RESP_ACK_uniso,

	output	[31:0]	TX_ADDR,
	output	[31:0]	TX_DATA,
	output			TX_PEND,
	output			TX_REQ,
	output			TX_PRIORITY,
	output			RX_ACK,
	output			TX_RESP_ACK,

	// MBus Ctrl --> Other
	input			LRC_SLEEP_uniso,
	input			LRC_CLKENB_uniso,
	input			LRC_RESET_uniso,
	input			LRC_ISOLATE_uniso,
	
	output			LRC_SLEEP,
	output			LRC_SLEEPB,
	output			LRC_CLKENB,
	output			LRC_CLKEN,
	output			LRC_RESET,
	output			LRC_RESETB,
	output			LRC_ISOLATE

);

	wire	LRC_ISOLATE_B;
	wire	LRC_ISOLATE_unbuf;
	wire	LRC_ISOLATE_B_unbuf;
	wire	MBC_ISOLATE_B;
	wire	LRC_CLKENB_B;
	wire	LRC_RESET_B_int;
	wire	LRC_SLEEP_B;
   
    genvar i;

    generate
        for (i=0; i<32; i=i+1) begin : GEN_TX_ADDR_DATA
	        AND2LLX1HVT_TSMC90 AND2_TX_ADDR (.A(LRC_ISOLATE_B), .B(TX_ADDR_uniso[i]),	.Y(TX_ADDR[i]) );
	        AND2LLX1HVT_TSMC90 AND2_TX_DATA (.A(LRC_ISOLATE_B), .B(TX_DATA_uniso[i]),	.Y(TX_DATA[i]) );
        end
    endgenerate

	AND2LLX1HVT_TSMC90	AND2_TX_PEND	(.A(LRC_ISOLATE_B),	.B(TX_PEND_uniso),	.Y(TX_PEND) );
	AND2LLX1HVT_TSMC90	AND2_TX_REQ		(.A(LRC_ISOLATE_B),	.B(TX_REQ_uniso),	.Y(TX_REQ) );
	AND2LLX1HVT_TSMC90	AND2_TX_PRIORITY(.A(LRC_ISOLATE_B),	.B(TX_PRIORITY_uniso),	.Y(TX_PRIORITY) );
	AND2LLX1HVT_TSMC90	AND2_RX_ACK		(.A(LRC_ISOLATE_B),	.B(RX_ACK_uniso),	.Y(RX_ACK) );
	AND2LLX1HVT_TSMC90	AND2_TX_RESP_ACK	(.A(LRC_ISOLATE_B),	.B(TX_RESP_ACK_uniso),	.Y(TX_RESP_ACK) );

	INVLLX8HVT_TSMC90		INV_MBC_ISOLATE	(.A(MBC_ISOLATE),	.Y(MBC_ISOLATE_B) );
	NOR2LLX1HVT_TSMC90	NOR2_LRC_SLEEP	(.A(MBC_ISOLATE),	.B(LRC_SLEEP_uniso),	.Y(LRC_SLEEP_B) );
	NOR2LLX1HVT_TSMC90	NOR2_LRC_CLKENB	(.A(MBC_ISOLATE),	.B(LRC_CLKENB_uniso),	.Y(LRC_CLKENB_B) );
	NOR2LLX1HVT_TSMC90	NOR2_LRC_RESET	(.A(MBC_ISOLATE),	.B(LRC_RESET_uniso),	.Y(LRC_RESET_B_int) );
	NOR2LLX1HVT_TSMC90	NOR2_LRC_ISOLATE(.A(MBC_ISOLATE),	.B(LRC_ISOLATE_uniso),	.Y(LRC_ISOLATE_B_unbuf) );
   
	INVLLX8HVT_TSMC90		INV_LRC_ISOLATE_B_0_0	(.A(LRC_ISOLATE_B_unbuf),	.Y(LRC_ISOLATE_unbuf) );
	INVLLX8HVT_TSMC90		INV_LRC_ISOLATE_B_0_1	(.A(LRC_ISOLATE_B_unbuf),	.Y(LRC_ISOLATE_unbuf) );
	INVLLX8HVT_TSMC90		INV_LRC_ISOLATE_B_0_2	(.A(LRC_ISOLATE_B_unbuf),	.Y(LRC_ISOLATE_unbuf) );
	INVLLX8HVT_TSMC90		INV_LRC_ISOLATE_B_0_3	(.A(LRC_ISOLATE_B_unbuf),	.Y(LRC_ISOLATE_unbuf) );

	INVLLX8HVT_TSMC90		INV_LRC_ISOLATE_B_1_0	(.A(LRC_ISOLATE_unbuf),	.Y(LRC_ISOLATE_B) );
	INVLLX8HVT_TSMC90		INV_LRC_ISOLATE_B_1_1	(.A(LRC_ISOLATE_unbuf),	.Y(LRC_ISOLATE_B) );
	INVLLX8HVT_TSMC90		INV_LRC_ISOLATE_B_1_2	(.A(LRC_ISOLATE_unbuf),	.Y(LRC_ISOLATE_B) );
	INVLLX8HVT_TSMC90		INV_LRC_ISOLATE_B_1_3	(.A(LRC_ISOLATE_unbuf),	.Y(LRC_ISOLATE_B) );

	INVLLX8HVT_TSMC90		INV_LRC_SLEEP_0	    (.A(LRC_SLEEP_B),	    .Y(LRC_SLEEP)   );
	INVLLX8HVT_TSMC90		INV_LRC_SLEEPB_0    (.A(LRC_SLEEP),	        .Y(LRC_SLEEPB)  );
	INVLLX8HVT_TSMC90		INV_LRC_CLKENB	    (.A(LRC_CLKENB_B),	    .Y(LRC_CLKENB)  );
	INVLLX8HVT_TSMC90		INV_LRC_CLKEN	    (.A(LRC_CLKENB),		.Y(LRC_CLKEN)   );
	INVLLX8HVT_TSMC90		INV_LRC_RESET	    (.A(LRC_RESET_B_int),	.Y(LRC_RESET)   );
	INVLLX8HVT_TSMC90		INV_LRC_RESETB	    (.A(LRC_RESET),	        .Y(LRC_RESETB)  );
	INVLLX8HVT_TSMC90		INV_LRC_ISOLATE	    (.A(LRC_ISOLATE_B),	    .Y(LRC_ISOLATE) );

endmodule // flpv3l_mbus_isolation
