
// Simulation only, not synthesisable
`include "include/mbus_def.v"

module int_action_rom #(
	parameter LC_INT_DEPTH = 8,
	parameter LC_RF_DEPTH = 128,		// 1 ~ 2^8
	parameter LC_MEM_DEPTH = 65536	// 1 ~ 2^30
)
(
	output	[`FUNC_WIDTH*LC_INT_DEPTH-1:0] int_func_id,
	output 	[(`DATA_WIDTH*3)*LC_INT_DEPTH-1:0] int_payload,
	output	[2*LC_INT_DEPTH-1:0] int_cmd_len
);


reg		[`FUNC_WIDTH-1:0] int_func_array [0:LC_INT_DEPTH-1];
reg		[(`DATA_WIDTH*3)-1:0] int_payload_array [0:LC_INT_DEPTH-1];
reg		[1:0] int_cmd_len_array [0:LC_INT_DEPTH-1];

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
 * 1: Read 10 location, write to another layer (MEM), length = 2 (Lagacy compatible)
 * 2: Read 1 location, write to another layer (MEM), length = 3
 * 3: Read 10 location, write to another layer (MEM), length = 3
 * 4: Read 1 location, out of range, write to another layer (MEM), length = 2 (Lagacy compatible)
 * 5: Read 10 location, out of range, write to another layer (MEM), length = 2 (Lagacy compatible)
 * 6: Read 1 location, out of range, write to another layer (MEM), length = 3
 * 7: Read 10 location, out of range, write to another layer (MEM), length = 3
 *
 */

/* Interrupt Test case D: Wake up
 * 1: Wake up system only, interrupt length = 0
 */
localparam RF_READ_INT_DEPTH = 4;
localparam RF_WRITE_INT_DEPTH = 9;
localparam MEM_READ_INT_DEPTH = 8;

reg		[7:0] rf_read_from [0:RF_READ_INT_DEPTH-1]; 
reg		[7:0] rf_read_length [0:RF_READ_INT_DEPTH-1]; 
reg		[7:0] rf_read_reply_addr[0:RF_READ_INT_DEPTH-1];  
reg		[7:0] rf_read_reply_loc[0:RF_READ_INT_DEPTH-1]; 

reg		[7:0] rf_write_to [0:RF_WRITE_INT_DEPTH-1];
reg		[23:0] rf_write_data [0:RF_WRITE_INT_DEPTH-1];

reg		[29:0] mem_read_start_addr [0:MEM_READ_INT_DEPTH-1];
reg		[7:0]  mem_read_reply_addr [0:MEM_READ_INT_DEPTH-1];
reg		[23:0] mem_read_length [0:MEM_READ_INT_DEPTH-1];
reg		[31:0] mem_read_reply_locs [0:MEM_READ_INT_DEPTH-1];

integer i;
initial
begin
	for (i=0; i<LC_INT_DEPTH; i=i+1)
	begin
		int_func_array[i] <= 0;
		int_payload_array[i] <= 0;
		int_cmd_len_array[i] <= 0;
	end
	

	// RF Read Command Structure, Read RF from this layer and generate something on the MBus
	// 8'b Start Addr, 8'b Length, 8'b Reply address (4'b short addr, 4'b functional ID), 8'b Reply location

	// Test Case A1, 1: Read 1 location, write to another layer, length = 1
	rf_read_from[0] <= 8'h0;					// Read from address 8'h0
	rf_read_length[0] <= 8'h0;					// Read 1 loc. (24-bit)
	rf_read_reply_addr[0] <= (4'd2<<4 | `LC_CMD_RF_WRITE);// Send to layer 2, with RF write command
	rf_read_reply_loc[0] <= 8'h0;				// Send to 8'h0
	int_cmd_len_array[0] <= 2'b01;					// Command length 1
	int_func_array[0] <= `LC_CMD_RF_READ;
	int_payload_array[0] <= (((rf_read_from[0]<<24 | rf_read_length[0]<<16 | rf_read_reply_addr[0]<<8 | rf_read_reply_loc[0])<<`DATA_WIDTH*2) | {(`DATA_WIDTH*2){1'b0}});	

	// Test Case A2, 2: Read 1 location, write to another layer, length = 2
	rf_read_from[1] <= 8'h1;					// Read from address 8'h1
	rf_read_length[1] <= 8'h0;					// Read 1 loc. (24-bit)
	rf_read_reply_addr[1] <= (4'd2<<4 | `LC_CMD_RF_WRITE);// Send to layer 2, with RF write command
	rf_read_reply_loc[1] <= 8'h1;				// Send to 8'h1
	int_cmd_len_array[1] <= 2'b10;					// Command length 2
	int_func_array[1] <= `LC_CMD_RF_READ;
	int_payload_array[1] <= (((rf_read_from[1]<<24 | rf_read_length[1]<<16 | rf_read_reply_addr[1]<<8 | rf_read_reply_loc[1])<<`DATA_WIDTH*2) | {(`DATA_WIDTH*2){1'b0}});	

	// Test Case A3, 3: Read 5 locations, write to another layer, length = 1
	rf_read_from[2] <= 8'h2;					// Read from address 8'h2
	rf_read_length[2] <= 8'h4;					// Read 5 loc. (24-bit)
	rf_read_reply_addr[2] <= (4'd2<<4 | `LC_CMD_RF_WRITE);// Send to layer 2, with RF write command
	rf_read_reply_loc[2] <= 8'h2;				// Send to 8'h2
	int_cmd_len_array[2] <= 2'b01;					// Command length 1
	int_func_array[2] <= `LC_CMD_RF_READ;
	int_payload_array[2] <= (((rf_read_from[2]<<24 | rf_read_length[2]<<16 | rf_read_reply_addr[2]<<8 | rf_read_reply_loc[2])<<`DATA_WIDTH*2) | {(`DATA_WIDTH*2){1'b0}});	

	// Test Case A4, 4: Read 5 locations, over RF range in the middle, write to another layer, length = 1
	rf_read_from[3] <= 8'd126;					// Read from address 8'd126
	rf_read_length[3] <= 8'h4;					// Read 5 loc. (24-bit)
	rf_read_reply_addr[3] <= (4'd2<<4 | `LC_CMD_RF_WRITE);// Send to layer 2, with RF write command
	rf_read_reply_loc[3] <= 8'h3;				// Send to 8'h3
	int_cmd_len_array[3] <= 2'b01;					// Command length 1
	int_func_array[3] <= `LC_CMD_RF_READ;
	int_payload_array[3] <= (((rf_read_from[3]<<24 | rf_read_length[3]<<16 | rf_read_reply_addr[3]<<8 | rf_read_reply_loc[3])<<`DATA_WIDTH*2) | {(`DATA_WIDTH*2){1'b0}});	

	// RF Write Command Structure, Write RF to this layer. No message is generate on the MBus
	// 8'b Address, 24'b Data

	// Test Case B1, 1: Write 1 location, length = 1
	rf_write_to[0] <= 8'b0;						// Write 0xabcdef to address 0
	rf_write_data[0] <= 24'habcdef;				// 
	int_cmd_len_array[4] <= 2'b01;					// Command length 1
	int_func_array[4] <= `LC_CMD_RF_WRITE;
	int_payload_array[4] <= (((rf_write_to[0]<<24 | rf_write_data[0])<<`DATA_WIDTH*2) | {(`DATA_WIDTH*2){1'b0}});	

	// Test Case B2, 2: Write 3 locations, length = 2
	rf_write_to[1] <= 8'd1;						// Write 0x123456 to address 1
	rf_write_data[1] <= 24'h123456;				// 
	rf_write_to[2] <= 8'd3;						// Write 0x987654 to address 3
	rf_write_data[2] <= 24'h987654;				// 
	int_cmd_len_array[5] <= 2'b10;					// Command length 2
	int_func_array[5] <= `LC_CMD_RF_WRITE;
	int_payload_array[5] <= (((rf_write_to[1]<<24 | rf_write_data[1])<<`DATA_WIDTH*2) | ((rf_write_to[2]<<24 | rf_write_data[2])<<`DATA_WIDTH) | {(`DATA_WIDTH){1'b0}});	

	// Test Case B3, 3: Write 3 locations, length = 3
	rf_write_to[3] <= 8'd2;						// Write 0x123321 to address 2
	rf_write_data[3] <= 24'h123321;				// 
	rf_write_to[4] <= 8'd4;						// Write 0xabccba to address 4
	rf_write_data[4] <= 24'habccba;				// 
	rf_write_to[5] <= 8'd6;						// Write 0x090785 to address 6
	rf_write_data[5] <= 24'h090785;				// 
	int_cmd_len_array[6] <= 2'b11;					// Command length 3
	int_func_array[6] <= `LC_CMD_RF_WRITE;
	int_payload_array[6] <= ((rf_write_to[3]<<24 | rf_write_data[3])<<`DATA_WIDTH*2) | ((rf_write_to[4]<<24 | rf_write_data[4])<<`DATA_WIDTH) | (rf_write_to[5]<<24 | rf_write_data[5]);

	// Test Case B4, 4: Write 3 locations, over RF range in the middle, length = 3
	rf_write_to[6] <= 8'd5;						// Write 0x052986 to address 5
	rf_write_data[6] <= 24'h052986;				// 
	rf_write_to[7] <= 8'd127;					// Write 0x031783 to address 127
	rf_write_data[7] <= 24'h031783;				// 
	rf_write_to[8] <= 8'd128;					// Write 0x101614 to address 128, should fail
	rf_write_data[8] <= 24'h101614;				// 
	int_cmd_len_array[7] <= 2'b11;					// Command length 3
	int_func_array[7] <= `LC_CMD_RF_WRITE;
	int_payload_array[7] <= ((rf_write_to[6]<<24 | rf_write_data[6])<<`DATA_WIDTH*2) | ((rf_write_to[7]<<24 | rf_write_data[7])<<`DATA_WIDTH) | (rf_write_to[8]<<24 | rf_write_data[8]);


	// Test Case C1, 1: Read 10 location, write to another layer (MEM), length = 2 (Lagacy compatible)
	mem_read_start_addr[0] <= 30'h0;			// Read from address 0
	mem_read_reply_addr[0] <= (4'd2<<4 | `LC_CMD_MEM_WRITE); // Write to layer 2, SRAM write
	mem_read_length[0]	<= 24'd9;				// Read 10 word
	int_cmd_len_array[8]		<= 2'b10;				// Lagecy compatible command
	int_func_array[8] <= `LC_CMD_MEM_READ;
	int_payload_array[8] <= ((mem_read_start_addr[0]<<2)<<`DATA_WIDTH*2) | (((mem_read_reply_addr[0]<<24) | mem_read_length[0])<<`DATA_WIDTH) | {(`DATA_WIDTH){1'b0}};

	// Test Case C2, 2: Read 1 location, write to another layer (MEM), length = 3
	mem_read_start_addr[1] <= 30'h0;			// Read from address 0
	mem_read_reply_addr[1] <= (4'd2<<4 | `LC_CMD_MEM_WRITE); // Write to layer 2, SRAM write
	mem_read_length[1]	<= 24'd0;				// Read 1 word
	mem_read_reply_locs[1] <= (30'd1<<30|2'b0);	// Send to address 1
	int_cmd_len_array[9]		<= 2'b11;				// Standard mem read command
	int_func_array[9] <= `LC_CMD_MEM_READ;
	int_payload_array[9] <= ((mem_read_start_addr[1]<<2)<<`DATA_WIDTH*2) | (((mem_read_reply_addr[1]<<24) | mem_read_length[1])<<`DATA_WIDTH) | mem_read_reply_locs[1];

	// Test Case C3, 3: Read 10 location, write to another layer (MEM), length = 3
	mem_read_start_addr[2] <= 30'h1;			// Read from address 1
	mem_read_reply_addr[2] <= (4'd2<<4 | `LC_CMD_MEM_WRITE); // Write to layer 2, SRAM write
	mem_read_length[2]	<= 24'd2;				// Read 3 word
	mem_read_reply_locs[2] <= (30'd2<<30|2'b0);	// Send to address 2
	int_cmd_len_array[10]		<= 2'b11;				// Standard mem read command
	int_func_array[10] <= `LC_CMD_MEM_READ;
	int_payload_array[10] <= ((mem_read_start_addr[2]<<2)<<`DATA_WIDTH*2) | (((mem_read_reply_addr[2]<<24) | mem_read_length[2])<<`DATA_WIDTH) | mem_read_reply_locs[2];

	// Test Case C4, 4: Read 1 location, out of range, write to another layer (MEM), length = 2 (Lagacy compatible)
	mem_read_start_addr[3] <= 30'd66666;		// Read from a non-existing address
	mem_read_reply_addr[3] <= (4'b0<<4 | `LC_CMD_MEM_WRITE); // Write to layer 0 (CPU), SRAM write
	mem_read_length[3]	<= 24'd0;				// Read 1 word
	int_cmd_len_array[11]		<= 2'b10;				// Legacy compatible command
	int_func_array[11] <= `LC_CMD_MEM_READ;
	int_payload_array[11] <= ((mem_read_start_addr[3]<<2)<<`DATA_WIDTH*2) | (((mem_read_reply_addr[3]<<24) | mem_read_length[3])<<`DATA_WIDTH) | {(`DATA_WIDTH){1'b0}};

	// Test Case C5, 5: Read 10 location, out of range, write to another layer (MEM), length = 2 (Lagacy compatible)
	mem_read_start_addr[4] <= 30'd65533;		// Read over memory boundary
	mem_read_reply_addr[4] <= (4'b0<<4 | `LC_CMD_MEM_WRITE); // Write to layer 0 (CPU), SRAM write
	mem_read_length[4]	<= 24'd9;				// Read 10 word
	int_cmd_len_array[12]		<= 2'b10;				// Legacy compatible command
	int_func_array[12] <= `LC_CMD_MEM_READ;
	int_payload_array[12] <= ((mem_read_start_addr[4]<<2)<<`DATA_WIDTH*2) | (((mem_read_reply_addr[4]<<24) | mem_read_length[4])<<`DATA_WIDTH) | {(`DATA_WIDTH){1'b0}};

	// Test Case C6, 6: Read 1 location, out of range, write to another layer (MEM), length = 3
	mem_read_start_addr[5] <= 30'd66666;		// Read from a non-existing address
	mem_read_reply_addr[5] <= (4'd2<<4 | `LC_CMD_MEM_WRITE); // Write to layer 2,  SRAM write
	mem_read_length[5]	<= 24'd0;				// Read 1 word
	mem_read_reply_locs[5] <= (30'd3<<30|2'b0);	// Send to address 3
	int_cmd_len_array[13]		<= 2'b11;				// Standard mem read command
	int_func_array[13] <= `LC_CMD_MEM_READ;
	int_payload_array[13] <= ((mem_read_start_addr[5]<<2)<<`DATA_WIDTH*2) | (((mem_read_reply_addr[5]<<24) | mem_read_length[5])<<`DATA_WIDTH) | mem_read_reply_locs[5];

	// Test Case C7, 7: Read 10 location, out of range, write to another layer (MEM), length = 3
	mem_read_start_addr[6] <= 30'd65533;		// Read over memory boundary
	mem_read_reply_addr[6] <= (4'd2<<4 | `LC_CMD_MEM_WRITE); // Write to layer 2, SRAM write
	mem_read_length[6]	<= 24'd9;				// Read 10 word
	mem_read_reply_locs[6] <= (30'd3<<30|2'b0);	// Send to address 3
	int_cmd_len_array[14]		<= 2'b11;				// Standard mem read command
	int_func_array[14] <= `LC_CMD_MEM_READ;
	int_payload_array[14] <= ((mem_read_start_addr[6]<<2)<<`DATA_WIDTH*2) | (((mem_read_reply_addr[6]<<24) | mem_read_length[6])<<`DATA_WIDTH) | mem_read_reply_locs[6];

	
	// Test case D1, 1: Wake up system only
	int_cmd_len_array[15]		<= 2'b00;				// wake up only
	int_func_array[15]	<= 0;					// Don't care
	int_payload_array[15] <= 0;					// Don't care
end


endmodule
