
//`define SYNTH
`define APR

`ifdef SYNTH
	`timescale 1ns/1ps
	`include "/afs/eecs.umich.edu/kits/ARM/TSMC_cl018g/mosis_2009q1/sc-x_2004q3v1/aci/sc/verilog/tsmc18_neg.v"
`ifdef APR
	`timescale 1ns/1ps
	`include "/afs/eecs.umich.edu/kits/ARM/TSMC_cl018g/mosis_2009q1/sc-x_2004q3v1/aci/sc/verilog/tsmc18_neg.v"
`endif

`include "include/ulpb_def.v"

module tb_ulpb_node32();

`include "include/ulpb_func.v"

reg		clk, resetn;
wire	SCLK;

reg		[`ADDR_WIDTH-1:0] n0_tx_addr, n1_tx_addr, n2_tx_addr, c0_tx_addr;
reg		[`DATA_WIDTH-1:0] n0_tx_data, n1_tx_data, n2_tx_data, c0_tx_data;
reg		n0_tx_req, n1_tx_req, n2_tx_req, c0_tx_req;
reg		n0_priority, n1_priority, n2_priority, c0_priority;
wire	n0_tx_ack, n1_tx_ack, n2_tx_ack, c0_tx_ack;
reg		n0_tx_pend, n1_tx_pend, n2_tx_pend, c0_tx_pend;

wire	[`ADDR_WIDTH-1:0] n0_rx_addr, n1_rx_addr, n2_rx_addr, c0_rx_addr;
wire	[`DATA_WIDTH-1:0] n0_rx_data, n1_rx_data, n2_rx_data, c0_rx_data;
wire	n0_rx_req, n1_rx_req, n2_rx_req, c0_rx_req;
reg		n0_rx_ack, n1_rx_ack, n2_rx_ack, c0_rx_ack;
wire	n0_rx_fail, n1_rx_fail, n2_rx_fail, c0_rx_fail;
wire	n0_rx_pend, n1_rx_pend, n2_rx_pend, c0_rx_pend;

wire	n0_tx_succ, n1_tx_succ, n2_tx_succ, c0_tx_succ;
wire	n0_tx_fail, n1_tx_fail, n2_tx_fail, c0_tx_fail;
reg		n0_tx_resp_ack, n1_tx_resp_ack, n2_tx_resp_ack, c0_tx_resp_ack;

wire	w_n2c0, w_c0n0, w_n0n1, w_n1n2;
wire	w_n0_clk_out, w_n1_clk_out, w_n2_clk_out;

reg		[31:0] rand_dat, rand_dat2;
reg		[4:0] state;
reg		[5:0] word_counter;
reg		clk_en;
integer	handle;

