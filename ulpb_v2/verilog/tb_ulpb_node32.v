
//`define SYNTH

`ifdef SYNTH
	`timescale 1ns/1ps
	`include "/afs/eecs.umich.edu/kits/ARM/TSMC_cl018g/mosis_2009q1/sc-x_2004q3v1/aci/sc/verilog/tsmc18_neg.v"
`endif

`include "include/ulpb_def.v"

module tb_ulpb_node32();

`include "include/ulpb_func.v"

reg		clk, resetn;
wire	SCLK;

reg		[`ADDR_WIDTH-1:0] n0_tx_addr, n1_tx_addr, n2_tx_addr;
reg		[`DATA_WIDTH-1:0] n0_tx_data, n1_tx_data, n2_tx_data;
reg		n0_tx_req, n1_tx_req, n2_tx_req;
reg		n0_priority, n1_priority, n2_priority;
wire	n0_tx_ack, n1_tx_ack, n2_tx_ack;
reg		n0_tx_pend, n1_tx_pend, n2_tx_pend;

wire	[`ADDR_WIDTH-1:0] n0_rx_addr, n1_rx_addr, n2_rx_addr;
wire	[`DATA_WIDTH-1:0] n0_rx_data, n1_rx_data, n2_rx_data;
wire	n0_rx_req, n1_rx_req, n2_rx_req;
reg		n0_rx_ack, n1_rx_ack, n2_rx_ack;
wire	n0_rx_pend, n1_rx_pend, n2_rx_pend;

wire	n0_tx_succ, n1_tx_succ, n2_tx_succ;
wire	n0_tx_fail, n1_tx_fail, n2_tx_fail;
reg		n0_tx_resp_ack, n1_tx_resp_ack, n2_tx_resp_ack;

wire	w_n2c0, w_c0n0, w_n0n1, w_n1n2;
wire	w_n0_clk_out, w_n1_clk_out, w_n2_clk_out;

reg		[31:0] rand_dat, rand_dat2;
reg		[3:0] state;
reg		[5:0] word_counter;
integer	handle;

parameter TASK0=0;
parameter TASK1=1;
parameter TASK2=2;
parameter TASK3=3;
parameter TASK4=4;
parameter TASK5=5;
parameter TASK6=6;
parameter TASK7=7;
parameter TASK8=8;
parameter TASK9=9;
parameter TASK10=10;
parameter TASK11=11;
parameter TASK12=12;
parameter TASK13=13;
parameter TASK14=14;

parameter TX_WAIT=15;


ulpb_ctrl c0(.CLK_EXT(clk), .RESETn(resetn), .CLKIN(w_n2_clk_out), .CLKOUT(SCLK), .DIN(w_n2c0), .DOUT(w_c0n0));

