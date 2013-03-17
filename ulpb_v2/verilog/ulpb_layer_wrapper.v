
`include "include/ulpb_def.v"

module ulpb_layer_wrapper(
	input CLKIN, 
	input RESETn, 
	input DIN, 
	output CLKOUT,
	output DOUT, 
	input [`ADDR_WIDTH-1:0] TX_ADDR, 
	input [`DATA_WIDTH-1:0] TX_DATA, 
	input TX_PEND, 
	input TX_REQ, 
	input PRIORITY,
	output TX_ACK, 
	output [`ADDR_WIDTH-1:0] RX_ADDR, 
	output [`DATA_WIDTH-1:0] RX_DATA, 
	output RX_REQ, 
	input RX_ACK, 
	output RX_FAIL,
	output RX_PEND, 
	output TX_FAIL, 
	output TX_SUCC, 
	input TX_RESP_ACK,

	output LC_POWER_ON,
	output LC_RELEASE_CLK,
	output LC_RELEASE_RST,
	output LC_RELEASE_ISO
);

parameter ADDRESS = 8'hab;
parameter LAYER_ID = 24'd5;

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
wire	n0_tx_ack_t_iso, n0_rx_req_t_iso, n0_rx_fail_t_iso, n0_rx_pend_t_iso, n0_tx_succ_t_iso, n0_tx_fail_t_iso, n0_pwr_on_t_iso, n0_rel_clk_t_iso, n0_rel_rst_t_iso, n0_rel_iso_t_iso;
   
// always on block, interface with layer controller
	ulpb_node32_isolation iso0
	(.RELEASE_ISO_FROM_SLEEP_CTRL(n0_release_iso_from_sc),
	 .TX_ADDR_FROM_LC(n0_tx_addr_f_lc), .TX_DATA_FROM_LC(n0_tx_data_f_lc), .TX_REQ_FROM_LC(n0_tx_req_f_lc), .TX_ACK_TO_LC(TX_ACK), .TX_PEND_FROM_LC(n0_tx_pend_f_lc), .PRIORITY_FROM_LC(n0_priority_f_lc),
	 .RX_ADDR_TO_LC(RX_ADDR), .RX_DATA_TO_LC(RX_DATA), .RX_REQ_TO_LC(RX_REQ), .RX_ACK_FROM_LC(n0_rx_ack_f_lc), .RX_FAIL_TO_LC(RX_FAIL), .RX_PEND_TO_LC(RX_PEND), 
	 .TX_SUCC_TO_LC(TX_SUCC), .TX_FAIL_TO_LC(TX_FAIL), .TX_RESP_ACK_FROM_LC(n0_tx_resp_ack_f_lc),

	 .TX_ADDR_TO_BC(n0_tx_addr_t_bc), .TX_DATA_TO_BC(n0_tx_data_t_bc), .TX_REQ_TO_BC(n0_tx_req_t_bc), .TX_ACK_FROM_BC(n0_tx_ack_f_bc), .TX_PEND_TO_BC(n0_tx_pend_t_bc), .PRIORITY_TO_BC(n0_priority_t_bc),
	 .RX_ADDR_FROM_BC(n0_rx_addr_f_bc), .RX_DATA_FROM_BC(n0_rx_data_f_bc), .RX_REQ_FROM_BC(n0_rx_req_f_bc), .RX_ACK_TO_BC(n0_rx_ack_t_bc), .RX_FAIL_FROM_BC(n0_rx_fail_f_bc), .RX_PEND_FROM_BC(n0_rx_pend_f_bc), 
	 .TX_FAIL_FROM_BC(n0_tx_fail_f_bc), .TX_SUCC_FROM_BC(n0_tx_succ_f_bc), .TX_RESP_ACK_TO_BC(n0_tx_resp_ack_t_bc),

	 .POWER_ON_FROM_BC(n0_pwr_on_f_bc), .RELEASE_CLK_FROM_BC(n0_rel_clk_f_bc), .RELEASE_RST_FROM_BC(n0_rel_rst_f_bc), .RELEASE_ISO_FROM_BC(n0_rel_iso_f_bc), .RELEASE_ISO_FROM_BC_MASKED(LC_RELEASE_ISO),
	 .POWER_ON_TO_LC(LC_POWER_ON), .RELEASE_CLK_TO_LC(LC_RELEASE_CLK), .RELEASE_RST_TO_LC(LC_RELEASE_RST));

// power gated block
   ulpb_node32 #(.ADDRESS(ADDRESS), .LAYER_ID(LAYER_ID)) n0
     (.CLKIN(CLKIN), .CLKOUT(w_n0lc0_clk_out), .RESETn(RESETn), .DIN(DIN), .DOUT(w_n0lc0), 
      .TX_ADDR(n0_tx_addr_t_bc), .TX_DATA(n0_tx_data_t_bc), .TX_REQ(n0_tx_req_t_bc), .TX_ACK(n0_tx_ack_t_iso), .TX_PEND(n0_tx_pend_t_bc), .PRIORITY(n0_priority_t_bc),
      .RX_ADDR(n0_rx_addr_t_iso), .RX_DATA(n0_rx_data_t_iso), .RX_REQ(n0_rx_req_t_iso), .RX_ACK(n0_rx_ack_t_bc), .RX_FAIL(n0_rx_fail_t_iso), .RX_PEND(n0_rx_pend_t_iso),
      .TX_SUCC(n0_tx_succ_t_iso), .TX_FAIL(n0_tx_fail_t_iso), .TX_RESP_ACK(n0_tx_resp_ack_t_bc),
	  .RELEASE_RST_FROM_SLEEP_CTRL(n0_release_rst), .SLEEP_REQUEST_TO_SLEEP_CTRL(n0_sleep_req),
	  .POWER_ON_TO_LAYER_CTRL(n0_pwr_on_t_iso), .RELEASE_CLK_TO_LAYER_CTRL(n0_rel_clk_t_iso), .RELEASE_RST_TO_LAYER_CTRL(n0_rel_rst_t_iso), .RELEASE_ISO_TO_LAYER_CTRL(n0_rel_iso_t_iso));

// always on block
	sleep_ctrl sc0
	(.CLKIN(CLKIN), .RESETn(RESETn),
	 .SLEEP_REQ(n0_sleep_req), .POWER_ON(n0_power_on), .RELEASE_CLK(), .RELEASE_RST(n0_release_rst), .RELEASE_ISO(n0_release_iso_from_sc));

// always on block
	line_controller_rx_only lc0
	(.DIN(DIN), .CLKIN(CLKIN), 										// the same input as the node
	 .RELEASE_ISO_FROM_SLEEP_CTRL(n0_release_iso_from_sc),			// from sleep controller
	 .DOUT_FROM_BUS(w_n0lc0), .CLKOUT_FROM_BUS(w_n0lc0_clk_out), 	// the outputs from the node
	 .DOUT(DOUT), .CLKOUT(CLKOUT));									// to next node

always @ *
begin
	if (n0_power_on)
	begin
		n0_tx_ack_f_bc 	= 1'bx;
		n0_rx_addr_f_bc = 8'bxx;
		n0_rx_data_f_bc = 32'hxxxxxxxx;
		n0_rx_req_f_bc 	= 1'bx;
		n0_rx_fail_f_bc = 1'bx;
		n0_rx_pend_f_bc = 1'bx;
		n0_tx_fail_f_bc = 1'bx;
		n0_tx_succ_f_bc = 1'bx;
		n0_pwr_on_f_bc 	= 1'bx;
		n0_rel_clk_f_bc = 1'bx;
		n0_rel_rst_f_bc = 1'bx;
		n0_rel_iso_f_bc = 1'bx;
	end
	else
	begin
		n0_tx_ack_f_bc 	= n0_tx_ack_t_iso;
		n0_rx_addr_f_bc = n0_rx_addr_t_iso;
		n0_rx_data_f_bc = n0_rx_data_t_iso;
		n0_rx_req_f_bc 	= n0_rx_req_t_iso;
		n0_rx_fail_f_bc = n0_rx_fail_t_iso;
		n0_rx_pend_f_bc = n0_rx_pend_t_iso;
		n0_tx_fail_f_bc = n0_tx_fail_t_iso;
		n0_tx_succ_f_bc = n0_tx_succ_t_iso;
		n0_pwr_on_f_bc 	= n0_pwr_on_t_iso;
		n0_rel_clk_f_bc = n0_rel_clk_t_iso;
		n0_rel_rst_f_bc = n0_rel_rst_t_iso;
		n0_rel_iso_f_bc = n0_rel_iso_t_iso;
	end
end

always @ *
begin
	// layer controller is power off
	if (LC_POWER_ON)
	begin
		n0_tx_addr_f_lc 	= 8'hxx;
		n0_tx_data_f_lc 	= 32'hxxxxxxxx;
		n0_tx_req_f_lc 		= 1'bx;
		n0_tx_pend_f_lc 	= 1'bx;
		n0_priority_f_lc 	= 1'bx;
		n0_rx_ack_f_lc 		= 1'bx;
		n0_tx_resp_ack_f_lc = 1'bx;
	end
	else
	begin
		n0_tx_addr_f_lc 	= TX_ADDR;
		n0_tx_data_f_lc 	= TX_DATA;
		n0_tx_req_f_lc 		= TX_REQ;
		n0_tx_pend_f_lc 	= TX_PEND;
		n0_priority_f_lc 	= PRIORITY;
		n0_rx_ack_f_lc 		= RX_ACK;
		n0_tx_resp_ack_f_lc = TX_RESP_ACK;
	end
end


endmodule
