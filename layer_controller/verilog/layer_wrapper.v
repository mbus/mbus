

`include "include/mbus_def.v"

module layer_wrapper(

	input 	CLK,
	input 	RESETn,

	// Interface with MBus
	output 	[`ADDR_WIDTH-1:0] TX_ADDR, 
	output 	[`DATA_WIDTH-1:0] TX_DATA, 
	output 	TX_PEND, 
	output 	TX_REQ, 
	input	TX_ACK, 
	output 	PRIORITY,

	input	[`ADDR_WIDTH-1:0] RX_ADDR, 
	input	[`DATA_WIDTH-1:0] RX_DATA, 
	input	RX_PEND, 
	input	RX_REQ, 
	output 	RX_ACK, 
	input	RX_BROADCAST,

	input	RX_FAIL,
	input	TX_FAIL, 
	input	TX_SUCC, 
	output 	TX_RESP_ACK,

	input 	RELEASE_RST_FROM_MBUS,

	input	INTERRUPT,
	output	CLR_INT,

	input	[`DYNA_WIDTH-1:0] SHORT_ADDR 
); 

parameter RF_DEPTH = 64;
parameter ROM_DEPTH = 64;

wire	mem_req_out, mem_write, mem_ack_f_mem;
wire	[`LC_MEM_ADDR_WIDTH-3:0] mem_aout;
wire	[`LC_MEM_DATA_WIDTH-1:0] mem_dat_f_lc, mem_dat_f_mem;

wire	[`LC_RF_DATA_WIDTH-1:0] rf_dat_f_lc;
wire	[`LC_RF_DEPTH-1:0] rf_load_f_lc;
wire	[`LC_RF_DATA_WIDTH*RF_DEPTH-1:0] rf_dat_f_rf;

wire	[`LC_RF_DATA_WIDTH*ROM_DEPTH-1:0] sensor_dat_f_rom;


layer_ctrl lc0(
	.CLK(CLK),
	.RESETn(RESETn),
	// Interface with MBus
	.TX_ADDR(TX_ADDR), 
	.TX_DATA(TX_DATA), 
	.TX_PEND(TX_PEND), 
	.TX_REQ(TX_REQ), 
	.TX_ACK(TX_ACK), 
	.PRIORITY(PRIORITY),
	.RX_ADDR(RX_ADDR), 
	.RX_DATA(RX_DATA), 
	.RX_PEND(RX_PEND), 
	.RX_REQ(RX_REQ), 
	.RX_ACK(RX_ACK), 
	.RX_BROADCAST(RX_BROADCAST),
	.RX_FAIL(RX_FAIL),
	.TX_FAIL(TX_FAIL), 
	.TX_SUCC(TX_SUCC), 
	.TX_RESP_ACK(TX_RESP_ACK),
	.RELEASE_RST_FROM_MBUS(RELEASE_RST_FROM_MBUS),
	// Interface with Registers
	.RF_DIN({sensor_dat_f_rom, rf_dat_f_rf}),
	.RF_DOUT(rf_dat_f_lc),
	.RF_LOAD(rf_load_f_lc),
	// Interface with MEM
	.MEM_REQ_OUT(mem_req_out),
	.MEM_WRITE(mem_write),
	.MEM_ACK_IN(mem_ack_f_mem),
	.MEM_DOUT(mem_dat_f_lc),
	.MEM_DIN(mem_dat_f_mem),
	.MEM_AOUT(mem_aout),
	// Interrupt
	.INTERRUPT(INTERRUPT),
	.CLR_INT(CLR_INT),
	.SHORT_ADDR(SHORT_ADDR)
);

mem_ctrl mem0(
	.CLK(CLK),
	.RESETn(RESETn),
	.ADDR(mem_aout),
	.DATA_IN(mem_dat_f_lc),
	.MEM_REQ(mem_req_out),
	.MEM_WRITE(mem_write),
	.DATA_OUT(mem_dat_f_mem),
	.MEM_ACK_OUT(mem_ack_f_mem)
);

rf_ctrl #(.RF_DEPTH(RF_DEPTH)) rf0(
	.RESETn(RESETn),
	.DIN(rf_dat_f_lc),
	.LOAD(rf_load_f_lc[RF_DEPTH-1:0]),
	.DOUT(rf_dat_f_rf)
);

sensor_rom #(.ROM_DEPTH(ROM_DEPTH)) r0(
	.DOUT(sensor_dat_f_rom)
);

endmodule
