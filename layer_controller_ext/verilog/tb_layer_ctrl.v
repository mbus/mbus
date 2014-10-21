
`define SD #1
`timescale 1ns/1ps

`include "include/mbus_def.v"

module tb_layer_ctrl();
`include "include/mbus_func.v"

	parameter LC_INT_DEPTH=13;
	parameter LC_MEM_DEPTH=65536;
	parameter LC_RF_DEPTH=256;

   reg		         clk, resetn;
   wire 		 SCLK;

	// n0 connections
	reg		[LC_INT_DEPTH-1:0] n0_int_vector;
	wire	[LC_INT_DEPTH-1:0]	n0_clr_int;
	// end of n0 connections

	// n1 connections
	reg		[LC_INT_DEPTH-1:0] n1_int_vector;
	wire	[LC_INT_DEPTH-1:0]	n1_clr_int;
	// end of n1 connections
	
	// n2 connections
	reg		[LC_INT_DEPTH-1:0] n2_int_vector;
	wire	[LC_INT_DEPTH-1:0]	n2_clr_int;
	// end of n2 connections
	
	// n3 connections
	reg		[LC_INT_DEPTH-1:0] n3_int_vector;
	wire	[LC_INT_DEPTH-1:0]	n3_clr_int;
	// end of n3 connections
	
	// c0 connections
	reg		[`ADDR_WIDTH-1:0] 	c0_tx_addr;
	reg		[`DATA_WIDTH-1:0]	c0_tx_data;
	reg							c0_tx_req, c0_priority, c0_tx_pend, c0_tx_resp_ack, c0_req_int;
	wire						c0_tx_ack, c0_tx_succ, c0_tx_fail;

	wire	[`ADDR_WIDTH-1:0]	c0_rx_addr;
	wire	[`DATA_WIDTH-1:0]	c0_rx_data;
	wire						c0_rx_req, c0_rx_fail, c0_rx_pend, c0_rx_broadcast;
	reg							c0_rx_ack;

   	wire						c0_lc_pwr_on, c0_lc_release_clk, c0_lc_release_rst, c0_lc_release_iso;
	// end of c0 connections
   
   	// connection between nodes
   	wire 		  				w_n0n1, w_n1n2, w_n2n3, w_n3c0, w_c0n0;
   	wire 		  				w_n0_clk_out, w_n1_clk_out, w_n2_clk_out, w_n3_clk_out;

	// testbench variables
   	reg [31:0]	rand_dat, rand_dat2;
   	reg [4:0] 	state;
   	reg [5:0] 	word_counter;
	reg [7:0]	rf_read_length;
	reg [7:0]	rf_addr;
	reg [29:0]	mem_addr;
	reg			mem_ptr_set;
	reg	[1:0]	mem_access_state;
	reg	[7:0]	relay_addr;
	reg [29:0]	mem_relay_loc;
	reg [7:0]	rf_relay_loc;
	reg	[31:0]	addr_increment;
	reg	[3:0]	dest_short_addr;
	reg [23:0]	rf_data;
	reg [31:0]	mem_data;
	reg [19:0]	mem_read_length;
	reg [3:0]	enum_short_addr;
	reg [19:0]	long_addr;
	reg [1:0]	layer_number;
	reg [LC_INT_DEPTH-1:0] int_vec;
	reg [31:0]	mem_w_data;
	reg [3:0]	functional_id;
	reg	[23:0]	rf_w_data;
   	integer 	handle;
	integer		task_counter;

	localparam TB_PROC_UP					= 0;
	localparam TB_QUERY						= 1;
	localparam TB_ENUM						= 2;
	localparam TB_ALL_WAKEUP				= 3;
	localparam TB_RF_WRITE					= 4;
	localparam TB_RF_READ					= 5;
	localparam TB_MEM_WRITE					= 6;
	localparam TB_MEM_READ					= 7;
	localparam TB_SEL_SLEEP_FULL_PREFIX		= 8;
	localparam TB_ALL_SLEEP					= 9;
	localparam TB_ALL_SHORT_ADDR_INVALID	= 10;
	localparam TB_SINGLE_INTERRUPT			= 11;
	localparam TB_MULTIPLE_INTERRUPT		= 12;
	localparam TB_SINGLE_MEM_WRITE			= 13;
	localparam TB_ARBITRARY_CMD				= 14;
	localparam TB_SINGLE_RF_WRITE			= 15;
	localparam TB_SHORT_MEM_READ			= 16;
	localparam TX_WAIT						= 31;

   reg	c0_auto_rx_ack;


