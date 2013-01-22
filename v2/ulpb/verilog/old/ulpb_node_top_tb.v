module testbench();


reg		clk, resetn;
wire	SCLK;
reg		[7:0] n0_addr_in, n1_addr_in, n2_addr_in;
reg		[31:0] n0_data_in, n1_data_in, n2_data_in;
reg		n0_req_in_from_lc, n1_req_in_from_lc, n2_req_in_from_lc;
wire	n0_ack_out_to_lc, n1_ack_out_to_lc, n2_ack_out_to_lc;
wire	[7:0] n0_addr_out, n1_addr_out, n2_addr_out;
wire	[31:0] n0_data_out, n1_data_out, n2_data_out;
wire	n0_req_out_to_lc, n1_req_out_to_lc, n2_req_out_to_lc;
reg		n0_ack_in_from_lc, n1_ack_in_from_lc, n2_ack_in_from_lc;
wire	n0_tx_fail, n1_tx_fail, n2_tx_fail;
wire	n0_tx_success, n1_tx_success, n2_tx_success;
reg		n0_tx_ack, n1_tx_ack, n2_tx_ack;

wire	w_c0n0, w_n0n1, w_n1n2, w_n2c0;

control c0(.DIN(w_n2c0), .DOUT(w_c0n0), .RESET(resetn), .CLK_OUT(SCLK), .CLK_IN(clk));

ulpb_node_top #(.ADDRESS(8'hab)) n0(.CLK(SCLK), .RESET(resetn), .DIN(w_c0n0), .DOUT(w_n0n1),
				.ADDR_IN(n0_addr_in), .DATA_IN(n0_data_in), .REQ_IN_FROM_LC(n0_req_in_from_lc), .ACK_OUT_TO_LC(n0_ack_out_to_lc), 
				.ADDR_OUT(n0_addr_out), .DATA_OUT(n0_data_out), .REQ_OUT_TO_LC(n0_req_out_to_lc), .ACK_IN_FROM_LC(n0_ack_in_from_lc),
				.TX_FAIL(n0_tx_fail), .TX_SUCCESS(n0_tx_success), .TX_ACK(n0_tx_ack));

ulpb_node_top #(.ADDRESS(8'hcd)) n1(.CLK(SCLK), .RESET(resetn),  .DIN(w_n0n1), .DOUT(w_n1n2),
				.ADDR_IN(n1_addr_in), .DATA_IN(n1_data_in), .REQ_IN_FROM_LC(n1_req_in_from_lc), .ACK_OUT_TO_LC(n1_ack_out_to_lc), 
				.ADDR_OUT(n1_addr_out), .DATA_OUT(n1_data_out), .REQ_OUT_TO_LC(n1_req_out_to_lc), .ACK_IN_FROM_LC(n1_ack_in_from_lc),
				.TX_FAIL(n1_tx_fail), .TX_SUCCESS(n1_tx_success), .TX_ACK(n1_tx_ack));

ulpb_node_top #(.ADDRESS(8'hef)) n2(.CLK(SCLK), .RESET(resetn), .DIN(w_n1n2), .DOUT(w_n2c0),
				.ADDR_IN(n2_addr_in), .DATA_IN(n2_data_in), .REQ_IN_FROM_LC(n2_req_in_from_lc), .ACK_OUT_TO_LC(n2_ack_out_to_lc), 
				.ADDR_OUT(n2_addr_out), .DATA_OUT(n2_data_out), .REQ_OUT_TO_LC(n2_req_out_to_lc), .ACK_IN_FROM_LC(n2_ack_in_from_lc),
				.TX_FAIL(n2_tx_fail), .TX_SUCCESS(n2_tx_success), .TX_ACK(n2_tx_ack));

