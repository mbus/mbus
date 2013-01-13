module ulpb_node_top(CLK, RESET, DIN, DOUT, 
					ADDR_IN, DATA_IN, REQ_IN_FROM_LC, ACK_OUT_TO_LC, 
					ADDR_OUT, DATA_OUT, REQ_OUT_TO_LC, ACK_IN_FROM_LC,
					TX_FAIL, TX_SUCCESS, TX_ACK);

parameter ADDR_WIDTH=8;
parameter DATA_WIDTH=32;
parameter ADDRESS=8'hab;
parameter ADDRESS_MASK=8'hff;

input	CLK, RESET;
input	DIN;
output	DOUT;

input	[ADDR_WIDTH-1:0] ADDR_IN;
input	[DATA_WIDTH-1:0] DATA_IN;
input	REQ_IN_FROM_LC;
output	ACK_OUT_TO_LC;

output	[ADDR_WIDTH-1:0] ADDR_OUT;
output	[DATA_WIDTH-1:0] DATA_OUT;
output	REQ_OUT_TO_LC;
input	ACK_IN_FROM_LC;

output	TX_FAIL;
output	TX_SUCCESS;
input	TX_ACK;

parameter DEPTH = 8;
// fifo registers
reg		[ADDR_WIDTH+DATA_WIDTH-1:0] NODE_FIFO [DEPTH-1:0];
reg		[log2(DEPTH-1):0] head, tail;
wire	empty = (head==tail)? 1 : 0;
wire	full = ((tail==0)&&(head==DEPTH-1))? 1 : (tail==head+1)? 1 : 0;
wire	[log2(DEPTH-1):0] previous_tail = (tail==0)? DEPTH-1 : (tail-1);

// state from ulpb
wire	BUSIDLE;

// ulpb control registers
reg		PENDING;
wire	[ADDR_WIDTH-1:0] ulpb_addr_in = (empty)? ADDR_IN : NODE_FIFO[tail][ADDR_WIDTH+DATA_WIDTH-1:DATA_WIDTH];
wire	[DATA_WIDTH-1:0] ulpb_data_in = (empty)? DATA_IN : NODE_FIFO[tail][DATA_WIDTH-1:0];
wire	DATA_LATCHED;
wire	ACK_TX;

// interface registers
reg		ACK_OUT_TO_LC;
reg		REQ_TX, req_tx_reg;

// Simulation only, remove for synthesis
integer k;
initial
begin
	for (k=0; k<DEPTH; k=k+1)
		NODE_FIFO[k] <= 0;
end

always @ (posedge CLK or negedge RESET)
begin
	if (~RESET)
	begin
		head <= 0;
		tail <= 0;
		ACK_OUT_TO_LC <= 0;
	end
	else
	begin
		if (REQ_IN_FROM_LC)
		begin
			if (~full)
			begin
				NODE_FIFO[head] <= {ADDR_IN, DATA_IN};
				head <= head + 1;
				ACK_OUT_TO_LC <= 1;
			end
		end

		if (ACK_OUT_TO_LC & (~REQ_IN_FROM_LC))
			ACK_OUT_TO_LC <= 0;

		if (DATA_LATCHED)
			tail <= tail + 1;
	end
end

always @ (posedge CLK or negedge RESET)
begin
	if (~RESET)
		req_tx_reg <= 0;
	else
		req_tx_reg <= REQ_TX;
end

always @ *
begin
	REQ_TX = req_tx_reg;
	if (BUSIDLE)
		REQ_TX = (~empty) | REQ_IN_FROM_LC;
	else
		if (req_tx_reg & ACK_TX)
			REQ_TX = 0;
end

always @ *
begin
	PENDING = 0;
	if ((NODE_FIFO[previous_tail][ADDR_WIDTH+DATA_WIDTH-1:DATA_WIDTH]==ulpb_addr_in)&&(~empty))
		PENDING = 1;
end

ulpb_node32 #(.ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH), .ADDRESS(ADDRESS), .ADDRESS_MASK(ADDRESS_MASK)) n0 
			(.CLK(CLK), .RESET(RESET), .DIN(DIN), .DOUT(DOUT), .BUSIDLE(BUSIDLE),
			.ADDR_IN(ulpb_addr_in), .DATA_IN(ulpb_data_in), .PENDING(PENDING), .DATA_LATCHED(DATA_LATCHED), .REQ_TX(REQ_TX), .ACK_TX(ACK_TX), 
			.ADDR_OUT(ADDR_OUT), .DATA_OUT(DATA_OUT), .REQ_RX(REQ_OUT_TO_LC), .ACK_RX(ACK_IN_FROM_LC), .TX_FAIL(TX_FAIL), .TX_SUCCESS(TX_SUCCESS), .TX_ACK(TX_ACK));

function integer log2;
	input [31:0] value;
	for (log2=0; value>0; log2=log2+1)
	value = value>>1;
endfunction

endmodule