layer_wrapper #(.ADDRESS(20'hbbbb0), .LC_INT_DEPTH(LC_INT_DEPTH)) layer0(
	.CLK(clk), .RESETn(resetn),
	.INT_VECTOR(n0_int_vector),
	.CLR_INT_EXTERNAL(n0_clr_int),
	// mbus
	.CLKIN(SCLK), .CLKOUT(w_n0_clk_out), .DIN(w_c0n0), .DOUT(w_n0n1)); 

layer_wrapper #(.ADDRESS(20'hbbbb1), .LC_INT_DEPTH(LC_INT_DEPTH)) layer1(
	.CLK(clk), .RESETn(resetn),
	.INT_VECTOR(n1_int_vector),
	.CLR_INT_EXTERNAL(n1_clr_int),
	// mbus
	.CLKIN(w_n0_clk_out), .CLKOUT(w_n1_clk_out), .DIN(w_n0n1), .DOUT(w_n1n2)); 

layer_wrapper #(.ADDRESS(20'hbbbb2), .LC_INT_DEPTH(LC_INT_DEPTH)) layer2(
	.CLK(clk), .RESETn(resetn),
	.INT_VECTOR(n2_int_vector),
	.CLR_INT_EXTERNAL(n2_clr_int),
	// mbus
	.CLKIN(w_n1_clk_out), .CLKOUT(w_n2_clk_out), .DIN(w_n1n2), .DOUT(w_n2n3)); 

layer_wrapper #(.ADDRESS(20'hbbbb2), .LC_INT_DEPTH(LC_INT_DEPTH)) layer3(
	.CLK(clk), .RESETn(resetn),
	.INT_VECTOR(n3_int_vector),
	.CLR_INT_EXTERNAL(n3_clr_int),
	// mbus
	.CLKIN(w_n2_clk_out), .CLKOUT(w_n3_clk_out), .DIN(w_n2n3), .DOUT(w_n3c0)); 

mbus_ctrl_layer_wrapper #(.ADDRESS(20'haaaa0)) c0 
     (.CLK_EXT(clk), .CLKIN(w_n3_clk_out), .CLKOUT(SCLK), .RESETn(resetn), .DIN(w_n3c0), .DOUT(w_c0n0), 
      .TX_ADDR(c0_tx_addr), .TX_DATA(c0_tx_data), .TX_REQ(c0_tx_req), .TX_ACK(c0_tx_ack), .TX_PEND(c0_tx_pend), .TX_PRIORITY(c0_priority),
      .RX_ADDR(c0_rx_addr), .RX_DATA(c0_rx_data), .RX_REQ(c0_rx_req), .RX_ACK(c0_rx_ack), .RX_FAIL(c0_rx_fail), .RX_PEND(c0_rx_pend),
      .TX_SUCC(c0_tx_succ), .TX_FAIL(c0_tx_fail), .TX_RESP_ACK(c0_tx_resp_ack),  .RX_BROADCAST(c0_rx_broadcast),
	  .LC_POWER_ON(c0_lc_pwr_on), .LC_RELEASE_CLK(c0_lc_release_clk), .LC_RELEASE_RST(c0_lc_release_rst), .LC_RELEASE_ISO(c0_lc_release_iso),
	  .REQ_INT(c0_req_int));