`define SD #1

integer	handle;
reg		n1_ack_en;
reg		[2:0] n0_state;
reg		[7:0] words_counter;
reg		[31:0] random_input;

parameter TASK_IDLE = 0;
parameter TASK_WAIT = 1;
parameter TASK0 = 2;
parameter TASK1 = 3;
parameter TASK2 = 4;
parameter TASK3 = 5;
parameter TASK4 = 6;
parameter TASK5 = 7;

initial
begin
	clk = 0;
	resetn = 0;
	n1_ack_en = 1;


	n1_addr_in = 0;
	n1_data_in = 0;
	n1_req_in_from_lc = 0;
	n1_ack_in_from_lc = 0;

	n2_addr_in = 0;
	n2_data_in = 0;
	n2_req_in_from_lc = 0;
	n2_ack_in_from_lc = 0;
   	handle=$fopen("testbench.txt");

	@(posedge clk)
	@(posedge clk)
	@(posedge clk)
		`SD
		resetn = 1;
	@(posedge clk)
	@(posedge clk)

	#10000
		n0_state = TASK0;
	@(posedge n0_tx_success or n0_tx_fail)

	#10000
		n0_state = TASK1;
	@(posedge n0_tx_success or n0_tx_fail)

	#10000
		n0_state = TASK2;
	@(posedge n0_tx_success or n0_tx_fail)

	#10000
		n0_state = TASK3;
		@ (negedge n1_req_out_to_lc)
		@ (negedge n1_req_out_to_lc)
		@ (negedge n1_req_out_to_lc)
		@ (negedge n1_req_out_to_lc)
		n1_ack_en = 0;
	@(posedge n0_tx_success or n0_tx_fail)
		n1_ack_en = 1;
	
	#10000
		n0_state = TASK4;
	@(posedge n0_tx_success or n0_tx_fail)
	@(posedge n0_tx_success or n0_tx_fail)

	#10000
		n1_ack_en = 0;
		n0_state = TASK5;
	@(posedge n0_tx_success or n0_tx_fail)
		n1_ack_en = 1;

	#10000
		n0_state = TASK0;
	@(posedge n0_tx_success or n0_tx_fail)

	#10000
		$stop;
	

		
end

always #5 clk = ~clk;


always @ (posedge clk)
begin
	if (~resetn)
	begin
		n0_req_in_from_lc <= 0;
		n0_addr_in <= 0;
		n0_data_in <= 0;
		n0_req_in_from_lc = 0;
		n0_state <= TASK_IDLE;
		words_counter <= 0;
	end
	else
	begin
		case (n0_state)
			// single word transmission
			TASK0:
			begin
				n0_addr_in <= 8'hcd;
				if ((~n0_ack_out_to_lc) & (~n0_req_in_from_lc))
				begin
					n0_data_in <= random_input;
   					$fdisplay(handle, "N0 Data in =\t32'h%h", random_input);
					n0_req_in_from_lc <= 1;
					n0_state <= TASK_WAIT;
				end
			end

			// 8 words bit streaming
			TASK1:
			begin
				n0_addr_in <= 8'hcd;
				if ((~n0_ack_out_to_lc) & (~n0_req_in_from_lc))
				begin
					n0_data_in <= random_input;
					n0_req_in_from_lc <= 1;
   					$fdisplay(handle, "N0 Data in =\t32'h%h", random_input);
					if (words_counter<7)
						words_counter <= words_counter + 1;
					else
					begin
						n0_state <= TASK_WAIT;
						words_counter <= 0;
					end
				end
			end

			// 16 words bit streaming
			TASK2:
			begin
				n0_addr_in <= 8'hcd;
				if ((~n0_ack_out_to_lc) & (~n0_req_in_from_lc))
				begin
					n0_data_in <= random_input;
					n0_req_in_from_lc <= 1;
   					$fdisplay(handle, "N0 Data in =\t32'h%h", random_input);
					if (words_counter<15)
						words_counter <= words_counter + 1;
					else
					begin
						n0_state <= TASK_WAIT;
						words_counter <= 0;
					end
				end
			end

			// Buffer overflow
			TASK3:
			begin
				n0_addr_in <= 8'hcd;
				if ((~n0_ack_out_to_lc) & (~n0_req_in_from_lc))
				begin
					n0_data_in <= random_input;
					n0_req_in_from_lc <= 1;
   					$fdisplay(handle, "N0 Data in =\t32'h%h", random_input);
					if (words_counter<7)
						words_counter <= words_counter + 1;
					else
					begin
						n0_state <= TASK_WAIT;
						words_counter <= 0;
					end
				end
			end

			// different address in fifo
			TASK4:
			begin
				if ((~n0_ack_out_to_lc) & (~n0_req_in_from_lc))
				begin
					n0_data_in <= random_input;
					n0_req_in_from_lc <= 1;
   					$fdisplay(handle, "N0 Data in =\t32'h%h", random_input);
					if (words_counter<7)
						words_counter <= words_counter + 1;
					else
					begin
						n0_state <= TASK_WAIT;
						words_counter <= 0;
					end

					if (words_counter<4)
						n0_addr_in <= 8'hcd;
					else
						n0_addr_in <= 8'hef;
				end
			end

			// fail test
			TASK5:
			begin
				n0_addr_in <= 8'hcd;
				if ((~n0_ack_out_to_lc) & (~n0_req_in_from_lc))
				begin
					n0_data_in <= random_input;
					n0_req_in_from_lc <= 1;
   					$fdisplay(handle, "N0 Data in =\t32'h%h", random_input);
					if (words_counter<7)
						words_counter <= words_counter + 1;
					else
					begin
						n0_state <= TASK_WAIT;
						words_counter <= 0;
					end
				end
			end



			TASK_WAIT:
			begin
			end
		endcase

		if (n0_req_in_from_lc & n0_ack_out_to_lc)
			n0_req_in_from_lc <= 0;
	end
