`define SD #1

`ifdef SYN
	`timescale 1ns/1ps
	`include "/afs/eecs.umich.edu/kits/ARM/TSMC_cl018g/mosis_2009q1/sc-x_2004q3v1/aci/sc/verilog/tsmc18_neg.v"
`elsif APR
	`timescale 1ns/1ps
	`include "/afs/eecs.umich.edu/kits/ARM/TSMC_cl018g/mosis_2009q1/sc-x_2004q3v1/aci/sc/verilog/tsmc18_neg.v"
`endif

`include "include/ulpb_def.v"

module tb_ulpb_node32();

`include "include/ulpb_func.v"

   reg		         clk, resetn;
   wire 		 SCLK;
   
   reg [`ADDR_WIDTH-1:0] n0_tx_addr,  n1_tx_addr,  n2_tx_addr,  c0_tx_addr;
   reg [`DATA_WIDTH-1:0] n0_tx_data,  n1_tx_data,  n2_tx_data,  c0_tx_data;
   reg 			 n0_tx_req,   n1_tx_req,   n2_tx_req,   c0_tx_req;
   reg 			 n0_priority, n1_priority, n2_priority, c0_priority;
   wire 		 n0_tx_ack,   n1_tx_ack,   n2_tx_ack,   c0_tx_ack;
   reg 			 n0_tx_pend,  n1_tx_pend,  n2_tx_pend,  c0_tx_pend;
   
   wire [`ADDR_WIDTH-1:0] n0_rx_addr, n1_rx_addr, n2_rx_addr, c0_rx_addr;
   wire [`DATA_WIDTH-1:0] n0_rx_data, n1_rx_data, n2_rx_data, c0_rx_data;
   wire 		  n0_rx_req,  n1_rx_req,  n2_rx_req,  c0_rx_req;
   reg 			  n0_rx_ack,  n1_rx_ack,  n2_rx_ack,  c0_rx_ack;
   wire 		  n0_rx_fail, n1_rx_fail, n2_rx_fail, c0_rx_fail;
   wire 		  n0_rx_pend, n1_rx_pend, n2_rx_pend, c0_rx_pend;
   
   wire 		  n0_tx_succ,     n1_tx_succ,     n2_tx_succ,     c0_tx_succ;
   wire 		  n0_tx_fail,     n1_tx_fail,     n2_tx_fail,     c0_tx_fail;
   reg 			  n0_tx_resp_ack, n1_tx_resp_ack, n2_tx_resp_ack, c0_tx_resp_ack;
   
   wire 		  w_n2c0,       w_c0n0,       w_n0n1,      w_n1n2;
   wire 		  w_n0_clk_out, w_n1_clk_out, w_n2_clk_out;
   
   reg [31:0] 		  rand_dat, rand_dat2;
   reg [4:0] 		  state;
   reg [5:0] 		  word_counter;
   reg 			  clk_en;
   integer 		  handle;

   parameter 		  TASK0=0;
   parameter 		  TASK1=1;
   parameter 		  TASK2=2;
   parameter 		  TASK3=3;
   parameter 		  TASK4=4;
   parameter 		  TASK5=5;
   parameter 		  TASK6=6;
   parameter 		  TASK7=7;
   parameter 		  TASK8=8;
   parameter 		  TASK9=9;
   parameter 		  TASK10=10;
   parameter 		  TASK11=11;
   parameter 		  TASK12=12;
   parameter 		  TASK13=13;
   parameter 		  TASK14=14;
   parameter 		  TASK15=15;
   parameter 		  TASK16=16;
   parameter 		  TASK17=17;
   parameter 		  TASK18=18;
   parameter 		  TASK19=19;
   parameter 		  TASK20=20;
   parameter 		  TASK21=21;
   parameter 		  TASK22=22;
   parameter 		  TASK23=23;
   parameter 		  TASK24=24;
   parameter 		  TASK25=25;
   parameter 		  TASK26=26;
   parameter 		  TASK27=27;
   
   parameter 		  TX_WAIT=31;

   reg 			  n0_auto_rx_ack, n1_auto_rx_ack, n2_auto_rx_ack, c0_auto_rx_ack;