`include "tasks.v"
initial 
begin
	task_counter = 0;
    clk = 0;
    resetn = 1;
	mem_addr = 0;
	mem_ptr_set = 0;
	mem_access_state = 0;
	mem_data = 0;
	mem_relay_loc = 0;
	mem_read_length = 0;
	rf_addr = 0;
	rf_data = 0;
	rf_read_length = 0;
	rf_relay_loc = 0;
	relay_addr = 0;
	addr_increment = 0;
	enum_short_addr = 4'h2;
	long_addr = 20'haaaa0;
	layer_number = 0;
	int_vec = 0;
	mem_w_data = 0;
	functional_id = 0;

	@ (posedge clk);
    @ (posedge clk);
    @ (posedge clk);
    `SD resetn = 0;
    @ (posedge clk);
    @ (posedge clk);
    `SD resetn = 1;
    @ (posedge clk);
    @ (posedge clk);

      //VCD DUMP SECTION

//`ifdef APR
/*
	`ifdef TASK4
		$dumpfile("task4.vcd");
	`elsif TASK5
		$dumpfile("task5.vcd");
	`endif
	$dumpvars(0, tb_ulpb_node32);
*/
//`endif
      
      //SDF ANNOTATION
 `ifdef SYN
 	$sdf_annotate("../syn/layer_ctrl.dc.sdf", layer0.lc0);
   	$sdf_annotate("../syn/layer_ctrl.dc.sdf", layer1.lc0);
   	$sdf_annotate("../syn/layer_ctrl.dc.sdf", layer2.lc0);
   	$sdf_annotate("../syn/layer_ctrl.dc.sdf", layer3.lc0);
`endif
	  /*
`elsif APR
      $sdf_annotate("../apr/ulpb_ctrl_wrapper/ulpb_ctrl_wrapper.apr.sdf", c0);
      $sdf_annotate("../apr/ulpb_node32_ab/ulpb_node32_ab.apr.sdf", n0);
      $sdf_annotate("../apr/ulpb_node32_cd/ulpb_node32_cd.apr.sdf", n1);
      $sdf_annotate("../apr/ulpb_node32_ef/ulpb_node32_ef.apr.sdf", n2);
`endif
*/

      //************************
      //TESTBENCH BEGINS
      //Calls Tasks from tasks.v
      //***********************

`ifdef TASK0
	task0();
`elsif TASK1
	task1();
`elsif TASK2
	task2();
`else
      $display("**************************************");
      $display("************NO TASKS SUPPLIED*********");
      $display("****************FAILURE***************");
      $display("**************************************");
      $finish;
`endif
   
end // initial begin

//Changed to 400K for primetime calculations
always #1250 clk = ~clk;

   
`include "task_list.v"

always @ (posedge layer0.lc_pwr_on)
	$fdisplay(handle, "N0 LC Sleep");

always @ (posedge layer1.lc_pwr_on)
	$fdisplay(handle, "N1 LC Sleep");

always @ (posedge layer2.lc_pwr_on)
	$fdisplay(handle, "N2 LC Sleep");

always @ (posedge layer3.lc_pwr_on)
	$fdisplay(handle, "N3 LC Sleep");

always @ (posedge c0_lc_pwr_on)
	$fdisplay(handle, "Processor Sleep");

always @ (negedge layer0.lc_pwr_on)
	$fdisplay(handle, "N0 LC Wakeup");

always @ (negedge layer1.lc_pwr_on)
	$fdisplay(handle, "N1 LC Wakeup");

always @ (negedge layer2.lc_pwr_on)
	$fdisplay(handle, "N2 LC Wakeup");

always @ (negedge layer3.lc_pwr_on)
	$fdisplay(handle, "N3 LC Wakeup");

always @ (negedge c0_lc_pwr_on)
	$fdisplay(handle, "Processor Wakeup");

always @ (posedge clk or negedge resetn)
begin
	if (~resetn)
	begin
	  	n0_int_vector <= 0;
	  	n1_int_vector <= 0;
	  	n2_int_vector <= 0;
	  	n3_int_vector <= 0;

		c0_tx_addr  <= 0;
		c0_tx_data  <= 0;
		c0_tx_pend  <= 0;
		c0_tx_req   <= 0;
		c0_priority <= 0;
		c0_req_int	<= 0;
		c0_auto_rx_ack <= 1;
		word_counter <= 0;

	end
	else
	begin
		if (c0_tx_ack) c0_tx_req <= 0;
		if (c0_tx_fail & c0_tx_req) c0_tx_req <= 0;
	end
end