end

always @ (posedge clk)
begin
	if (~resetn)
	begin
		n0_ack_in_from_lc <= 0;
	end
	else
	begin
		if ((n0_req_out_to_lc)&(~n0_ack_in_from_lc))
		begin
			n0_ack_in_from_lc <= 1;
   			$fdisplay(handle, "N0 Data out =\t32'h%h", n0_data_out);
		end
		
		if ((~n0_req_out_to_lc)&(n0_ack_in_from_lc))
			n0_ack_in_from_lc <= 0;
	end
end

always @ (posedge clk)
begin
	if (~resetn)
	begin
		n1_ack_in_from_lc <= 0;
	end
	else if (n1_ack_en)
	begin
		begin
		if ((n1_req_out_to_lc)&(~n1_ack_in_from_lc))
		begin
			n1_ack_in_from_lc <= 1;
   			$fdisplay(handle, "N1 Data out =\t32'h%h", n1_data_out);
		end
		
		if ((~n1_req_out_to_lc)&(n1_ack_in_from_lc))
			n1_ack_in_from_lc <= 0;
		end
	end
end

always @ (posedge clk)
begin
	if (~resetn)
	begin
		n2_ack_in_from_lc <= 0;
	end
	else
	begin
		if ((n2_req_out_to_lc)&(~n2_ack_in_from_lc))
		begin
			n2_ack_in_from_lc <= 1;
   			$fdisplay(handle, "N2 Data out =\t32'h%h", n2_data_out);
		end
		
		if ((~n2_req_out_to_lc)&(n2_ack_in_from_lc))
			n2_ack_in_from_lc <= 0;
	end
end

always @ (posedge clk)
begin
	if (~resetn)
	begin
		n0_tx_ack <= 0;
		n1_tx_ack <= 0;
		n2_tx_ack <= 0;
	end
	else
	begin
		if ((n0_tx_success | n0_tx_fail)&(~n0_tx_ack))
		begin
			n0_tx_ack <= 1;
			if (n0_tx_success)
   				$fdisplay(handle, "N0 TX SUCCESS\n");
			else
   				$fdisplay(handle, "N0 TX FAIL\n");
		end
		if ((~(n0_tx_success | n0_tx_fail))&(n0_tx_ack))
			n0_tx_ack <= 0;

		if ((n1_tx_success | n1_tx_fail)&(~n1_tx_ack))
		begin
			n1_tx_ack <= 1;
			if (n1_tx_success)
   				$fdisplay(handle, "N1 TX SUCCESS\n");
			else
   				$fdisplay(handle, "N1 TX FAIL\n");
		end
		if ((~(n1_tx_success | n1_tx_fail))&(n1_tx_ack))
			n1_tx_ack <= 0;

		if ((n2_tx_success | n2_tx_fail)&(~n2_tx_ack))
		begin
			n2_tx_ack = 1;
			if (n2_tx_success)
   				$fdisplay(handle, "N2 TX SUCCESS\n");
			else
   				$fdisplay(handle, "N2 TX FAIL\n");
		end
		if ((~(n2_tx_success | n2_tx_fail))&(n2_tx_ack))
			n2_tx_ack = 0;
	end
end

always @ (posedge clk)
begin
	if (~resetn)
		random_input <= 0;
	else
		random_input <= $random;
end

endmodule