`ifdef SYNTH
   ulpb_node32_ab n0
     (.CLKIN(SCLK), .CLKOUT(w_n0_clk_out), .RESETn(resetn), .DIN(w_c0n0), .DOUT(w_n0n1), 
      .TX_ADDR(n0_tx_addr), .TX_DATA(n0_tx_data),	.TX_REQ(n0_tx_req), .TX_ACK(n0_tx_ack), .TX_PEND(n0_tx_pend), .PRIORITY(n0_priority),
      .RX_ADDR(n0_rx_addr), .RX_DATA(n0_rx_data), .RX_REQ(n0_rx_req), .RX_ACK(n0_rx_ack), .RX_FAIL(n0_rx_fail), .RX_PEND(n0_rx_pend),
      .TX_SUCC(n0_tx_succ), .TX_FAIL(n0_tx_fail), .TX_RESP_ACK(n0_tx_resp_ack));

ulpb_node32_cd n1
  (.CLKIN(w_n0_clk_out), .CLKOUT(w_n1_clk_out), .RESETn(resetn), .DIN(w_n0n1), .DOUT(w_n1n2), 
   .TX_ADDR(n1_tx_addr), .TX_DATA(n1_tx_data), .TX_REQ(n1_tx_req), .TX_ACK(n1_tx_ack), .TX_PEND(n1_tx_pend), .PRIORITY(n1_priority),
   .RX_ADDR(n1_rx_addr), .RX_DATA(n1_rx_data), .RX_REQ(n1_rx_req), .RX_ACK(n1_rx_ack), .RX_FAIL(n1_rx_fail), .RX_PEND(n1_rx_pend),
   .TX_SUCC(n1_tx_succ), .TX_FAIL(n1_tx_fail), .TX_RESP_ACK(n1_tx_resp_ack));

ulpb_node32_ef n2
			(.CLKIN(w_n1_clk_out), .CLKOUT(w_n2_clk_out), .RESETn(resetn), .DIN(w_n1n2), .DOUT(w_n2c0), 
			.TX_ADDR(n2_tx_addr), .TX_DATA(n2_tx_data), .TX_REQ(n2_tx_req), .TX_ACK(n2_tx_ack), .TX_PEND(n2_tx_pend), .PRIORITY(n2_priority),
			.RX_ADDR(n2_rx_addr), .RX_DATA(n2_rx_data), .RX_REQ(n2_rx_req), .RX_ACK(n2_rx_ack), .RX_FAIL(n2_rx_fail), .RX_PEND(n2_rx_pend),
			.TX_SUCC(n2_tx_succ), .TX_FAIL(n2_tx_fail), .TX_RESP_ACK(n2_tx_resp_ack));

ulpb_ctrl_wrapper c0 
			(.CLK_EXT(clk), .CLKIN(w_n2_clk_out), .CLKOUT(SCLK), .RESETn(resetn), .DIN(w_n2c0), .DOUT(w_c0n0), 
			.TX_ADDR(c0_tx_addr), .TX_DATA(c0_tx_data), .TX_REQ(c0_tx_req), .TX_ACK(c0_tx_ack), .TX_PEND(c0_tx_pend), .PRIORITY(c0_priority),
			.RX_ADDR(c0_rx_addr), .RX_DATA(c0_rx_data), .RX_REQ(c0_rx_req), .RX_ACK(c0_rx_ack), .RX_FAIL(c0_rx_fail), .RX_PEND(c0_rx_pend),
			.TX_SUCC(c0_tx_succ), .TX_FAIL(c0_tx_fail), .TX_RESP_ACK(c0_tx_resp_ack));
`elsif APR
ulpb_node32_ab n0
			(.CLKIN(SCLK), .CLKOUT(w_n0_clk_out), .RESETn(resetn), .DIN(w_c0n0), .DOUT(w_n0n1), 
			.TX_ADDR(n0_tx_addr), .TX_DATA(n0_tx_data),	.TX_REQ(n0_tx_req), .TX_ACK(n0_tx_ack), .TX_PEND(n0_tx_pend), .PRIORITY(n0_priority),
			.RX_ADDR(n0_rx_addr), .RX_DATA(n0_rx_data), .RX_REQ(n0_rx_req), .RX_ACK(n0_rx_ack), .RX_FAIL(n0_rx_fail), .RX_PEND(n0_rx_pend),
			.TX_SUCC(n0_tx_succ), .TX_FAIL(n0_tx_fail), .TX_RESP_ACK(n0_tx_resp_ack));

ulpb_node32_cd n1
			(.CLKIN(w_n0_clk_out), .CLKOUT(w_n1_clk_out), .RESETn(resetn), .DIN(w_n0n1), .DOUT(w_n1n2), 
			.TX_ADDR(n1_tx_addr), .TX_DATA(n1_tx_data), .TX_REQ(n1_tx_req), .TX_ACK(n1_tx_ack), .TX_PEND(n1_tx_pend), .PRIORITY(n1_priority),
			.RX_ADDR(n1_rx_addr), .RX_DATA(n1_rx_data), .RX_REQ(n1_rx_req), .RX_ACK(n1_rx_ack), .RX_FAIL(n1_rx_fail), .RX_PEND(n1_rx_pend),
			.TX_SUCC(n1_tx_succ), .TX_FAIL(n1_tx_fail), .TX_RESP_ACK(n1_tx_resp_ack));

ulpb_node32_ef n2
			(.CLKIN(w_n1_clk_out), .CLKOUT(w_n2_clk_out), .RESETn(resetn), .DIN(w_n1n2), .DOUT(w_n2c0), 
			.TX_ADDR(n2_tx_addr), .TX_DATA(n2_tx_data), .TX_REQ(n2_tx_req), .TX_ACK(n2_tx_ack), .TX_PEND(n2_tx_pend), .PRIORITY(n2_priority),
			.RX_ADDR(n2_rx_addr), .RX_DATA(n2_rx_data), .RX_REQ(n2_rx_req), .RX_ACK(n2_rx_ack), .RX_FAIL(n2_rx_fail), .RX_PEND(n2_rx_pend),
			.TX_SUCC(n2_tx_succ), .TX_FAIL(n2_tx_fail), .TX_RESP_ACK(n2_tx_resp_ack));

