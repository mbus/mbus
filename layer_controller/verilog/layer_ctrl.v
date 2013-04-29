
`include "include/mbus_def.v"

module layer_ctrl(

	input		CLK,
	input		RESETn,

	// Interface with MBus
	output reg	[`ADDR_WIDTH-1:0] TX_ADDR, 
	output reg	[`DATA_WIDTH-1:0] TX_DATA, 
	output reg	TX_PEND, 
	output reg	TX_REQ, 
	input		TX_ACK, 
	output reg	PRIORITY,

	input		[`ADDR_WIDTH-1:0] RX_ADDR, 
	input		[`DATA_WIDTH-1:0] RX_DATA, 
	input		RX_PEND, 
	input		RX_REQ, 
	output reg	RX_ACK, 
	input		RX_BROADCAST,

	input		RX_FAIL,
	input		TX_FAIL, 
	input		TX_SUCC, 
	output reg	TX_RESP_ACK,

	input 		RELEASE_RST_FROM_MBUS,
	// End of interface
	
	// Interface with Registers
	input		[(`LC_RF_DATA_WIDTH*`LC_RF_DEPTH)-1:0] RF_DIN,
	output reg	[`LC_RF_DATA_WIDTH-1:0] RF_DOUT,
	output reg	[`LC_RF_DEPTH-1:0] RF_LOAD,
	// End of interface
	
	// Interface with MEM
	output 		MEM_REQ_OUT,
	output 		MEM_WRITE,
	input		MEM_ACK_IN,
	output reg	[`LC_MEM_DATA_WIDTH-1:0] MEM_DOUT,
	input		[`LC_MEM_DATA_WIDTH-1:0] MEM_DIN,
	output reg	[`LC_MEM_ADDR_WIDTH-1:0] MEM_AOUT,
	// End of interface
	
	// Interrupt
	input		INTERRUPT,
	output reg	CLR_INT,

	input	[`DYNA_WIDTH-1:0] SHORT_ADDR 
);
`include "include/mbus_func.v"

wire	RESETn_local = (RESETn & (~RELEASE_RST_FROM_MBUS));

parameter MAX_DMA_LENGTH = 16;

parameter LC_STATE_IDLE 		= 3'd0;
parameter LC_STATE_RF_READ 		= 3'd1;
parameter LC_STATE_RF_WRITE 	= 3'd2;
parameter LC_STATE_MEM_READ 	= 3'd3;
parameter LC_STATE_MEM_WRITE 	= 3'd4;
parameter LC_STATE_BUS_TX		= 3'd5;
parameter LC_STATE_WAIT_CPL		= 3'd6;
parameter LC_STATE_INT			= 3'd7;

// General registers
reg		[2:0]	lc_state, next_lc_state, lc_return_state, next_lc_return_state;
reg		rx_pend_reg, next_rx_pend_reg;
reg		[2:0]	mem_sub_state, next_mem_sub_state;
reg		[`DATA_WIDTH-1:0] 	rx_dat_buffer, next_rx_dat_buffer;
reg		[MAX_DMA_LENGTH-1:0] dma_counter, next_dma_counter;

// Interrupt register
reg		next_clr_int;

// Mbus interface
reg		[`ADDR_WIDTH-1:0] 	next_tx_addr;
reg		[`DATA_WIDTH-1:0]	next_tx_data;
reg		next_tx_pend;
reg		next_tx_req;
reg		next_priority;
reg		next_rx_ack;
reg		next_tx_resp_ack;

// RF interface
wire	[`LC_RF_DATA_WIDTH-1:0] rf_in_array [0:`LC_RF_DEPTH-1];
genvar unpk_idx; 
generate 
	for (unpk_idx=0; unpk_idx<(`LC_RF_DEPTH); unpk_idx=unpk_idx+1)
	begin: UNPACK
		assign rf_in_array[unpk_idx] = RF_DIN[((`LC_RF_DATA_WIDTH)*(unpk_idx+1)-1):((`LC_RF_DATA_WIDTH)*unpk_idx)]; 
	end
