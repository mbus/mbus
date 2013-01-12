module testbench();

reg		clk, resetn;
wire	SCLK;

parameter ADDR_WIDTH=8;
parameter DATA_WIDTH=32;
reg		[ADDR_WIDTH-1:0] n0_addr_in, n1_addr_in, n2_addr_in;
reg		[DATA_WIDTH-1:0] n0_data_in, n1_data_in, n2_data_in;
reg		n0_pending, n1_pending, n2_pending;
reg		n0_req_tx, n1_req_tx, n2_req_tx;
wire	n0_ack_tx, n1_ack_tx, n2_ack_tx;
wire	n0_data_latched, n1_data_latched, n2_data_latched;

wire	[ADDR_WIDTH-1:0] n0_addr_out, n1_addr_out, n2_addr_out;
wire	[DATA_WIDTH-1:0] n0_data_out, n1_data_out, n2_data_out;
wire	n0_req_rx, n1_req_rx, n2_req_rx;
wire	n0_tx_success, n1_tx_success, n2_tx_success;
wire	n0_tx_fail, n1_tx_fail, n2_tx_fail;
reg		n0_ack_rx, n1_ack_rx, n2_ack_rx;
reg		n0_tx_ack, n1_tx_ack, n2_tx_ack;

control c0(.DIN(w_n2c0), .DOUT(w_c0n0), .RESET(resetn), .CLK_OUT(SCLK), .CLK_IN(clk));
ulpb_node32 #(.ADDRESS(8'h12)) n0(.CLK(SCLK), .RESET(resetn), .DIN(w_c0n0), .DOUT(w_n0n1), 
			.ADDR_IN(n0_addr_in), .DATA_IN(n0_data_in), .PENDING(n0_pending), .DATA_LATCHED(n0_data_latched), .REQ_TX(n0_req_tx), .ACK_TX(n0_ack_tx), 
			.ADDR_OUT(n0_addr_out), .DATA_OUT(n0_data_out), .REQ_RX(n0_req_rx), .ACK_RX(n0_ack_rx), 
			.TX_SUCCESS(n0_tx_success), .TX_FAIL(n0_tx_fail), .TX_ACK(n0_tx_ack), .BUSIDLE(n0_idle));

ulpb_node32 #(.ADDRESS(8'hab)) n1(.CLK(SCLK), .RESET(resetn), .DIN(w_n0n1), .DOUT(w_n1n2), 
			.ADDR_IN(n1_addr_in), .DATA_IN(n1_data_in), .PENDING(n1_pending), .DATA_LATCHED(n1_data_latched), .REQ_TX(n1_req_tx), .ACK_TX(n1_ack_tx), 
			.ADDR_OUT(n1_addr_out), .DATA_OUT(n1_data_out), .REQ_RX(n1_req_rx), .ACK_RX(n1_ack_rx), 
			.TX_SUCCESS(n1_tx_success), .TX_FAIL(n1_tx_fail), .TX_ACK(n1_tx_ack), .BUSIDLE(n1_idle));

ulpb_node32 #(.ADDRESS(8'hcd)) n2(.CLK(SCLK), .RESET(resetn), .DIN(w_n1n2), .DOUT(w_n2c0), 
			.ADDR_IN(n2_addr_in), .DATA_IN(n2_data_in), .PENDING(n2_pending), .DATA_LATCHED(n2_data_latched), .REQ_TX(n2_req_tx), .ACK_TX(n2_ack_tx), 
			.ADDR_OUT(n2_addr_out), .DATA_OUT(n2_data_out), .REQ_RX(n2_req_rx), .ACK_RX(n2_ack_rx), 
			.TX_SUCCESS(n2_tx_success), .TX_FAIL(n2_tx_fail), .TX_ACK(n2_tx_ack), .BUSIDLE(n2_idle));

always #5 clk = ~clk;

