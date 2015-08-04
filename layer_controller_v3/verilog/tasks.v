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

//****************************************
//Task 0 testbench: Comprehensive testbench
//****************************************
`ifdef LC_INT_ENABLE
task task0;
begin
    handle=$fopen("result_task0.txt");

    #100000;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK0%d, Master node and Processor wake up", task_counter);
    $fdisplay(handle, "-------------------------------------------------------------------------");
    state = TB_PROC_UP;
	@ (posedge SCLK);
	c0_req_int = 0;
    #50000;

    #100000;
	task_counter = task_counter + 1;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK%d, Query", task_counter);
    $fdisplay(handle, "Master node sends out query");
    $fdisplay(handle, "-------------------------------------------------------------------------");
    state = TB_QUERY;
	@ (posedge c0_rx_req);
	@ (posedge c0_rx_req);
	@ (posedge c0_rx_req);
	@ (posedge c0_rx_req);

    #100000;
	task_counter = task_counter + 1;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK%d, Enumerate", task_counter);
    $fdisplay(handle, "Master node enumerate with address 4'h2");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	enum_short_addr = 4'h2;
    state = TB_ENUM;
	@ (posedge c0_rx_req);

    #100000;
	task_counter = task_counter + 1;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK%d, Enumerate", task_counter);
    $fdisplay(handle, "Master node enumerate with address 4'h3");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	enum_short_addr = 4'h3;
    state = TB_ENUM;
	@ (posedge c0_rx_req);

    #100000;
	task_counter = task_counter + 1;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK%d, Enumerate", task_counter);
    $fdisplay(handle, "Master node enumerate with address 4'h4");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	enum_short_addr = 4'h4;
    state = TB_ENUM;
	@ (posedge c0_rx_req);

    #100000;
	task_counter = task_counter + 1;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK%d, Enumerate", task_counter);
    $fdisplay(handle, "Master node enumerate with address 4'h5");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	enum_short_addr = 4'h5;
    state = TB_ENUM;
	@ (posedge c0_rx_req);

    #100000;
	task_counter = task_counter + 1;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK%d, All Wake", task_counter);
    $fdisplay(handle, "-------------------------------------------------------------------------");
    state = TB_ALL_WAKEUP;
	@ (posedge c0_tx_succ | c0_tx_fail);

    #100000;
	task_counter = task_counter + 1;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK%d, MEM Write", task_counter);
    $fdisplay(handle, "CPU writes random data to Layer 1's MEM address 0, bulk write enable is not set, it won't fail but no memory operation");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	dest_short_addr = 4'h3;
	mem_addr = 0;
	word_counter = 0;
    state = TB_MEM_WRITE;
	@ (posedge c0_tx_succ|c0_tx_fail);

    #100000;
	task_counter = task_counter + 1;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK%d, RF Write", task_counter);
    $fdisplay(handle, "CPU configures Layer 0 default sys register bulk mem message control");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	rf_addr = BULK_MEM_CTRL_REG_IDX;
	dest_short_addr = 4'h2;
	rf_w_data = 24'h80_0000;
    state = TB_SINGLE_RF_WRITE;
	@ (posedge c0_tx_succ|c0_tx_fail);

    #100000;
	task_counter = task_counter + 1;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK%d, RF Write", task_counter);
    $fdisplay(handle, "CPU configures Layer 1 default sys register bulk mem message control");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	rf_addr = BULK_MEM_CTRL_REG_IDX;
	dest_short_addr = 4'h3;
	rf_w_data = 24'h80_0000;
    state = TB_SINGLE_RF_WRITE;
	@ (posedge c0_tx_succ|c0_tx_fail);

    #100000;
	task_counter = task_counter + 1;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK%d, RF Write", task_counter);
    $fdisplay(handle, "CPU configures Layer 2 default sys register bulk mem message control");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	rf_addr = BULK_MEM_CTRL_REG_IDX;
	dest_short_addr = 4'h4;
	rf_w_data = 24'h80_0000;
    state = TB_SINGLE_RF_WRITE;
	@ (posedge c0_tx_succ|c0_tx_fail);

    #100000;
	task_counter = task_counter + 1;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK%d, RF Write", task_counter);
    $fdisplay(handle, "CPU configures Layer 3 default sys register bulk mem message control");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	rf_addr = BULK_MEM_CTRL_REG_IDX;
	dest_short_addr = 4'h5;
	rf_w_data = 24'h80_0000;
    state = TB_SINGLE_RF_WRITE;
	@ (posedge c0_tx_succ|c0_tx_fail);

    #100000;
	task_counter = task_counter + 1;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK%d, RF Write", task_counter);
    $fdisplay(handle, "CPU writes random data to Layer 1 RF address 0");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	rf_addr = 0;
	dest_short_addr = 4'h3;
    state = TB_RF_WRITE;
	@ (posedge c0_tx_succ|c0_tx_fail);

    #100000;
	task_counter = task_counter + 1;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK%d, RF Write", task_counter);
    $fdisplay(handle, "CPU bulk writes random data to Layer 1 RF address 1-4");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	rf_addr = 1;
	dest_short_addr = 4'h3;
	word_counter = 3;
    state = TB_RF_WRITE;
	@ (posedge c0_tx_succ|c0_tx_fail);

    #100000;
	task_counter = task_counter + 1;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK%d, RF Read", task_counter);
    $fdisplay(handle, "Read Layer 1's RF address 0, and write to Layer 2's RF address 0xa");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	dest_short_addr = 4'h3;
	rf_addr = 0;
	rf_read_length = 0;
	relay_addr = ((4'h4<<4) | `LC_CMD_RF_WRITE);
	rf_relay_loc = 8'ha;
    state = TB_RF_READ;
	@ (posedge c0_tx_succ|c0_tx_fail);
	@ (posedge layer1.tx_succ|layer1.tx_fail);

    #100000;
	task_counter = task_counter + 1;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK%d, RF Read", task_counter);
    $fdisplay(handle, "Bulk read Layer 1's RF address 1-4, and write to Layer 2's RF address 0x1");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	dest_short_addr = 4'h3;
	rf_addr = 1;
	rf_read_length = 3;
	relay_addr = ((4'h4<<4) | `LC_CMD_RF_WRITE);
	rf_relay_loc = 8'h1;
    state = TB_RF_READ;
	@ (posedge c0_tx_succ|c0_tx_fail);
	@ (posedge layer1.tx_succ|layer1.tx_fail);

    #100000;
	task_counter = task_counter + 1;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK%d, MEM Write", task_counter);
    $fdisplay(handle, "CPU writes random data to Layer 1's MEM address 0");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	dest_short_addr = 4'h3;
	mem_addr = 0;
	word_counter = 0;
    state = TB_MEM_WRITE;
	@ (posedge c0_tx_succ|c0_tx_fail);

    #100000;
	task_counter = task_counter + 1;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK%d, MEM Read", task_counter);
    $fdisplay(handle, "Read Layer 1's MEM address 0, and write to layer 2's MEM, address 0x1");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	dest_short_addr = 4'h3;
	mem_read_length = 0;
	mem_addr = 0;
	relay_addr = ((4'h4<<4) | `LC_CMD_MEM_WRITE);
	mem_relay_loc = 30'd1;
    state = TB_MEM_READ;
	@ (posedge c0_tx_succ|c0_tx_fail);
	@ (posedge layer1.tx_succ | layer1.tx_fail);

    #100000;
	task_counter = task_counter + 1;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK%d, MEM Write", task_counter);
    $fdisplay(handle, "CPU bulk writes random data to Layer 1's MEM address 1-10, bulk active is not set");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	dest_short_addr = 4'h3;
	mem_addr = 1;
	word_counter = 9;
    state = TB_MEM_WRITE;
	@ (posedge c0_tx_succ|c0_tx_fail);

    #100000;
	task_counter = task_counter + 1;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK%d, RF Write", task_counter);
    $fdisplay(handle, "CPU configures Layer 1 default sys register bulk mem message control, set active, length 0");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	rf_addr = BULK_MEM_CTRL_REG_IDX;
	dest_short_addr = 4'h3;
	rf_w_data = 24'hc0_0000;
    state = TB_SINGLE_RF_WRITE;
	@ (posedge c0_tx_succ|c0_tx_fail);

    #100000;
	task_counter = task_counter + 1;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK%d, MEM Write", task_counter);
    $fdisplay(handle, "CPU bulk writes random data to Layer 1's MEM address 1-2, bulk active is set, length is 0, only write 1 word");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	dest_short_addr = 4'h3;
	mem_addr = 1;
	word_counter = 1;
    state = TB_MEM_WRITE;
	@ (posedge c0_tx_succ|c0_tx_fail);

    #100000;
	task_counter = task_counter + 1;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK%d, MEM Write", task_counter);
    $fdisplay(handle, "CPU bulk writes random data to Layer 1's MEM address 1-3, bulk active is set, length is 0, only write 1 word, should fail");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	dest_short_addr = 4'h3;
	mem_addr = 1;
	word_counter = 2;
    state = TB_MEM_WRITE;
	@ (posedge c0_tx_succ|c0_tx_fail);

    #100000;
	task_counter = task_counter + 1;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK%d, RF Write", task_counter);
    $fdisplay(handle, "CPU configures Layer 1 default sys register bulk mem message control, set active, length 16");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	rf_addr = BULK_MEM_CTRL_REG_IDX;
	dest_short_addr = 4'h3;
	rf_w_data = 24'hc0_000f;
    state = TB_SINGLE_RF_WRITE;
	@ (posedge c0_tx_succ|c0_tx_fail);

    #100000;
	task_counter = task_counter + 1;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK%d, MEM Write", task_counter);
    $fdisplay(handle, "CPU bulk writes random data to Layer 1's MEM address 1-10");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	dest_short_addr = 4'h3;
	mem_addr = 1;
	word_counter = 9;
    state = TB_MEM_WRITE;
	@ (posedge c0_tx_succ|c0_tx_fail);

	#100000;
	task_counter = task_counter + 1;
	$fdisplay(handle, "\n-------------------------------------------------------------------------");
	$fdisplay(handle, "TASK%d, RF Write", task_counter);
	$fdisplay(handle, "CPU configures Layer 3 default sys register bulk mem message control, set to maximum length 16");
	$fdisplay(handle, "-------------------------------------------------------------------------");
	rf_addr = BULK_MEM_CTRL_REG_IDX;
	dest_short_addr = 4'h5;
	rf_w_data = 24'hc0_000f;
	state = TB_SINGLE_RF_WRITE;
	@ (posedge c0_tx_succ|c0_tx_fail);

    #100000;
	task_counter = task_counter + 1;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK%d, MEM Read", task_counter);
    $fdisplay(handle, "Bulk read Layer 1's MEM address 1-10, and write to layer 3's MEM, address 0x0");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	dest_short_addr = 4'h3;
	mem_read_length = 9;
	mem_addr = 1;
	relay_addr = ((4'h5<<4) | `LC_CMD_MEM_WRITE);
	mem_relay_loc = 30'd0;
    state = TB_MEM_READ;
	@ (posedge c0_tx_succ|c0_tx_fail);
	@ (posedge layer1.tx_succ | layer1.tx_fail);

	#100000;
	task_counter = task_counter + 1;
	$fdisplay(handle, "\n-------------------------------------------------------------------------");
	$fdisplay(handle, "TASK%d, RF Write", task_counter);
	$fdisplay(handle, "CPU configures Layer 1's stream channel 0, register 0 ");
	$fdisplay(handle, "-------------------------------------------------------------------------");
	rf_addr = STREAM_CH0_REG0_IDX;				// only 2 channels available
	dest_short_addr = 4'h3;
	rf_w_data = 24'h00_0004;
	state = TB_SINGLE_RF_WRITE;
	@ (posedge c0_tx_succ|c0_tx_fail);

	#100000;
	task_counter = task_counter + 1;
	$fdisplay(handle, "\n-------------------------------------------------------------------------");
	$fdisplay(handle, "TASK%d, RF Write", task_counter);
	$fdisplay(handle, "CPU configures Layer 1's stream channel 0, register 1");
	$fdisplay(handle, "-------------------------------------------------------------------------");
	rf_addr = STREAM_CH0_REG1_IDX;				// only 2 channels available
	dest_short_addr = 4'h3;
	rf_w_data = {8'hf9, 16'b0};	// stream location 30'd1
	state = TB_SINGLE_RF_WRITE;
	@ (posedge c0_tx_succ|c0_tx_fail);

	#100000;
	task_counter = task_counter + 1;
	$fdisplay(handle, "\n-------------------------------------------------------------------------");
	$fdisplay(handle, "TASK%d, RF Write", task_counter);
	$fdisplay(handle, "CPU configures Layer 1's stream channel 0, register 2, register 3 should be written by layer controller itself");
	$fdisplay(handle, "-------------------------------------------------------------------------");
	rf_addr = STREAM_CH0_REG2_IDX;				// only 2 channels available
	dest_short_addr = 4'h3;
	rf_w_data = {4'b1010, 20'd15};
	state = TB_SINGLE_RF_WRITE;
	@ (posedge c0_tx_succ|c0_tx_fail);

	#100000;
	task_counter = task_counter + 1;
	$fdisplay(handle, "\n-------------------------------------------------------------------------");
	$fdisplay(handle, "TASK%d, RF Write", task_counter);
	$fdisplay(handle, "CPU configures Layer 1's stream channel 1, register 0 ");
	$fdisplay(handle, "-------------------------------------------------------------------------");
	rf_addr = STREAM_CH1_REG0_IDX;				// only 2 channels available
	dest_short_addr = 4'h3;
	rf_w_data = 24'h190;		// 100 << 2
	state = TB_SINGLE_RF_WRITE;
	@ (posedge c0_tx_succ|c0_tx_fail);

	#100000;
	task_counter = task_counter + 1;
	$fdisplay(handle, "\n-------------------------------------------------------------------------");
	$fdisplay(handle, "TASK%d, RF Write", task_counter);
	$fdisplay(handle, "CPU configures Layer 1's stream channel 1, register 1");
	$fdisplay(handle, "-------------------------------------------------------------------------");
	rf_addr = STREAM_CH1_REG1_IDX;				// only 2 channels available
	dest_short_addr = 4'h3;
	rf_w_data = {8'hf9, 16'b0};	// stream location 30'd100
	state = TB_SINGLE_RF_WRITE;
	@ (posedge c0_tx_succ|c0_tx_fail);

	#100000;
	task_counter = task_counter + 1;
	$fdisplay(handle, "\n-------------------------------------------------------------------------");
	$fdisplay(handle, "TASK%d, RF Write", task_counter);
	$fdisplay(handle, "CPU configures Layer 1's stream channel 1, register 2, register 3 should be written by layer controller itself");
	$fdisplay(handle, "-------------------------------------------------------------------------");
	rf_addr = STREAM_CH1_REG2_IDX;				// only 2 channels available
	dest_short_addr = 4'h3;
	rf_w_data = {4'b1110, 20'd7};
	state = TB_SINGLE_RF_WRITE;
	@ (posedge c0_tx_succ|c0_tx_fail);

	#100000;
	task_counter = task_counter + 1;
	$fdisplay(handle, "\n-------------------------------------------------------------------------");
	$fdisplay(handle, "TASK%d, Stream MEM Write", task_counter);
	$fdisplay(handle, "CPU sends 1 word streaming data to Layer 3's stream channel 0, enable is not set, should fail");
	$fdisplay(handle, "-------------------------------------------------------------------------");
	dest_short_addr = 4'h5;
	stream_channel = 0;
	word_counter = 2;
	state = TB_STREAMING;
	@ (posedge c0_tx_succ|c0_tx_fail);

	#100000;
	task_counter = task_counter + 1;
	$fdisplay(handle, "\n-------------------------------------------------------------------------");
	$fdisplay(handle, "TASK%d, Stream MEM Write", task_counter);
	$fdisplay(handle, "CPU sends 16 word streaming data to Layer 1's stream channel 0, CPU should receive a buffer full alert");
	$fdisplay(handle, "-------------------------------------------------------------------------");
	dest_short_addr = 4'h3;
	stream_channel = 0;
	word_counter = 15;
	state = TB_STREAMING;
	@ (posedge c0_tx_succ|c0_tx_fail);
	@ (posedge c0_rx_req)

	#100000;
	task_counter = task_counter + 1;
	$fdisplay(handle, "\n-------------------------------------------------------------------------");
	$fdisplay(handle, "TASK%d, Stream MEM Write", task_counter);
	$fdisplay(handle, "CPU sends 1 word streaming data to Layer 1's stream channel 0, nothing happens");
	$fdisplay(handle, "-------------------------------------------------------------------------");
	dest_short_addr = 4'h3;
	stream_channel = 0;
	state = TB_STREAMING;
	@ (posedge c0_tx_succ|c0_tx_fail);

	#100000;
	task_counter = task_counter + 1;
	$fdisplay(handle, "\n-------------------------------------------------------------------------");
	$fdisplay(handle, "TASK%d, RF Write", task_counter);
	$fdisplay(handle, "CPU configures Layer 1's stream channel 0, register 2, register 3 should be written by layer controller itself");
	$fdisplay(handle, "-------------------------------------------------------------------------");
	rf_addr = STREAM_CH0_REG2_IDX;				// only 2 channels available
	dest_short_addr = 4'h3;
	rf_w_data = {4'b1010, 20'd15};
	state = TB_SINGLE_RF_WRITE;
	@ (posedge c0_tx_succ|c0_tx_fail);

	#100000;
	task_counter = task_counter + 1;
	$fdisplay(handle, "\n-------------------------------------------------------------------------");
	$fdisplay(handle, "TASK%d, Stream MEM Write", task_counter);
	$fdisplay(handle, "CPU sends 1 word streaming data to Layer 1's stream channel 0");
	$fdisplay(handle, "-------------------------------------------------------------------------");
	dest_short_addr = 4'h3;
	stream_channel = 0;
	state = TB_STREAMING;
	@ (posedge c0_tx_succ|c0_tx_fail);

	#100000;
	task_counter = task_counter + 1;
	$fdisplay(handle, "\n-------------------------------------------------------------------------");
	$fdisplay(handle, "TASK%d, Stream MEM Write", task_counter);
	$fdisplay(handle, "CPU sends 10 word streaming data to Layer 1's stream channel 0, CPU should receive a double buffer alert");
	$fdisplay(handle, "-------------------------------------------------------------------------");
	dest_short_addr = 4'h3;
	stream_channel = 0;
	word_counter = 9;
	state = TB_STREAMING;
	@ (posedge c0_tx_succ|c0_tx_fail);
	@ (posedge c0_rx_req)

	#100000;
	task_counter = task_counter + 1;
	$fdisplay(handle, "\n-------------------------------------------------------------------------");
	$fdisplay(handle, "TASK%d, Stream MEM Write", task_counter);
	$fdisplay(handle, "CPU sends 10 word streaming data to Layer 1's stream channel 0, only 5 words are available, TX should fail, and generates alert");
	$fdisplay(handle, "-------------------------------------------------------------------------");
	dest_short_addr = 4'h3;
	stream_channel = 0;
	word_counter = 9;
	state = TB_STREAMING;
	@ (posedge c0_tx_succ|c0_tx_fail);
	@ (posedge c0_rx_req)

	#100000;
	task_counter = task_counter + 1;
	$fdisplay(handle, "\n-------------------------------------------------------------------------");
	$fdisplay(handle, "TASK%d, Stream MEM Write", task_counter);
	$fdisplay(handle, "CPU sends 4 word streaming data to Layer 1's stream channel 1, generates double buffer alert");
	$fdisplay(handle, "-------------------------------------------------------------------------");
	dest_short_addr = 4'h3;
	stream_channel = 1;
	word_counter = 3;
	state = TB_STREAMING;
	@ (posedge c0_tx_succ|c0_tx_fail);
	@ (posedge c0_rx_req)

	#100000;
	task_counter = task_counter + 1;
	$fdisplay(handle, "\n-------------------------------------------------------------------------");
	$fdisplay(handle, "TASK%d, Stream MEM Write", task_counter);
	$fdisplay(handle, "CPU sends 4 word streaming data to Layer 1's stream channel 1, generates buffer full alert");
	$fdisplay(handle, "-------------------------------------------------------------------------");
	dest_short_addr = 4'h3;
	stream_channel = 1;
	word_counter = 3;
	state = TB_STREAMING;
	@ (posedge c0_tx_succ|c0_tx_fail);
	@ (posedge c0_rx_req)

	#100000;
	task_counter = task_counter + 1;
	$fdisplay(handle, "\n-------------------------------------------------------------------------");
	$fdisplay(handle, "TASK%d, Stream MEM Write", task_counter);
	$fdisplay(handle, "CPU sends 8 word streaming data to Layer 1's stream channel 1, generates alert 0xe");
	$fdisplay(handle, "-------------------------------------------------------------------------");
	dest_short_addr = 4'h3;
	stream_channel = 1;
	word_counter = 7;
	state = TB_STREAMING;
	@ (posedge c0_tx_succ|c0_tx_fail);
	@ (posedge c0_rx_req)

	#100000;
	task_counter = task_counter + 1;
	$fdisplay(handle, "\n-------------------------------------------------------------------------");
	$fdisplay(handle, "TASK%d, Stream MEM Write", task_counter);
	$fdisplay(handle, "CPU sends 16 word streaming data to Layer 1's stream channel 1, generates alert 0xf");
	$fdisplay(handle, "-------------------------------------------------------------------------");
	dest_short_addr = 4'h3;
	stream_channel = 1;
	word_counter = 15;
	state = TB_STREAMING;
	@ (posedge c0_tx_succ|c0_tx_fail);
	@ (posedge c0_rx_req)

	#100000;
	task_counter = task_counter + 1;
	$fdisplay(handle, "\n-------------------------------------------------------------------------");
	$fdisplay(handle, "TASK%d, RF Write", task_counter);
	$fdisplay(handle, "CPU configures Layer 1's stream channel 1, register 2, register 3 should be written by layer controller itself");
	$fdisplay(handle, "-------------------------------------------------------------------------");
	rf_addr = STREAM_CH1_REG2_IDX;				// only 2 channels available
	dest_short_addr = 4'h3;
	rf_w_data = {4'b1100, 20'd7};
	state = TB_SINGLE_RF_WRITE;
	@ (posedge c0_tx_succ|c0_tx_fail);

	#100000;
	task_counter = task_counter + 1;
	$fdisplay(handle, "\n-------------------------------------------------------------------------");
	$fdisplay(handle, "TASK%d, RF Write", task_counter);
	$fdisplay(handle, "Read layer 3's MEM and stream to layer 1's MEM, channel 1");
	$fdisplay(handle, "-------------------------------------------------------------------------");
	dest_short_addr = 4'h5;
	mem_read_length = 3;
	mem_addr = 0;
	relay_addr = {4'd3, 2'b01, 2'b01};	// to layer 1, stream, channel 1
	state = TB_SHORT_MEM_READ;
	@ (posedge c0_tx_succ|c0_tx_fail);
	@ (posedge layer3.tx_succ | layer3.tx_fail);

    #100000;
	task_counter = task_counter + 1;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK%d, Select sleep", task_counter);
    $fdisplay(handle, "Select sleep using long prefix, Sleep layer 1");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	long_addr = 20'hbbbb1;
	state = TB_SEL_SLEEP_FULL_PREFIX;
	@ (posedge c0_tx_succ|c0_tx_fail);

    #100000;
	task_counter = task_counter + 1;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK%d, MEM Write", task_counter);
    $fdisplay(handle, "CPU writes random data to Layer 1's MEM address 0xa");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	dest_short_addr = 4'h3;
	mem_addr = 30'ha;
	word_counter = 0;
    state = TB_MEM_WRITE;
	@ (posedge c0_tx_succ|c0_tx_fail);

    #100000;
	task_counter = task_counter + 1;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK%d, Interrupt", task_counter);
    $fdisplay(handle, "Layer 1, Interrupt vector 0, Read layer 1's RF address 0, and write to layer 2's RF address 0");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	layer_number = 1;
	int_vec = 0;	
    state = TB_SINGLE_INTERRUPT;
	@ (posedge n1_clr_int[int_vec]);

    #100000;
	task_counter = task_counter + 1;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK%d, Interrupt", task_counter);
    $fdisplay(handle, "Layer 1, Interrupt vector 1, Bulk read layer 1's RF address 2-6, and write to layer 2's RF address 2");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	layer_number = 1;
	int_vec = 1;	
    state = TB_SINGLE_INTERRUPT;
	@ (posedge n1_clr_int[int_vec]);

    #100000;
	task_counter = task_counter + 1;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK%d, RF Write", task_counter);
    $fdisplay(handle, "CPU bulk writes random data to Layer 1 RF address 0-9");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	rf_addr = 0;
	dest_short_addr = 4'h3;
	word_counter = 9;
    state = TB_RF_WRITE;
	@ (posedge c0_tx_succ|c0_tx_fail);

	#100000;
	task_counter = task_counter + 1;
	$fdisplay(handle, "\n-------------------------------------------------------------------------");
	$fdisplay(handle, "TASK%d, RF Write", task_counter);
	$fdisplay(handle, "CPU configures Layer 2's stream channel 0, register 0");
	$fdisplay(handle, "-------------------------------------------------------------------------");
	rf_addr = STREAM_CH0_REG0_IDX;				// only 2 channels available
	dest_short_addr = 4'h4;
	rf_w_data = 24'h190;		// 100 << 2
	state = TB_SINGLE_RF_WRITE;
	@ (posedge c0_tx_succ|c0_tx_fail);

	#100000;
	task_counter = task_counter + 1;
	$fdisplay(handle, "\n-------------------------------------------------------------------------");
	$fdisplay(handle, "TASK%d, RF Write", task_counter);
	$fdisplay(handle, "CPU configures Layer 2's stream channel 0, register 1");
	$fdisplay(handle, "-------------------------------------------------------------------------");
	rf_addr = STREAM_CH0_REG1_IDX;				// only 2 channels available
	dest_short_addr = 4'h4;
	rf_w_data = {8'hf9, 16'b0};	// stream location 30'd100
	state = TB_SINGLE_RF_WRITE;
	@ (posedge c0_tx_succ|c0_tx_fail);

	#100000;
	task_counter = task_counter + 1;
	$fdisplay(handle, "\n-------------------------------------------------------------------------");
	$fdisplay(handle, "TASK%d, RF Write", task_counter);
	$fdisplay(handle, "CPU configures Layer 2's stream channel 0, register 2, register 3 should be written by layer controller itself");
	$fdisplay(handle, "-------------------------------------------------------------------------");
	rf_addr = STREAM_CH0_REG2_IDX;				// only 2 channels available
	dest_short_addr = 4'h4;
	rf_w_data = {4'b1100, 20'd15};	// maximum length = 16
	state = TB_SINGLE_RF_WRITE;
	@ (posedge c0_tx_succ|c0_tx_fail);

	#100000;
	task_counter = task_counter + 1;
	$fdisplay(handle, "\n-------------------------------------------------------------------------");
	$fdisplay(handle, "TASK%d, RF Write", task_counter);
	$fdisplay(handle, "CPU configures Layer 2's stream channel 1, register 0");
	$fdisplay(handle, "-------------------------------------------------------------------------");
	rf_addr = STREAM_CH1_REG0_IDX;
	dest_short_addr = 4'h4;
	rf_w_data = 24'hc8;			// 50 << 2
	state = TB_SINGLE_RF_WRITE;
	@ (posedge c0_tx_succ|c0_tx_fail);

	#100000;
	task_counter = task_counter + 1;
	$fdisplay(handle, "\n-------------------------------------------------------------------------");
	$fdisplay(handle, "TASK%d, RF Write", task_counter);
	$fdisplay(handle, "CPU configures Layer 2's stream channel 1, register 1");
	$fdisplay(handle, "-------------------------------------------------------------------------");
	rf_addr = STREAM_CH1_REG1_IDX;
	dest_short_addr = 4'h4;
	rf_w_data = {8'hf9, 16'b0};	// stream location 30'd50
	state = TB_SINGLE_RF_WRITE;
	@ (posedge c0_tx_succ|c0_tx_fail);

	#100000;
	task_counter = task_counter + 1;
	$fdisplay(handle, "\n-------------------------------------------------------------------------");
	$fdisplay(handle, "TASK%d, RF Write", task_counter);
	$fdisplay(handle, "CPU configures Layer 2's stream channel 1, register 2, register 3 should be written by layer controller itself");
	$fdisplay(handle, "-------------------------------------------------------------------------");
	rf_addr = STREAM_CH1_REG2_IDX;
	dest_short_addr = 4'h4;
	rf_w_data = {4'b1110, 20'd4};	// maximum length = 5
	state = TB_SINGLE_RF_WRITE;
	@ (posedge c0_tx_succ|c0_tx_fail);

    #100000;
	task_counter = task_counter + 1;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK%d, Interrupt", task_counter);
    $fdisplay(handle, "Layer 1, Interrupt vector 2, Bulk read layer 1's RF address 0-9, and stream to layer 2's MEM address 100");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	layer_number = 1;
	int_vec = 2;	
    state = TB_SINGLE_INTERRUPT;
	@ (posedge n1_clr_int[int_vec]);

    #100000;
	task_counter = task_counter + 1;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK%d, Interrupt", task_counter);
    $fdisplay(handle, "Layer 1, Interrupt vector 3, Write to layer 1's RF address 0");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	layer_number = 1;
	int_vec = 3;	
    state = TB_SINGLE_INTERRUPT;
	@ (posedge n1_clr_int[int_vec]);

    #100000;
	task_counter = task_counter + 1;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK%d, Interrupt", task_counter);
    $fdisplay(handle, "Layer 1, Interrupt vector 4, Write to layer 1's RF address 1, and 3");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	layer_number = 1;
	int_vec = 4;	
    state = TB_SINGLE_INTERRUPT;
	@ (posedge n1_clr_int[int_vec]);

    #100000;
	task_counter = task_counter + 1;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK%d, Interrupt", task_counter);
    $fdisplay(handle, "Layer 1, Interrupt vector 5, Write to layer 1's RF address 2, 4, and 6");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	layer_number = 1;
	int_vec = 5;	
    state = TB_SINGLE_INTERRUPT;
	@ (posedge n1_clr_int[int_vec]);

    #100000;
	task_counter = task_counter + 1;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK%d, Interrupt", task_counter);
    $fdisplay(handle, "Layer 1, Interrupt vector 6, Read from layer 1's MEM address 0, and write to layer 2's MEM, address 0x1");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	layer_number = 1;
	int_vec = 6;	
    state = TB_SINGLE_INTERRUPT;
	@ (posedge n1_clr_int[int_vec]);

    #100000;
	task_counter = task_counter + 1;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK%d, RF Write", task_counter);
    $fdisplay(handle, "CPU configures Layer 2 default sys register bulk mem message control, set to maximum length 16");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	rf_addr = BULK_MEM_CTRL_REG_IDX;
	dest_short_addr = 4'h4;
	rf_w_data = 24'hc0_000f;
    state = TB_SINGLE_RF_WRITE;
	@ (posedge c0_tx_succ|c0_tx_fail);

    #100000;
	task_counter = task_counter + 1;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK%d, Select sleep", task_counter);
    $fdisplay(handle, "Select sleep using long prefix, Sleep layer 1");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	long_addr = 20'hbbbb1;
	state = TB_SEL_SLEEP_FULL_PREFIX;
	@ (posedge c0_tx_succ|c0_tx_fail);

    #100000;
	task_counter = task_counter + 1;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK%d, Interrupt", task_counter);
    $fdisplay(handle, "Layer 1, Interrupt vector 7, Bulk read from layer 1's MEM address 1-5, and write to layer 2's MEM, address 2-6");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	layer_number = 1;
	int_vec = 7;	
    state = TB_SINGLE_INTERRUPT;
	@ (posedge n1_clr_int[int_vec]);

    #100000;
	task_counter = task_counter + 1;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK%d, Interrupt", task_counter);
    $fdisplay(handle, "Layer 2, Interrupt vector 8, Read from layer 2's MEM address 100, and write to layer 1's RF (ADDRESS is burried in MEM)");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	layer_number = 2;	// THIS IS ASSERTED FROM LAYER 2
	int_vec = 8;	
    state = TB_SINGLE_INTERRUPT;
	@ (posedge n2_clr_int[int_vec]);

    #100000;
	task_counter = task_counter + 1;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK%d, Interrupt", task_counter);
    $fdisplay(handle, "Layer 2, Interrupt vector 9, Read from layer 2's MEM address 101-104, and write to layer 1's RF (ADDRESS is burried in MEM)");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	layer_number = 2;	// THIS IS ASSERTED FROM LAYER 2
	int_vec = 9;	
    state = TB_SINGLE_INTERRUPT;
	@ (posedge n2_clr_int[int_vec]);

    #100000;
	task_counter = task_counter + 1;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK%d, Interrupt", task_counter);
    $fdisplay(handle, "Layer 1, Interrupt vector 10, Bulk read from layer 1's MEM address 0-9, stream to layer 2's MEM, alert should generate");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	layer_number = 1;
	int_vec = 10;	
    state = TB_SINGLE_INTERRUPT;
	@ (posedge n1_clr_int[int_vec]);
	@ (posedge c0_rx_req)

    #100000;
	task_counter = task_counter + 1;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK%d, Sleep all", task_counter);
    $fdisplay(handle, "-------------------------------------------------------------------------");
	state = TB_ALL_SLEEP;
	@ (posedge c0_tx_succ|c0_tx_fail);

    #100000;
	task_counter = task_counter + 1;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK%d, Interrupt", task_counter);
    $fdisplay(handle, "Layer 1, Interrupt vector 11, Wakeup only");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	layer_number = 1;
	int_vec = 11;	
    state = TB_SINGLE_INTERRUPT;
	@ (posedge n1_clr_int[int_vec]);

    #100000;
	task_counter = task_counter + 1;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK%d, Master node and Processor wake up", task_counter);
    $fdisplay(handle, "-------------------------------------------------------------------------");
    state = TB_PROC_UP;
	@ (posedge SCLK);
	c0_req_int = 0;
    #50000;

    #100000;
	task_counter = task_counter + 1;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK%d, Error command test", task_counter);
    $fdisplay(handle, "CPU sends a command with an unknown functional ID");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	dest_short_addr = 4'h3;
	functional_id = 4'b1100;
	word_counter = 1;
    state = TB_ARBITRARY_CMD;
	@ (posedge c0_tx_succ|c0_tx_fail);

    #100000;
	task_counter = task_counter + 1;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK%d, Error command test", task_counter);
    $fdisplay(handle, "Bulk read Layer 1's MEM address 0-1, and read layer 3's RF");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	dest_short_addr = 4'h3;
	mem_read_length = 1;
	mem_addr = 0;
	relay_addr = ((4'h5<<4) | `LC_CMD_RF_READ);		// Fake RF read
	// Read RF from 192-197, write to layer 2's RF location 0 <- This is an invalid RF read command
	mem_relay_loc = (8'd192<<22 | 8'd5<<14 | 4'h4<<10 | `LC_CMD_RF_WRITE<<6 | 6'h0);
    state = TB_MEM_READ;
	@ (posedge c0_tx_succ|c0_tx_fail);
	@ (posedge layer1.tx_succ | layer1.tx_fail);

    #100000;
	task_counter = task_counter + 1;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK%d, Error command test", task_counter);
    $fdisplay(handle, "Read Layer 1's MEM address 0, and read layer 3's RF");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	dest_short_addr = 4'h3;
	mem_read_length = 0;
	mem_addr = 0;
	relay_addr = ((4'h5<<4) | `LC_CMD_RF_READ);		// Fake RF read
	// Read RF from 192-197 (non-existing location), write to layer 2's RF location 0 <- This is an invalid RF read command
	mem_relay_loc = (8'd192<<22 | 8'd5<<14 | 4'h4<<10 | `LC_CMD_RF_WRITE<<6 | 6'h0);
    state = TB_MEM_READ;
	@ (posedge c0_tx_succ|c0_tx_fail);
	@ (posedge layer1.tx_succ | layer1.tx_fail);

    #100000;
	task_counter = task_counter + 1;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK%d, RF Read", task_counter);
    $fdisplay(handle, "Read Layer 1's RF address 250-4, and send to processor, coverage test");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	dest_short_addr = 4'h3;
	rf_addr = 8'd250;
	rf_read_length = 9;
	relay_addr = {4'h1, `LC_CMD_RF_WRITE}; // FUID don't care
	rf_relay_loc = 8'ha;	// don't care
    state = TB_RF_READ;
	@ (posedge c0_tx_succ|c0_tx_fail);
	@ (posedge layer1.tx_succ|layer1.tx_fail);

    #100000;
	task_counter = task_counter + 1;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK%d, Error command test", task_counter);
    $fdisplay(handle, "Invalid MEM read command");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	dest_short_addr = 4'h3;
	functional_id = `LC_CMD_MEM_READ;
	word_counter = 0;
    state = TB_ARBITRARY_CMD;
	@ (posedge c0_tx_succ|c0_tx_fail);

    #100000;
	task_counter = task_counter + 1;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK%d, Error command test", task_counter);
    $fdisplay(handle, "Invalid MEM read command");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	dest_short_addr = 4'h3;
	functional_id = `LC_CMD_MEM_READ;
	word_counter = 5;
    state = TB_ARBITRARY_CMD;
	@ (posedge c0_tx_succ|c0_tx_fail);

    #100000;
	task_counter = task_counter + 1;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK%d, Error command test", task_counter);
    $fdisplay(handle, "Invalid MEM write command");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	dest_short_addr = 4'h3;
	functional_id = `LC_CMD_MEM_WRITE;
	word_counter = 0;
    state = TB_ARBITRARY_CMD;
	@ (posedge c0_tx_succ|c0_tx_fail);

	#100000;
	task_counter = task_counter + 1;
	$fdisplay(handle, "\n-------------------------------------------------------------------------");
	$fdisplay(handle, "TASK%d, Stream", task_counter);
	$fdisplay(handle, "CPU sends 1 word streaming data to Layer 3's stream channel 0. (stream enable = 0, no MEM operation)");
	$fdisplay(handle, "-------------------------------------------------------------------------");
	dest_short_addr = 4'h5;
	stream_channel = 0;
	word_counter = 0;
	state = TB_STREAMING;
	@ (posedge c0_tx_succ|c0_tx_fail);

    #100000;
	task_counter = task_counter + 1;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK%d, Interrupt", task_counter);
    $fdisplay(handle, "Layer 1, Interrupt vector 12, Invalid interrupt command");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	layer_number = 1;
	int_vec = 12;	
    state = TB_SINGLE_INTERRUPT;
	@ (posedge n1_clr_int[int_vec]);

    #100000;
	task_counter = task_counter + 1;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK%d, RF Write", task_counter);
    $fdisplay(handle, "CPU configures Layer 1 default sys register bulk mem message control, set to maximum length 64");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	rf_addr = BULK_MEM_CTRL_REG_IDX;
	dest_short_addr = 4'h3;
	rf_w_data = 24'hc0_003f;
    state = TB_SINGLE_RF_WRITE;
	@ (posedge c0_tx_succ|c0_tx_fail);

    #100000;
	task_counter = task_counter + 1;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK%d, RF Write", task_counter);
    $fdisplay(handle, "CPU configures Layer 2 default sys register bulk mem message control, set to maximum length 64");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	rf_addr = BULK_MEM_CTRL_REG_IDX;
	dest_short_addr = 4'h4;
	rf_w_data = 24'hc0_003f;
    state = TB_SINGLE_RF_WRITE;
	@ (posedge c0_tx_succ|c0_tx_fail);

    #100000;
	task_counter = task_counter + 1;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK%d, MEM Write", task_counter);
    $fdisplay(handle, "CPU bulk writes random data to Layer 1's MEM address 0-63");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	dest_short_addr = 4'h3;
	mem_addr = 0;
	word_counter = 63;
    state = TB_MEM_WRITE;
	@ (posedge c0_tx_succ|c0_tx_fail);

    #100000;
	task_counter = task_counter + 1;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK%d, MEM Read", task_counter);
    $fdisplay(handle, "Read Layer 1's MEM address 0, and write to layer 2's MEM, address 0x0");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	dest_short_addr = 4'h3;
	mem_read_length = 63;
	mem_addr = 0;
	relay_addr = ((4'h4<<4) | `LC_CMD_MEM_WRITE);
	mem_relay_loc = 30'd0;
    state = TB_MEM_READ;
	@ (posedge c0_tx_succ|c0_tx_fail);
	@ (posedge layer1.tx_succ | layer1.tx_fail);

    #500000;
    $display("*************************************");
    $display("************TASK0 Complete***********");
    $display("*************************************");
    $finish;
end
endtask // task0

// Interrupt only
task task1;
begin
    handle=$fopen("result_task1.txt");

    #100000;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK0%d, Master node and Processor wake up", task_counter);
    $fdisplay(handle, "-------------------------------------------------------------------------");
    state = TB_PROC_UP;
	@ (posedge SCLK);
	c0_req_int = 0;
    #50000;

    #100000;
	task_counter = task_counter + 1;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK%d, Query", task_counter);
    $fdisplay(handle, "Master node sends out query");
    $fdisplay(handle, "-------------------------------------------------------------------------");
    state = TB_QUERY;
	@ (posedge c0_rx_req);
	@ (posedge c0_rx_req);
	@ (posedge c0_rx_req);
	@ (posedge c0_rx_req);

    #100000;
	task_counter = task_counter + 1;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK%d, Enumerate", task_counter);
    $fdisplay(handle, "Master node enumerate with address 4'h2");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	enum_short_addr = 4'h2;
    state = TB_ENUM;
	@ (posedge c0_rx_req);

    #100000;
	task_counter = task_counter + 1;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK%d, Enumerate", task_counter);
    $fdisplay(handle, "Master node enumerate with address 4'h3");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	enum_short_addr = 4'h3;
    state = TB_ENUM;
	@ (posedge c0_rx_req);

    #100000;
	task_counter = task_counter + 1;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK%d, Enumerate", task_counter);
    $fdisplay(handle, "Master node enumerate with address 4'h4");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	enum_short_addr = 4'h4;
    state = TB_ENUM;
	@ (posedge c0_rx_req);

    #100000;
	task_counter = task_counter + 1;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK%d, Enumerate", task_counter);
    $fdisplay(handle, "Master node enumerate with address 4'h5");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	enum_short_addr = 4'h5;
    state = TB_ENUM;
	@ (posedge c0_rx_req);

    #100000;
	task_counter = task_counter + 1;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK%d, All Wake", task_counter);
    $fdisplay(handle, "-------------------------------------------------------------------------");
    state = TB_ALL_WAKEUP;
	@ (posedge c0_tx_succ | c0_tx_fail);

    #100000;
	task_counter = task_counter + 1;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK%d, MEM Write", task_counter);
    $fdisplay(handle, "CPU bulk writes random data to Layer 1's MEM address 1-3, no MEM present, should fail");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	dest_short_addr = 4'h3;
	mem_addr = 1;
	word_counter = 2;
    state = TB_MEM_WRITE;
	@ (posedge c0_tx_succ|c0_tx_fail);

    #100000;
	task_counter = task_counter + 1;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK%d, MEM Read", task_counter);
    $fdisplay(handle, "Read Layer 1's MEM address 0, and write to layer 2's MEM, address 0x0, no MEM present, should fail");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	dest_short_addr = 4'h3;
	mem_read_length = 63;
	mem_addr = 0;
	relay_addr = ((4'h4<<4) | `LC_CMD_MEM_WRITE);
	mem_relay_loc = 30'd0;
    state = TB_MEM_READ;
	@ (posedge c0_tx_succ|c0_tx_fail);

    #100000;
	task_counter = task_counter + 1;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK%d, Sleep all", task_counter);
    $fdisplay(handle, "-------------------------------------------------------------------------");
	state = TB_ALL_SLEEP;
	@ (posedge c0_tx_succ|c0_tx_fail);

    #100000;
	task_counter = task_counter + 1;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK%d, Interrupt", task_counter);
    $fdisplay(handle, "Layer 1, Interrupt vector 7, MEM read, no MEM present. only wakeup layer controller");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	layer_number = 1;
	int_vec = 7;	
    state = TB_SINGLE_INTERRUPT;
	@ (posedge n1_clr_int[int_vec]);

    #100000;
	task_counter = task_counter + 1;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK%d, Master node and Processor wake up", task_counter);
    $fdisplay(handle, "-------------------------------------------------------------------------");
    state = TB_PROC_UP;
	@ (posedge SCLK);
	c0_req_int = 0;
    #50000;

    #100000;
	task_counter = task_counter + 1;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK%d, RF Write", task_counter);
    $fdisplay(handle, "CPU bulk writes random data to Layer 1 RF address 0-9");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	rf_addr = 0;
	dest_short_addr = 4'h3;
	word_counter = 9;
    state = TB_RF_WRITE;
	@ (posedge c0_tx_succ|c0_tx_fail);

    #100000;
	task_counter = task_counter + 1;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK%d, RF Read", task_counter);
    $fdisplay(handle, "Read Layer 1's RF address 0, and write to Layer 2's RF address 0xa");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	dest_short_addr = 4'h3;
	rf_addr = 0;
	rf_read_length = 9;
	relay_addr = ((4'h4<<4) | `LC_CMD_RF_WRITE);
	rf_relay_loc = 8'ha;
    state = TB_RF_READ;
	@ (posedge c0_tx_succ|c0_tx_fail);
	@ (posedge layer1.tx_succ|layer1.tx_fail);

	#100000;
	task_counter = task_counter + 1;
	$fdisplay(handle, "\n-------------------------------------------------------------------------");
	$fdisplay(handle, "TASK%d, Stream MEM Write", task_counter);
	$fdisplay(handle, "CPU sends 1 word streaming data to Layer 3's stream channel 0, no MEM present, should fail");
	$fdisplay(handle, "-------------------------------------------------------------------------");
	dest_short_addr = 4'h5;
	stream_channel = 0;
	word_counter = 2;
	state = TB_STREAMING;
	@ (posedge c0_tx_succ|c0_tx_fail);

    #100000;
	task_counter = task_counter + 1;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK%d, Interrupt", task_counter);
    $fdisplay(handle, "Layer 1, Interrupt vector 3, Write to layer 1's RF address 0");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	layer_number = 1;
	int_vec = 3;	
    state = TB_SINGLE_INTERRUPT;
	@ (posedge n1_clr_int[int_vec]);

    #100000;
	task_counter = task_counter + 1;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK%d, Interrupt", task_counter);
    $fdisplay(handle, "Layer 1, Interrupt vector 4, Write to layer 1's RF address 1, and 3");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	layer_number = 1;
	int_vec = 4;	
    state = TB_SINGLE_INTERRUPT;
	@ (posedge n1_clr_int[int_vec]);

    #100000;
	task_counter = task_counter + 1;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK%d, Interrupt", task_counter);
    $fdisplay(handle, "Layer 1, Interrupt vector 0, Read layer 1's RF address 0, and write to layer 2's RF address 0");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	layer_number = 1;
	int_vec = 0;	
    state = TB_SINGLE_INTERRUPT;
	@ (posedge n1_clr_int[int_vec]);

    #100000;
	task_counter = task_counter + 1;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK%d, Interrupt", task_counter);
    $fdisplay(handle, "Layer 1, Interrupt vector 1, Bulk read layer 1's RF address 2-6, and write to layer 2's RF address 2");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	layer_number = 1;
	int_vec = 1;	
    state = TB_SINGLE_INTERRUPT;
	@ (posedge n1_clr_int[int_vec]);

	#100000;
	task_counter = task_counter + 1;
	$fdisplay(handle, "\n-------------------------------------------------------------------------");
	$fdisplay(handle, "TASK%d, RF Read", task_counter);
	$fdisplay(handle, "Read layer 3's MEM and stream to layer 1's MEM, channel 1, no MEM present, nothing should happen");
	$fdisplay(handle, "-------------------------------------------------------------------------");
	dest_short_addr = 4'h5;
	mem_read_length = 3;
	mem_addr = 0;
	relay_addr = {4'd3, 2'b01, 2'b01};	// to layer 1, stream, channel 1
	state = TB_SHORT_MEM_READ;
	@ (posedge c0_tx_succ|c0_tx_fail);

    #500000;
    $display("*************************************");
    $display("************TASK1 Complete***********");
    $display("*************************************");
    $finish;
end
endtask // end of task 1
`endif

task task2;
begin
    handle=$fopen("result_task2.txt");

    #100000;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK0%d, Master node and Processor wake up", task_counter);
    $fdisplay(handle, "-------------------------------------------------------------------------");
    state = TB_PROC_UP;
	@ (posedge SCLK);
	c0_req_int = 0;
    #50000;

    #100000;
	task_counter = task_counter + 1;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK%d, Query", task_counter);
    $fdisplay(handle, "Master node sends out query");
    $fdisplay(handle, "-------------------------------------------------------------------------");
    state = TB_QUERY;
	@ (posedge c0_rx_req);
	@ (posedge c0_rx_req);
	@ (posedge c0_rx_req);
	@ (posedge c0_rx_req);

    #100000;
	task_counter = task_counter + 1;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK%d, Enumerate", task_counter);
    $fdisplay(handle, "Master node enumerate with address 4'h2");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	enum_short_addr = 4'h2;
    state = TB_ENUM;
	@ (posedge c0_rx_req);

    #100000;
	task_counter = task_counter + 1;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK%d, Enumerate", task_counter);
    $fdisplay(handle, "Master node enumerate with address 4'h3");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	enum_short_addr = 4'h3;
    state = TB_ENUM;
	@ (posedge c0_rx_req);

    #100000;
	task_counter = task_counter + 1;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK%d, Enumerate", task_counter);
    $fdisplay(handle, "Master node enumerate with address 4'h4");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	enum_short_addr = 4'h4;
    state = TB_ENUM;
	@ (posedge c0_rx_req);

    #100000;
	task_counter = task_counter + 1;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK%d, Enumerate", task_counter);
    $fdisplay(handle, "Master node enumerate with address 4'h5");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	enum_short_addr = 4'h5;
    state = TB_ENUM;
	@ (posedge c0_rx_req);

    #100000;
	task_counter = task_counter + 1;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK%d, All Wake", task_counter);
    $fdisplay(handle, "-------------------------------------------------------------------------");
    state = TB_ALL_WAKEUP;
	@ (posedge c0_tx_succ | c0_tx_fail);

    #100000;
	task_counter = task_counter + 1;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK%d, MEM Write", task_counter);
    $fdisplay(handle, "CPU bulk writes random data to Layer 1's MEM address 1-3, no MEM present, should fail");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	dest_short_addr = 4'h3;
	mem_addr = 1;
	word_counter = 2;
    state = TB_MEM_WRITE;
	@ (posedge c0_tx_succ|c0_tx_fail);

    #100000;
	task_counter = task_counter + 1;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK%d, MEM Read", task_counter);
    $fdisplay(handle, "Read Layer 1's MEM address 0, and write to layer 2's MEM, address 0x0, no MEM present, should fail");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	dest_short_addr = 4'h3;
	mem_read_length = 63;
	mem_addr = 0;
	relay_addr = ((4'h4<<4) | `LC_CMD_MEM_WRITE);
	mem_relay_loc = 30'd0;
    state = TB_MEM_READ;
	@ (posedge c0_tx_succ|c0_tx_fail);

    #100000;
	task_counter = task_counter + 1;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK%d, Sleep all", task_counter);
    $fdisplay(handle, "-------------------------------------------------------------------------");
	state = TB_ALL_SLEEP;
	@ (posedge c0_tx_succ|c0_tx_fail);

    #100000;
	task_counter = task_counter + 1;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK%d, Master node and Processor wake up", task_counter);
    $fdisplay(handle, "-------------------------------------------------------------------------");
    state = TB_PROC_UP;
	@ (posedge SCLK);
	c0_req_int = 0;
    #50000;

    #100000;
	task_counter = task_counter + 1;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK%d, RF Write", task_counter);
    $fdisplay(handle, "CPU bulk writes random data to Layer 1 RF address 0-9");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	rf_addr = 0;
	dest_short_addr = 4'h3;
	word_counter = 9;
    state = TB_RF_WRITE;
	@ (posedge c0_tx_succ|c0_tx_fail);

    #100000;
	task_counter = task_counter + 1;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK%d, RF Read", task_counter);
    $fdisplay(handle, "Read Layer 1's RF address 0, and write to Layer 2's RF address 0xa");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	dest_short_addr = 4'h3;
	rf_addr = 0;
	rf_read_length = 9;
	relay_addr = ((4'h4<<4) | `LC_CMD_RF_WRITE);
	rf_relay_loc = 8'ha;
    state = TB_RF_READ;
	@ (posedge c0_tx_succ|c0_tx_fail);
	@ (posedge layer1.tx_succ|layer1.tx_fail);

	#100000;
	task_counter = task_counter + 1;
	$fdisplay(handle, "\n-------------------------------------------------------------------------");
	$fdisplay(handle, "TASK%d, Stream MEM Write", task_counter);
	$fdisplay(handle, "CPU sends 1 word streaming data to Layer 3's stream channel 0, no MEM present, should fail");
	$fdisplay(handle, "-------------------------------------------------------------------------");
	dest_short_addr = 4'h5;
	stream_channel = 0;
	word_counter = 2;
	state = TB_STREAMING;
	@ (posedge c0_tx_succ|c0_tx_fail);

    #100000;
	task_counter = task_counter + 1;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK%d, RF Write", task_counter);
    $fdisplay(handle, "CPU bulk writes random data to Layer 1 RF address 10");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	rf_addr = 10;
	dest_short_addr = 4'h3;
	word_counter = 0;
    state = TB_RF_WRITE;
	@ (posedge c0_tx_succ|c0_tx_fail);

    #100000;
	task_counter = task_counter + 1;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK%d, RF Read", task_counter);
    $fdisplay(handle, "Read Layer 1's RF address 10, and write to Layer 2's RF address 0xa");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	dest_short_addr = 4'h3;
	rf_addr = 10;
	rf_read_length = 0;
	relay_addr = ((4'h4<<4) | `LC_CMD_RF_WRITE);
	rf_relay_loc = 8'ha;
    state = TB_RF_READ;
	@ (posedge c0_tx_succ|c0_tx_fail);
	@ (posedge layer1.tx_succ|layer1.tx_fail);

    #100000;
	task_counter = task_counter + 1;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK%d, Sleep all", task_counter);
    $fdisplay(handle, "-------------------------------------------------------------------------");
	state = TB_ALL_SLEEP;
	@ (posedge c0_tx_succ|c0_tx_fail);

    #100000;
	task_counter = task_counter + 1;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK%d, Master node and Processor wake up", task_counter);
    $fdisplay(handle, "-------------------------------------------------------------------------");
    state = TB_PROC_UP;
	@ (posedge SCLK);
	c0_req_int = 0;
    #50000;

    #100000;
	task_counter = task_counter + 1;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK%d, RF Read", task_counter);
    $fdisplay(handle, "Read Layer 1's RF address 10, and write to Layer 2's RF address 0xa");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	dest_short_addr = 4'h3;
	rf_addr = 10;
	rf_read_length = 0;
	relay_addr = ((4'h4<<4) | `LC_CMD_RF_WRITE);
	rf_relay_loc = 8'ha;
    state = TB_RF_READ;
	@ (posedge c0_tx_succ|c0_tx_fail);
	@ (posedge layer1.tx_succ|layer1.tx_fail);

    #500000;
    $display("*************************************");
    $display("************TASK2 Complete***********");
    $display("*************************************");
    $finish;
end
endtask // end of task 2