ulpb_ctrl_wrapper c0 
			(.CLK_EXT(clk), .CLKIN(w_n2_clk_out), .CLKOUT(SCLK), .RESETn(resetn), .DIN(w_n2c0), .DOUT(w_c0n0), 
			.TX_ADDR(c0_tx_addr), .TX_DATA(c0_tx_data), .TX_REQ(c0_tx_req), .TX_ACK(c0_tx_ack), .TX_PEND(c0_tx_pend), .PRIORITY(c0_priority),
			.RX_ADDR(c0_rx_addr), .RX_DATA(c0_rx_data), .RX_REQ(c0_rx_req), .RX_ACK(c0_rx_ack), .RX_FAIL(c0_rx_fail), .RX_PEND(c0_rx_pend),
			.TX_SUCC(c0_tx_succ), .TX_FAIL(c0_tx_fail), .TX_RESP_ACK(c0_tx_resp_ack));
`else
ulpb_node32 #(.ADDRESS(8'hab)) n0
			(.CLKIN(SCLK), .CLKOUT(w_n0_clk_out), .RESETn(resetn), .DIN(w_c0n0), .DOUT(w_n0n1), 
			.TX_ADDR(n0_tx_addr), .TX_DATA(n0_tx_data),	.TX_REQ(n0_tx_req), .TX_ACK(n0_tx_ack), .TX_PEND(n0_tx_pend), .PRIORITY(n0_priority),
			.RX_ADDR(n0_rx_addr), .RX_DATA(n0_rx_data), .RX_REQ(n0_rx_req), .RX_ACK(n0_rx_ack), .RX_FAIL(n0_rx_fail), .RX_PEND(n0_rx_pend),
			.TX_SUCC(n0_tx_succ), .TX_FAIL(n0_tx_fail), .TX_RESP_ACK(n0_tx_resp_ack));

ulpb_node32 #(.ADDRESS(8'hcd)) n1
			(.CLKIN(w_n0_clk_out), .CLKOUT(w_n1_clk_out), .RESETn(resetn), .DIN(w_n0n1), .DOUT(w_n1n2), 
			.TX_ADDR(n1_tx_addr), .TX_DATA(n1_tx_data), .TX_REQ(n1_tx_req), .TX_ACK(n1_tx_ack), .TX_PEND(n1_tx_pend), .PRIORITY(n1_priority),
			.RX_ADDR(n1_rx_addr), .RX_DATA(n1_rx_data), .RX_REQ(n1_rx_req), .RX_ACK(n1_rx_ack), .RX_FAIL(n1_rx_fail), .RX_PEND(n1_rx_pend),
			.TX_SUCC(n1_tx_succ), .TX_FAIL(n1_tx_fail), .TX_RESP_ACK(n1_tx_resp_ack));

ulpb_node32 #(.ADDRESS(8'hef)) n2
			(.CLKIN(w_n1_clk_out), .CLKOUT(w_n2_clk_out), .RESETn(resetn), .DIN(w_n1n2), .DOUT(w_n2c0), 
			.TX_ADDR(n2_tx_addr), .TX_DATA(n2_tx_data), .TX_REQ(n2_tx_req), .TX_ACK(n2_tx_ack), .TX_PEND(n2_tx_pend), .PRIORITY(n2_priority),
			.RX_ADDR(n2_rx_addr), .RX_DATA(n2_rx_data), .RX_REQ(n2_rx_req), .RX_ACK(n2_rx_ack), .RX_FAIL(n2_rx_fail), .RX_PEND(n2_rx_pend),
			.TX_SUCC(n2_tx_succ), .TX_FAIL(n2_tx_fail), .TX_RESP_ACK(n2_tx_resp_ack));

ulpb_ctrl_wrapper #(.CTRL_ADDRESS(8'h01), .NODE_ADDRESS(8'haa)) c0 
			(.CLK_EXT(clk), .CLKIN(w_n2_clk_out), .CLKOUT(SCLK), .RESETn(resetn), .DIN(w_n2c0), .DOUT(w_c0n0), 
			.TX_ADDR(c0_tx_addr), .TX_DATA(c0_tx_data), .TX_REQ(c0_tx_req), .TX_ACK(c0_tx_ack), .TX_PEND(c0_tx_pend), .PRIORITY(c0_priority),
			.RX_ADDR(c0_rx_addr), .RX_DATA(c0_rx_data), .RX_REQ(c0_rx_req), .RX_ACK(c0_rx_ack), .RX_FAIL(c0_rx_fail), .RX_PEND(c0_rx_pend),
			.TX_SUCC(c0_tx_succ), .TX_FAIL(c0_tx_fail), .TX_RESP_ACK(c0_tx_resp_ack));
`endif


`define SD #1
reg	n0_auto_rx_ack, n1_auto_rx_ack, n2_auto_rx_ack, c0_auto_rx_ack;

initial
begin
	$dumpfile("tb_task1.vcd");
	$dumpvars(0, tb_ulpb_node32);
`ifdef SYNTH
   $sdf_annotate("ulpb_ctrl_wrapper.dc.sdf", c0);
   $sdf_annotate("ulpb_node32_ab.dc.sdf", n0);
   $sdf_annotate("ulpb_node32_cd.dc.sdf", n1);
   $sdf_annotate("ulpb_node32_ef.dc.sdf", n2);