// n0 interrupt control
wire	[LC_INT_DEPTH-1:0] n0_int_clr_mask = (n0_clr_int & n0_int_vector);
always @ (posedge clk)
begin
	if (n0_int_clr_mask)
		n0_int_vector <= `SD (n0_int_vector & (~n0_int_clr_mask));
end

always @ (posedge layer0.rx_fail)
	$fdisplay(handle, "N0 RX Fail");

always @ (posedge layer0.rx_req)
begin
	$fdisplay(handle, "N0 RX Success");
   	//$fdisplay(handle, "N0 Data out =\t32'h%h", layer0.rx_data);
end

always @ (posedge layer0.tx_succ)
	$fdisplay(handle, "N0 TX Success\n");

always @ (posedge layer0.tx_fail)
	$fdisplay(handle, "N0 TX Fail\n");
// end of n0 interrupt control

// n1 interrupt control
wire	[LC_INT_DEPTH-1:0] n1_int_clr_mask = (n1_clr_int & n1_int_vector);
always @ (posedge clk)
begin
	if (n1_int_clr_mask)
		n1_int_vector <= `SD (n1_int_vector & (~n1_int_clr_mask));
end

always @ (posedge layer1.rx_fail)
	$fdisplay(handle, "N1 RX Fail");

always @ (posedge layer1.rx_req)
begin
	$fdisplay(handle, "N1 RX Success");
   	//$fdisplay(handle, "N1 Data out =\t32'h%h", layer1.rx_data);
end

always @ (posedge layer1.tx_succ)
	$fdisplay(handle, "N1 TX Success\n");

always @ (posedge layer1.tx_fail)
	$fdisplay(handle, "N1 TX Fail\n");
// end of n1 interrupt control

// n2 interrupt control
wire	[LC_INT_DEPTH-1:0] n2_int_clr_mask = (n2_clr_int & n2_int_vector);
always @ (posedge clk)
begin
	if (n2_int_clr_mask)
		n2_int_vector <= `SD (n2_int_vector & (~n2_int_clr_mask));
end

always @ (posedge layer2.rx_fail)
	$fdisplay(handle, "N2 RX Fail");

always @ (posedge layer2.rx_req)
begin
	$fdisplay(handle, "N2 RX Success");
   	//$fdisplay(handle, "N2 Data out =\t32'h%h", layer2.rx_data);
end

always @ (posedge layer2.tx_succ)
	$fdisplay(handle, "N2 TX Success\n");

always @ (posedge layer2.tx_fail)
	$fdisplay(handle, "N2 TX Fail\n");
// end of n2 interrupt control

// n3 interrupt control
wire	[LC_INT_DEPTH-1:0] n3_int_clr_mask = (n3_clr_int & n3_int_vector);
always @ (posedge clk)
begin
	if (n3_int_clr_mask)
		n3_int_vector <= `SD (n3_int_vector & (~n3_int_clr_mask));
end

always @ (posedge layer3.rx_fail)
	$fdisplay(handle, "N3 RX Fail");

always @ (posedge layer3.rx_req)
begin
	$fdisplay(handle, "N3 RX Success");
   	//$fdisplay(handle, "N3 Data out =\t32'h%h", layer3.rx_data);
end

always @ (posedge layer3.tx_succ)
	$fdisplay(handle, "N3 TX Success\n");

always @ (posedge layer3.tx_fail)
	$fdisplay(handle, "N3 TX Fail\n");
// end of n3 interrupt control


// c0 rx tx ack control
always @ (negedge resetn)
begin
	c0_rx_ack <= 0;
	c0_tx_resp_ack <= 0;
end

always @ (posedge c0_rx_fail)
	$fdisplay(handle, "C0 RX Fail");

always @ (posedge c0_rx_req)
begin
	$fdisplay(handle, "C0 RX Success");
   	$fdisplay(handle, "C0 Data out =\t32'h%h", c0_rx_data);
end

always @ (posedge clk)
begin
	if ((c0_rx_req | c0_rx_fail) & c0_auto_rx_ack)
		`SD c0_rx_ack <= 1;
	
	if (c0_rx_ack & (~c0_rx_req))
		`SD c0_rx_ack <= 0;
	
	if (c0_rx_ack & (~c0_rx_fail))
		`SD c0_rx_ack <= 0;
end

always @ (posedge c0_tx_succ)
	$fdisplay(handle, "C0 TX Success");

always @ (posedge c0_tx_fail)
	$fdisplay(handle, "C0 TX Fail");

always @ (posedge clk)
begin
	if (c0_tx_succ | c0_tx_fail)
		`SD c0_tx_resp_ack <= 1;

	if (c0_tx_resp_ack & (~c0_tx_succ))
		`SD c0_tx_resp_ack <= 0;
	
	if (c0_tx_resp_ack & (~c0_tx_fail))
		`SD c0_tx_resp_ack <= 0;
