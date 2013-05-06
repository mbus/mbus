
`include "include/mbus_def.v"

module layer_wrapper(

	// layer controller
	input 	CLK,
	input 	RESETn,
	input	[`LC_INT_DEPTH-1:0] INT_VECTOR,
	output 	[`LC_INT_DEPTH-1:0] CLR_INT_EXTERNAL,

	// mbus
	input	CLKIN,
	output	CLKOUT,
	input	DIN,
	output	DOUT
); 

parameter RF_DEPTH = 64;
parameter ROM_DEPTH = 64;
parameter ADDRESS = 20'hccccc;

// from layer controller, need isolation
// Mem
wire	mem_req_out, mem_write;
wire	[`LC_MEM_DATA_WIDTH-1:0] mem_dout;
wire	[`LC_MEM_ADDR_WIDTH-3:0] mem_aout;

// RF
wire	[`LC_RF_DATA_WIDTH-1:0] rf_dout;
wire	[`LC_RF_DEPTH-1:0] rf_load;

// Mbus
wire	[`ADDR_WIDTH-1:0] 	tx_addr;
wire	[`DATA_WIDTH-1:0]	tx_data;
wire						tx_req, tx_priority, tx_pend, tx_resp_ack; 
wire						tx_ack, tx_succ, tx_fail;

// Interrupt
wire	[`LC_INT_DEPTH-1:0] clr_int;

// unknown state when power if off
// Mem
reg		mem_req_out_f_lc, mem_write_f_lc;
reg		[`LC_MEM_DATA_WIDTH-1:0] mem_dout_f_lc;
reg		[`LC_MEM_ADDR_WIDTH-3:0] mem_aout_f_lc;

// RF
reg		[`LC_RF_DATA_WIDTH-1:0] rf_dout_f_lc;
reg		[`LC_RF_DEPTH-1:0] rf_load_f_lc;

// Mbus
reg		[`ADDR_WIDTH-1:0] 	tx_addr_f_lc;
reg		[`DATA_WIDTH-1:0]	tx_data_f_lc;
reg							tx_req_f_lc, priority_f_lc, tx_pend_f_lc, tx_resp_ack_f_lc; 
reg							rx_ack_f_lc;

// Interrupt
reg		[`LC_INT_DEPTH-1:0] clr_int_f_lc;

// output from isolation
// Mem
wire	mem_req_out_t_mem, mem_write_t_mem;
wire	[`LC_MEM_DATA_WIDTH-1:0] mem_dout_t_mem;
wire	[`LC_MEM_ADDR_WIDTH-3:0] mem_aout_t_mem;

// RF
wire	[`LC_RF_DATA_WIDTH-1:0] rf_dout_t_rf;
wire	[`LC_RF_DEPTH-1:0] rf_load_t_rf;

// Mbus
wire	[`ADDR_WIDTH-1:0] 	tx_addr_t_mbus;
wire	[`DATA_WIDTH-1:0]	tx_data_t_mbus;
wire						tx_req_t_mbus, priority_t_mbus, tx_pend_t_mbus, tx_resp_ack_t_mbus; 
wire						rx_ack_t_mbus;


// To layer controller, doesn't need isolation
// MEM
wire	mem_ack_f_mem;
wire	[`LC_MEM_DATA_WIDTH-1:0] mem_data_f_mem;

