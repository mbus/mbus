
`include "include/mbus_def.v"

module mbus_ctrl_layer_wrapper(
	input	CLK_EXT,
	input 	CLKIN, 
	input 	RESETn, 
	input 	DIN, 
	output 	CLKOUT,
	output 	DOUT, 
	input 	[`ADDR_WIDTH-1:0] TX_ADDR, 
	input 	[`DATA_WIDTH-1:0] TX_DATA, 
	input 	TX_PEND, 
	input 	TX_REQ, 
	input 	PRIORITY,
	output 	TX_ACK, 
	output 	[`ADDR_WIDTH-1:0] RX_ADDR, 
	output 	[`DATA_WIDTH-1:0] RX_DATA, 
	output 	RX_REQ, 
	input 	RX_ACK, 
	output	RX_BROADCAST,
	output 	RX_FAIL,
	output 	RX_PEND, 
	output 	TX_FAIL, 
	output 	TX_SUCC, 
	input 	TX_RESP_ACK,

	output 	LC_POWER_ON,
	output 	LC_RELEASE_CLK,
	output 	LC_RELEASE_RST,
	output 	LC_RELEASE_ISO,

	input 	REQ_INT,

	input	WAKEUP_PROC
);

parameter ADDRESS = 20'haaaaa;

wire	m0_power_on;
wire	CLK_GEN;
wire	release_iso_from_s0, release_rst_from_s0;
wire	sleep_req_from_m0;

SLEEP_CONTROLv4 s0(
	.MBC_ISOLATE(release_iso_from_s0), 
	.MBC_ISOLATE_B(), 
	.MBC_RESET(release_rst_from_s0),
    .MBC_RESET_B(), 
	.MBC_SLEEP(),
	.MBC_SLEEP_B(m0_power_on), 
	.SYSTEM_ACTIVE(),
    .WAKEUP_REQ_ORED(),
	.CLK(CLK_GEN), 
	.MBUS_DIN(DIN), 
	.RESETn(RESETn), 
	.SLEEP_REQ(sleep_req_from_m0),
    .WAKEUP_REQ0(WAKEUP_PROC), 
	.WAKEUP_REQ1(), 
	.WAKEUP_REQ2());


mbus_clk_sim mcs0(
	.ext_clk(CLK_EXT),		// generated from testbench, always ticking
	.clk_en(m0_power_on),	// from sleep controller
	.clk_out(CLK_GEN)		// to sleep controller, mbus
);

wire	w_m0wc0_clk_out, w_m0wc0;
wire	ext_int_to_wire, ext_int_to_bus, clr_ext_int;


reg		m0_tx_ack_f_bc;
reg		[`ADDR_WIDTH-1:0] m0_rx_addr_f_bc;
reg		[`DATA_WIDTH-1:0] m0_rx_data_f_bc;
reg		m0_rx_req_f_bc, m0_rx_bcast_f_bc, m0_rx_fail_f_bc, m0_rx_pend_f_bc, m0_tx_fail_f_bc, m0_tx_succ_f_bc, m0_pwr_on_f_bc, m0_rel_clk_f_bc, m0_rel_rst_f_bc, m0_rel_iso_f_bc;

wire	[`ADDR_WIDTH-1:0] m0_rx_addr_t_iso;
wire	[`DATA_WIDTH-1:0] m0_rx_data_t_iso;
wire	m0_tx_ack_t_iso, m0_rx_req_t_iso, m0_rx_bcast_t_iso, m0_rx_fail_t_iso, m0_rx_pend_t_iso, m0_tx_succ_t_iso, m0_tx_fail_t_iso, m0_pwr_on_t_iso, m0_rel_clk_t_iso, m0_rel_rst_t_iso, m0_rel_iso_t_iso;

reg		[`ADDR_WIDTH-1:0] m0_tx_addr_f_lc;
reg		[`DATA_WIDTH-1:0] m0_tx_data_f_lc;
reg		m0_tx_req_f_lc, m0_tx_pend_f_lc, m0_priority_f_lc, m0_rx_ack_f_lc, m0_tx_resp_ack_f_lc;

wire	[`ADDR_WIDTH-1:0] m0_tx_addr_t_bc;
wire	[`DATA_WIDTH-1:0] m0_tx_data_t_bc;
wire	m0_tx_req_t_bc, m0_tx_pend_t_bc, m0_priority_t_bc, m0_rx_ack_t_bc, m0_tx_resp_ack_t_bc;

// always on block, interface with layer controller
mbus_regular_isolation iso0
	(.RELEASE_ISO_FROM_SLEEP_CTRL(release_iso_from_s0),
	 .TX_ADDR_FROM_LC(m0_tx_addr_f_lc), .TX_DATA_FROM_LC(m0_tx_data_f_lc), .TX_REQ_FROM_LC(m0_tx_req_f_lc), .TX_ACK_TO_LC(TX_ACK), .TX_PEND_FROM_LC(m0_tx_pend_f_lc), .PRIORITY_FROM_LC(m0_priority_f_lc),
	 .RX_ADDR_TO_LC(RX_ADDR), .RX_DATA_TO_LC(RX_DATA), .RX_REQ_TO_LC(RX_REQ), .RX_ACK_FROM_LC(m0_rx_ack_f_lc), .RX_FAIL_TO_LC(RX_FAIL), .RX_PEND_TO_LC(RX_PEND), 
	 .TX_SUCC_TO_LC(TX_SUCC), .TX_FAIL_TO_LC(TX_FAIL), .TX_RESP_ACK_FROM_LC(m0_tx_resp_ack_f_lc), .RX_BROADCAST_TO_LC(RX_BROADCAST),

	 .TX_ADDR_TO_BC(m0_tx_addr_t_bc), .TX_DATA_TO_BC(m0_tx_data_t_bc), .TX_REQ_TO_BC(m0_tx_req_t_bc), .TX_ACK_FROM_BC(m0_tx_ack_f_bc), .TX_PEND_TO_BC(m0_tx_pend_t_bc), .PRIORITY_TO_BC(m0_priority_t_bc),
	 .RX_ADDR_FROM_BC(m0_rx_addr_f_bc), .RX_DATA_FROM_BC(m0_rx_data_f_bc), .RX_REQ_FROM_BC(m0_rx_req_f_bc), .RX_ACK_TO_BC(m0_rx_ack_t_bc), .RX_FAIL_FROM_BC(m0_rx_fail_f_bc), .RX_PEND_FROM_BC(m0_rx_pend_f_bc), 
	 .TX_FAIL_FROM_BC(m0_tx_fail_f_bc), .TX_SUCC_FROM_BC(m0_tx_succ_f_bc), .TX_RESP_ACK_TO_BC(m0_tx_resp_ack_t_bc), .RX_BROADCAST_FROM_BC(m0_rx_bcast_f_bc),

	 .POWER_ON_FROM_BC(m0_pwr_on_f_bc), .RELEASE_CLK_FROM_BC(m0_rel_clk_f_bc), .RELEASE_RST_FROM_BC(m0_rel_rst_f_bc), .RELEASE_ISO_FROM_BC(m0_rel_iso_f_bc), .RELEASE_ISO_FROM_BC_MASKED(LC_RELEASE_ISO),
	 .POWER_ON_TO_LC(LC_POWER_ON), .RELEASE_CLK_TO_LC(LC_RELEASE_CLK), .RELEASE_RST_TO_LC(LC_RELEASE_RST));

mbus_ctrl_wrapper #(.ADDRESS(ADDRESS)) m0(
	.CLK_EXT(CLK_GEN), .RESETn(RESETn), 
	.CLKIN(CLKIN), .CLKOUT(w_m0wc0_clk_out), .DIN(DIN), .DOUT(w_m0wc0),
	.TX_ADDR(m0_tx_addr_t_bc), .TX_DATA(m0_tx_data_t_bc), .TX_PEND(m0_tx_pend_t_bc), .TX_REQ(m0_tx_req_t_bc), .PRIORITY(m0_priority_t_bc), .TX_ACK(m0_tx_ack_t_iso), 
	.RX_ADDR(m0_rx_addr_t_iso), .RX_DATA(m0_rx_data_t_iso), .RX_REQ(m0_rx_req_t_iso), .RX_ACK(m0_rx_ack_t_bc), .RX_BROADCAST(m0_rx_bcast_t_iso),
	.RX_FAIL(m0_rx_fail_t_iso), .RX_PEND(m0_rx_pend_t_iso), 
	.TX_FAIL(m0_tx_fail_t_iso), .TX_SUCC(m0_tx_succ_t_iso), .TX_RESP_ACK(m0_tx_resp_ack_t_bc), 

	.THRESHOLD(20'h05fff),

	.RELEASE_RST_FROM_SLEEP_CTRL(release_rst_from_s0),
	.POWER_ON_TO_LAYER_CTRL(m0_pwr_on_t_iso),
	.RELEASE_CLK_TO_LAYER_CTRL(m0_rel_clk_t_iso),
	.RELEASE_RST_TO_LAYER_CTRL(m0_rel_rst_t_iso),
	.RELEASE_ISO_TO_LAYER_CTRL(m0_rel_iso_t_iso),
	.EXTERNAL_INT(ext_int_to_bus), .CLR_EXT_INT(clr_ext_int),
	.WAKEUP_PROC(WAKEUP_PROC),
	.SLEEP_REQUEST_TO_SLEEP_CTRL(sleep_req_from_m0)
);


// always on wire controller
mbus_wire_ctrl wc0
	(.DIN(DIN), .CLKIN(CLKIN), 										// the same input as the node
	 .RELEASE_ISO_FROM_SLEEP_CTRL(release_iso_from_s0),			// from sleep controller
	 .DOUT_FROM_BUS(w_m0wc0), .CLKOUT_FROM_BUS(w_m0wc0_clk_out), 	// the outputs from the node
	 .DOUT(DOUT), .CLKOUT(CLKOUT),									// to next node
	 .EXTERNAL_INT(ext_int_to_wire));

// always on interrupt request
mbus_ext_int int0(
	.CLKIN(CLKIN), 
	.RESETn(RESETn),
	.REQ_INT(REQ_INT), 
	.EXTERNAL_INT_TO_WIRE(ext_int_to_wire), 
	.EXTERNAL_INT_TO_BUS(ext_int_to_bus), 
	.CLR_EXT_INT(clr_ext_int));

always @ *
begin
	if (~m0_power_on)
	begin
		m0_tx_ack_f_bc 	= 1'bx;
		m0_rx_addr_f_bc = 8'bxx;
		m0_rx_data_f_bc = 32'hxxxxxxxx;
		m0_rx_req_f_bc 	= 1'bx;
		m0_rx_bcast_f_bc= 1'bx;
		m0_rx_fail_f_bc = 1'bx;
		m0_rx_pend_f_bc = 1'bx;
		m0_tx_fail_f_bc = 1'bx;
		m0_tx_succ_f_bc = 1'bx;
		m0_pwr_on_f_bc 	= 1'bx;
		m0_rel_clk_f_bc = 1'bx;
		m0_rel_rst_f_bc = 1'bx;
		m0_rel_iso_f_bc = 1'bx;
	end
	else
	begin
		m0_tx_ack_f_bc 	= m0_tx_ack_t_iso;
		m0_rx_addr_f_bc = m0_rx_addr_t_iso;
		m0_rx_data_f_bc = m0_rx_data_t_iso;
		m0_rx_req_f_bc 	= m0_rx_req_t_iso;
		m0_rx_bcast_f_bc= m0_rx_bcast_t_iso;
		m0_rx_fail_f_bc = m0_rx_fail_t_iso;
		m0_rx_pend_f_bc = m0_rx_pend_t_iso;
		m0_tx_fail_f_bc = m0_tx_fail_t_iso;
		m0_tx_succ_f_bc = m0_tx_succ_t_iso;
		m0_pwr_on_f_bc 	= m0_pwr_on_t_iso;
		m0_rel_clk_f_bc = m0_rel_clk_t_iso;
		m0_rel_rst_f_bc = m0_rel_rst_t_iso;
		m0_rel_iso_f_bc = m0_rel_iso_t_iso;
	end
end

always @ *
begin
	// layer controller is power off
	if (LC_POWER_ON)
	begin
		m0_tx_addr_f_lc 	= 8'hxx;
		m0_tx_data_f_lc 	= 32'hxxxxxxxx;
		m0_tx_req_f_lc 		= 1'bx;
		m0_tx_pend_f_lc 	= 1'bx;
		m0_priority_f_lc 	= 1'bx;
		m0_rx_ack_f_lc 		= 1'bx;
		m0_tx_resp_ack_f_lc = 1'bx;
	end
	else
	begin
		m0_tx_addr_f_lc 	= TX_ADDR;
		m0_tx_data_f_lc 	= TX_DATA;
		m0_tx_req_f_lc 		= TX_REQ;
		m0_tx_pend_f_lc 	= TX_PEND;
		m0_priority_f_lc 	= PRIORITY;
		m0_rx_ack_f_lc 		= RX_ACK;
		m0_tx_resp_ack_f_lc = TX_RESP_ACK;
	end
end

endmodule