end
// end of c0 rx, tx ack control


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
   
// RF Write output
	wire [31:0] layer0_rf0_addr = log2long(layer0.rf0.LOAD) - 1;
	wire [31:0] layer1_rf0_addr = log2long(layer1.rf0.LOAD) - 1;
	wire [31:0] layer2_rf0_addr = log2long(layer2.rf0.LOAD) - 1;
	wire [31:0] layer3_rf0_addr = log2long(layer3.rf0.LOAD) - 1;
	genvar idx;
	generate 
		for (idx=0; idx<LC_RF_DEPTH; idx = idx+1)
		begin: rf_write
			always @ (posedge layer0.rf0.LOAD[idx])
				$fdisplay(handle, "Layer 0, RF Write, Addr: 8'h%h,\tData: 24'h%h", layer0_rf0_addr[7:0], layer0.rf0.DIN);
			always @ (posedge layer1.rf0.LOAD[idx])
				$fdisplay(handle, "Layer 1, RF Write, Addr: 8'h%h,\tData: 24'h%h", layer1_rf0_addr[7:0], layer1.rf0.DIN);
			always @ (posedge layer2.rf0.LOAD[idx])
				$fdisplay(handle, "Layer 2, RF Write, Addr: 8'h%h,\tData: 24'h%h", layer2_rf0_addr[7:0], layer2.rf0.DIN);
			always @ (posedge layer3.rf0.LOAD[idx])
				$fdisplay(handle, "Layer 3, RF Write, Addr: 8'h%h,\tData: 24'h%h", layer3_rf0_addr[7:0], layer3.rf0.DIN);
		end
	endgenerate
// End of RF Write output

// MEM Write output
	always @ (posedge layer0.mem0.MEM_ACK_OUT)
		if (layer0.mem0.MEM_WRITE)
			$fdisplay(handle, "Layer 0, MEM Write, Addr: 30'h%h,\tData: 32'h%h", layer0.mem0.ADDR, layer0.mem0.DATA_IN);
		else
			$fdisplay(handle, "Layer 0, MEM Read, Addr: 30'h%h,\tData: 32'h%h", layer0.mem0.ADDR, layer0.mem0.DATA_OUT);
	always @ (posedge layer1.mem0.MEM_ACK_OUT)
		if (layer1.mem0.MEM_WRITE)
			$fdisplay(handle, "Layer 1, MEM Write, Addr: 30'h%h,\tData: 32'h%h", layer1.mem0.ADDR, layer1.mem0.DATA_IN);
		else
			$fdisplay(handle, "Layer 1, MEM Read, Addr: 30'h%h,\tData: 32'h%h", layer1.mem0.ADDR, layer1.mem0.DATA_OUT);
	always @ (posedge layer2.mem0.MEM_ACK_OUT)
		if (layer2.mem0.MEM_WRITE)
			$fdisplay(handle, "Layer 2, MEM Write, Addr: 30'h%h,\tData: 32'h%h", layer2.mem0.ADDR, layer2.mem0.DATA_IN);
		else
			$fdisplay(handle, "Layer 2, MEM Read, Addr: 30'h%h,\tData: 32'h%h", layer2.mem0.ADDR, layer2.mem0.DATA_OUT);
	always @ (posedge layer3.mem0.MEM_ACK_OUT)
		if (layer3.mem0.MEM_WRITE)
			$fdisplay(handle, "Layer 3, MEM Write, Addr: 30'h%h,\tData: 32'h%h", layer3.mem0.ADDR, layer3.mem0.DATA_IN);
		else
			$fdisplay(handle, "Layer 3, MEM Read, Addr: 30'h%h,\tData: 32'h%h", layer3.mem0.ADDR, layer3.mem0.DATA_OUT);
// End of MEM Write output

endmodule // tb_layer_ctrl