// RF
wire	[`LC_RF_DATA_WIDTH*RF_DEPTH-1:0] rf_dout_f_rf;
// ROM
wire	[`LC_RF_DATA_WIDTH*ROM_DEPTH-1:0] sensor_dat_f_rom;
wire	[`FUNC_WIDTH*`LC_INT_DEPTH-1:0] int_func_id_f_rom;
wire	[(`DATA_WIDTH<<1)*`LC_INT_DEPTH-1:0] int_payload_f_rom;

// Mbus
wire	[`ADDR_WIDTH-1:0]	rx_addr;
wire	[`DATA_WIDTH-1:0]	rx_data;
wire						rx_req, rx_fail, rx_pend, rx_broadcast;
wire						rx_ack;

// Power signals
wire						lc_pwr_on, lc_release_clk, lc_release_rst, lc_release_iso;

// interrupt, clock
wire						req_int = (INT_VECTOR>0)? 1'b1 : 1'b0;
wire						CLK_LC = (CLK&(~lc_release_clk));

// always on isolation
layer_ctrl_isolation lc_iso0(
	.LC_ISOLATION(lc_release_iso),
	// Interface with MBus
	.TX_ADDR_FROM_LC(tx_addr_f_lc), .TX_DATA_FROM_LC(tx_data_f_lc), .TX_PEND_FROM_LC(tx_pend_f_lc), .TX_REQ_FROM_LC(tx_req_f_lc),
	.PRIORITY_FROM_LC(priority_f_lc), .RX_ACK_FROM_LC(rx_ack_f_lc), .TX_RESP_ACK_FROM_LC(tx_resp_ack_f_lc), 
	// Interface with Registers
	.RF_DATA_FROM_LC(rf_dout_f_lc), .RF_LOAD_FROM_LC(rf_load_f_lc),
	// Interface with MEM
	.MEM_REQ_OUT_FROM_LC(mem_req_out_f_lc), .MEM_WRITE_FROM_LC(mem_write_f_lc), .MEM_DOUT_FROM_LC(mem_dout_f_lc), .MEM_AOUT_FROM_LC(mem_aout_f_lc),
	// Interrupt
	.CLR_INT_FROM_LC(clr_int_f_lc),

	// Interface with MBus
	.TX_ADDR_TO_MBUS(tx_addr_t_mbus), .TX_DATA_TO_MBUS(tx_data_t_mbus), .TX_PEND_TO_MBUS(tx_pend_t_mbus), .TX_REQ_TO_MBUS(tx_req_t_mbus),
	.PRIORITY_TO_MBUS(priority_t_mbus), .RX_ACK_TO_MBUS(rx_ack_t_mbus), .TX_RESP_ACK_TO_MBUS(tx_resp_ack_t_mbus), 
	// Interface with Registers
	.RF_DATA_TO_RF(rf_dout_t_rf), .RF_LOAD_TO_RF(rf_load_t_rf),
	// Interface with MEM
	.MEM_REQ_OUT_TO_MEM(mem_req_out_t_mem), .MEM_WRITE_TO_MEM(mem_write_t_mem), .MEM_DOUT_TO_MEM(mem_dout_t_mem), .MEM_AOUT_TO_MEM(mem_aout_t_mem),
	// Interrupt
	.CLR_INT_EXTERNAL(CLR_INT_EXTERNAL)
);

layer_ctrl lc0(
	.CLK(CLK_LC),
	.RESETn(RESETn),
	// Interface with MBus
	.TX_ADDR(tx_addr), 
	.TX_DATA(tx_data), 
	.TX_PEND(tx_pend), 
	.TX_REQ(tx_req), 
	.TX_ACK(tx_ack), 
	.TX_PRIORITY(tx_priority),
	.RX_ADDR(rx_addr), 
	.RX_DATA(rx_data), 
	.RX_PEND(rx_pend), 
	.RX_REQ(rx_req), 
	.RX_ACK(rx_ack), 
	.RX_BROADCAST(rx_broadcast),
	.RX_FAIL(rx_fail),
	.TX_FAIL(tx_fail), 
	.TX_SUCC(tx_succ), 
	.TX_RESP_ACK(tx_resp_ack),
	.RELEASE_RST_FROM_MBUS(lc_release_rst),
	// Interface with Registers
	.RF_DIN({sensor_dat_f_rom, rf_dout_f_rf}),
	.RF_DOUT(rf_dout),
	.RF_LOAD(rf_load),
	// Interface with MEM
	.MEM_REQ_OUT(mem_req_out),
	.MEM_WRITE(mem_write),
	.MEM_ACK_IN(mem_ack_f_mem),
	.MEM_DOUT(mem_dout),
	.MEM_DIN(mem_data_f_mem),
	.MEM_AOUT(mem_aout),
	// Interrupt
	.INT_VECTOR(INT_VECTOR),
	.CLR_INT(clr_int),
	.INT_CMD_FUNC_ID(int_func_id_f_rom),
	.INT_CMD_PAYLOAD(int_payload_f_rom)
);

mbus_layer_wrapper #(.ADDRESS(ADDRESS)) mbus_node0
     (.CLKIN(CLKIN), .CLKOUT(CLKOUT), .RESETn(RESETn), .DIN(DIN), .DOUT(DOUT), 
      .TX_ADDR(tx_addr_t_mbus), .TX_DATA(tx_data_t_mbus), .TX_REQ(tx_req_t_mbus), .TX_ACK(tx_ack), .TX_PEND(tx_pend_t_mbus), .TX_PRIORITY(priority_t_mbus),
      .RX_ADDR(rx_addr), .RX_DATA(rx_data), .RX_REQ(rx_req), .RX_ACK(rx_ack_t_mbus), .RX_FAIL(rx_fail), .RX_PEND(rx_pend),
      .TX_SUCC(tx_succ), .TX_FAIL(tx_fail), .TX_RESP_ACK(tx_resp_ack_t_mbus), .RX_BROADCAST(rx_broadcast),
	  .LC_POWER_ON(lc_pwr_on), .LC_RELEASE_CLK(lc_release_clk), .LC_RELEASE_RST(lc_release_rst), .LC_RELEASE_ISO(lc_release_iso),
	  .REQ_INT(req_int));

always @ *
begin
	// LC is power off, output from LC should be XXXX
	if (lc_pwr_on)
	begin
		tx_addr_f_lc = {(`ADDR_WIDTH){1'bx}};
		tx_data_f_lc = {(`DATA_WIDTH){1'bx}};
		tx_pend_f_lc = 1'bx;
		tx_req_f_lc = 1'bx;
		priority_f_lc = 1'bx;
		rx_ack_f_lc = 1'bx;
		tx_resp_ack_f_lc = 1'bx;
	end
	else
	begin
		tx_addr_f_lc = tx_addr;
		tx_data_f_lc = tx_data;
		tx_pend_f_lc = tx_pend;
		tx_req_f_lc = tx_req;
		priority_f_lc = tx_priority;
		rx_ack_f_lc = rx_ack;
		tx_resp_ack_f_lc = tx_resp_ack;
	end
end

always @ *
begin
	if (lc_pwr_on)
	begin
		rf_dout_f_lc= {(`LC_RF_DATA_WIDTH){1'bx}};
		rf_load_f_lc = {(`LC_RF_DEPTH){1'bx}};
	end
	else
	begin
		rf_dout_f_lc = rf_dout;
		rf_load_f_lc = rf_load;
	end
end

always @ *
begin
	if (lc_pwr_on)
	begin
		mem_req_out_f_lc = 1'bx;
		mem_write_f_lc = 1'bx;
		mem_dout_f_lc = {(`LC_MEM_DATA_WIDTH){1'bx}};
		mem_aout_f_lc = {(`LC_MEM_ADDR_WIDTH-2){1'bx}};
	end
	else
	begin
		mem_req_out_f_lc = mem_req_out;
		mem_write_f_lc = mem_write;
		mem_dout_f_lc = mem_dout;
		mem_aout_f_lc = mem_aout;
	end
end
always @ *
begin
	if (lc_pwr_on)
	begin
		clr_int_f_lc = 1'bx;
	end
	else
	begin
		clr_int_f_lc = clr_int;
	end
end

// always on MEM
mem_ctrl mem0(
	.CLK(CLK),
	.RESETn(RESETn),
	.ADDR(mem_aout_t_mem),
	.DATA_IN(mem_dout_t_mem),
	.MEM_REQ(mem_req_out_t_mem),
	.MEM_WRITE(mem_write_t_mem),
	.DATA_OUT(mem_data_f_mem),
	.MEM_ACK_OUT(mem_ack_f_mem)
);

// always on RF
rf_ctrl #(.RF_DEPTH(RF_DEPTH)) rf0(
	.RESETn(RESETn),
	.DIN(rf_dout_t_rf),
	.LOAD(rf_load_t_rf[RF_DEPTH-1:0]),
	.DOUT(rf_dout_f_rf)
);

// always on sensor roms
sensor_rom #(.ROM_DEPTH(ROM_DEPTH)) r0(
	.DOUT(sensor_dat_f_rom)
);

// always on interrupt command roms
int_action_rom ir0(
	.int_func_id(int_func_id_f_rom),
	.int_payload(int_payload_f_rom)
);


endmodule