endgenerate
// End of generator
reg		[`LC_RF_DEPTH-1:0] next_rf_load;
wire	[`LC_RF_DEPTH-1:0] rf_load_temp = (1'b1<<(rx_dat_buffer[`DATA_WIDTH-1:`LC_RF_DATA_WIDTH]));
reg		[`LC_RF_DATA_WIDTH-1:0] next_rf_dout;
wire	[`LC_RF_ADDR_WIDTH-1:0] rf_dma_length = rx_dat_buffer[`LC_RF_DATA_WIDTH-1:`LC_RF_DATA_WIDTH-`LC_RF_ADDR_WIDTH];
// Watch out for aliasing, ex: LC_RF_DEPTH = 32 but CPU accessing register 33,
wire	[log2(`LC_RF_DEPTH-1)-1:0] rf_idx_temp = rx_dat_buffer[(`LC_RF_DATA_WIDTH+log2(`LC_RF_DEPTH-1)-1):`LC_RF_DATA_WIDTH];
reg		[log2(`LC_RF_DEPTH-1)-1:0] rf_idx, next_rf_idx;

// Mem interface
reg		mem_write, next_mem_write, mem_read, next_mem_read;
assign	MEM_REQ_OUT = (mem_write | mem_read);
assign	MEM_WRITE = mem_write;
reg		[`LC_MEM_ADDR_WIDTH-1:0] next_mem_aout;
reg		[`LC_MEM_DATA_WIDTH-1:0] next_mem_dout;

wire MEM_ACK_RSTn = (RESETn_local & (~MEM_ACK_IN));
always @ (posedge CLK or negedge MEM_ACK_RSTn)
begin
	if (~MEM_ACK_RSTn)
	begin
		mem_write 	<= 0;
		mem_read 	<= 0;
	end
	else
	begin
		mem_write	<= next_mem_write;
		mem_read 	<= next_mem_read;
	end
end

always @ (posedge CLK or negedge RESETn_local)
begin
	if (~RESETn_local)
	begin
		// General registers
		lc_state <= LC_STATE_IDLE;
		lc_return_state <= LC_STATE_IDLE;
		rx_pend_reg <= 0;
		mem_sub_state <= 0;
		dma_counter <= 0;
		// rx buffers
		rx_dat_buffer <= 0;
		// MBus interface
		TX_ADDR <= 0;
		TX_DATA <= 0;
		TX_REQ <= 0;
		TX_PEND <= 0;
		PRIORITY<= 0;
		RX_ACK	<= 0;
		TX_RESP_ACK <= 0;
		// Register file interface
		RF_LOAD <= 0;
		RF_DOUT <= 0;
		rf_idx <= 0;
		// Memory interface
		MEM_AOUT <= 0;
		MEM_DOUT <= 0;
		// Interrupt interface
		CLR_INT <= 0;
	end
	else
	begin
		// General registers
		lc_state <= next_lc_state;
		lc_return_state <= next_lc_return_state;
		rx_pend_reg <= next_rx_pend_reg;
		mem_sub_state <= next_mem_sub_state;
		dma_counter <= next_dma_counter;
		// rx buffers
		rx_dat_buffer <= next_rx_dat_buffer;
		// MBus interface
		TX_ADDR <= next_tx_addr;
		TX_DATA <= next_tx_data;
		TX_REQ <= next_tx_req;
		TX_PEND <= next_tx_pend;
		PRIORITY<= next_priority;
		RX_ACK	<= next_rx_ack;
		TX_RESP_ACK <= next_tx_resp_ack;
		// Register file interface
		RF_LOAD <= next_rf_load;
		RF_DOUT <= next_rf_dout;
		rf_idx <= next_rf_idx;
		// Memory interface
		MEM_AOUT <= next_mem_aout;
		MEM_DOUT <= next_mem_dout;
		// Interrupt interface
		CLR_INT <= next_clr_int;
	end
end