`ifdef SYNTH
ulpb_node32_ab n0
			(.CLKIN(SCLK), .CLKOUT(w_n0_clk_out), .RESETn(resetn), .DIN(w_c0n0), .DOUT(w_n0n1), 
			.TX_ADDR(n0_tx_addr), .TX_DATA(n0_tx_data),	.TX_REQ(n0_tx_req), .TX_ACK(n0_tx_ack), .TX_PEND(n0_tx_pend), .PRIORITY(n0_priority),
			.RX_ADDR(n0_rx_addr), .RX_DATA(n0_rx_data), .RX_REQ(n0_rx_req), .RX_ACK(n0_rx_ack), .RX_PEND(n0_rx_pend),
			.TX_SUCC(n0_tx_succ), .TX_FAIL(n0_tx_fail), .TX_RESP_ACK(n0_tx_resp_ack));

ulpb_node32_cd n1
			(.CLKIN(w_n0_clk_out), .CLKOUT(w_n1_clk_out), .RESETn(resetn), .DIN(w_n0n1), .DOUT(w_n1n2), 
			.TX_ADDR(n1_tx_addr), .TX_DATA(n1_tx_data), .TX_REQ(n1_tx_req), .TX_ACK(n1_tx_ack), .TX_PEND(n1_tx_pend), .PRIORITY(n1_priority),
			.RX_ADDR(n1_rx_addr), .RX_DATA(n1_rx_data), .RX_REQ(n1_rx_req), .RX_ACK(n1_rx_ack), .RX_PEND(n1_rx_pend),
			.TX_SUCC(n1_tx_succ), .TX_FAIL(n1_tx_fail), .TX_RESP_ACK(n1_tx_resp_ack));

ulpb_node32_ef n2
			(.CLKIN(w_n1_clk_out), .CLKOUT(w_n2_clk_out), .RESETn(resetn), .DIN(w_n1n2), .DOUT(w_n2c0), 
			.TX_ADDR(n2_tx_addr), .TX_DATA(n2_tx_data), .TX_REQ(n2_tx_req), .TX_ACK(n2_tx_ack), .TX_PEND(n2_tx_pend), .PRIORITY(n2_priority),
			.RX_ADDR(n2_rx_addr), .RX_DATA(n2_rx_data), .RX_REQ(n2_rx_req), .RX_ACK(n2_rx_ack), .RX_PEND(n2_rx_pend),
			.TX_SUCC(n2_tx_succ), .TX_FAIL(n2_tx_fail), .TX_RESP_ACK(n2_tx_resp_ack));

`else
ulpb_node32 #(.ADDRESS(8'hab)) n0
			(.CLKIN(SCLK), .CLKOUT(w_n0_clk_out), .RESETn(resetn), .DIN(w_c0n0), .DOUT(w_n0n1), 
			.TX_ADDR(n0_tx_addr), .TX_DATA(n0_tx_data),	.TX_REQ(n0_tx_req), .TX_ACK(n0_tx_ack), .TX_PEND(n0_tx_pend), .PRIORITY(n0_priority),
			.RX_ADDR(n0_rx_addr), .RX_DATA(n0_rx_data), .RX_REQ(n0_rx_req), .RX_ACK(n0_rx_ack), .RX_PEND(n0_rx_pend),
			.TX_SUCC(n0_tx_succ), .TX_FAIL(n0_tx_fail), .TX_RESP_ACK(n0_tx_resp_ack));

ulpb_node32 #(.ADDRESS(8'hcd)) n1
			(.CLKIN(w_n0_clk_out), .CLKOUT(w_n1_clk_out), .RESETn(resetn), .DIN(w_n0n1), .DOUT(w_n1n2), 
			.TX_ADDR(n1_tx_addr), .TX_DATA(n1_tx_data), .TX_REQ(n1_tx_req), .TX_ACK(n1_tx_ack), .TX_PEND(n1_tx_pend), .PRIORITY(n1_priority),
			.RX_ADDR(n1_rx_addr), .RX_DATA(n1_rx_data), .RX_REQ(n1_rx_req), .RX_ACK(n1_rx_ack), .RX_PEND(n1_rx_pend),
			.TX_SUCC(n1_tx_succ), .TX_FAIL(n1_tx_fail), .TX_RESP_ACK(n1_tx_resp_ack));

ulpb_node32 #(.ADDRESS(8'hef)) n2
			(.CLKIN(w_n1_clk_out), .CLKOUT(w_n2_clk_out), .RESETn(resetn), .DIN(w_n1n2), .DOUT(w_n2c0), 
			.TX_ADDR(n2_tx_addr), .TX_DATA(n2_tx_data), .TX_REQ(n2_tx_req), .TX_ACK(n2_tx_ack), .TX_PEND(n2_tx_pend), .PRIORITY(n2_priority),
			.RX_ADDR(n2_rx_addr), .RX_DATA(n2_rx_data), .RX_REQ(n2_rx_req), .RX_ACK(n2_rx_ack), .RX_PEND(n2_rx_pend),
			.TX_SUCC(n2_tx_succ), .TX_FAIL(n2_tx_fail), .TX_RESP_ACK(n2_tx_resp_ack));
`endif

always #100 clk = ~clk;

`define SD #1
reg	n0_auto_rx_ack, n1_auto_rx_ack, n2_auto_rx_ack;

