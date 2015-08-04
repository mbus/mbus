/*
 * MBus Copyright 2015 Regents of the University of Michigan
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// Simulation only, not synthesisable
`include "include/mbus_def.v"

module int_action_rom #(
	parameter LC_INT_DEPTH = 13
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
 * 1: Read 1 location, write to another layer's RF
 * 2: Read 5 locations, write to another layer's RF
 * 3: Read 5 locations, stream to another layer's MEM
 *
 */

/* Interrupt Test case B : RF WRITE
 *
 * 1: Write 1 location, length = 1
 * 2: Write 3 locations, length = 2
 * 3: Write 3 locations, length = 3
 *
 */

/* Interrupt Test case C : MEM READ
 *
 * 1: Read 1 location, write to another layer (MEM)
 * 2: Read 10 location, write to another layer (MEM)
 * 3: Read 1 location, write to another layer (RF) (length = 2)
 * 4: Read 4 location, write to another layer (RF) (length = 2)
 * 5: Read 10 location, stream to another layer (MEM), (length = 2)
 *
 */

/* Interrupt Test case D: Wake up
 * 1: Wake up system only, interrupt length = 0
 */
localparam RF_READ_INT_DEPTH = 3;
localparam RF_WRITE_INT_DEPTH = 3;
localparam MEM_READ_INT_DEPTH = 5;

wire	[7:0] rf_read_from [0:RF_READ_INT_DEPTH-1]; 
wire	[7:0] rf_read_length [0:RF_READ_INT_DEPTH-1]; 
wire	[7:0] rf_read_reply_addr[0:RF_READ_INT_DEPTH-1];  
wire	[7:0] rf_read_reply_loc[0:RF_READ_INT_DEPTH-1]; 

wire	[7:0] rf_write_to [0:5];
wire	[23:0] rf_write_data [0:5];

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
		assign int_cmd_len_array[idx] = 2'b01;
		assign int_func_array[idx] = `LC_CMD_RF_READ;
	end
endgenerate

	// Test Case A1, 1: Read 1 location, write to layer 2's RF
assign rf_read_from[0] = 8'h0;					// Read from address 8'h0
assign rf_read_length[0] = 8'h0;				// Read 1 loc. (24-bit)
assign rf_read_reply_addr[0] = {4'd4, `LC_CMD_RF_WRITE};// Send to layer 2, with RF write command
assign rf_read_reply_loc[0] = 8'h0;				// Send to 8'h0

	// Test Case A2, 2: Read 5 locations, write to layer 2's RF
