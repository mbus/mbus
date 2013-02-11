

`ifdef SYNTH
	`timescale 1ns/1ps
	`include "/afs/eecs.umich.edu/kits/ARM/TSMC_cl018g/mosis_2009q1/sc-x_2004q3v1/aci/sc/verilog/tsmc18_neg.v"
`endif

module testbench();

reg		clk, resetn;
wire	SCLK;

parameter ADDR_WIDTH=8;
parameter DATA_WIDTH=32;

wire	[5:0] ctrl_state_out;
reg		[ADDR_WIDTH-1:0] n0_tx_addr, n1_tx_addr, n2_tx_addr;
reg		[DATA_WIDTH-1:0] n0_tx_data, n1_tx_data, n2_tx_data;
reg		n0_tx_req, n1_tx_req, n2_tx_req;
wire	n0_tx_ack, n1_tx_ack, n2_tx_ack;
reg		n0_tx_pend, n1_tx_pend, n2_tx_pend;

wire	[ADDR_WIDTH-1:0] n0_rx_addr, n1_rx_addr, n2_rx_addr;
wire	[DATA_WIDTH-1:0] n0_rx_data, n1_rx_data, n2_rx_data;
wire	n0_rx_req, n1_rx_req, n2_rx_req;
reg		n0_rx_ack, n1_rx_ack, n2_rx_ack;
wire	n0_rx_pend, n1_rx_pend, n2_rx_pend;

wire	n0_tx_succ, n1_tx_succ, n2_tx_succ;
wire	n0_tx_fail, n1_tx_fail, n2_tx_fail;
reg		n0_tx_resp_ack, n1_tx_resp_ack, n2_tx_resp_ack;

wire	w_n2c0, w_c0n0, w_n0n1, w_n1n2;

reg		[31:0] rand_dat, rand_dat2;
reg		[2:0] state;
reg		[5:0] word_counter;
integer	handle;

parameter TX_WAIT=0;
parameter TASK0=1;
parameter TASK1=2;
parameter TASK2=3;
parameter TASK3=4;
parameter TASK4=5;
parameter TASK5=6;
parameter TASK6=7;


control c0(.DIN(w_n2c0), .DOUT(w_c0n0), .RESET(resetn), .CLK_OUT(SCLK), .CLK(clk), .test_pt(ctrl_state_out));

ulpb_node32 #(.ADDRESS(8'hab)) n0
			(.CLK(SCLK), .RESET(resetn), .DIN(w_c0n0), .DOUT(w_n0n1), 
			.TX_ADDR(n0_tx_addr), .TX_DATA(n0_tx_data),	.TX_REQ(n0_tx_req), .TX_ACK(n0_tx_ack), .TX_PEND(n0_tx_pend),
			.RX_ADDR(n0_rx_addr), .RX_DATA(n0_rx_data), .RX_REQ(n0_rx_req), .RX_ACK(n0_rx_ack), .RX_PEND(n0_rx_pend),
			.TX_SUCC(n0_tx_succ), .TX_FAIL(n0_tx_fail), .TX_RESP_ACK(n0_tx_resp_ack));

ulpb_node32 #(.ADDRESS(8'hcd)) n1
			(.CLK(SCLK), .RESET(resetn), .DIN(w_n0n1), .DOUT(w_n1n2), 
			.TX_ADDR(n1_tx_addr), .TX_DATA(n1_tx_data), .TX_REQ(n1_tx_req), .TX_ACK(n1_tx_ack), .TX_PEND(n1_tx_pend), 
			.RX_ADDR(n1_rx_addr), .RX_DATA(n1_rx_data), .RX_REQ(n1_rx_req), .RX_ACK(n1_rx_ack), .RX_PEND(n1_rx_pend),
			.TX_SUCC(n1_tx_succ), .TX_FAIL(n1_tx_fail), .TX_RESP_ACK(n1_tx_resp_ack));

ulpb_node32 #(.ADDRESS(8'hef)) n2
			(.CLK(SCLK), .RESET(resetn), .DIN(w_n1n2), .DOUT(w_n2c0), 
			.TX_ADDR(n2_tx_addr), .TX_DATA(n2_tx_data), .TX_REQ(n2_tx_req), .TX_ACK(n2_tx_ack), .TX_PEND(n2_tx_pend), 
			.RX_ADDR(n2_rx_addr), .RX_DATA(n2_rx_data), .RX_REQ(n2_rx_req), .RX_ACK(n2_rx_ack), .RX_PEND(n2_rx_pend),
			.TX_SUCC(n2_tx_succ), .TX_FAIL(n2_tx_fail), .TX_RESP_ACK(n2_tx_resp_ack));

always #50 clk = ~clk;

