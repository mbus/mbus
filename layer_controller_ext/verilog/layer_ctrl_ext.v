/* Verilog implementation of Generic Layer Controller
 *
 * This layer controller is a interface between MBus and layer peripherials.
 * It has 4 major IO banks
 * 1. IOs with MBus
 * 2. IOs with Register Files (RF)
 * 3. IOs with Memory controller
 * 4. IOs with interrupt configuration
 *
 * Layer controller configuration:
 * Register Files
 * 1. LC_RF_DATA_WIDTH; 1 ~ 24 (24 default)
 *
 * Memory
 * 1. LC_MEM_ADDR_WIDTH; 1~32 (32 default)
 * 2. LC_MEM_DATA_WIDTH; 1~32 (32 default)
 *
 * Interrupt
 * 1. LC_INT_DEPTH;
 *
 * In normal application, users need to configure LC_RF_DEPTH, LC_MEM_DEPTH,
 * LC_INT_DEPTH for their application. Changing the width causes bits waste
 * on the MBus; thus, it's not recommended.
 *
 * IMPORTANT:
 * 1. The memory interface is WORD address. Thus, the width of MEM_ADDR is
 * 2-bit less than MEM_RD_DATA or MEM_WR_DATA.
 * e.g. 0x00000000 and 0x00000001 address two different WORD in memory.
 * If a user has byte address memory controller, remember to pad two 0s at the
 * LSB in layer_wrapper.v
 *
 * 2. Interrupt Commands and Functional ID only work with RF_READ or MEM_READ
 * commands, any other command will be rejected.
 *
 * 3. Unused IO, Don't be panic if synthesis tool reports Warning messages
 *   a) RX_ADDR[31:4] (default 32-bit width)
 *   b) TX_ADDR[31:8] (default 32-bit width)
 *   c) TX_PRIORITY
 *
 * 4. For more information, please refer to layer controller document
 *
 * Error Handling:
 * The layer controller supports MEM/RF Error handling. If users accenditally
 * read or write to a memory/RF location which is not exist. The read
 * operation will automatically stops. If users initiate a DMA write which
 * beyond the memory location, the layer controller will try to interrupt the
 * BMus transaction by holding the RX_REQ low (rx overflow fault) if possible.
 * However, user should be aware of the memory/RF depth at any time.
 * 
 *
 * Last modified date: 10/19 '14
 * Last modified by: Ye-sheng Kuo <samkuo@umich.edu>
 *
 * Update log:
 *
 * 10/19 '14
 * Fixed MEM_READ and RF_READ, Added interrupt support for wakeup only and RF_WRITE
 * Note: RF_READ and RF_WRITE don't wrap around, if address fall outside the range would
 *		 be treated as an invalid command.
 *
 * 10/15 '14
 * Start working on generation 2
 *
 * 8/7 '14
 * Fix priority of TX_FAIL. If TX_FAIL, fsm should go to IDLE state.
 * Add INT_VECTOR double latch
 * Clean up the interface
 *
 * 6/9 '13
 * Fix non-24 bit RF
 *
 * 5/22 '13
 * Change define to parameter
 *
 * 5/17 '13
 * Change memory interface, MEM_ACK_IN is no longer asynchronously reset MEM_REQ_OUT
 *
 * 5/6 '13
 * first added
  * */
