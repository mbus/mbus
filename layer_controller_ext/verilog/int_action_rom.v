
// Simulation only, not synthesisable
`include "include/mbus_def.v"

module int_action_rom #(
	parameter LC_INT_DEPTH = 13,
	parameter LC_RF_DEPTH = 128,		// 1 ~ 2^8
	parameter LC_MEM_DEPTH = 65536	// 1 ~ 2^30
)
(
	output	[`FUNC_WIDTH*LC_INT_DEPTH-1:0] int_func_id,
	output 	[(`DATA_WIDTH*3)*LC_INT_DEPTH-1:0] int_payload,
	output	[2*LC_INT_DEPTH-1:0] int_cmd_len
);


wire	[`FUNC_WIDTH-1:0] int_func_array [0:LC_INT_DEPTH-1];
wire	[(`DATA_WIDTH*3)-1:0] int_payload_array [0:LC_INT_DEPTH-1];
wire	[1:0] int_cmd_len_array [0:LC_INT_DEPTH-1];

genvar idx;
generate
	for (idx=0; idx<LC_INT_DEPTH; idx=idx+1)
	begin: INT_ACTION
		assign int_func_id[`FUNC_WIDTH*(idx+1)-1:`FUNC_WIDTH*idx] = int_func_array[idx];
		assign int_payload[(`DATA_WIDTH*3)*(idx+1)-1:(`DATA_WIDTH*3)*idx] = int_payload_array[idx];
		assign int_cmd_len[2*(idx+1)-1:2*idx] = int_cmd_len_array[idx];
	end
endgenerate

/* Interrupt Test case A : RF READ
 *
 * 1: Read 1 location, write to another layer, length = 1
 * 2: Read 1 location, write to another layer, length = 2
 * 3: Read 5 locations, write to another layer, length = 1
 * 4: Read 5 locations, over RF range in the middle, write to another layer, length = 1
 *
 */

/* Interrupt Test case B : RF WRITE
 *
 * 1: Write 1 location, length = 1
 * 2: Write 3 locations, length = 2
 * 3: Write 3 locations, length = 3
 * 4: Write 3 locations, over RF range in the middle, length = 3
 *
 */

/* Interrupt Test case C : MEM READ
 *
 * 1: Read 1 location, write to another layer (MEM), length = 3
 * 2: Read 10 location, write to another layer (MEM), length = 3
 * 3: Read 1 location, out of range, write to another layer (MEM), length = 3
 * 4: Read 10 location, out of range, write to another layer (MEM), length = 3
 *
 */

/* Interrupt Test case D: Wake up
 * 1: Wake up system only, interrupt length = 0
 */
localparam RF_READ_INT_DEPTH = 4;
localparam RF_WRITE_INT_DEPTH = 9;
localparam MEM_READ_INT_DEPTH = 4;

wire	[7:0] rf_read_from [0:RF_READ_INT_DEPTH-1]; 
wire	[7:0] rf_read_length [0:RF_READ_INT_DEPTH-1]; 
wire	[7:0] rf_read_reply_addr[0:RF_READ_INT_DEPTH-1];  
wire	[7:0] rf_read_reply_loc[0:RF_READ_INT_DEPTH-1]; 

wire	[7:0] rf_write_to [0:RF_WRITE_INT_DEPTH-1];
wire	[23:0] rf_write_data [0:RF_WRITE_INT_DEPTH-1];

wire	[29:0] mem_read_start_addr [0:MEM_READ_INT_DEPTH-1];
wire	[7:0]  mem_read_reply_addr [0:MEM_READ_INT_DEPTH-1];
wire	[19:0] mem_read_length [0:MEM_READ_INT_DEPTH-1];
wire	[29:0] mem_read_reply_locs [0:MEM_READ_INT_DEPTH-1];


	// RF Read Command Structure, Read RF from this layer and generate something on the MBus
	// 8'b Start Addr, 8'b Length, 8'b Reply address (4'b short addr, 4'b functional ID), 8'b Reply location
generate
	for (idx=0; idx<RF_READ_INT_DEPTH; idx=idx+1)
	begin: RF_READ_INT
		assign int_payload_array[idx] = (((rf_read_from[idx]<<24 | rf_read_length[idx]<<16 | rf_read_reply_addr[idx]<<8 | rf_read_reply_loc[idx])<<`DATA_WIDTH*2) | {(`DATA_WIDTH*2){1'b0}});	
	end
endgenerate

	// Test Case A1, 1: Read 1 location, write to another layer, length = 1
assign rf_read_from[0] = 8'h0;					// Read from address 8'h0
assign rf_read_length[0] = 8'h0;					// Read 1 loc. (24-bit)
assign rf_read_reply_addr[0] = (4'd2<<4 | `LC_CMD_RF_WRITE);// Send to layer 2, with RF write command
assign rf_read_reply_loc[0] = 8'h0;				// Send to 8'h0
assign int_cmd_len_array[0] = 2'b01;					// Command length 1
assign int_func_array[0] = `LC_CMD_RF_READ;

	// Test Case A2, 2: Read 1 location, write to another layer, length = 2
assign rf_read_from[1] = 8'h1;					// Read from address 8'h1
assign rf_read_length[1] = 8'h0;					// Read 1 loc. (24-bit)
assign rf_read_reply_addr[1] = (4'd2<<4 | `LC_CMD_RF_WRITE);// Send to layer 2, with RF write command
assign rf_read_reply_loc[1] = 8'h1;				// Send to 8'h1
assign int_cmd_len_array[1] = 2'b10;					// Command length 2
assign int_func_array[1] = `LC_CMD_RF_READ;

	// Test Case A3, 3: Read 5 locations, write to another layer, length = 1
assign rf_read_from[2] = 8'h2;					// Read from address 8'h2
assign rf_read_length[2] = 8'h4;					// Read 5 loc. (24-bit)
assign rf_read_reply_addr[2] = (4'd2<<4 | `LC_CMD_RF_WRITE);// Send to layer 2, with RF write command
assign rf_read_reply_loc[2] = 8'h2;				// Send to 8'h2
assign int_cmd_len_array[2] = 2'b01;					// Command length 1
assign int_func_array[2] = `LC_CMD_RF_READ;

	// Test Case A4, 4: Read 5 locations, over RF range in the middle, write to another layer, length = 1
assign rf_read_from[3] = 8'd126;					// Read from address 8'd126
assign rf_read_length[3] = 8'h4;					// Read 5 loc. (24-bit)
assign rf_read_reply_addr[3] = (4'd2<<4 | `LC_CMD_RF_WRITE);// Send to layer 2, with RF write command
assign rf_read_reply_loc[3] = 8'h3;				// Send to 8'h3
assign int_cmd_len_array[3] = 2'b01;					// Command length 1
assign int_func_array[3] = `LC_CMD_RF_READ;


	// RF Write Command Structure, Write RF to this layer. No message is generate on the MBus
	// 8'b Address, 24'b Data

	// Test Case B1, 1: Write 1 location, length = 1
assign rf_write_to[0] = 8'b0;						// Write 0xabcdef to address 0
assign rf_write_data[0] = 24'habcdef;				// 
assign int_cmd_len_array[4] = 2'b01;					// Command length 1
assign int_func_array[4] = `LC_CMD_RF_WRITE;
assign int_payload_array[4] = (((rf_write_to[0]<<24 | rf_write_data[0])<<(`DATA_WIDTH*2)) | {(`DATA_WIDTH*2){1'b0}});	

	// Test Case B2, 2: Write 3 locations, length = 2
assign rf_write_to[1] = 8'd1;						// Write 0x123456 to address 1
assign rf_write_data[1] = 24'h123456;				// 
assign rf_write_to[2] = 8'd3;						// Write 0x987654 to address 3
assign rf_write_data[2] = 24'h987654;				// 
assign int_cmd_len_array[5] = 2'b10;					// Command length 2
assign int_func_array[5] = `LC_CMD_RF_WRITE;
assign int_payload_array[5] = (((rf_write_to[1]<<24 | rf_write_data[1])<<(`DATA_WIDTH*2)) | ((rf_write_to[2]<<24 | rf_write_data[2])<<`DATA_WIDTH) | {(`DATA_WIDTH){1'b0}});	

	// Test Case B3, 3: Write 3 locations, length = 3
assign rf_write_to[3] = 8'd2;						// Write 0x123321 to address 2
assign rf_write_data[3] = 24'h123321;				// 
assign rf_write_to[4] = 8'd4;						// Write 0xabccba to address 4
assign rf_write_data[4] = 24'habccba;				// 
assign rf_write_to[5] = 8'd6;						// Write 0x090785 to address 6
assign rf_write_data[5] = 24'h090785;				// 
assign int_cmd_len_array[6] = 2'b11;					// Command length 3
assign int_func_array[6] = `LC_CMD_RF_WRITE;
assign int_payload_array[6] = ((rf_write_to[3]<<24 | rf_write_data[3])<<(`DATA_WIDTH*2)) | ((rf_write_to[4]<<24 | rf_write_data[4])<<`DATA_WIDTH) | (rf_write_to[5]<<24 | rf_write_data[5]);

	// Test Case B4, 4: Write 3 locations, over RF range in the middle, length = 3
assign rf_write_to[6] = 8'd5;						// Write 0x052986 to address 5
assign rf_write_data[6] = 24'h052986;				// 
assign rf_write_to[7] = 8'd127;					// Write 0x031783 to address 127
assign rf_write_data[7] = 24'h031783;				// 
assign rf_write_to[8] = 8'd128;					// Write 0x101614 to address 128, should fail
assign rf_write_data[8] = 24'h101614;				// 
assign int_cmd_len_array[7] = 2'b11;					// Command length 3
assign int_func_array[7] = `LC_CMD_RF_WRITE;
assign int_payload_array[7] = ((rf_write_to[6]<<24 | rf_write_data[6])<<(`DATA_WIDTH*2)) | ((rf_write_to[7]<<24 | rf_write_data[7])<<`DATA_WIDTH) | (rf_write_to[8]<<24 | rf_write_data[8]);

	// MEM Read Command Structure, Read MEM to this layer, and generate something on the MBus
	// Word 1: 8 bit replay address, 4 bit reserved, 20 bit length
	// Word 2: 30 bit start address, 2 bit dont't care
	// Word 3: 30 bit destination location, 2 bit don't care
generate
	for (idx=0; idx<MEM_READ_INT_DEPTH; idx=idx+1)
	begin: MEM_READ_INT
		assign int_payload_array[8+idx]	= ((((mem_read_reply_addr[idx]<<24) | (4'b0<<20) | mem_read_length[idx])<<(`DATA_WIDTH*2)) | ((mem_read_start_addr[idx]<<2) | 2'b0)<<`DATA_WIDTH) | ((mem_read_reply_locs[idx]<<2) | 2'b0);
	end
endgenerate

	// Test Case C1, 1: Read 1 location, write to another layer (MEM), length = 3
assign mem_read_start_addr[0]	= 30'h0;			// Read from address 0
assign mem_read_reply_addr[0]	= (4'd2<<4 | `LC_CMD_MEM_WRITE); // Write to layer 2, SRAM write
assign mem_read_length[0]		= 20'd0;			// Read 1 word
assign mem_read_reply_locs[0]	= 30'd1;			// Send to address 1
assign int_cmd_len_array[8]	= 2'b11;
assign int_func_array[8]		= `LC_CMD_MEM_READ;

	// Test Case C2, 2: Read 10 location, write to another layer (MEM), length = 3
assign mem_read_start_addr[1]	= 30'h1;			// Read from address 1
assign mem_read_reply_addr[1]	= (4'd2<<4 | `LC_CMD_MEM_WRITE); // Write to layer 2, SRAM write
assign mem_read_length[1]		= 20'd2;			// Read 3 word
assign mem_read_reply_locs[1]	= 30'd2;			// Send to address 2
assign int_cmd_len_array[9]	= 2'b11;
assign int_func_array[9]		= `LC_CMD_MEM_READ;

	// Test Case C3, 3: Read 1 location, out of range, wrap around, write to another layer (MEM), length = 3
assign mem_read_start_addr[2]	= 30'd66666;		// Read from a non-existing address
assign mem_read_reply_addr[2]	= (4'd2<<4 | `LC_CMD_MEM_WRITE); // Write to layer 2,  SRAM write
assign mem_read_length[2]		= 20'd0;			// Read 1 word
assign mem_read_reply_locs[2]	= 30'd3;			// Send to address 3
assign int_cmd_len_array[10]	= 2'b11;
assign int_func_array[10]		= `LC_CMD_MEM_READ;

	// Test Case C4, 4: Read 10 location, out of range, wrap around, write to another layer (MEM), length = 3
assign mem_read_start_addr[3]	= 30'd65533;		// Read over memory boundary
assign mem_read_reply_addr[3]	= (4'd2<<4 | `LC_CMD_MEM_WRITE); // Write to layer 2, SRAM write
assign mem_read_length[3]		= 20'd9;			// Read 10 word
assign mem_read_reply_locs[3]	= 30'd3;			// Send to address 3
assign int_cmd_len_array[11]	= 2'b11;
assign int_func_array[11]		= `LC_CMD_MEM_READ;

	// Test case D1, 1: Wake up system only
assign int_cmd_len_array[12]	= 2'b00;				// wake up only
assign int_func_array[12]		= 4'b0;					// Don't care
assign int_payload_array[12]	= 96'b0;					// Don't care

endmodule
