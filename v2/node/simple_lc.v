module simple_layer_controller(
				HSEL, HADDR, HWRITE, HSIZE, HBURST, HPROT, HTRANS, 
				HMASTLOCK, HREADY, HWDATA, HRESETn, HCLK,
				HREADYOUT, HRESP, HRDATA,
				DIN, DOUT, SCLK,
				TX_FAIL, TX_SUCC, 
				frame_complete, rx_fifo_empty );

// IOs for AHB bus
input 			HSEL, HWRITE, HMASTLOCK, HREADY, HRESETn, HCLK;
input 	[31:0] 	HADDR, HWDATA;
input 	[2:0] 	HSIZE, HBURST;
input 	[3:0] 	HPROT;
input 	[1:0] 	HTRANS;

output 			HREADYOUT;
output 	[1:0] 	HRESP;
output 	[31:0] 	HRDATA;

// IOs for LC
output			TX_FAIL, TX_SUCC;
output			frame_complete, rx_fifo_empty;

// IOs for ulpb
input			SCLK;
input			DIN;
input			DOUT;

// ulpb registers
reg				TX_REQ, next_tx_req, TX_PEND;
reg				TX_RESP_ACK, next_tx_resp_ack;
reg				RX_ACK, next_rx_ack, rx_pending, next_rx_pending;
reg				tx_state, rx_state;
reg				rx_frame_complete, next_rx_frame_complete;

wire			TX_ACK, TX_PEND;
wire			RX_REQ, RX_PEND;
wire	[DATA_WIDTH-1:0] RX_DATA; 
wire	[ADDR_WIDTH-1:0] RX_ADDR;
wire	[ADDR_WIDTH-1:0] TX_ADDR;
wire	[DATA_WIDTH-1:0] TX_DATA;

// fifo registers
reg				rx_fifo_we, rx_fifo_re, next_rx_fifo_we, next_rx_fifo_re;

wire	[DATA_WIDTH-1:0] rx_data_out; 


// fifo registers
parameter DEPTH = 8;
reg		[ADDR_WIDTH+DATA_WIDTH-1:0] NODE_FIFO [DEPTH-1:0];
reg		[log2(DEPTH-1)-1:0] head, tail;
wire	tx_fifo_empty = (head==tail)? 1 : 0;
wire	tx_fifo_full = ((tail==0)&&(head==DEPTH-1))? 1 : (tail==head+1)? 1 : 0;
wire	[log2(DEPTH-1)-1:0] next_tail = (tail==DEPTH-1)? 0 : (tail+1);
wire	tx_fifo_next_empty = (head==next_tail)? 1 : 0;

assign TX_ADDR = NODE_FIFO[tail][ADDR_WIDTH+DATA_WIDTH-1:DATA_WIDTH];
assign TX_DATA = NODE_FIFO[tail][DATA_WIDTH-1:0];

always @ (posedge HCLK or negedge HRESETn)
begin
	if (~HRESETn)
	begin
		TX_REQ <= 0;
		tx_state <= TX_IDLE;
		tail <= 0;
		TX_RESP_ACK <= 0;
	end
	else
	begin
		TX_REQ <= next_tx_req;
		tx_state <= next_tx_state;
		tail <= next_tail;
		TX_RESP_ACK <= next_tx_resp_ack;
	end
end

always @ *
begin
	next_tx_req = TX_REQ;
	next_tx_state = tx_state;
	next_tail = tail;
	next_tx_resp_ack = TX_RESP_ACK;

	if ((TX_FAIL | TX_SUCC) & (~TX_RESP_ACK))
		next_tx_resp_ack = 1;

	if ((~(TX_FAIL | TX_SUCC)) & TX_RESP_ACK)
		next_tx_resp_ack = 0;

	case (tx_state)
		TX_IDLE:
		begin
			if ((~tx_fifo_empty)&(~TX_ACK))
			begin
				next_tx_req = 1;
				next_tx_state = TX_WAIT;
			end
		end

		TX_WAIT:
		begin
			if (TX_ACK)
			begin
				next_tx_req = 0;
				next_tail = tail + 1;
				next_tx_state = TX_IDLE;
			end
		end
	endcase
end

always @ (posedge HCLK or negedge HRESETn)
begin
	if (~HRESETn)
	begin
		RX_ACK <= 0;
		rx_fifo_we <= 0;
		rx_pending <= 0;
		rx_state <= RX_IDLE;
		rx_frame_complete <= 0;
	end
	else
	begin
		RX_ACK <= next_rx_ack;
		rx_fifo_we <= next_rx_fifo_we;
		rx_pending <= next_rx_pending;
		rx_state <= next_rx_state;
		rx_frame_complete <= next_rx_frame_complete;
	end
end

always @ *
begin
	next_rx_ack = RX_ACK;
	next_rx_fifo_we = rx_fifo_we;
	next_rx_pending = rx_pending;
	next_rx_state = rx_state;
	next_frame_complete = 0;
	case (rx_state)
		RX_IDLE:
		begin
			if (RX_REQ & (~RX_ACK) & (~rx_fifo_full))
			begin
				next_rx_ack = 1;
				next_rx_fifo_we = 1;
				next_rx_pending = RX_PEND;
				next_rx_state = RX_WAIT;
			end
		end

		RX_WAIT:
		begin
			next_rx_fifo_we = 0;
			if ((~RX_REQ)&RX_ACK))
			begin
				next_rx_ack = 0;
				next_rx_state = RX_IDLE;
				if (rx_pending)
					next_frame_complete = 0;
				else
					next_frame_complete = 1;
			end
		end

	endcase
end

always @ (posedge CLK or negedge RESET)
begin
	if (~RESET)
	begin
		head <= 0;
		for (k=0; k<DEPTH; k=k+1)
			NODE_FIFO[k] <= 0;
	end
	else
	begin
		if (TX_FAIL)
		begin
			head <= 0;
		end
		else
		begin
			if ((tx_fifo_we) & (~tx_fifo_full))
			begin
				NODE_FIFO[head] <= {ADDR_IN, DATA_IN};
				head <= head + 1;
			end
		end
	end
end

always @ *
begin
	TX_PEND = 0;
	if ((NODE_FIFO[next_tail][ADDR_WIDTH+DATA_WIDTH-1:DATA_WIDTH]==TX_ADDR)&&(~(tx_fifo_empty | tx_fifo_next_empty)))
		TX_PEND = 1;
end

ulpb_node32 #(.ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH), .ADDRESS(ADDRESS), .ADDRESS_MASK(ADDRESS_MASK)) n0 
			(.CLK(SCLK), .RESET(HRESETn), .DIN(DIN), .DOUT(DOUT), 
			.TX_ADDR(TX_ADDR), .TX_DATA(TX_DATA),	.TX_REQ(TX_REQ), .TX_ACK(TX_ACK), .TX_PEND(TX_PEND),
			.RX_ADDR(RX_ADDR), .RX_DATA(RX_DATA), 	.RX_REQ(RX_REQ), .RX_ACK(RX_ACK), .RX_PEND(RX_PEND),
			.TX_SUCC(TX_SUCC), .TX_FAIL(TX_FAIL), 	.TX_RESP_ACK(TX_RESP_ACK), .BUSIDLE());


fifo8x32 rx_fifo(.DATA(RX_DATA), .Q(rx_data_out), .CLK(HCLK), .WE(rx_fifo_we), .RE(rx_fifo_re), .RESET(HRESETn), .FULL(rx_fifo_full), .EMPTY(rx_fifo_empty));


endmodule