`include "include/mbus_def.v"

module layer_ctrl #(
	parameter LC_RF_DATA_WIDTH = 24,	// don't change this, stream will fail
	parameter LC_RF_ADDR_WIDTH = 8,		// don't change this value
	parameter LC_RF_DEPTH = 128,		// 1 ~ 2^8

	parameter LC_MEM_ADDR_WIDTH = 32,	// should ALWAYS less than DATA_WIDTH
	parameter LC_MEM_DATA_WIDTH = 32,	// should ALWAYS less than DATA_WIDTH

	parameter LC_INT_DEPTH = 8,
	parameter LC_MEM_STREAM_CHANNELS = 4,
	parameter LC_MEM_STREAM_SYSREG_OFFSET = 16
)
(
	input		CLK,
	input		RESETn,

	// Interface with MBus
	output reg	[`ADDR_WIDTH-1:0] TX_ADDR,
	output reg	[`DATA_WIDTH-1:0] TX_DATA, 
	output reg	TX_PEND,
	output reg	TX_REQ,
	input		TX_ACK, 
	output reg	TX_PRIORITY,

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
	input		[(LC_RF_DATA_WIDTH*LC_RF_DEPTH)-1:0] REG_RD_DATA,
	output reg	[LC_RF_DATA_WIDTH-1:0] REG_WR_DATA,
	output reg	[LC_RF_DEPTH-1:0] REG_WR_EN,
	// End of interface
	
	// Interface with MEM
	output 		MEM_REQ_OUT,
	output 		MEM_WRITE,
	input		MEM_ACK_IN,
	output reg	MEM_PEND,
	output reg	[LC_MEM_DATA_WIDTH-1:0] MEM_WR_DATA,
	input		[LC_MEM_DATA_WIDTH-1:0] MEM_RD_DATA,
	output reg	[LC_MEM_ADDR_WIDTH-3:0] MEM_ADDR,
	// End of interface
	
	// Interrupt
	input		[LC_INT_DEPTH-1:0] INT_VECTOR,
	output reg	[LC_INT_DEPTH-1:0] CLR_INT,
	input		[`FUNC_WIDTH*LC_INT_DEPTH-1:0] INT_FU_ID,
	input		[(`DATA_WIDTH*3)*LC_INT_DEPTH-1:0] INT_CMD,
	input		[2*LC_INT_DEPTH-1:0] INT_CMD_LEN
);


wire		[LC_INT_DEPTH-1:0] INT_VECTOR_clocked;

input_stabilizer_layer_ctrl input_stabilizer_layer_ctrl0[LC_INT_DEPTH-1:0]  (
		.clk(CLK),
		.reset(~RESETn),
		.a(INT_VECTOR),
		.a_clocked(INT_VECTOR_clocked)
);

`include "include/mbus_func.v"

wire	RESETn_local = (RESETn & (~RELEASE_RST_FROM_MBUS));

parameter MAX_DMA_LENGTH = 20; // cannot greater than `DATA_WIDTH - `SHORT_ADDR_WIDTH

localparam LC_STATE_IDLE		= 4'd0;
localparam LC_STATE_RF_READ 	= 4'd1;
localparam LC_STATE_RF_WRITE 	= 4'd2;
localparam LC_STATE_MEM_READ 	= 4'd3;
localparam LC_STATE_MEM_WRITE 	= 4'd4;
localparam LC_STATE_BUS_TX		= 4'd5;
localparam LC_STATE_WAIT_CPL	= 4'd6;
localparam LC_STATE_ERROR		= 4'd7;
localparam LC_STATE_INT_ARBI	= 4'd8;
localparam LC_STATE_INT_HANDLED	= 4'd9;
localparam LC_STATE_CLR_INT		= 4'd10;
localparam LC_STATE_STREAM_ALERT= 4'd11;

// CANNOT assign anything to 3'd0 (in use)
// MEM Read sub state definition
localparam MEM_READ_WAIT_START_ADDRESS	= 3'd1;
localparam MEM_READ_WAIT_DEST_LOCATION	= 3'd2;
localparam MEM_READ_TX_DEST_LOC			= 3'd3;
localparam MEM_READ_ACCESS_READ			= 3'd4;
localparam MEM_READ_ACCESS_WAIT			= 3'd5;

// RF Write MEM sub state definition
localparam RF_WRITE_LOAD			= 3'd1;
localparam RF_WRITE_STREAM_COUNTER	= 3'd2;
localparam RF_WRITE_STREAM_LOAD		= 3'd3;
localparam RF_WRITE_CHECK			= 3'd4;
localparam RF_WRITE_RECEIVE			= 3'd5;
localparam RF_WRITE_INT_COPY		= 3'd6

// Stream MEM Write sub state definition
localparam STREAM_MEM_WRITE			= 3'd1;
localparam STREAM_MEM_WAIT			= 3'd2;
localparam STREAM_COUNTER_DEC		= 3'd3;
localparam STREAM_RF_WRITE			= 3'd4;
localparam STREAM_RECEIVE			= 3'd5;

// Double latching registers
reg		TX_ACK_DL1, TX_ACK_DL2;
reg		RX_REQ_DL1, RX_REQ_DL2;

// General registers
reg		[3:0]	lc_state, next_lc_state, lc_return_state, next_lc_return_state;
reg		rx_pend_reg, next_rx_pend_reg;
reg		[2:0]	mem_sub_state, next_mem_sub_state;
reg		[MAX_DMA_LENGTH-1:0] dma_counter, next_dma_counter;

// rx buffers
reg		[`DATA_WIDTH-1:0] 	rx_dat_buffer, next_rx_dat_buffer;

// Mbus interface
reg		[`ADDR_WIDTH-1:0] 	next_tx_addr;
reg		[`DATA_WIDTH-1:0]	next_tx_data;
reg		next_tx_pend;
reg		next_tx_req;
reg		next_priority;
reg		next_rx_ack;
reg		next_tx_resp_ack;

// RF interface
wire	[LC_RF_DATA_WIDTH-1:0] rf_in_array [0:LC_RF_DEPTH-1];
genvar unpk_idx; 
generate 
	for (unpk_idx=0; unpk_idx<(LC_RF_DEPTH); unpk_idx=unpk_idx+1)
	begin: UNPACK
		assign rf_in_array[unpk_idx] = REG_RD_DATA[((LC_RF_DATA_WIDTH)*(unpk_idx+1)-1):((LC_RF_DATA_WIDTH)*unpk_idx)]; 
	end
endgenerate
reg		[LC_RF_DEPTH-1:0] next_rf_load;
wire	[LC_RF_DEPTH-1:0] rf_load_temp = (1'b1<<(rx_dat_buffer[`DATA_WIDTH-1:`DATA_WIDTH-LC_RF_ADDR_WIDTH]));
reg		[LC_RF_DATA_WIDTH-1:0] next_rf_dout;
wire	[LC_RF_ADDR_WIDTH-1:0] rf_dma_length = rx_dat_buffer[23:16];
wire	[log2(LC_RF_DEPTH-1)-1:0] rf_idx_temp = rx_dat_buffer[(24+log2(LC_RF_DEPTH-1)-1):24];
wire	[`SHORT_ADDR_WIDTH-1:0] rf_relay_addr = rx_dat_buffer[15:15-`SHORT_ADDR_WIDTH+1];
reg		[log2(LC_RF_DEPTH-1)-1:0] rf_idx, next_rf_idx;

// Mem interface
reg		mem_write, next_mem_write, mem_read, next_mem_read;
assign	MEM_REQ_OUT = (mem_write | mem_read);
assign	MEM_WRITE = mem_write;
reg		[LC_MEM_ADDR_WIDTH-3:0] next_mem_aout;
reg		[LC_MEM_DATA_WIDTH-1:0] next_mem_dout;
reg		next_mem_pend;

// Interrupt register
reg		[LC_INT_DEPTH-1:0] next_clr_int, int_vector_copied, next_int_vector_copied;
reg		[log2(LC_INT_DEPTH-1)-1:0] int_idx, next_int_idx;
reg		next_layer_interrupted, layer_interrupted;
wire	[`FUNC_WIDTH-1:0] interrupt_functional_id [0:LC_INT_DEPTH-1];
wire	[(`DATA_WIDTH*3)-1:0] interrupt_payload [0:LC_INT_DEPTH-1];
wire	[1:0] interrupt_command_length [0:LC_INT_DEPTH-1];
reg		[1:0] int_cmd_cnt, next_int_cmd_cnt;
generate
	for (unpk_idx=0; unpk_idx<(LC_INT_DEPTH); unpk_idx=unpk_idx+1)
	begin: UNPACK_INT
		assign interrupt_functional_id[unpk_idx] = INT_FU_ID[((`FUNC_WIDTH)*(unpk_idx+1)-1):((`FUNC_WIDTH)*unpk_idx)]; 
		assign interrupt_payload[unpk_idx] = INT_CMD[((`DATA_WIDTH*3)*(unpk_idx+1)-1):((`DATA_WIDTH*3)*unpk_idx)]; 
		assign interrupt_command_length[unpk_idx] = INT_CMD_LEN[(2*(unpk_idx+1)-1):(2*unpk_idx)];
	end
endgenerate

// Streaming registers
wire	[LC_RF_DATA_WIDTH-1:0] stream_reg0 [0:LC_MEM_STREAM_CHANNELS-1];
wire	[LC_RF_DATA_WIDTH-1:0] stream_reg1 [0:LC_MEM_STREAM_CHANNELS-1];
wire	[LC_RF_DATA_WIDTH-1:0] stream_reg2 [0:LC_MEM_STREAM_CHANNELS-1];
wire	[LC_RF_DATA_WIDTH-1:0] stream_reg3 [0:LC_MEM_STREAM_CHANNELS-1];
wire	[`FUNC_WIDTH-3:0] STREAM_CH = RX_ADDR[`FUNC_WIDTH-3:0];
reg		[`FUNC_WIDTH-3:0] stream_channel, next_stream_channel;
reg		stream_double_bf_alert, next_stream_double_bf_alert;
reg		stream_overflow_alert, next_stream_overflow_alert;
wire	stream_remaining	= (stream_reg3[stream_channel][19:0] > 0)? 1'b1 : 1'b0;
wire	stream_enable		= stream_reg2[stream_channel][LC_RF_DATA_WIDTH-1];
wire	stream_wrapping		= stream_reg2[stream_channel[LC_RF_DATA_WIDTH-2];
wire	stream_double_bf	= stream_reg2[stream_channel][LC_RF_DATA_WIDTH-3];
wire	[7:0] stream_alert_address = stream_reg0[stream_channel][LC_RF_DATA_WIDTH-1:LC_RF_DATA_WIDTH-8];
wire	[LC_MEM_ADDR_WIDTH-3:0] stream_write_buffer = {stream_reg1[stream_channel][15:0], stream_reg0[stream_channel][15:2]};
wire	stream_enable_temp = ((rx_dat_buffer[LC_RF_DATA_WIDTH-1])==1'b1)? 1'b1: 1'b0;
wire	[LC_MEM_STREAM_CHANNELS-1:0] channel_enable_set;

generate
	for (unpk_idx=0; unpk_idx<(LC_MEM_STREAM_CHANNELS); unpk_idx=unpk_idx+1)
	begin: UNPACK_STREAM
		assign stream_reg0[unpk_idx] = rf_in_array[LC_RF_DEPTH-LC_MEM_STREAM_SYSREG_OFFSET-1-(4*unpk_idx)-3];	//8, 14, 2
		assign stream_reg1[unpk_idx] = rf_in_array[LC_RF_DEPTH-LC_MEM_STREAM_SYSREG_OFFSET-1-(4*unpk_idx)-2];	//8, 16
		assign stream_reg2[unpk_idx] = rf_in_array[LC_RF_DEPTH-LC_MEM_STREAM_SYSREG_OFFSET-1-(4*unpk_idx)-1];	//4, 20 (Length)
		assign stream_reg3[unpk_idx] = rf_in_array[LC_RF_DEPTH-LC_MEM_STREAM_SYSREG_OFFSET-1-(4*unpk_idx)];		//4, 20 (Count)
		assign channel_enable_set[unpk_idx] = (rx_dat_buffer[`DATA_WIDTH-1:`DATA_WIDTH-LC_RF_ADDR_WIDTH]==(LC_RF_DEPTH-LC_MEM_STREAM_SYSREG_OFFSET-1-(4*unpk_idx)-1))? stream_enable_temp : 1'b0;
	end
endgenerate

// System registers
wire	[LC_RF_DATA_WIDTH-1:0] sys_reg_action	= rf_in_array[LC_RF_DEPTH-1];
wire	[LC_RF_DATA_WIDTH-1:0] sys_reg_alert	= rf_in_array[LC_RF_DEPTH-2];
wire	[LC_RF_DATA_WIDTH-1:0] sys_reg_bulk_mem = rf_in_array[LC_RF_DEPTH-LC_MEM_STREAM_SYSREG_OFFSET+2];
wire	bulk_enable = sys_reg_bulk_mem[LC_RF_DATA_WIDTH-1];
wire	bulk_ctrl_active = sys_reg_bulk_mem[LC_RF_DATA_WIDTH-2];
wire	[19:0] bulk_max_length = sys_reg_bulk_mem[19:0];

always @ (posedge CLK or negedge RESETn_local)
begin
	if (~RESETn_local)
	begin
		TX_ACK_DL1 <= 0;
		TX_ACK_DL2 <= 0;
		RX_REQ_DL1 <= 0;
		RX_REQ_DL2 <= 0;
	end
	else
	begin
		TX_ACK_DL1 <= TX_ACK;
		TX_ACK_DL2 <= TX_ACK_DL1;
		RX_REQ_DL1 <= RX_REQ;
		RX_REQ_DL2 <= RX_REQ_DL1;
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
		TX_PRIORITY<= 0;
		RX_ACK	<= 0;
		TX_RESP_ACK <= 0;
		// Register file interface
		REG_WR_EN <= 0;
		REG_WR_DATA <= 0;
		rf_idx <= 0;
		// Memory interface
		mem_write 	<= 0;
		mem_read 	<= 0;
		MEM_ADDR <= 0;
		MEM_WR_DATA <= 0;
		MEM_PEND <= 1'b0;
		// Interrupt interface
		CLR_INT <= 0;
		int_idx <= 0;
		int_vector_copied <= 0;
		layer_interrupted <= 0;
		int_cmd_cnt <= 0;
		// Stream registers
		stream_channel <= 0;
		stream_double_bf_alert <= 1'b0;
		stream_overflow_alert <= 1'b0;
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
		TX_PRIORITY <= next_priority;
		RX_ACK	<= next_rx_ack;
		TX_RESP_ACK <= next_tx_resp_ack;
		// Register file interface
		REG_WR_EN <= next_rf_load;
		REG_WR_DATA <= next_rf_dout;
		rf_idx <= next_rf_idx;
		// Memory interface
		mem_write	<= next_mem_write;
		mem_read 	<= next_mem_read;
		MEM_ADDR <= next_mem_aout;
		MEM_WR_DATA <= next_mem_dout;
		MEM_PEND <= next_mem_pend;
		// Interrupt interface
		CLR_INT <= next_clr_int;
		int_idx <= next_int_idx;
		int_vector_copied <= next_int_vector_copied;
		layer_interrupted <= next_layer_interrupted;
		int_cmd_cnt <= next_int_cmd_cnt;
		// Stream registers
		stream_channel <= next_stream_channel;
		stream_double_bf_alert <= next_stream_double_bf_alert;
		stream_overflow_alert <= next_stream_overflow_alert;
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
	next_priority 	= TX_PRIORITY;
	next_rx_ack		= RX_ACK;
	next_tx_resp_ack= TX_RESP_ACK;
	// RF registers
	next_rf_load 	= 0;
	next_rf_dout 	= REG_WR_DATA;
	next_rf_idx		= rf_idx;
	// MEM registers
	next_mem_aout	= MEM_ADDR;
	next_mem_dout	= MEM_WR_DATA;
	next_mem_write	= mem_write;
	next_mem_read	= mem_read;
	next_mem_pend	= MEM_PEND;
	// Interrupt registers
	next_clr_int = CLR_INT;
	next_int_idx = int_idx;
	next_int_vector_copied = int_vector_copied;
	next_layer_interrupted = layer_interrupted;
	next_int_cmd_cnt = int_cmd_cnt;
	// Stream registers
	next_stream_channel = stream_channel;
	next_stream_double_bf_alert = stream_double_bf_alert;
	next_stream_overflow_alert = stream_overflow_alert;

	// Asynchronized interface
	if ((~(RX_REQ_DL2 | RX_FAIL)) & RX_ACK)
		next_rx_ack = 0;
	
	if (CLR_INT & (~INT_VECTOR_clocked))
		next_clr_int = 0;

	if (TX_ACK_DL2 & TX_REQ)
		next_tx_req = 0;

	if (TX_SUCC | TX_FAIL)
		next_tx_resp_ack = 1;

	if ((~(TX_SUCC | TX_FAIL)) & TX_RESP_ACK)
		next_tx_resp_ack = 0;
	
	if (MEM_ACK_IN & MEM_REQ_OUT)
	begin
		next_mem_read = 0;
		next_mem_write = 0;
	end
	// End of asynchronized interface

	case (lc_state)
		LC_STATE_IDLE:
		begin
			next_mem_sub_state = 0;
			next_layer_interrupted = 0;
			next_mem_pend = 0;
			next_tx_pend = 0;
			if (stream_overflow_alert | stream_double_bf_alert)		// Check Alert first
			begin
				next_lc_state = LC_STATE_STREAM_ALERT;
			end
			else if ((INT_VECTOR_clocked>0) && (CLR_INT==0))		// Then interrupt
			begin
				next_int_vector_copied = INT_VECTOR_clocked;
				next_lc_state = LC_STATE_INT_ARBI;
				next_int_idx = 0;
			end
			else
			begin
				if (RX_REQ_DL2 | RX_FAIL)							// Receive last
					next_rx_ack = 1;

				if (RX_REQ_DL2 & (~RX_ACK))	 // prevent double trigger
				begin
					next_rx_dat_buffer = RX_DATA;
					next_rx_pend_reg = RX_PEND;
					case (RX_ADDR[`FUNC_WIDTH-1:0])
						`LC_CMD_RF_READ: begin next_lc_state = LC_STATE_RF_READ; end
						`LC_CMD_RF_WRITE: begin next_lc_state = LC_STATE_RF_WRITE; end
						`LC_CMD_MEM_READ: begin next_lc_state = LC_STATE_MEM_READ; end
						`LC_CMD_MEM_WRITE: begin next_lc_state = LC_STATE_MEM_WRITE; end
						default: 
						begin 
							if ((RX_ADDR[`FUNC_WIDTH-1:FUNC_WIDTH-2]==`LC_CMD_MEM_STREAM) && (STREAM_CH < LC_MEM_STREAM_CHANNELS))
							begin
								next_stream_channel = STREAM_CH;
								next_lc_state = LC_STATE_STREAM_WRITE;
							end
							else if (RX_PEND)  // Invalid message
								next_lc_state = LC_STATE_ERROR; 
						end	
					endcase
				end
			end
		end

		LC_STATE_RF_READ:
		begin
			case (mem_sub_state)
				0:
				begin
					if (~rx_pend_reg)
					begin
						next_dma_counter = {{(MAX_DMA_LENGTH-LC_RF_ADDR_WIDTH){1'b0}}, rf_dma_length};
						next_rf_idx = rf_idx_temp;
						next_mem_sub_state = 1;
						next_tx_addr = {{(`ADDR_WIDTH-`SHORT_ADDR_WIDTH){1'b0}}, rf_relay_addr};
					end
					else	// invalid message
					begin 
						next_lc_state = LC_STATE_ERROR;
						next_mem_sub_state = 0;
					end
				end

				1:
				begin
					if (~TX_REQ)
					begin
						// Warning!! non-32 bit DATA_WIDTH and non-24 bit RF_WIDTH may fail
						next_tx_data = (((rx_dat_buffer[(`DATA_WIDTH-24-1):0] + (rf_idx-rf_idx_temp))<<24) | rf_in_array[rf_idx]);
						next_tx_req = 1;
						next_lc_state = LC_STATE_BUS_TX;
						next_mem_sub_state = 2;
						next_lc_return_state = LC_STATE_RF_READ;
						if (dma_counter)
						begin
							next_tx_pend = 1;
							next_dma_counter = dma_counter - 1'b1;
						end
						else
							next_tx_pend = 0;
					end
				end

				2:
				begin
					if (rf_idx < {LC_RF_ADDR_WIDTH{1'b1}})
						next_rf_idx = rf_idx + 1'b1;
					else
						next_rf_idx = 0;
					next_mem_sub_state = 1;
				end

			endcase
		end

		LC_STATE_RF_WRITE:
		begin
			case (mem_sub_state)
				0:
				begin
					next_rf_dout = rx_dat_buffer[LC_RF_DATA_WIDTH-1:0];
					next_mem_sub_state = RF_WRITE_LOAD;
				end

				RF_WRITE_LOAD:
				begin
					next_rf_load = rf_load_temp;
					if (channel_enable_set)	// streaming is enabled
						next_mem_sub_state = RF_WRITE_STREAM_COUNTER;
				end

				RF_WRITE_STREAM_COUNTER:
				begin
					next_rf_dout = (REG_WR_DATA & 24'h0fffff);
					next_mem_sub_state = RF_WRITE_STREAM_LOAD;
				end

				RF_WRITE_STREAM_LOAD:
				begin
					next_rf_load = (rf_load_temp<<1);
					next_mem_sub_state = RF_WRITE_CHECK;
				end

				RF_WRITE_CHECK:
				begin
					if (layer_interrupted)
						next_mem_sub_state = RF_WRITE_INT_COPY;
					else
					begin
						if (rx_pend_reg)
							next_mem_sub_state = RF_WRITE_RECEIVE;
						else
							next_lc_state = LC_STATE_IDLE;
					end
				end

				RF_WRITE_RECEIVE:
				begin
					if (RX_REQ_DL2 & (~RX_ACK))
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

				RF_WRITE_INT_COPY:
				begin
					next_mem_sub_state = 0;
					next_int_cmd_cnt = int_cmd_cnt + 1'b1;
					if (rx_pend_reg)
					begin
						if (int_cmd_cnt==interrupt_command_length[int_idx])
							next_rx_pend_reg = 1'b0;
						else
							next_rx_pend_reg = 1'b1;
						case(int_cmd_cnt)
							2'b10: begin next_rx_dat_buffer = interrupt_payload[int_idx][(`DATA_WIDTH<<1)-1:`DATA_WIDTH]; end
							2'b11: begin next_rx_dat_buffer = interrupt_payload[int_idx][`DATA_WIDTH-1:0]; end
						endcase
					end
					else
						next_lc_state = LC_STATE_CLR_INT;
						
				end

			endcase

		end

		// length could be 2 word or 3 word long
		LC_STATE_MEM_READ:
		begin
			case (mem_sub_state)
				0:
				begin
					next_dma_counter = rx_dat_buffer[MAX_DMA_LENGTH-1:0];	
					next_tx_addr = {{(`ADDR_WIDTH-`SHORT_ADDR_WIDTH){1'b0}}, rx_dat_buffer[`DATA_WIDTH-1:`DATA_WIDTH-`SHORT_ADDR_WIDTH]};
					if (rx_pend_reg)
						next_mem_sub_state = MEM_READ_WAIT_START_ADDRESS;
					else // Error command, can only come from MBus
						next_lc_state = LC_STATE_IDLE;
				end

				MEM_READ_WAIT_START_ADDRESS:
				begin
					if (layer_interrupted)
					begin
						next_tx_pend = 1;
						next_mem_aout = interrupt_payload[int_idx][(`DATA_WIDTH<<1)-1:`DATA_WIDTH+2]; // bit 63 ~ 34
						if (interrupt_command_length[int_idx]==2'b11)
							next_mem_sub_state = MEM_READ_WAIT_DEST_LOCATION;
						else
							next_mem_sub_state = MEM_READ_ACCESS_READ;
					end
					else
					begin
						if (RX_REQ_DL2 & (~RX_ACK))
						begin
							next_tx_pend = 1;
							next_rx_ack = 1;
							next_mem_aout = RX_DATA[`DATA_WIDTH-1:2]; // bit 63 ~ 34
							if (RX_PEND)
								next_mem_sub_state = MEM_READ_WAIT_DEST_LOCATION;
							else 
								next_mem_sub_state = MEM_READ_ACCESS_READ;
						end
						else if (RX_FAIL & (~RX_ACK))
						begin
							next_rx_ack = 1;
							next_lc_state = LC_STATE_IDLE;
						end
					end
				end

				MEM_READ_WAIT_DEST_LOCATION:
				begin
					if (layer_interrupted)
					begin
						next_tx_data = (interrupt_payload[int_idx][`DATA_WIDTH-1:0] & 32'hfffffffc); // clear last two bits, address is 30 bits only
						next_mem_sub_state = MEM_READ_TX_DEST_LOC;
					end
					else
					begin
						if (RX_REQ_DL2 & (~RX_ACK))
						begin
							next_rx_ack = 1;
							next_tx_data = (RX_DATA & 32'hfffffffc);	// clear last two bits, address is 30 bits only
							if (RX_PEND) // Error MBus command
							begin
								next_rx_pend_reg = 1;
								next_mem_sub_state = 0;
								next_lc_state = LC_STATE_ERROR;
							end
							else 
								next_mem_sub_state = MEM_READ_TX_DEST_LOC;
						end
						else if (RX_FAIL & (~RX_ACK))
						begin
							next_rx_ack = 1;
							next_lc_state = LC_STATE_IDLE;
						end
					end
				end

				MEM_READ_TX_DEST_LOC:
				begin
					if (~TX_REQ)
					begin
						next_tx_req = 1;
						next_mem_sub_state = MEM_READ_ACCESS_READ;
						next_lc_state = LC_STATE_BUS_TX;
						next_lc_return_state = LC_STATE_MEM_READ;
					end
				end

				MEM_READ_ACCESS_READ:
				begin
					if (~MEM_REQ_OUT)
					begin
						next_mem_read = 1;
						next_mem_sub_state = MEM_READ_ACCESS_WAIT;
						if (dma_counter)
							next_mem_pend = 1'b1;
						else
							next_mem_pend = 1'b0;
					end
				end

				MEM_READ_ACCESS_WAIT:
				begin
					// Read complete
					if (MEM_ACK_IN & (~TX_REQ))
					begin
						next_tx_req = 1;
						next_tx_data = MEM_RD_DATA;
						next_lc_state = LC_STATE_BUS_TX;
						next_lc_return_state = LC_STATE_MEM_READ;
						next_mem_aout = MEM_ADDR + 1'b1;
						if (dma_counter)
						begin
							next_dma_counter = dma_counter - 1'b1;
							next_tx_pend = 1;
						end
						else
							next_tx_pend = 0;
					end
				end

			endcase
		end

		LC_STATE_MEM_WRITE:
		begin
			case (mem_sub_state)
				0:
				begin
					next_mem_aout = rx_dat_buffer[LC_MEM_ADDR_WIDTH-1:2];
					next_dma_counter = bulk_max_length;
					if (~rx_pend_reg) // Invalid message
						next_lc_state = LC_STATE_IDLE;
					else if (~bulk_enable)	// Bulk enable is not set
					begin
						next_mem_sub_state = 0;
						next_lc_state = LC_STATE_ERROR;
					end
					else
						next_mem_sub_state = 1;
				end

				1:
				begin
					if (RX_REQ_DL2 & (~RX_ACK))
					begin
						next_rx_ack = 1;
						next_mem_sub_state = 2;
						next_mem_dout = RX_DATA[LC_MEM_DATA_WIDTH-1:0];
						next_rx_pend_reg = RX_PEND;
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
						next_mem_write = 1;
						next_mem_sub_state = 3;
						if (dma_counter)
							next_mem_pend = rx_pend_reg;
						else
							next_mem_pend = 0;
					end
				end

				3:
				begin
					// write complete
					if (MEM_ACK_IN)
					begin
						if (rx_pend_reg)
						begin
							if (dma_counter)
							begin
								next_dma_counter = dma_counter - 1'b1;
								next_mem_aout = MEM_ADDR + 1'b1;
								next_mem_sub_state = 1;
							end
							else
							begin
								next_mem_sub_state = 0;
								next_lc_state = LC_STATE_ERROR;
							end
						end
						else// no more data coming, no need to substract dma counter
							next_lc_state = LC_STATE_IDLE;
					end
				end
			endcase
		end

		LC_STATE_STREAM_WRITE:
		begin
			case (mem_sub_state)
				0:
				begin
					if (stream_enable)
					begin
						next_mem_aout = stream_write_buffer;
						next_mem_dout = rx_dat_buffer;
						next_mem_pend = ((stream_wrapping & rx_pend_reg) | (rx_pend_reg & stream_remaining));
						next_mem_sub_state = STREAM_MEM_WRITE;
					end
					else
					begin
						if (rx_pend_reg)
						begin
							next_mem_sub_state = 0;
							next_lc_state = LC_STATE_ERROR;
						end
						else
							next_lc_state = LC_STATE_IDLE;
					end
				end

				STREAM_MEM_WRITE:
				begin
					if (~MEM_REQ_OUT)
					begin
						next_mem_write = 1;
						next_mem_sub_state = STREAM_MEM_WAIT;
					end
				end

				STREAM_MEM_WAIT:
				begin
					if (MEM_ACK_IN)
						next_mem_sub_state = STREAM_COUNTER_DEC;
				end

				STREAM_COUNTER_DEC:
				begin
					next_mem_sub_state = STREAM_RF_WRITE;
					if (stream_remaining)
					begin
						next_rf_dout = (stream_reg3[stream_channel][`LC_RF_DATA_WIDTH-1:20]<<20) | (stream_reg3[stream_channel][19:0] - 1'b1);
						if ((stream_reg3[stream_channel][18:0]==stream_reg2[stream_channel][19:1]) && (~stream_double_bf_alert))
							next_stream_double_bf_alert = 1'b1;
					end
					else
					begin
						next_stream_overflow_alert = 1'b1;
						if (stream_wrapping)
							next_rf_dout = (stream_reg3[stream_channel][`LC_RF_DATA_WIDTH-1:20]<<20) | stream_reg2[stream_channel][19:0];
						else
							next_rf_dout = (1'b1<<(`LC_RF_DATA_WIDTH-1)) | stream_reg2[stream_channel][`LC_RF_DATA_WIDTH-2:0]; // clear enable
					end
				end

				STREAM_RF_WRITE:
				begin
					if ((~stream_remaining) & (~stream_wrapping))
					begin
						next_rf_load = (1'b1<<(LC_RF_DEPTH - 1'b1 - (stream_channel<<2)) - 1'b1);	// clear enable
						if (rx_pend_reg)
						begin
							next_mem_sub_state = 0;
							next_lc_state = LC_STATE_ERROR;
						end
					end
					else
						next_rf_load = (1'b1<<(LC_RF_DEPTH - 1'b1 - (stream_channel<<2)));			// reload counter

					if (MEM_PEND)
						next_mem_sub_state = STREAM_RECEIVE;
					else
						next_lc_state = LC_STATE_IDLE;
				end

				STREAM_RECEIVE:
				begin
					if (RX_REQ_DL2 & (~RX_ACK))
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

		LC_STATE_STREAM_ALERT:
		begin
		end


		LC_STATE_BUS_TX:
		begin // cannot modify mem_sub_state here
			if (TX_FAIL)
				next_lc_state = LC_STATE_CLR_INT;
			else if (TX_ACK_DL2)
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
				next_lc_state = LC_STATE_CLR_INT;
		end

		LC_STATE_INT_ARBI:
		begin
			if (int_vector_copied[0])
				next_lc_state = LC_STATE_INT_HANDLED;
			else
			begin
				next_int_vector_copied = (int_vector_copied>>1);
				next_int_idx = int_idx + 1;
			end
		end

		LC_STATE_INT_HANDLED:
		begin
			// only wake up the system, don't do anything
			next_layer_interrupted = 1;
			if ((interrupt_command_length[int_idx])==2'b00)
				next_lc_state = LC_STATE_CLR_INT;
			else
			begin
				next_rx_dat_buffer = interrupt_payload[int_idx][(`DATA_WIDTH*3)-1:(`DATA_WIDTH<<1)];
				case (interrupt_functional_id[int_idx])
					`LC_CMD_RF_WRITE: begin next_lc_state = LC_STATE_RF_WRITE; next_rx_pend_reg = interrupt_command_length[int_idx][1]; next_int_cmd_cnt = 2; end
					`LC_CMD_RF_READ: begin next_lc_state = LC_STATE_RF_READ; next_rx_pend_reg = 0; end
					`LC_CMD_MEM_READ: begin next_lc_state = LC_STATE_MEM_READ; next_rx_pend_reg = 1; end
					default: begin next_lc_state = LC_STATE_CLR_INT; end	// Invalid interrupt message
				endcase
			end

		end

		// This state handles errors, junk message coming in.
		// Do not assert RX_ACK until it fails
		// the message before return idle state
		LC_STATE_ERROR:
		begin
			case (mem_sub_state)
				0:
				begin
					if (RX_REQ_DL2 & (~RX_ACK))
					begin
						next_rx_pend_reg = RX_PEND;
						next_mem_sub_state = 1;
					end
				end

				1:
				begin
					if (~rx_pend_reg)
					begin
						next_rx_ack = 1;
						next_lc_state = LC_STATE_IDLE;
					end
					else if (RX_FAIL)
					begin
						next_rx_ack = 1;
						next_lc_state = LC_STATE_IDLE;
					end
				end
			endcase
		end

		LC_STATE_CLR_INT:
		begin
			next_lc_state = LC_STATE_IDLE;
			if (layer_interrupted)
				next_clr_int = (1'b1 << int_idx);
		end

		default:
		begin
		end

	endcase
end


endmodule
module input_stabilizer_layer_ctrl (
	input clk,
	input reset,
	input a,
	output a_clocked
);

	reg [1:0] a_reg;

   // synopsys async_set_reset "reset"
   always @ (posedge reset or posedge clk)
     if (reset)
       a_reg <= #1 2'b00; // `SD not used due to cluster_clock hold constraint
     else
       a_reg <= #1 {a,a_reg[1]};

	 assign a_clocked = a_reg[0];

endmodule // input_stabilizer