`define SD #1
reg	n1_auto_rx_ack;

initial
begin
	clk = 0;
	resetn = 1;
	n1_auto_rx_ack = 1;
   	handle=$fopen("node_tb.txt");


	@ (posedge clk)
	@ (posedge clk)
	@ (posedge clk)
		`SD resetn = 0;
	@ (posedge clk)
	@ (posedge clk)
		`SD resetn = 1;
	@ (posedge clk)
	@ (posedge clk)

/*
	#10000
		state = TASK0;
	@ (posedge n0_tx_succ | n0_tx_fail)

	#10000
		word_counter = 7;
		state = TASK1;
	@ (posedge n0_tx_succ | n0_tx_fail)

	#10000
		state = TASK2;
	@ (posedge n0_tx_succ | n0_tx_fail)

	#10000
		word_counter = 7;
		state = TASK3;
	@ (posedge n0_tx_succ | n0_tx_fail)
*/		
	#10000
		word_counter = 7;
		state = TASK4;
		n1_auto_rx_ack = 0;
	@ (posedge n0_tx_succ | n0_tx_fail)
		n1_auto_rx_ack = 1;

	#10000
		word_counter = 1;
		state = TASK5;
		n1_auto_rx_ack = 0;
	@ (posedge n0_tx_succ | n0_tx_fail)
		n1_auto_rx_ack = 1;
		
	#10000
		state = TASK6;
	@ (posedge n0_tx_succ | n0_tx_fail)
	@ (posedge n1_tx_succ | n1_tx_fail)

	#10000
		$stop;
end

always @ (posedge clk or negedge resetn)
begin
	if (~resetn)
	begin
		n0_tx_addr <= 0;
		n0_tx_data <= 0;
		n0_tx_pend <= 0;
		n0_tx_req <= 0;

		n1_tx_addr <= 0;
		n1_tx_data <= 0;
		n1_tx_pend <= 0;
		n1_tx_req <= 0;

		n2_tx_addr <= 0;
		n2_tx_data <= 0;
		n2_tx_pend <= 0;
		n2_tx_req <= 0;

		word_counter <= 0;
	end
	else
	begin
		if (n0_tx_ack)
			n0_tx_req <= 0;

		if (n1_tx_ack)
			n1_tx_req <= 0;

		if (n2_tx_ack)
			n2_tx_req <= 0;


		case (state)
			// simple transmission
			TASK0:
			begin
				if ((~n0_tx_ack) & (~n0_tx_req))
				begin
					n0_tx_addr <= 8'hcd;
					n0_tx_data <= rand_dat;
					n0_tx_pend <= 0;
					n0_tx_req <= 1;
   					$fdisplay(handle, "N0 Data in =\t32'h%h", rand_dat);
					state <= TX_WAIT;
				end
			end

			// streaming
			TASK1:
			begin
				if ((~n0_tx_ack) & (~n0_tx_req))
				begin
					n0_tx_addr <= 8'hcd;
					n0_tx_data <= rand_dat;
					n0_tx_req <= 1;
   					$fdisplay(handle, "N0 Data in =\t32'h%h", rand_dat);
					if (word_counter)
					begin
						word_counter <= word_counter - 1;
						n0_tx_pend <= 1;
					end
					else
					begin
						n0_tx_pend <= 0;
						state <= TX_WAIT;
					end
				end
			end

			// Unknown address
			TASK2:
			begin
				if ((~n0_tx_ack) & (~n0_tx_req))
				begin
					n0_tx_addr <= 8'hff;
					n0_tx_data <= rand_dat;
					n0_tx_pend <= 0;
					n0_tx_req <= 1;
   					$fdisplay(handle, "N0 Data in =\t32'h%h", rand_dat);
					state <= TX_WAIT;
				end
			end

			// TX buffer underflow
			TASK3:
			begin
				if ((~n0_tx_ack) & (~n0_tx_req))
				begin
					n0_tx_addr <= 8'hcd;
					n0_tx_data <= rand_dat;
					n0_tx_pend <= 1;
   					$fdisplay(handle, "N0 Data in =\t32'h%h", rand_dat);
					if (word_counter)
					begin
						n0_tx_req <= 1;
						word_counter <= word_counter - 1;
					end
					else
					begin
						n0_tx_req <= 0;
						state <= TX_WAIT;
					end
				end
			end

			// RX buffer overflow, middle of transmission
			TASK4:
			begin
				if ((~n0_tx_ack) & (~n0_tx_req))
				begin
					n0_tx_addr <= 8'hcd;
					n0_tx_data <= rand_dat;
					n0_tx_req <= 1;
   					$fdisplay(handle, "N0 Data in =\t32'h%h", rand_dat);
					if (word_counter)
					begin
						word_counter <= word_counter - 1;
						n0_tx_pend <= 1;
					end
					else
					begin
						n0_tx_pend <= 0;
						state <= TX_WAIT;
					end
				end
				
				if (n0_tx_fail)
				begin
					state <= TX_WAIT;
					n0_tx_req <= 0;
				end
			end

			// RX buffer overflow, last word
			TASK5:
			begin
				if ((~n0_tx_ack) & (~n0_tx_req))
				begin
					n0_tx_addr <= 8'hcd;
					n0_tx_data <= rand_dat;
					n0_tx_req <= 1;
   					$fdisplay(handle, "N0 Data in =\t32'h%h", rand_dat);
					if (word_counter)
					begin
						word_counter <= word_counter - 1;
						n0_tx_pend <= 1;
					end
					else
					begin
						n0_tx_pend <= 0;
						state <= TX_WAIT;
					end
				end
				
				if (n0_tx_fail)
				begin
					state <= TX_WAIT;
					n0_tx_req <= 0;
				end
			end

			// Arbitration test
			TASK6:
			begin
				if ((~n0_tx_ack) & (~n0_tx_req))
				begin
					n0_tx_addr <= 8'hef;
					n0_tx_data <= rand_dat;
					n0_tx_pend <= 0;
					n0_tx_req <= 1;
   					$fdisplay(handle, "N0 Data in =\t32'h%h", rand_dat);
				end

				if ((~n1_tx_ack) & (~n1_tx_req))
				begin
					n1_tx_addr <= 8'hef;
					n1_tx_data <= rand_dat2;
					n1_tx_pend <= 0;
					n1_tx_req <= 1;
   					$fdisplay(handle, "N1 Data in =\t32'h%h", rand_dat2);
					state <= TX_WAIT;
				end

			end

		endcase
	end
end

always @ (posedge clk or negedge resetn)
begin
	if (~resetn)
	begin
		n0_rx_ack <= 0;
		n1_rx_ack <= 0;
		n2_rx_ack <= 0;
	end
	else
	begin
		if ((n0_rx_req==1)&&(n0_rx_ack==0))
		begin
			n0_rx_ack <= 1;
   			$fdisplay(handle, "N0 Data out =\t32'h%h", n0_rx_data);
		end
		
		if ((n0_rx_req==0)&&(n0_rx_ack==1))
			n0_rx_ack <= 0;

		if (n1_auto_rx_ack)
		begin
			if ((n1_rx_req==1)&&(n1_rx_ack==0))
			begin
				n1_rx_ack <= 1;
   				$fdisplay(handle, "N1 Data out =\t32'h%h", n1_rx_data);
			end
			
			if ((n1_rx_req==0)&&(n1_rx_ack==1))
				n1_rx_ack <= 0;
		end

		if ((n2_rx_req==1)&&(n2_rx_ack==0))
		begin
			n2_rx_ack <= 1;
   			$fdisplay(handle, "N2 Data out =\t32'h%h", n2_rx_data);
		end
		
		if ((n2_rx_req==0)&&(n2_rx_ack==1))
			n2_rx_ack <= 0;
	end
end


always @ (posedge clk or negedge resetn)
begin
	if (~resetn)
	begin
		n0_tx_resp_ack <= 0;
		n1_tx_resp_ack <= 0;
		n2_tx_resp_ack <= 0;
	end
	else
	begin
		if ((n0_tx_succ | n0_tx_fail)&(~n0_tx_resp_ack))
		begin
			n0_tx_resp_ack <= 1;
			if (n0_tx_succ)
   				$fdisplay(handle, "N0 TX SUCCESS\n");
			else
   				$fdisplay(handle, "N0 TX FAIL\n");
		end
		
		if ((n1_tx_succ | n1_tx_fail)&(~n1_tx_resp_ack))
		begin
			n1_tx_resp_ack <= 1;
			if (n1_tx_succ)
   				$fdisplay(handle, "N1 TX SUCCESS\n");
			else
   				$fdisplay(handle, "N1 TX FAIL\n");
		end

		if ((n2_tx_succ | n2_tx_fail)&(~n2_tx_resp_ack))
		begin
			n2_tx_resp_ack <= 1;
			if (n0_tx_succ)
   				$fdisplay(handle, "N2 TX SUCCESS\n");
			else
   				$fdisplay(handle, "N2 TX FAIL\n");
		end
		
		if ((~(n0_tx_succ | n0_tx_fail))&(n0_tx_resp_ack))
			n0_tx_resp_ack <= 0;

		if ((~(n1_tx_succ | n1_tx_fail))&(n1_tx_resp_ack))
			n1_tx_resp_ack <= 0;

		if ((~(n2_tx_succ | n2_tx_fail))&(n2_tx_resp_ack))
			n2_tx_resp_ack <= 0;
	end
end

always @ (posedge clk or negedge resetn)
begin
	if (~resetn)
	begin
		rand_dat <= 0;
		rand_dat2 <= 0;
	end
	else
	begin
		rand_dat <= $random;
		rand_dat2 <= $random;
	end
end


endmodule
