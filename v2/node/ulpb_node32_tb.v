module testbench();

reg		clk, resetn;
wire	SCLK;

parameter ADDR_WIDTH=8;
parameter DATA_WIDTH=32;
reg		[ADDR_WIDTH-1:0] addr_in0, addr_in1, addr_in2;
reg		[DATA_WIDTH-1:0] n0_data_in0, n0_data_in1, n1_data_in0, n1_data_in1, n2_data_in0, n2_data_in1;
reg		n0_pending, n1_pending, n2_pending;
reg		req_tx0, req_tx1, req_tx2;
wire	ack_tx0, ack_tx1, ack_tx2;

wire	[ADDR_WIDTH-1:0] addr_out0, addr_out1, addr_out2;
wire	[DATA_WIDTH-1:0] data_out0, data_out1, data_out2;
wire	req_rx0, req_rx1, req_rx2;
wire	ack_received0, ack_received1, ack_received2;
wire	n0_w_ind, n1_w_ind, n2_w_ind;
wire	n0_tx_fail, n1_tx_fail, n2_tx_fail;
reg		ack_rx0, ack_rx1, ack_rx2;

control c0(.DIN(w_n2c0), .DOUT(w_c0n0), .RESET(resetn), .CLK_OUT(SCLK), .CLK_IN(clk));
ulpb_node32 #(.ADDRESS(8'h12)) n0(.CLK(SCLK), .RESET(resetn), .DIN(w_c0n0), .DOUT(w_n0n1), 
			.ADDR_IN(addr_in0), .DATA_IN0(n0_data_in0), .DATA_IN1(n0_data_in1), .PENDING(n0_pending), .WORD_INDICATOR(n0_w_ind), .REQ_TX(req_tx0), .ACK_TX(ack_tx0), 
			.ADDR_OUT(addr_out0), .DATA_OUT(data_out0), .REQ_RX(req_rx0), .ACK_RX(ack_rx0), .ACK_RECEIVED(ack_received0), .TX_FAIL(n0_tx_fail));

ulpb_node32 #(.ADDRESS(8'hab)) n1(.CLK(SCLK), .RESET(resetn), .DIN(w_n0n1), .DOUT(w_n1n2), 
			.ADDR_IN(addr_in1), .DATA_IN0(n1_data_in0), .DATA_IN1(n1_data_in1), .PENDING(n1_pending), .WORD_INDICATOR(n1_w_ind), .REQ_TX(req_tx1), .ACK_TX(ack_tx1), 
			.ADDR_OUT(addr_out1), .DATA_OUT(data_out1), .REQ_RX(req_rx1), .ACK_RX(ack_rx1), .ACK_RECEIVED(ack_received1), .TX_FAIL(n1_tx_fail));

ulpb_node32 #(.ADDRESS(8'hcd)) n2(.CLK(SCLK), .RESET(resetn), .DIN(w_n1n2), .DOUT(w_n2c0), 
			.ADDR_IN(addr_in2), .DATA_IN0(n2_data_in0), .DATA_IN1(n2_data_in1), .PENDING(n2_pending), .WORD_INDICATOR(n2_w_ind), .REQ_TX(req_tx2), .ACK_TX(ack_tx2), 
			.ADDR_OUT(addr_out2), .DATA_OUT(data_out2), .REQ_RX(req_rx2), .ACK_RX(ack_rx2), .ACK_RECEIVED(ack_received2), .TX_FAIL(n2_tx_fail));

always #5 clk = ~clk;

`define SD #1
reg	n1_auto_ack_rx;

initial
begin
	clk = 0;
	resetn = 1;
	n1_auto_ack_rx = 1;

	addr_in0 = 8'hab;
	n0_data_in0 = 32'habcdef12;
	n0_data_in1 = 32'h34567890;
	n0_pending = 0;
	req_tx0 = 0;
	ack_rx0 = 0;

	addr_in1 = 8'hcd;
	n1_data_in0 = 32'haabbccdd;
	n1_data_in1 = 32'h11223344;
	n1_pending = 0;
	req_tx1 = 0;
	ack_rx1 = 0;

	addr_in2 = 8'hef;
	n2_data_in0 = 32'h55667788;
	n2_data_in1 = 32'habcdabcd;
	n2_pending = 0;
	req_tx2 = 0;
	ack_rx2 = 0;

	@ (posedge clk)
	@ (posedge clk)
	@ (posedge clk)
		`SD resetn = 0;
	@ (posedge clk)
		`SD resetn = 1;
	@ (posedge clk)
	@ (posedge clk)
	@ (posedge clk)
		`SD req_tx0 = 1;
	@ (posedge ack_rx1)
	
	// Byte stream test
	#10000
		n0_data_in0 = 32'h21fedcba;
		n0_pending = 1;
		req_tx0 = 1;
	@ (posedge req_rx1)
	// data0 completed
		n0_data_in0 = 32'habcdef12;
	@ (posedge req_rx1)
	// data1 completed
		n0_data_in1 = 32'ha1b2c3d4;
	@ (posedge req_rx1)
	// data0 completed
		n0_pending = 0;
	@ (posedge req_rx1)
	// data1 completed
	
	// unknown address test
	#10000
		addr_in0 = 8'haa;
		req_tx0 = 1;

	// Buffer overflow test
	#50000
		addr_in0 = 8'hab;
		n0_data_in0 = 32'h21fedcba;
		n0_pending = 1;
		req_tx0 = 1;
	@ (posedge req_rx1)
	@ (negedge ack_rx1)
		n1_auto_ack_rx = 0;
		n0_data_in0 = 32'habcdef12;
	@ (posedge n0_tx_fail)

	// Buffer overflow test 2
	#10000
		n1_auto_ack_rx = 1;
		n0_data_in0 = 32'h21fedcba;
		n0_pending = 1;
		req_tx0 = 1;
	@ (posedge req_rx1)
		n0_data_in0 = 32'habcdef12;
	@ (posedge req_rx1)
	@ (negedge ack_rx1)
		n1_auto_ack_rx = 0;
		n0_data_in1 = 32'haabbccdd;
	@ (posedge req_rx1)
		n0_pending = 0;
	@ (posedge n0_tx_fail)

	// Arbitration test
	#10000
	n1_auto_ack_rx = 1;
	addr_in0 = 8'hcd;
	n0_data_in0 = 32'habcdef12;
	n0_pending = 0;

	addr_in1 = 8'hcd;
	n1_data_in0 = 32'haabbccdd;
	n1_pending = 0;
	req_tx0 = 1;
	req_tx1 = 1;

	@(posedge req_rx2)
	@(posedge req_rx2)

	#10000
		$stop;
end

always @ *
begin
	if (ack_tx0)
		req_tx0 = 0;
end

always @ *
begin
	if (ack_tx1)
		req_tx1 = 0;
end

always @ *
begin
	if (ack_tx2)
		req_tx2 = 0;
end

always @ *
begin
	if (n1_auto_ack_rx)
	begin
		if ((req_rx1==1)&&(ack_rx1==0))
			ack_rx1 = 1;
		
		if ((req_rx1==0)&&(ack_rx1==1))
			ack_rx1 = 0;
	end
end

always @ *
begin
	if ((req_rx2==1)&&(ack_rx2==0))
		ack_rx2 = 1;
	
	if ((req_rx2==0)&&(ack_rx2==1))
		ack_rx2 = 0;
end




endmodule
