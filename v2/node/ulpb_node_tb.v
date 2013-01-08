module testbench();

reg		clk, resetn;
wire	SCLK;

parameter ADDR_WIDTH=8;
parameter DATA_WIDTH=32;
reg		[ADDR_WIDTH-1:0] addr_in0, addr_in1, addr_in2;
reg		[DATA_WIDTH-1:0] data_in0, data_in1, data_in2;
reg		req_tx0, req_tx1, req_tx2;
wire	ack_tx0, ack_tx1, ack_tx2;

wire	[ADDR_WIDTH-1:0] addr_out0, addr_out1, addr_out2;
wire	[DATA_WIDTH-1:0] data_out0, data_out1, data_out2;
wire	req_rx0, req_rx1, req_rx2;
reg		ack_rx0, ack_rx1, ack_rx2;

control c0(.IN(w_n2c0), .OUT(w_c0n0), .RESET(resetn), .CLK_OUT(SCLK), .CLK_IN(clk));
ulpb_node #(.ADDRESS(8'h12)) n0(.CLK(SCLK), .RESET(resetn), .IN(w_c0n0), .OUT(w_n0n1), 
			.ADDR_IN(addr_in0), .DATA_IN(data_in0), .REQ_TX(req_tx0), .ACK_TX(ack_tx0), 
			.ADDR_OUT(addr_out0), .DATA_OUT(data_out0), .REQ_RX(req_rx0), .ACK_RX(ack_rx0));

ulpb_node #(.ADDRESS(8'hab)) n1(.CLK(SCLK), .RESET(resetn), .IN(w_n0n1), .OUT(w_n1n2), 
			.ADDR_IN(addr_in1), .DATA_IN(data_in1), .REQ_TX(req_tx1), .ACK_TX(ack_tx1), 
			.ADDR_OUT(addr_out1), .DATA_OUT(data_out1), .REQ_RX(req_rx1), .ACK_RX(ack_rx1));

ulpb_node #(.ADDRESS(8'hcd)) n2(.CLK(SCLK), .RESET(resetn), .IN(w_n1n2), .OUT(w_n2c0), 
			.ADDR_IN(addr_in2), .DATA_IN(data_in2), .REQ_TX(req_tx2), .ACK_TX(ack_tx2), 
			.ADDR_OUT(addr_out2), .DATA_OUT(data_out2), .REQ_RX(req_rx2), .ACK_RX(ack_rx2));

always #5 clk = ~clk;

`define SD #1

initial
begin
	clk = 0;
	resetn = 1;

	addr_in0 = 8'hab;
	data_in0 = 32'habcdef12;
	req_tx0 = 0;
	ack_rx0 = 0;

	addr_in1 = 8'h0;
	data_in1 = 32'h0;
	req_tx1 = 0;
	ack_rx1 = 0;

	addr_in2 = 8'h0;
	data_in2 = 32'h0;
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
	#3000
		$stop;
end

always @ *
begin
	if (ack_tx0)
		req_tx0 = 0;
end

always @ *
begin
	if (req_rx1)
		ack_rx1 = 1;
end



endmodule