always @ *
begin
	// General registers
	next_lc_state 	= lc_state;
	next_lc_return_state = lc_return_state;
	next_rx_pend_reg= rx_pend_reg;
	next_mem_sub_state = mem_sub_state;
	next_dma_counter = dma_counter;
	// rx buffers
	next_rx_dat_buffer = rx_dat_buffer;
	// MBus registers
	next_tx_addr 	= TX_ADDR;
	next_tx_data 	= TX_DATA;
	next_tx_pend 	= TX_PEND;
	next_tx_req 	= TX_REQ;
	next_priority 	= PRIORITY;
	next_rx_ack		= RX_ACK;
	next_tx_resp_ack= TX_RESP_ACK;
	// RF registers
	next_rf_load 	= 0;
	next_rf_dout 	= RF_DOUT;
	next_rf_idx		= rf_idx;
	// MEM registers
	next_mem_aout	= MEM_AOUT;
	next_mem_dout	= MEM_DOUT;
	next_mem_write	= mem_write;
	next_mem_read	= mem_read;
	// Interrupt registers
	next_clr_int = CLR_INT;

	// Asynchronized interface
	if ((~(RX_REQ | RX_FAIL)) & RX_ACK)
		next_rx_ack = 0;
	
	if (CLR_INT & (~INTERRUPT))
		next_clr_int = 0;

	if (TX_ACK & TX_REQ)
		next_tx_req = 0;

	if (TX_SUCC | TX_FAIL)
		next_tx_resp_ack = 1;

	if ((~(TX_SUCC | TX_FAIL)) & TX_RESP_ACK)
		next_tx_resp_ack = 0;
	// End of asynchronized interface

	case (lc_state)
		LC_STATE_IDLE:
		begin
			if (INTERRUPT)
			begin
				next_lc_state = LC_STATE_INT;
				next_clr_int = 1;
			end
			else
			begin
				if (RX_REQ | RX_FAIL)
				begin
					next_rx_ack = 1;
				end

				if (RX_REQ & (~RX_ACK))	 // prevent double trigger
				begin
					next_rx_dat_buffer = RX_DATA;
					next_rx_pend_reg = RX_PEND;
					case (RX_ADDR[`FUNC_WIDTH-1:0])
						`LC_CMD_RF_READ: begin next_lc_state = LC_STATE_RF_READ; end
						`LC_CMD_RF_WRITE: begin next_lc_state = LC_STATE_RF_WRITE; end
						`LC_CMD_MEM_READ: begin next_lc_state = LC_STATE_MEM_READ; end
						`LC_CMD_MEM_WRITE: begin next_lc_state = LC_STATE_MEM_WRITE; end
					endcase
				end
				next_mem_sub_state = 0;
			end
		end

		LC_STATE_RF_READ:
		begin
			case (mem_sub_state)
				0:
				begin
					if ((rx_dat_buffer[`DATA_WIDTH-1:`LC_RF_DATA_WIDTH]) < `LC_RF_DEPTH)	// prevent aliasing
					begin 
						next_dma_counter = {{(MAX_DMA_LENGTH-`LC_RF_ADDR_WIDTH){1'b0}}, rf_dma_length};
						next_rf_idx = rf_idx_temp;
						next_mem_sub_state = 1;
					end
					else
						next_lc_state = LC_STATE_IDLE;
				end

				1:
				begin
					next_tx_data = {{(`LC_RF_ADDR_WIDTH){1'b0}}, rf_in_array[rf_idx]};
					next_tx_addr = {{(`ADDR_WIDTH-`FUNC_WIDTH){1'b0}}, `CHANNEL_MEMBER_EVENT};
					next_tx_req = 1;
					next_lc_state = LC_STATE_BUS_TX;
					next_mem_sub_state = 2;
					next_lc_return_state = LC_STATE_RF_READ;
					if ((dma_counter)&&(rf_idx < (`LC_RF_DEPTH-1'b1)))
					begin
						next_tx_pend = 1;
						next_dma_counter = dma_counter - 1'b1;
					end
					else
						next_tx_pend = 0;
				end

				2:
				begin
					next_rf_idx = rf_idx + 1'b1;
					next_mem_sub_state = 1;
				end
			endcase
		end

		LC_STATE_RF_WRITE:
		begin
			case (mem_sub_state)
				0:
				begin
					if ((rx_dat_buffer[`DATA_WIDTH-1:`LC_RF_DATA_WIDTH]) < `LC_RF_DEPTH)
					begin
						next_rf_dout = rx_dat_buffer[`LC_RF_DATA_WIDTH-1:0];
						next_rf_load = rf_load_temp;
						if (rx_pend_reg)
							next_mem_sub_state = 1;
						else
							next_lc_state = LC_STATE_IDLE;
					end
					else
						next_lc_state = LC_STATE_IDLE;
				end

				1:
				begin
					if (RX_REQ & (~RX_ACK))
					begin
						next_rx_ack = 1;
						next_mem_sub_state = 0;
						next_rx_dat_buffer = RX_DATA;
						next_rx_pend_reg = RX_PEND;
					end
					else if ((RX_FAIL) & (~RX_ACK))
					begin
						next_rx_ack = 1;
						next_lc_state = LC_STATE_IDLE;
					end
				end
			endcase

		end

		LC_STATE_MEM_READ:
		begin
			case (mem_sub_state)
				0:
				begin
					if ((rx_dat_buffer[`LC_MEM_ADDR_WIDTH-1:0] < `LC_MEM_DEPTH))
					begin
						next_mem_aout = rx_dat_buffer[`LC_MEM_ADDR_WIDTH-1:0];
						next_dma_counter = 0;
						if (rx_pend_reg)	// DMA access
							next_mem_sub_state = 1;
						else
							next_mem_sub_state = 2;
					end
					else // Error handling
						next_lc_state = LC_STATE_IDLE;
				end

				1:
				begin
					if (RX_REQ & (~RX_ACK))
					begin
						next_rx_ack = 1;
						next_rx_pend_reg = RX_PEND;
						next_mem_sub_state = 2;
						next_dma_counter = RX_DATA[MAX_DMA_LENGTH-1:0];	
					end
					else if (RX_FAIL & (~RX_ACK))
					begin
						next_rx_ack = 1;
						next_lc_state = LC_STATE_IDLE;
					end
				end

				2:
				begin
					if (~MEM_REQ_OUT)
					begin
						next_mem_read = 1;
						next_mem_sub_state = 3;
					end
				end

				3:
				begin
					// Read complete
					if (MEM_ACK_IN)
					begin
						next_tx_req = 1;
						next_tx_addr = {{(`ADDR_WIDTH-`FUNC_WIDTH){1'b0}}, `CHANNEL_MEMBER_EVENT};
						next_tx_data[`LC_MEM_DATA_WIDTH-1:0] = MEM_DIN;
						next_lc_state = LC_STATE_BUS_TX;
						next_lc_return_state = LC_STATE_MEM_READ;
						next_mem_sub_state = 4;
						if ((dma_counter)&&(MEM_AOUT < (`LC_MEM_DEPTH-1'b1)))
						begin
							next_tx_pend = 1;
							next_dma_counter = dma_counter - 1'b1;
						end
						else
							next_tx_pend = 0;
					end
				end

				4:	// increment address
				begin
					next_mem_aout = MEM_AOUT + 1'b1;
					next_mem_sub_state = 2;
				end
			endcase
		end

		LC_STATE_MEM_WRITE:
		begin
			case (mem_sub_state)
				0:
				begin
					if ((rx_pend_reg)&&(rx_dat_buffer[`LC_MEM_ADDR_WIDTH-1:0] < `LC_MEM_DEPTH))
					begin
						next_mem_aout = rx_dat_buffer[`LC_MEM_ADDR_WIDTH-1:0];
						next_mem_sub_state = 1;
					end
					else // Error handling
						next_lc_state = LC_STATE_IDLE;
				end

				1:
				begin
					if (RX_REQ & (~RX_ACK))
					begin
						next_rx_ack = 1;
						next_mem_sub_state = 2;
						next_mem_dout = RX_DATA[`LC_MEM_DATA_WIDTH-1:0];
						next_rx_pend_reg = RX_PEND;
					end
					else if (RX_FAIL & (~RX_ACK))
						next_lc_state = LC_STATE_IDLE;
				end

				2:
				begin
					if (~MEM_REQ_OUT)
					begin
						next_mem_write = 1;
						next_mem_sub_state = 3;
					end
				end

				3:
				begin
					// write complete
					if (MEM_ACK_IN)
					begin
						if ((rx_pend_reg)&&(MEM_AOUT<(`LC_MEM_DEPTH-1'b1)))
						begin
							next_mem_aout = MEM_AOUT + 1'b1;
							next_mem_sub_state = 1;
						end
						else
							next_lc_state = LC_STATE_IDLE;
					end
				end
			endcase
		end

		LC_STATE_BUS_TX:
		begin // cannot modify mem_sub_state here
			if (TX_ACK)
			begin
				if (TX_PEND)
					next_lc_state = lc_return_state;
				else
					next_lc_state = LC_STATE_WAIT_CPL;
			end
		end

		LC_STATE_WAIT_CPL:
		begin
			if (TX_SUCC | TX_FAIL)
				next_lc_state = LC_STATE_IDLE;
		end

		LC_STATE_INT:
		begin
			next_tx_data = {4'h0, SHORT_ADDR, 24'hff_ffff};
			next_tx_addr = {{(`ADDR_WIDTH-`FUNC_WIDTH){1'b0}}, `CHANNEL_MEMBER_EVENT};
			next_tx_req = 1;
			next_tx_pend = 0;
			next_lc_state = LC_STATE_BUS_TX;
		end
	endcase
end


endmodule
