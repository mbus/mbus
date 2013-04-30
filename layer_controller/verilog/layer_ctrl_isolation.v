
`include "include/mbus_def.v"

module layer_ctrl_isolation(
	input 	LC_ISOLATION,

	// Interface with MBus
	input	[`ADDR_WIDTH-1:0] 	TX_ADDR_FROM_LC,
	input	[`DATA_WIDTH-1:0] 	TX_DATA_FROM_LC,
	input	TX_PEND_FROM_LC,
	input	TX_REQ_FROM_LC,
	input	PRIORITY_FROM_LC,
	input	RX_ACK_FROM_LC,
	input	TX_RESP_ACK_FROM_LC,

	// Interface with Registers
	input	[`LC_RF_DATA_WIDTH-1:0] RF_DATA_FROM_LC,
	input	[`LC_RF_DEPTH-1:0] RF_LOAD_FROM_LC,

	// Interface with MEM
	input	MEM_REQ_OUT_FROM_LC,
	input	MEM_WRITE_FROM_LC,
	input	[`LC_MEM_DATA_WIDTH-1:0] MEM_DOUT_FROM_LC,
	input	[`LC_MEM_ADDR_WIDTH-3:0] MEM_AOUT_FROM_LC,

	// Interrupt
	input	[`LC_INT_DEPTH-1:0] CLR_INT_FROM_LC,

	// Interface with MBus
	output	reg [`ADDR_WIDTH-1:0] 	TX_ADDR_TO_MBUS,
	output	reg [`DATA_WIDTH-1:0] 	TX_DATA_TO_MBUS,
	output	reg TX_PEND_TO_MBUS,
	output	reg TX_REQ_TO_MBUS,
	output	reg PRIORITY_TO_MBUS,
	output	reg RX_ACK_TO_MBUS,
	output	reg TX_RESP_ACK_TO_MBUS,

	// Interface with Registers
	output	reg [`LC_RF_DATA_WIDTH-1:0] RF_DATA_TO_RF,
	output	reg [`LC_RF_DEPTH-1:0] RF_LOAD_TO_RF,

	// Interface with MEM
	output	reg MEM_REQ_OUT_TO_MEM,
	output	reg MEM_WRITE_TO_MEM,
	output	reg [`LC_MEM_DATA_WIDTH-1:0] MEM_DOUT_TO_MEM,
	output	reg [`LC_MEM_ADDR_WIDTH-3:0] MEM_AOUT_TO_MEM,

	// Interrupt
	output	reg [`LC_INT_DEPTH-1:0] CLR_INT_EXTERNAL
);

always @ *
begin
	if (LC_ISOLATION==`IO_HOLD)
	begin
		TX_ADDR_TO_MBUS		<= 0;
		TX_DATA_TO_MBUS		<= 0;
		TX_PEND_TO_MBUS		<= 0;
		TX_REQ_TO_MBUS		<= 0;
		PRIORITY_TO_MBUS	<= 0;
		RX_ACK_TO_MBUS		<= 0;
		TX_RESP_ACK_TO_MBUS <= 0;
	end
	else
	begin
		TX_ADDR_TO_MBUS		<= TX_ADDR_FROM_LC;
		TX_DATA_TO_MBUS		<= TX_DATA_FROM_LC;
		TX_PEND_TO_MBUS		<= TX_PEND_FROM_LC;
		TX_REQ_TO_MBUS		<= TX_REQ_FROM_LC;
		PRIORITY_TO_MBUS	<= PRIORITY_FROM_LC;
		RX_ACK_TO_MBUS		<= RX_ACK_FROM_LC;
		TX_RESP_ACK_TO_MBUS <= TX_RESP_ACK_FROM_LC;
	end
end

always @ *
begin
	if (LC_ISOLATION==`IO_HOLD)
	begin
		RF_DATA_TO_RF <= 0;
		RF_LOAD_TO_RF <= 0;
	end
	else
	begin
		RF_DATA_TO_RF <= RF_DATA_FROM_LC;
		RF_LOAD_TO_RF <= RF_LOAD_FROM_LC;
	end
end

always @ *
begin
	if (LC_ISOLATION==`IO_HOLD)
	begin
		MEM_REQ_OUT_TO_MEM 	<= 0;
		MEM_WRITE_TO_MEM 	<= 0;
		MEM_DOUT_TO_MEM 	<= 0;
		MEM_AOUT_TO_MEM 	<= 0;
	end
	else
	begin
		MEM_REQ_OUT_TO_MEM 	<= MEM_REQ_OUT_FROM_LC;
		MEM_WRITE_TO_MEM 	<= MEM_WRITE_FROM_LC;
		MEM_DOUT_TO_MEM 	<= MEM_DOUT_FROM_LC;
		MEM_AOUT_TO_MEM 	<= MEM_AOUT_FROM_LC;
	end
end

always @ *
begin
	if (LC_ISOLATION==`IO_HOLD)
	begin
		CLR_INT_EXTERNAL <= 0;
	end
	else
	begin
		CLR_INT_EXTERNAL <= CLR_INT_FROM_LC;
	end
end
endmodule