`define SD #1
reg	n1_auto_ack_rx;

initial
begin
	clk = 0;
	resetn = 1;
	n1_auto_ack_rx = 1;

	n0_addr_in = 0;
	n0_data_in = 0;
	n0_pending = 0;
	n0_req_tx = 0;
	n0_ack_rx = 0;
	n0_tx_ack = 0;

	n1_addr_in = 0;
	n1_data_in = 0;
	n1_pending = 0;
	n1_req_tx = 0;
	n1_ack_rx = 0;
	n1_tx_ack = 0;

	n2_addr_in = 0;
	n2_data_in = 0;
	n2_pending = 0;
	n2_req_tx = 0;
	n2_ack_rx = 0;
	n2_tx_ack = 0;

	@ (posedge clk)
	@ (posedge clk)
	@ (posedge clk)
		`SD resetn = 0;
	@ (posedge clk)
		`SD resetn = 1;
	@ (posedge clk)
	@ (posedge clk)

	// Simple transmit
	@ (posedge clk)
		`SD 
		n0_req_tx = 1;
		n0_addr_in = 8'hab;
		n0_data_in = 32'haabbccdd;
	@ (posedge n0_tx_success)
	
	// Byte stream test
	#10000
		n0_req_tx = 1;
		n0_addr_in = 8'hab;
		n0_data_in = 32'h00112233;
		n0_pending = 1;
	@ (posedge n0_data_latched)
		n0_data_in = 32'haa00bb11;
	@ (posedge n0_data_latched)
		n0_data_in = 32'h12341234;
	@ (posedge n0_data_latched)
		n0_data_in = 32'habcdabcd;
	@ (posedge n0_data_latched)
		n0_pending = 0;
	@ (posedge n0_tx_success)

	// unknown address test
	#10000
		n0_req_tx = 1;
		n0_addr_in = 8'haa;
		n0_data_in = 32'h00112233;
	@ (posedge n0_tx_fail)

	// Buffer overflow test
	#10000
		n0_req_tx = 1;
		n0_addr_in = 8'hab;
		n0_data_in = 32'h00112233;
		n0_pending = 1;
	@ (posedge n0_data_latched)
		n0_data_in = 32'haabbaabb;
	@ (negedge n1_ack_rx)
		n1_auto_ack_rx = 0;
	@ (posedge n0_tx_fail)
		n1_auto_ack_rx = 1;

	// Buffer overflow test 2, last word fails
	#10000
		n0_req_tx = 1;
		n0_addr_in = 8'hab;
		n0_data_in = 32'h00112233;
		n0_pending = 1;
	@ (posedge n0_data_latched)
		n0_data_in = 32'haa00bb11;
	@ (posedge n0_data_latched)
		n0_data_in = 32'h12341234;
	@ (posedge n0_data_latched)
		n0_data_in = 32'habcdabcd;
	@ (posedge n0_data_latched)
		n0_pending = 0;
		n1_auto_ack_rx = 0;
	@ (posedge n0_tx_fail)
		n1_auto_ack_rx = 1;

	// Arbitration test
	#10000
		n0_req_tx = 1;
		n0_addr_in = 8'hab;
		n0_data_in = 32'h00112233;
		n0_pending = 0;

		n2_req_tx = 1;
		n2_addr_in = 8'hab;
		n2_data_in = 32'haabbccdd;
		n2_pending = 0;
	@(posedge n1_req_rx)
	@(posedge n1_req_rx)

	#10000
		$stop;
end

always @ *
begin
	if (n0_ack_tx)
		n0_req_tx = 0;
end

always @ *
begin
	if (n1_ack_tx)
		n1_req_tx = 0;
end

always @ *
begin
	if (n2_ack_tx)
		n2_req_tx = 0;
end


always @ *
begin
	if (n1_auto_ack_rx)
	begin
		if ((n1_req_rx==1)&&(n1_ack_rx==0))
			n1_ack_rx = 1;
		
		if ((n1_req_rx==0)&&(n1_ack_rx==1))
			n1_ack_rx = 0;
	end
end

always @ *
begin
	if ((n2_req_rx==1)&&(n2_ack_rx==0))
		n2_ack_rx = 1;
	
	if ((n2_req_rx==0)&&(n2_ack_rx==1))
		n2_ack_rx = 0;
end

always @ *
begin
	if ((n0_tx_success | n0_tx_fail)&(~n0_tx_ack))
		n0_tx_ack = 1;
	
	if ((~(n0_tx_success | n0_tx_fail))&(n0_tx_ack))
		n0_tx_ack = 0;
end

always @ *
begin
	if ((n1_tx_success | n1_tx_fail)&(~n1_tx_ack))
		n1_tx_ack = 1;
	
	if ((~(n1_tx_success | n1_tx_fail))&(n1_tx_ack))
		n1_tx_ack = 0;
end

always @ *
begin
	if ((n2_tx_success | n2_tx_fail)&(~n2_tx_ack))
		n2_tx_ack = 1;
	
	if ((~(n2_tx_success | n2_tx_fail))&(n2_tx_ack))
		n2_tx_ack = 0;
end


endmodule