wire	[`WATCH_DOG_WIDTH-1:0] THRESHOLD = 20'h05fff;

wire	n0_power_on, n0_sleep_req, n0_release_rst, n0_release_iso_from_sc;
wire	w_n0lc0, w_n0lc0_clk_out;

reg		n0_tx_ack_f_bc;
reg		[`ADDR_WIDTH-1:0] n0_rx_addr_f_bc;
reg		[`DATA_WIDTH-1:0] n0_rx_data_f_bc;
reg		n0_rx_req_f_bc, n0_rx_fail_f_bc, n0_rx_pend_f_bc, n0_tx_fail_f_bc, n0_tx_succ_f_bc, n0_pwr_on_f_bc, n0_rel_clk_f_bc, n0_rel_rst_f_bc, n0_rel_iso_f_bc;

reg		[`ADDR_WIDTH-1:0] n0_tx_addr_f_lc;
reg		[`DATA_WIDTH-1:0] n0_tx_data_f_lc;
reg		n0_tx_req_f_lc, n0_tx_pend_f_lc, n0_priority_f_lc, n0_rx_ack_f_lc, n0_tx_resp_ack_f_lc;

wire	[`ADDR_WIDTH-1:0] n0_tx_addr_t_bc;
wire	[`DATA_WIDTH-1:0] n0_tx_data_t_bc;
wire	n0_tx_req_t_bc, n0_tx_pend_t_bc, n0_priority_t_bc, n0_rx_ack_t_bc, n0_tx_resp_ack_t_bc;

wire	[`ADDR_WIDTH-1:0] n0_rx_addr_t_iso;
wire	[`DATA_WIDTH-1:0] n0_rx_data_t_iso;
wire	n0_rx_req_t_iso, n0_rx_fail_t_iso, n0_rx_pend_t_iso, n0_tx_succ_t_iso, n0_tx_fail_t_iso, n0_pwr_on_t_iso, n0_rel_clk_t_iso, n0_rel_rst_t_iso, n0_rel_iso_t_iso;
   
	ulpb_node32_isolation iso0
	(.RELEASE_ISO_FROM_SLEEP_CTRL(n0_release_iso_from_sc),
	 .TX_ADDR_FROM_LC(n0_tx_addr_f_lc), .TX_DATA_FROM_LC(n0_tx_data_f_lc), .TX_REQ_FROM_LC(n0_tx_req_f_lc), .TX_ACK_TO_LC(n0_tx_ack), .TX_PEND_FROM_LC(n0_tx_pend_f_lc), .PRIORITY_FROM_LC(n0_priority_f_lc),
	 .RX_ADDR_TO_LC(n0_rx_addr), .RX_DATA_TO_LC(n0_rx_data), .RX_REQ_TO_LC(n0_rx_req), .RX_ACK_FROM_LC(n0_rx_ack_f_lc), .RX_FAIL_TO_LC(n0_rx_fail), .RX_PEND_TO_LC(n0_rx_pend), 
	 .TX_SUCC_TO_LC(n0_tx_succ), .TX_FAIL_TO_LC(n0_tx_fail), .TX_RESP_ACK_FROM_LC(n0_tx_resp_ack_f_lc),

	 .TX_ADDR_TO_BC(n0_tx_addr_t_bc), .TX_DATA_TO_BC(n0_tx_data_t_bc), .TX_REQ_TO_BC(n0_tx_req_t_bc), .TX_ACK_FROM_BC(n0_tx_ack_f_bc), .TX_PEND_TO_BC(n0_tx_pend_t_bc), .PRIORITY_TO_BC(n0_priority_t_bc),
	 .RX_ADDR_FROM_BC(n0_rx_addr_f_bc), .RX_DATA_FROM_BC(n0_rx_data_f_bc), .RX_REQ_FROM_BC(n0_rx_req_f_bc), .RX_ACK_TO_BC(n0_rx_ack_t_bc), .RX_FAIL_FROM_BC(n0_rx_fail_f_bc), .RX_PEND_FROM_BC(n0_rx_pend_f_bc), 
	 .TX_FAIL_FROM_BC(n0_tx_fail_f_bc), .TX_SUCC_FROM_BC(n0_tx_succ_f_bc), .TX_RESP_ACK_TO_BC(n0_tx_resp_ack_t_bc),

	 .POWER_ON_FROM_BC(n0_pwr_on_f_bc), .RELEASE_CLK_FROM_BC(n0_rel_clk_f_bc), .RELEASE_RST_FROM_BC(n0_rel_rst_f_bc), .RELEASE_ISO_FROM_BC(n0_rel_iso_f_bc), RELEASE_ISO_FROM_BC_MASKED(),
	 .POWER_ON_TO_LC(n0_pwr_on_t_lc), .RELEASE_CLK_TO_LC(), .RELEASE_RST_TO_LC(n0_rel_rst_t_lc));

   ulpb_node32 #(.ADDRESS(8'hab)) n0
     (.CLKIN(SCLK), .CLKOUT(w_n0lc0_clk_out), .RESETn(resetn), .DIN(w_c0n0), .DOUT(w_n0lc0), 
      .TX_ADDR(n0_tx_addr_t_bc), .TX_DATA(n0_tx_data_t_bc), .TX_REQ(n0_tx_req_t_bc), .TX_ACK(n0_tx_ack_t_iso), .TX_PEND(n0_tx_pend_t_bc), .PRIORITY(n0_priority_t_bc),
      .RX_ADDR(n0_rx_addr_t_iso), .RX_DATA(n0_rx_data_t_iso), .RX_REQ(n0_rx_req_t_iso), .RX_ACK(n0_rx_ack_t_bc), .RX_FAIL(n0_rx_fail_t_iso), .RX_PEND(n0_rx_pend_t_iso),
      .TX_SUCC(n0_tx_succ_t_iso), .TX_FAIL(n0_tx_fail_t_iso), .TX_RESP_ACK(n0_tx_resp_ack_t_bc),
	  .RELEASE_RST_FROM_SLEEP_CTRL(n0_release_rst), .SLEEP_REQUEST_TO_SLEEP_CTRL(n0_sleep_req),
	  .POWER_ON_TO_LAYER_CTRL(n0_pwr_on_t_iso), .RELEASE_CLK_TO_LAYER_CTRL(n0_rel_clk_t_iso), .RELEASE_RST_TO_LAYER_CTRL(n0_rel_rst_t_iso), .RELEASE_ISO_TO_LAYER_CTRL(n0_rel_iso_t_iso));

	sleep_ctrl sc0
	(.CLKIN(SCLK), .RESETn(resetn),
	 .SLEEP_REQ(n0_sleep_req), .POWER_ON(n0_power_on), .RELEASE_CLK(), .RELEASE_RST(n0_release_rst), .RELEASE_ISO(n0_release_iso_from_sc));

	line_controller_rx_only lc0
	(.DIN(w_c0n0), .CLKIN(SCLK), 									// the same input as the node
	 .RELEASE_ISO_FROM_SLEEP_CTRL(n0_release_iso_from_sc),			// from sleep controller
	 .DOUT_FROM_BUS(w_n0lc0), .CLKOUT_FROM_BUS(w_n0lc0_clk_out), 	// the outputs from the node
	 .DOUT(w_n0n1), .CLKOUT(w_n0_clk_out));							// to next node

always @ *
begin
	if (n0_power_on)
	begin
		n0_tx_ack_f_bc = 1'hz;
		n0_rx_addr_f_bc = 8'hzz;
		n0_rx_data_f_bc = 32'hzzzzzzzz;
		n0_rx_req_f_bc = 1'hz;
		n0_rx_fail_f_bc = 1'hz;
		n0_rx_pend_f_bc = 1'hz;
		n0_tx_fail_f_bc = 1'hz;
		n0_tx_succ_f_bc = 1'hz;
		n0_pwr_on_f_bc = 1'bz;
		n0_rel_clk_f_bc = 1'bz;
		n0_rel_rst_f_bc = 1'bz;
		n0_rel_iso_f_bc = 1'bz;
	end
	else
	begin
		n0_tx_ack_f_bc = n0_tx_ack_t_iso;
		n0_rx_addr_f_bc = n0_rx_addr_t_iso;
		n0_rx_data_f_bc = n0_rx_data_t_iso;
		n0_rx_req_f_bc = n0_rx_req_t_iso;
		n0_rx_fail_f_bc = n0_rx_fail_t_iso;
		n0_rx_pend_f_bc = n0_rx_pend_t_iso;
		n0_tx_fail_f_bc = n0_tx_fail_t_iso;
		n0_tx_succ_f_bc = n0_tx_succ_t_iso;
		n0_pwr_on_f_bc = n0_pwr_on_t_iso;
		n0_rel_clk_f_bc = n0_rel_clk_t_iso;
		n0_rel_rst_f_bc = n0_rel_rst_t_iso;
		n0_rel_iso_f_bc = n0_rel_iso_t_iso;
	end
end

always @ *
begin
	// layer controller is power off
	if (n0_pwr_on_t_lc)
	begin
		n0_tx_addr_f_lc = 8'hzz;
		n0_tx_data_f_lc = 32'hzzzzzzzz;
		n0_tx_req_f_lc = 1'bz;
		n0_tx_pend_f_lc = 1'bz;
		n0_priority_f_lc = 1'bz;
		n0_rx_ack_f_lc = 1'bz;
		n0_tx_resp_ack_f_lc = 1'bz;
	end
	else
	begin
		n0_tx_addr_f_lc = n0_tx_addr;
		n0_tx_data_f_lc = n0_tx_data;
		n0_tx_req_f_lc = n0_tx_req;
		n0_tx_pend_f_lc = n0_tx_pend;
		n0_priority_f_lc = n0_priority;
		n0_rx_ack_f_lc = n0_rx_ack;
		n0_tx_resp_ack_f_lc = n0_tx_resp_ack;
	end
end


   
   ulpb_node32_wo_pwr_gated #(.ADDRESS(8'hcd)) n1
     (.CLKIN(w_n0_clk_out), .CLKOUT(w_n1_clk_out), .RESETn(resetn), .DIN(w_n0n1), .DOUT(w_n1n2), 
      .TX_ADDR(n1_tx_addr), .TX_DATA(n1_tx_data), .TX_REQ(n1_tx_req), .TX_ACK(n1_tx_ack), .TX_PEND(n1_tx_pend), .PRIORITY(n1_priority),
      .RX_ADDR(n1_rx_addr), .RX_DATA(n1_rx_data), .RX_REQ(n1_rx_req), .RX_ACK(n1_rx_ack), .RX_FAIL(n1_rx_fail), .RX_PEND(n1_rx_pend),
      .TX_SUCC(n1_tx_succ), .TX_FAIL(n1_tx_fail), .TX_RESP_ACK(n1_tx_resp_ack));
   
   ulpb_node32_wo_pwr_gated #(.ADDRESS(8'hef)) n2
     (.CLKIN(w_n1_clk_out), .CLKOUT(w_n2_clk_out), .RESETn(resetn), .DIN(w_n1n2), .DOUT(w_n2c0), 
      .TX_ADDR(n2_tx_addr), .TX_DATA(n2_tx_data), .TX_REQ(n2_tx_req), .TX_ACK(n2_tx_ack), .TX_PEND(n2_tx_pend), .PRIORITY(n2_priority),
      .RX_ADDR(n2_rx_addr), .RX_DATA(n2_rx_data), .RX_REQ(n2_rx_req), .RX_ACK(n2_rx_ack), .RX_FAIL(n2_rx_fail), .RX_PEND(n2_rx_pend),
      .TX_SUCC(n2_tx_succ), .TX_FAIL(n2_tx_fail), .TX_RESP_ACK(n2_tx_resp_ack));
   
   ulpb_ctrl_wrapper #(.CTRL_ADDRESS(8'h01), .NODE_ADDRESS(8'haa)) c0 
     (.CLK_EXT(clk), .CLKIN(w_n2_clk_out), .CLKOUT(SCLK), .RESETn(resetn), .DIN(w_n2c0), .DOUT(w_c0n0), 
      .TX_ADDR(c0_tx_addr), .TX_DATA(c0_tx_data), .TX_REQ(c0_tx_req), .TX_ACK(c0_tx_ack), .TX_PEND(c0_tx_pend), .PRIORITY(c0_priority),
      .RX_ADDR(c0_rx_addr), .RX_DATA(c0_rx_data), .RX_REQ(c0_rx_req), .RX_ACK(c0_rx_ack), .RX_FAIL(c0_rx_fail), .RX_PEND(c0_rx_pend),
      .TX_SUCC(c0_tx_succ), .TX_FAIL(c0_tx_fail), .TX_RESP_ACK(c0_tx_resp_ack), .THRESHOLD(THRESHOLD));

initial
 begin
      clk = 0;
      resetn = 1;
      n0_auto_rx_ack = 1;
      n1_auto_rx_ack = 1;
      n2_auto_rx_ack = 1;
      c0_auto_rx_ack = 1;
      clk_en = 1;
      handle=$fopen("node_tb_rx_only.txt");

      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      `SD resetn = 0;
      @ (posedge clk);
      @ (posedge clk);
      `SD resetn = 1;
      @ (posedge clk);
      @ (posedge clk);
      clk_en = 0;

      #10000;
      clk_en = 1;
      $fdisplay(handle, "TASK0, Correct result: N1 TX Success");
      state = TASK0;
      @ (posedge n1_tx_succ | n1_tx_fail);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      clk_en = 0;

      #10000;
      clk_en = 1;
      $fdisplay(handle, "TASK0, Correct result: N1 TX Success");
      state = TASK0;
      @ (posedge n1_tx_succ | n1_tx_fail);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      clk_en = 0;

      #10000;
      clk_en = 1;
      $fdisplay(handle, "TASK1, Sleep N0");
      state = TASK1;
      @ (posedge n1_tx_succ | n1_tx_fail);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      clk_en = 0;
	  $stop;
end // initial begin
   
always @ (posedge clk or negedge resetn) begin
   if (~resetn) begin
      n0_tx_addr  <= 0;
      n0_tx_data  <= 0;
      n0_tx_pend  <= 0;
      n0_tx_req   <= 0;
      n0_priority <= 0;
      
      n1_tx_addr  <= 0;
      n1_tx_data  <= 0;
      n1_tx_pend  <= 0;
      n1_tx_req   <= 0;
      n1_priority <= 0;
      
      n2_tx_addr  <= 0;
      n2_tx_data  <= 0;
      n2_tx_pend  <= 0;
      n2_tx_req   <= 0;
      n2_priority <= 0;
      
      c0_tx_addr  <= 0;
      c0_tx_data  <= 0;
      c0_tx_pend  <= 0;
      c0_tx_req   <= 0;
      c0_priority <= 0;
      
      word_counter <= 0;
   end
   else begin
      if (n0_tx_ack) n0_tx_req <= 0;
      if (n1_tx_ack) n1_tx_req <= 0;
      if (n2_tx_ack) n2_tx_req <= 0;
      if (c0_tx_ack) c0_tx_req <= 0;
      case (state)
	// simple transmission
	TASK0: begin
	   if ((~n1_tx_ack) & (~n1_tx_req)) begin
	      n1_tx_addr <= 8'hab;
	      n1_tx_data <= rand_dat;
	      n1_tx_pend <= 0;
	      n1_tx_req <= 1;
   	      $fdisplay(handle, "N1 Data in =\t32'h%h", rand_dat);
	      state <= TX_WAIT;
	   end
	end

	// sleep n0
	TASK1: begin
	   if ((~n1_tx_ack) & (~n1_tx_req)) begin
	      n1_tx_addr <= 8'h00;
	      n1_tx_data <= (8'hfe<<24) | (1'b1<<5);
	      n1_tx_pend <= 0;
	      n1_tx_req <= 1;
   	      $fdisplay(handle, "N1 Data in =\t32'h%h", rand_dat);
	      state <= TX_WAIT;
	   end
	end
	
      endcase // case (state)
   end
end // always @ (posedge clk or negedge resetn)

  always @ (posedge clk or negedge resetn) begin
     if (~resetn) begin
	n0_rx_ack <= 0;
	n1_rx_ack <= 0;
	n2_rx_ack <= 0;
	c0_rx_ack <= 0;
     end
     else begin
	if ((n0_rx_fail)&(~n0_rx_ack)) begin
	   n0_rx_ack <= 1;
   	   $fdisplay(handle, "N0 RX Fail");
	end

	if ((~n0_rx_fail) & n0_rx_ack) n0_rx_ack <= 0;
	if ((n1_rx_fail)&(~n1_rx_ack))	begin
	   n1_rx_ack <= 1;
   	   $fdisplay(handle, "N1 RX Fail");
	end

	if ((~n1_rx_fail) & n1_rx_ack)	n1_rx_ack <= 0;

	if ((n2_rx_fail)&(~n2_rx_ack))	begin
	   n2_rx_ack <= 1;
   	   $fdisplay(handle, "N2 RX Fail");
	end

	if ((~n2_rx_fail) & n2_rx_ack)	n2_rx_ack <= 0;

	if ((c0_rx_fail)&(~c0_rx_ack))	begin
	   c0_rx_ack <= 1;
   	   $fdisplay(handle, "C0 RX Fail");
	end

	if ((~c0_rx_fail) & c0_rx_ack)	c0_rx_ack <= 0;

	if (n0_auto_rx_ack) begin
	   if ((n0_rx_req==1)&&(n0_rx_ack==0))	begin
	      n0_rx_ack <= 1;
   	      $fdisplay(handle, "N0 Data out =\t32'h%h", n0_rx_data);
	   end
	   if ((n0_rx_req==0)&&(n0_rx_ack==1))	n0_rx_ack <= 0;
	end

	if (n1_auto_rx_ack) begin
	   if ((n1_rx_req==1)&&(n1_rx_ack==0)) begin
	      n1_rx_ack <= 1;
   	      $fdisplay(handle, "N1 Data out =\t32'h%h", n1_rx_data);
	   end
	   
	   if ((n1_rx_req==0)&&(n1_rx_ack==1)) n1_rx_ack <= 0;
	end

	if (n2_auto_rx_ack) begin
	   if ((n2_rx_req==1)&&(n2_rx_ack==0)) begin
	      n2_rx_ack <= 1;
   	      $fdisplay(handle, "N2 Data out =\t32'h%h", n2_rx_data);
	   end
	   
	   if ((n2_rx_req==0)&&(n2_rx_ack==1)) n2_rx_ack <= 0;
	end
	
	if (c0_auto_rx_ack) begin
	   if ((c0_rx_req==1)&&(c0_rx_ack==0)) begin
	      c0_rx_ack <= 1;
   	      $fdisplay(handle, "C0 Data out =\t32'h%h", c0_rx_data);
	   end
	   
	   if ((c0_rx_req==0)&&(c0_rx_ack==1)) c0_rx_ack <= 0;
	end
     end
  end


   always @ (posedge clk or negedge resetn) begin
      if (~resetn) begin
	 n0_tx_resp_ack <= 0;
	 n1_tx_resp_ack <= 0;
	 n2_tx_resp_ack <= 0;
	 c0_tx_resp_ack <= 0;
      end
      else begin
	 if ((n0_tx_succ | n0_tx_fail)&(~n0_tx_resp_ack)) begin
	    n0_tx_resp_ack <= 1;
	    if (n0_tx_succ) $fdisplay(handle, "N0 TX SUCCESS\n");
	    else  	    $fdisplay(handle, "N0 TX FAIL\n");
	 end
	 if ((n1_tx_succ | n1_tx_fail)&(~n1_tx_resp_ack)) begin
	    n1_tx_resp_ack <= 1;
	    if (n1_tx_succ) $fdisplay(handle, "N1 TX SUCCESS\n");
	    else	    $fdisplay(handle, "N1 TX FAIL\n");
	 end
	 if ((n2_tx_succ | n2_tx_fail)&(~n2_tx_resp_ack)) begin
	    n2_tx_resp_ack <= 1;
	    if (n2_tx_succ) $fdisplay(handle, "N2 TX SUCCESS\n");
	    else            $fdisplay(handle, "N2 TX FAIL\n");
	 end
	 if ((c0_tx_succ | c0_tx_fail)&(~c0_tx_resp_ack)) begin
	    c0_tx_resp_ack <= 1;
	    if (c0_tx_succ) $fdisplay(handle, "C0 TX SUCCESS\n");
	    else 	    $fdisplay(handle, "C0 TX FAIL\n");
	 end
	 if ((~(n0_tx_succ | n0_tx_fail))&(n0_tx_resp_ack)) n0_tx_resp_ack <= 0;
	 if ((~(n1_tx_succ | n1_tx_fail))&(n1_tx_resp_ack)) n1_tx_resp_ack <= 0;
	 if ((~(n2_tx_succ | n2_tx_fail))&(n2_tx_resp_ack)) n2_tx_resp_ack <= 0;
	 if ((~(c0_tx_succ | c0_tx_fail))&(c0_tx_resp_ack)) c0_tx_resp_ack <= 0;
      end // else: !if(~resetn)
   end // always @ (posedge clk or negedge resetn)

   always @ (posedge clk or negedge resetn) begin
      if (~resetn) begin
	 rand_dat  <= 0;
	 rand_dat2 <= 0;
      end
      else begin
	 rand_dat  <= $random;
	 rand_dat2 <= $random;
      end
   end
   
   //Changed to 400K for primetime calculations
   always #1250 if (clk_en) clk = ~clk; else clk = 1;

`include "tasks.v"
endmodule // tb_ulpb_node32