assign rf_read_from[1] = 8'h2;					// Read from address 8'h2
assign rf_read_length[1] = 8'h4;				// Read 5 loc. (24-bit)
assign rf_read_reply_addr[1] = {4'd4, | `LC_CMD_RF_WRITE};// Send to layer 2, with RF write command
assign rf_read_reply_loc[1] = 8'h2;				// Send to 8'h2

	// Test Case A3, 3: Read 10 locations, stream to layer 2's MEM
assign rf_read_from[2] = 8'h0;					// Read from address 8'h0
assign rf_read_length[2] = 8'd9;				// Read 10 loc. (24-bit)
assign rf_read_reply_addr[2] = {4'd4, `LC_CMD_MEM_STREAM, 2'b00};// Stream to layer 2
assign rf_read_reply_loc[2] = 8'd100;			// Send to mem location 100



	// RF Write Command Structure, Write RF to this layer. No message is generate on the MBus
	// 8'b Address, 24'b Data
generate
	for (idx=0; idx<RF_WRITE_INT_DEPTH; idx=idx+1)
	begin: RF_WRITE_INT
		assign int_func_array[RF_READ_INT_DEPTH+idx] = `LC_CMD_RF_WRITE;
	end
endgenerate

	// Test Case B1, 1: Write 1 location, length = 1
assign rf_write_to[0] = 8'b0;						// Write 0xabcdef to address 0
assign rf_write_data[0] = 24'habcdef;				// 
assign int_cmd_len_array[RF_READ_INT_DEPTH] = 2'b01;					// Command length 1
assign int_payload_array[RF_READ_INT_DEPTH] = (((rf_write_to[0]<<24 | rf_write_data[0])<<(`DATA_WIDTH*2)) | {(`DATA_WIDTH*2){1'b0}});	

	// Test Case B2, 2: Write 3 locations, length = 2
assign rf_write_to[1] = 8'd1;						// Write 0x123456 to address 1
assign rf_write_data[1] = 24'h123456;				// 
assign rf_write_to[2] = 8'd3;						// Write 0x987654 to address 3
assign rf_write_data[2] = 24'h987654;				// 
assign int_cmd_len_array[RF_READ_INT_DEPTH+1] = 2'b10;					// Command length 2
assign int_payload_array[RF_READ_INT_DEPTH+1] = (((rf_write_to[1]<<24 | rf_write_data[1])<<(`DATA_WIDTH*2)) | ((rf_write_to[2]<<24 | rf_write_data[2])<<`DATA_WIDTH) | {(`DATA_WIDTH){1'b0}});	

	// Test Case B3, 3: Write 3 locations, length = 3
assign rf_write_to[3] = 8'd2;						// Write 0x123321 to address 2
assign rf_write_data[3] = 24'h123321;				// 
assign rf_write_to[4] = 8'd4;						// Write 0xabccba to address 4
assign rf_write_data[4] = 24'habccba;				// 
assign rf_write_to[5] = 8'd6;						// Write 0x090785 to address 6
assign rf_write_data[5] = 24'h090785;				// 
assign int_cmd_len_array[RF_READ_INT_DEPTH+2] = 2'b11;				// Command length 3
assign int_payload_array[RF_READ_INT_DEPTH+2] = ((rf_write_to[3]<<24 | rf_write_data[3])<<(`DATA_WIDTH*2)) | ((rf_write_to[4]<<24 | rf_write_data[4])<<`DATA_WIDTH) | (rf_write_to[5]<<24 | rf_write_data[5]);


	// MEM Read Command Structure, Read MEM to this layer, and generate something on the MBus
	// Word 1: 8 bit replay address, 4 bit reserved, 20 bit length
	// Word 2: 30 bit start address, 2 bit dont't care
	// Word 3: 30 bit destination location, 2 bit don't care
generate
	for (idx=0; idx<MEM_READ_INT_DEPTH; idx=idx+1)
	begin: MEM_READ_INT
		assign int_payload_array[RF_READ_INT_DEPTH + RF_WRITE_INT_DEPTH + idx]	= ((((mem_read_reply_addr[idx]<<24) | (4'b0<<20) | mem_read_length[idx])<<(`DATA_WIDTH*2)) | ((mem_read_start_addr[idx]<<2) | 2'b0)<<`DATA_WIDTH) | ((mem_read_reply_locs[idx]<<2) | 2'b0);
	assign int_func_array[RF_READ_INT_DEPTH + RF_WRITE_INT_DEPTH + idx]		= `LC_CMD_MEM_READ;
	end
endgenerate

	// Test Case C1, 1: Read 1 location, write to layer 2's MEM
assign mem_read_start_addr[0]	= 30'h0;			// Read from address 0
assign mem_read_reply_addr[0]	= {4'd4, `LC_CMD_MEM_WRITE}; // Write to layer 2's MEM
assign mem_read_length[0]		= 20'd0;			// Read 1 word
assign mem_read_reply_locs[0]	= 30'd1;			// Send to address 1
assign int_cmd_len_array[RF_READ_INT_DEPTH+RF_WRITE_INT_DEPTH]	= 2'b11;

	// Test Case C2, 2: Read 5 location, write to layer 2's MEM
assign mem_read_start_addr[1]	= 30'h1;			// Read from address 1
assign mem_read_reply_addr[1]	= {4'd4, `LC_CMD_MEM_WRITE}; // Write to layer 2's MEM
assign mem_read_length[1]		= 20'd4;			// Read 5 word
assign mem_read_reply_locs[1]	= 30'd2;			// Send to address 2
assign int_cmd_len_array[RF_READ_INT_DEPTH+RF_WRITE_INT_DEPTH+1]	= 2'b11;

	// Test Case C3, 3: Read 1 location, write to layer 1's RF (This should assert from layer 2)
assign mem_read_start_addr[2]	= 30'd100;			// Read from address 100
assign mem_read_reply_addr[2]	= {4'd3, `LC_CMD_RF_WRITE}; // Write to layer 1's RF  
assign mem_read_length[2]		= 20'd0;			// Read 1 word
assign mem_read_reply_locs[2]	= 30'd0;			// Don't care 
assign int_cmd_len_array[RF_READ_INT_DEPTH+RF_WRITE_INT_DEPTH+2]	= 2'b10;

	// Test Case C4, 4: Read 4 location, write to layer 1'f RF (This should assert from layer 2)
assign mem_read_start_addr[3]	= 30'd101;			// Read from address 101
assign mem_read_reply_addr[3]	= {4'd3, `LC_CMD_RF_WRITE}; // Write to layer 1's RF
assign mem_read_length[3]		= 20'd3;			// Read 4 word
assign mem_read_reply_locs[3]	= 30'd0;			// Don't care
assign int_cmd_len_array[RF_READ_INT_DEPTH+RF_WRITE_INT_DEPTH+3]	= 2'b10;

	// Test Case C5, 5: Read 10 location, stream to layer 2's MEM channel 1
assign mem_read_start_addr[4]	= 30'd0;			// Read from address 0
assign mem_read_reply_addr[4]	= {4'd4, `LC_CMD_MEM_STREAM, 2'b01}; // Write to layer 2, channel 1
assign mem_read_length[4]		= 20'd9;			// Read 10 word
assign mem_read_reply_locs[4]	= 30'd0;			// Don't care
assign int_cmd_len_array[RF_READ_INT_DEPTH+RF_WRITE_INT_DEPTH+4]	= 2'b10;

	// Test case D1, 1: Wake up system only
assign int_cmd_len_array[RF_READ_INT_DEPTH + RF_WRITE_INT_DEPTH + MEM_READ_INT_DEPTH]	= 2'b00;	// wake up only
assign int_func_array[RF_READ_INT_DEPTH + RF_WRITE_INT_DEPTH + MEM_READ_INT_DEPTH]		= 4'b0;		// Don't care
assign int_payload_array[RF_READ_INT_DEPTH + RF_WRITE_INT_DEPTH + MEM_READ_INT_DEPTH]	= 96'b0;	// Don't care

	// Test case D2, 2: Invalid interrupt command
assign int_cmd_len_array[RF_READ_INT_DEPTH + RF_WRITE_INT_DEPTH + MEM_READ_INT_DEPTH + 1]	= 2'b01;	
assign int_func_array[RF_READ_INT_DEPTH + RF_WRITE_INT_DEPTH + MEM_READ_INT_DEPTH + 1]		= 4'b1100;	// not exist
assign int_payload_array[RF_READ_INT_DEPTH + RF_WRITE_INT_DEPTH + MEM_READ_INT_DEPTH + 1]	= 96'b0;	// Don't care

endmodule