`elsif APR
   $sdf_annotate("../apr/ulpb_ctrl_wrapper/ulpb_ctrl_wrapper.apr.sdf", c0);
   $sdf_annotate("../apr/ulpb_node32_ab/ulpb_node32_ab.apr.sdf", n0);
   $sdf_annotate("../apr/ulpb_node32_cd/ulpb_node32_cd.apr.sdf", n1);
   $sdf_annotate("../apr/ulpb_node32_ef/ulpb_node32_ef.apr.sdf", n2);
`endif
	clk = 0;
	resetn = 1;
	n0_auto_rx_ack = 1;
	n1_auto_rx_ack = 1;
	n2_auto_rx_ack = 1;
	c0_auto_rx_ack = 1;
	clk_en = 1;
   	handle=$fopen("task1_tb.txt");


	@ (posedge clk)
	@ (posedge clk)
	@ (posedge clk)
		`SD resetn = 0;
	@ (posedge clk)
	@ (posedge clk)
		`SD resetn = 1;
	@ (posedge clk)
	@ (posedge clk)

//   #500000;
   $display("done");
//   $stop;
   $finish;
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

		c0_tx_addr <= 0;
		c0_tx_data <= 0;
		c0_tx_pend <= 0;
		c0_tx_req <= 0;
		c0_priority <= 0;

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

		if (c0_tx_ack)
			c0_tx_req <= 0;
	end
end

always @ (posedge clk or negedge resetn)
begin
	if (~resetn)
	begin
		n0_rx_ack <= 0;
		n1_rx_ack <= 0;
		n2_rx_ack <= 0;
		c0_rx_ack <= 0;
	end
	else
	begin
		if ((n0_rx_fail)&(~n0_rx_ack))
		begin
			n0_rx_ack <= 1;
   			$fdisplay(handle, "N0 RX Fail");
		end

		if ((~n0_rx_fail) & n0_rx_ack)
			n0_rx_ack <= 0;

		if ((n1_rx_fail)&(~n1_rx_ack))
		begin
			n1_rx_ack <= 1;
   			$fdisplay(handle, "N1 RX Fail");
		end

		if ((~n1_rx_fail) & n1_rx_ack)
			n1_rx_ack <= 0;

		if ((n2_rx_fail)&(~n2_rx_ack))
		begin
			n2_rx_ack <= 1;
   			$fdisplay(handle, "N2 RX Fail");
		end

		if ((~n2_rx_fail) & n2_rx_ack)
			n2_rx_ack <= 0;

		if ((c0_rx_fail)&(~c0_rx_ack))
		begin
			c0_rx_ack <= 1;
   			$fdisplay(handle, "C0 RX Fail");
		end

		if ((~c0_rx_fail) & c0_rx_ack)
			c0_rx_ack <= 0;

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

		if (c0_auto_rx_ack)
		begin
			if ((c0_rx_req==1)&&(c0_rx_ack==0))
			begin
				c0_rx_ack <= 1;
   				$fdisplay(handle, "C0 Data out =\t32'h%h", c0_rx_data);
			end
			
			if ((c0_rx_req==0)&&(c0_rx_ack==1))
				c0_rx_ack <= 0;
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
		c0_tx_resp_ack <= 0;
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
			if (n2_tx_succ)
   				$fdisplay(handle, "N2 TX SUCCESS\n");
			else
   				$fdisplay(handle, "N2 TX FAIL\n");
		end
		
		if ((c0_tx_succ | c0_tx_fail)&(~c0_tx_resp_ack))
		begin
			c0_tx_resp_ack <= 1;
			if (c0_tx_succ)
   				$fdisplay(handle, "C0 TX SUCCESS\n");
			else
   				$fdisplay(handle, "C0 TX FAIL\n");
		end

		if ((~(n0_tx_succ | n0_tx_fail))&(n0_tx_resp_ack))
			n0_tx_resp_ack <= 0;

		if ((~(n1_tx_succ | n1_tx_fail))&(n1_tx_resp_ack))
			n1_tx_resp_ack <= 0;

		if ((~(n2_tx_succ | n2_tx_fail))&(n2_tx_resp_ack))
			n2_tx_resp_ack <= 0;

		if ((~(c0_tx_succ | c0_tx_fail))&(c0_tx_resp_ack))
			c0_tx_resp_ack <= 0;
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

   //Changed to 400K for primetime calculations
always #1250 if (clk_en) clk = ~clk; else clk = 1;

endmodule