initial
begin
	`ifdef SYNTH
		$sdf_annotate("ulpb_ctrl.dc.sdf", c0);
		$sdf_annotate("ulpb_node32_ab.dc.sdf", n0);
		$sdf_annotate("ulpb_node32_cd.dc.sdf", n1);
		$sdf_annotate("ulpb_node32_ef.dc.sdf", n2);
	`endif
	clk = 0;
	resetn = 1;
	n0_auto_rx_ack = 1;
	n1_auto_rx_ack = 1;
	n2_auto_rx_ack = 1;
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

	#10000
   	$fdisplay(handle, "TASK0, Correct result: N1 TX Success");
		state = TASK0;
	@ (posedge n1_tx_succ | n1_tx_fail)

	#10000
   	$fdisplay(handle, "TASK1, Correct result: N1 TX Success");
		word_counter = 7;
		state = TASK1;
	@ (posedge n1_tx_succ | n1_tx_fail)

	#10000
   	$fdisplay(handle, "TASK2, Correct result: N1 TX Success");
		state = TASK2;
	@ (posedge n1_tx_succ | n1_tx_fail)

	#10000
   	$fdisplay(handle, "TASK3, Correct result: N1 TX Success");
		word_counter = 7;
		state = TASK3;
	@ (posedge n1_tx_succ | n1_tx_fail)

	#10000
   	$fdisplay(handle, "TASK4, Correct result: N1 TX Fail");
		state = TASK4;
	@ (posedge n1_tx_succ | n1_tx_fail)

	#10000
   	$fdisplay(handle, "TASK5, Correct result: N1 TX Fail");
		word_counter = 7;
		state = TASK5;
	@ (posedge n1_tx_succ | n1_tx_fail)

	#10000
   	$fdisplay(handle, "TASK6, Correct result: N1 TX Fail");
		word_counter = 7;
		state = TASK6;
	@ (posedge n1_tx_succ | n1_tx_fail)

	#10000
   	$fdisplay(handle, "TASK7, Correct result: N1 TX Fail");
		word_counter = 7;
		state = TASK7;
		n2_auto_rx_ack = 0;
	@ (posedge n1_tx_succ | n1_tx_fail)
		n2_auto_rx_ack = 1;
		
	#10000
   	$fdisplay(handle, "TASK8, Correct result: N1 TX Fail");
		word_counter = 7;
		state = TASK8;
		n0_auto_rx_ack = 0;
	@ (posedge n1_tx_succ | n1_tx_fail)
		n0_auto_rx_ack = 1;

	#10000
   	$fdisplay(handle, "TASK9, Correct result: N1 TX Fail");
		word_counter = 1;
		state = TASK9;
		n2_auto_rx_ack = 0;
	@ (posedge n1_tx_succ | n1_tx_fail)
		n2_auto_rx_ack = 1;

	#10000
   	$fdisplay(handle, "TASK10, Correct result: N1 TX Fail");
		word_counter = 1;
		state = TASK10;
		n0_auto_rx_ack = 0;
	@ (posedge n1_tx_succ | n1_tx_fail)
		n0_auto_rx_ack = 1;

	#10000
   	$fdisplay(handle, "TASK1l, Correct result: N0, N1 TX Success");
		state = TASK11;
	@ (posedge n0_tx_succ | n0_tx_fail)
	@ (posedge n1_tx_succ | n1_tx_fail)

	#10000
   	$fdisplay(handle, "TASK12, Correct result: N1, N0 TX Success");
		state = TASK12;
	@ (posedge n1_tx_succ | n1_tx_fail)
	@ (posedge n0_tx_succ | n0_tx_fail)
	n1_priority = 0;

	#10000
   	$fdisplay(handle, "TASK13, Correct result: N0, N1 TX Success");
		state = TASK13;
	@ (posedge n0_tx_succ | n0_tx_fail)
	@ (posedge n1_tx_succ | n1_tx_fail)
	n0_priority = 0;
	n1_priority = 0;

	#10000
   	$fdisplay(handle, "TASK14, Correct result: N0 TX Success");
		state = TASK14;
	@ (posedge n0_tx_succ | n0_tx_fail)
	n0_priority = 0;
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
		n0_priority <= 0;

		n1_tx_addr <= 0;
		n1_tx_data <= 0;
		n1_tx_pend <= 0;
		n1_tx_req <= 0;
		n1_priority <= 0;

		n2_tx_addr <= 0;
		n2_tx_data <= 0;
		n2_tx_pend <= 0;
		n2_tx_req <= 0;
		n2_priority <= 0;

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
				if ((~n1_tx_ack) & (~n1_tx_req))
				begin
					n1_tx_addr <= 8'hef;
					n1_tx_data <= rand_dat;
					n1_tx_pend <= 0;
					n1_tx_req <= 1;
   					$fdisplay(handle, "N1 Data in =\t32'h%h", rand_dat);
					state <= TX_WAIT;
				end
			end

			// simple transmission, RX above TX
			TASK1:
			begin
				if ((~n1_tx_ack) & (~n1_tx_req))
				begin
					n1_tx_addr <= 8'hab;
					n1_tx_data <= rand_dat;
					n1_tx_pend <= 0;
					n1_tx_req <= 1;
   					$fdisplay(handle, "N1 Data in =\t32'h%h", rand_dat);
					state <= TX_WAIT;
				end
			end

			// streaming down
			TASK2:
			begin
				if ((~n1_tx_ack) & (~n1_tx_req))
				begin
					n1_tx_addr <= 8'hef;
					n1_tx_data <= rand_dat;
					n1_tx_req <= 1;
   					$fdisplay(handle, "N1 Data in =\t32'h%h", rand_dat);
					if (word_counter)
					begin
						word_counter <= word_counter - 1;
						n1_tx_pend <= 1;
					end
					else
					begin
						n1_tx_pend <= 0;
						state <= TX_WAIT;
					end
				end
			end

			// streaming up 
			TASK3:
			begin
				if ((~n1_tx_ack) & (~n1_tx_req))
				begin
					n1_tx_addr <= 8'hab;
					n1_tx_data <= rand_dat;
					n1_tx_req <= 1;
   					$fdisplay(handle, "N1 Data in =\t32'h%h", rand_dat);
					if (word_counter)
					begin
						word_counter <= word_counter - 1;
						n1_tx_pend <= 1;
					end
					else
					begin
						n1_tx_pend <= 0;
						state <= TX_WAIT;
					end
				end
			end

			// Unknown address
			TASK4:
			begin
				if ((~n1_tx_ack) & (~n1_tx_req))
				begin
					n1_tx_addr <= 8'hff;
					n1_tx_data <= rand_dat;
					n1_tx_pend <= 0;
					n1_tx_req <= 1;
   					$fdisplay(handle, "N1 Data in =\t32'h%h", rand_dat);
					state <= TX_WAIT;
				end
			end

			// TX buffer underflow
			TASK5:
			begin
				if ((~n1_tx_ack) & (~n1_tx_req))
				begin
					n1_tx_addr <= 8'hef;
					n1_tx_data <= rand_dat;
					n1_tx_pend <= 1;
   					$fdisplay(handle, "N1 Data in =\t32'h%h", rand_dat);
					if (word_counter)
					begin
						n1_tx_req <= 1;
						word_counter <= word_counter - 1;
					end
					else
					begin
						n1_tx_req <= 0;
						state <= TX_WAIT;
					end
				end
			end

			// TX buffer underflow
			TASK6:
			begin
				if ((~n1_tx_ack) & (~n1_tx_req))
				begin
					n1_tx_addr <= 8'hab;
					n1_tx_data <= rand_dat;
					n1_tx_pend <= 1;
   					$fdisplay(handle, "N1 Data in =\t32'h%h", rand_dat);
					if (word_counter)
					begin
						n1_tx_req <= 1;
						word_counter <= word_counter - 1;
					end
					else
					begin
						n1_tx_req <= 0;
						state <= TX_WAIT;
					end
				end
			end

			// RX buffer overflow, middle of transmission
			TASK7:
			begin
				if ((~n1_tx_ack) & (~n1_tx_req))
				begin
					n1_tx_addr <= 8'hef;
					n1_tx_data <= rand_dat;
					n1_tx_req <= 1;
   					$fdisplay(handle, "N1 Data in =\t32'h%h", rand_dat);
					if (word_counter)
					begin
						word_counter <= word_counter - 1;
						n1_tx_pend <= 1;
					end
					else
					begin
						n1_tx_pend <= 0;
						state <= TX_WAIT;
					end
				end
				else if (n1_tx_fail)
				begin
					state <= TX_WAIT;
					n1_tx_req <= 0;
				end
			end

			// RX buffer overflow, middle of transmission
			TASK8:
			begin
				if ((~n1_tx_ack) & (~n1_tx_req))
				begin
					n1_tx_addr <= 8'hab;
					n1_tx_data <= rand_dat;
					n1_tx_req <= 1;
   					$fdisplay(handle, "N1 Data in =\t32'h%h", rand_dat);
					if (word_counter)
					begin
						word_counter <= word_counter - 1;
						n1_tx_pend <= 1;
					end
					else
					begin
						n1_tx_pend <= 0;
						state <= TX_WAIT;
					end
				end
				else if (n1_tx_fail)
				begin
					state <= TX_WAIT;
					n1_tx_req <= 0;
				end
			end

			// RX buffer overflow, last word
			TASK9:
			begin
				if ((~n1_tx_ack) & (~n1_tx_req))
				begin
					n1_tx_addr <= 8'hef;
					n1_tx_data <= rand_dat;
					n1_tx_req <= 1;
   					$fdisplay(handle, "N1 Data in =\t32'h%h", rand_dat);
					if (word_counter)
					begin
						word_counter <= word_counter - 1;
						n1_tx_pend <= 1;
					end
					else
					begin
						n1_tx_pend <= 0;
						state <= TX_WAIT;
					end
				end
			end

			// RX buffer overflow, last word
			TASK10:
			begin
				if ((~n1_tx_ack) & (~n1_tx_req))
				begin
					n1_tx_addr <= 8'hab;
					n1_tx_data <= rand_dat;
					n1_tx_req <= 1;
   					$fdisplay(handle, "N1 Data in =\t32'h%h", rand_dat);
					if (word_counter)
					begin
						word_counter <= word_counter - 1;
						n1_tx_pend <= 1;
					end
					else
					begin
						n1_tx_pend <= 0;
						state <= TX_WAIT;
					end
				end
				
			end

			// Arbitration test
			TASK11:
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

			// Priority test1
			TASK12:
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
					n1_priority <= 1;
   					$fdisplay(handle, "N1 Data in =\t32'h%h", rand_dat2);
					state <= TX_WAIT;
				end
			end

			// Priority test2
			// Geometry Priority + Priority
			TASK13:
			begin
				if ((~n0_tx_ack) & (~n0_tx_req))
				begin
					n0_tx_addr <= 8'hef;
					n0_tx_data <= rand_dat;
					n0_tx_pend <= 0;
					n0_tx_req <= 1;
					n0_priority <= 1;
   					$fdisplay(handle, "N0 Data in =\t32'h%h", rand_dat);
				end

				if ((~n1_tx_ack) & (~n1_tx_req))
				begin
					n1_tx_addr <= 8'hef;
					n1_tx_data <= rand_dat2;
					n1_tx_pend <= 0;
					n1_tx_req <= 1;
					n1_priority <= 1;
   					$fdisplay(handle, "N1 Data in =\t32'h%h", rand_dat2);
					state <= TX_WAIT;
				end
			end

			// Priority test3
			// Geometry Priority
			TASK14:
			begin
				if ((~n0_tx_ack) & (~n0_tx_req))
				begin
					n0_tx_addr <= 8'hef;
					n0_tx_data <= rand_dat;
					n0_tx_pend <= 0;
					n0_tx_req <= 1;
					n0_priority <= 1;
   					$fdisplay(handle, "N0 Data in =\t32'h%h", rand_dat);
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
		if (n0_auto_rx_ack)
		begin
			if ((n0_rx_req==1)&&(n0_rx_ack==0))
			begin
				n0_rx_ack <= 1;
   				$fdisplay(handle, "N0 Data out =\t32'h%h", n0_rx_data);
			end
			
			if ((n0_rx_req==0)&&(n0_rx_ack==1))
				n0_rx_ack <= 0;
		end

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

		if (n2_auto_rx_ack)
		begin
			if ((n2_rx_req==1)&&(n2_rx_ack==0))
			begin
				n2_rx_ack <= 1;
   				$fdisplay(handle, "N2 Data out =\t32'h%h", n2_rx_data);
			end
			
			if ((n2_rx_req==0)&&(n2_rx_ack==1))
				n2_rx_ack <= 0;
		end
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
