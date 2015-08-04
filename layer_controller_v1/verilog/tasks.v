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
task task0;
begin
    handle=$fopen("result_task0.txt");

    #100000;
    $fdisplay(handle, "\nTASK0, Master node and Processor wake up");
    state = TASK0;
	@ (posedge SCLK);
	c0_req_int = 0;
    #50000;

    #100000;
    $fdisplay(handle, "\nTASK1, Master node sends out querry");
    state = TASK1;
	@ (posedge c0_rx_req);
	@ (posedge c0_rx_req);
	@ (posedge c0_rx_req);
	@ (posedge c0_rx_req);

    #100000;
    $fdisplay(handle, "\nTASK2, Master node enumerate with address 4'h2");
    state = TASK2;
	@ (posedge c0_rx_req);

    #100000;
    $fdisplay(handle, "\nTASK3, Master node enumerate with address 4'h3");
    state = TASK3;
	@ (posedge c0_rx_req);

    #100000;
    $fdisplay(handle, "\nTASK4, Master node enumerate with address 4'h4");
    state = TASK4;
	@ (posedge c0_rx_req);

    #100000;
    $fdisplay(handle, "\nTASK5, Master node enumerate with address 4'h5");
    state = TASK5;
	@ (posedge c0_rx_req);

    #100000;
    $fdisplay(handle, "\nTASK6, All Wake");
    state = TASK6;
	@ (posedge c0_tx_succ | c0_tx_fail);

    #100000;
    $fdisplay(handle, "\nTASK7, write to Layer 1 RF address 0");
	rf_addr = 0;
	dest_short_addr = 4'h3;
    state = TASK7;
	@ (posedge c0_tx_succ|c0_tx_fail);

    #100000;
    $fdisplay(handle, "\nTASK7, write to Layer 1 RF address 1-4");
	rf_addr = 1;
	dest_short_addr = 4'h3;
	word_counter = 3;
    state = TASK7;
	@ (posedge c0_tx_succ|c0_tx_fail);
	word_counter = 0;

    #100000;
    $fdisplay(handle, "\nTASK7, write to Layer 1 RF address 67 (ROM, not writable)");
	rf_addr = 67;
	dest_short_addr = 4'h3;
    state = TASK7;
	@ (posedge c0_tx_succ|c0_tx_fail);

    #100000;
    $fdisplay(handle, "\nTASK8, read from Layer 1 RF address 0");
	rf_addr = 0;
	dest_short_addr = 4'h3;
	relay_addr = 8'h03;
    state = TASK8;
	@ (posedge c0_tx_succ|c0_tx_fail);
	@ (posedge c0_rx_req|c0_rx_fail);
   	$fdisplay(handle, "RF Addr: 8'h%h,\tData: 24'h%h", rf_addr, (c0_rx_data & 32'h00ff_ffff));

    #100000;
    $fdisplay(handle, "\nTASK8, read from Laer 1 RF address 1-4");
	rf_addr = 1;
	dest_short_addr = 4'h3;
	relay_addr = 8'h03;
	word_counter = 3;
    state = TASK8;
	@ (posedge c0_tx_succ|c0_tx_fail);
	@ (posedge layer1.tx_succ|layer1.tx_fail);
	word_counter = 0;

    #100000;
    $fdisplay(handle, "\nTASK8, read from Layer 1 RF address 67 (ROM)");
	rf_addr = 67;
	dest_short_addr = 4'h3;
	relay_addr = 8'h03;
    state = TASK8;
	@ (posedge c0_tx_succ|c0_tx_fail);
	@ (posedge c0_rx_req|c0_rx_fail);
   	$fdisplay(handle, "RF Addr: 8'h%h,\tData: 24'h%h", rf_addr, (c0_rx_data & 32'h00ff_ffff));

    #100000;
    $fdisplay(handle, "\nTASK9, write to Layer 1 MEM address 0");
	mem_addr = 0;
	dest_short_addr = 4'h3;
    state = TASK9;
	@ (posedge c0_tx_succ|c0_tx_fail);

    #100000;
    $fdisplay(handle, "\nTASK10, read from Layer 1 MEM address 0");
	mem_addr = 0;
	dest_short_addr = 4'h3;
	relay_addr = 8'h03;
    state = TASK10;
	@ (posedge c0_tx_succ|c0_tx_fail);
	@ (posedge c0_rx_req|c0_rx_fail);
   	$fdisplay(handle, "MEM Addr: 32'h%h,\tData: 32'h%h", mem_addr, c0_rx_data);

    #100000;
    $fdisplay(handle, "\nTASK11, sleep N1");
    state = TASK11;
	@ (posedge c0_tx_succ|c0_tx_fail);

    #100000;
    $fdisplay(handle, "\nTASK9, write to Layer 1 MEM address 1");
	mem_addr = 1;
	dest_short_addr = 4'h3;
    state = TASK9;
	@ (posedge c0_tx_succ|c0_tx_fail);

    #100000;
    $fdisplay(handle, "\nTASK9, write to Layer 1 MEM address 2");
	mem_addr = 2;
	dest_short_addr = 4'h3;
    state = TASK9;
	@ (posedge c0_tx_succ|c0_tx_fail);

    #100000;
    $fdisplay(handle, "\nTASK10, read from Layer 1 MEM address 1");
	mem_addr = 1;
	dest_short_addr = 4'h3;
	relay_addr = 8'h03;
    state = TASK10;
	@ (posedge c0_tx_succ|c0_tx_fail);
	@ (posedge c0_rx_req|c0_rx_fail);
   	$fdisplay(handle, "MEM Addr: 32'h%h,\tData: 32'h%h", mem_addr, c0_rx_data);

    #100000;
    $fdisplay(handle, "\nTASK10, read from Layer 1 MEM address 2");
	mem_addr = 2;
	dest_short_addr = 4'h3;
	relay_addr = 8'h03;
    state = TASK10;
	@ (posedge c0_tx_succ|c0_tx_fail);
	@ (posedge c0_rx_req|c0_rx_fail);
   	$fdisplay(handle, "MEM Addr: 32'h%h,\tData: 32'h%h", mem_addr, c0_rx_data);

    #100000;
    $fdisplay(handle, "\nTASK9, DMA write 16-word to Layer 1 MEM address 3-18");
	mem_addr = 3;
	dest_short_addr = 4'h3;
	word_counter = 15;
    state = TASK9;
	@ (posedge c0_tx_succ|c0_tx_fail);
	word_counter = 0;

    #100000;
    $fdisplay(handle, "\nTASK10, DMA read 16-word from Layer 1 MEM address 3-18");
	mem_addr = 3;
	dest_short_addr = 4'h3;
	relay_addr = 8'h03;
	word_counter = 15;
    state = TASK10;
	@ (posedge c0_tx_succ|c0_tx_fail);
	@ (posedge layer1.tx_succ|layer1.tx_fail);
	word_counter = 0;

    #100000;
    $fdisplay(handle, "\nTASK11, sleep N1");
    state = TASK11;
	@ (posedge c0_tx_succ|c0_tx_fail);

    #100000;
    $fdisplay(handle, "\nN1 request interrupt with vecto 8'h1");
	n1_int_vector <= 8'h1;
	@ (posedge layer1.tx_succ|layer1.tx_fail);

    #100000;
    $fdisplay(handle, "\nTASK9, write to Layer 1 Maximum MEM address");
	mem_addr = (LC_MEM_DEPTH-1'b1);
	dest_short_addr = 4'h3;
    state = TASK9;
	@ (posedge c0_tx_succ|c0_tx_fail);

    #100000;
    $fdisplay(handle, "\nTASK10, DMA read from Layer 1 invalid MEM address");
	mem_addr = LC_MEM_DEPTH;
	dest_short_addr = 4'h3;
	relay_addr = 8'h03;
    state = TASK10;
	@ (posedge c0_tx_succ|c0_tx_fail);

    #100000;
    $fdisplay(handle, "\nTASK10, DMA read from Layer 1 invalid MEM address, part 2");
	mem_addr = (LC_MEM_DEPTH-1'b1);
	dest_short_addr = 4'h3;
	relay_addr = 8'h03;
	word_counter = 1;
    state = TASK10;
	@ (posedge c0_tx_succ|c0_tx_fail);
	@ (posedge layer1.tx_succ|layer1.tx_fail);
	word_counter = 0;

    #100000;
    $fdisplay(handle, "\nTASK10, DMA read from Layer 1 invalid MEM address, part 3");
	mem_addr = (LC_MEM_DEPTH-1'b1);
	dest_short_addr = 4'h3;
	relay_addr = 8'h03;
	word_counter = 2;
    state = TASK10;
	@ (posedge c0_tx_succ|c0_tx_fail);
	@ (posedge layer1.tx_succ|layer1.tx_fail);
	word_counter = 0;

    #100000;
    $fdisplay(handle, "\nTASK10, DMA read from Layer 1 invalid MEM address, part 4");
	mem_addr = (LC_MEM_DEPTH-1'b1);
	dest_short_addr = 4'h3;
	relay_addr = 8'h03;
	word_counter = 3;
    state = TASK10;
	@ (posedge c0_tx_succ|c0_tx_fail);
	@ (posedge layer1.tx_succ|layer1.tx_fail);
	word_counter = 0;

    #100000;
    $fdisplay(handle, "\nTASK10, DMA read from Layer 1 invalid MEM address, part 5");
	mem_addr = LC_MEM_DEPTH;
	dest_short_addr = 4'h3;
	relay_addr = 8'h03;
	word_counter = 1;
    state = TASK10;
	@ (posedge c0_tx_succ|c0_tx_fail);
	word_counter = 0;

    #100000;
    $fdisplay(handle, "\nTASK7, write to Layer 1 maximum RF address");
	rf_addr = LC_RF_DEPTH-1'b1;
	dest_short_addr = 4'h3;
    state = TASK7;
	@ (posedge c0_tx_succ|c0_tx_fail);

    #100000;
    $fdisplay(handle, "\nTASK8, read from Layer 1 invalid RF address");
	rf_addr = LC_RF_DEPTH;
	dest_short_addr = 4'h3;
	relay_addr = 8'h03;
	word_counter = 0;
    state = TASK8;
	@ (posedge c0_tx_succ|c0_tx_fail);

    #100000;
    $fdisplay(handle, "\nTASK8, read from Layer 1 invalid RF address, part 2");
	rf_addr = LC_RF_DEPTH-1'b1;
	dest_short_addr = 4'h3;
	relay_addr = 8'h03;
	word_counter = 1;
    state = TASK8;
	@ (posedge c0_tx_succ|c0_tx_fail);
	@ (posedge layer1.tx_succ|layer1.tx_fail);
	word_counter = 0;

    #100000;
    $fdisplay(handle, "\nTASK8, read from Layer 1 invalid RF address, part 3");
	rf_addr = LC_RF_DEPTH-1'b1;
	dest_short_addr = 4'h3;
	relay_addr = 8'h03;
	word_counter = 2;
    state = TASK8;
	@ (posedge c0_tx_succ|c0_tx_fail);
	@ (posedge layer1.tx_succ|layer1.tx_fail);
	word_counter = 0;

    #100000;
    $fdisplay(handle, "\nTASK8, read from Layer 1 invalid RF address, part 4");
	rf_addr = LC_RF_DEPTH-1'b1;
	dest_short_addr = 4'h3;
	relay_addr = 8'h03;
	word_counter = 3;
    state = TASK8;
	@ (posedge c0_tx_succ|c0_tx_fail);
	@ (posedge layer1.tx_succ|layer1.tx_fail);
	word_counter = 0;

    #100000;
    $fdisplay(handle, "\nTASK7, write to Layer 1 invalid RF address");
	rf_addr = LC_RF_DEPTH;
	dest_short_addr = 4'h3;
	word_counter = 0;
    state = TASK7;
	@ (posedge c0_tx_succ|c0_tx_fail);

    #100000;
    $fdisplay(handle, "\nTASK7, write to Layer 1 invalid RF address, part 2");
	rf_addr = LC_RF_DEPTH-1'b1;
	dest_short_addr = 4'h3;
	word_counter = 1;
    state = TASK7;
	@ (posedge c0_tx_succ|c0_tx_fail);
	word_counter = 0;

    #100000;
    $fdisplay(handle, "\nTASK7, write to Layer 1 invalid RF address, part 3");
	rf_addr = LC_RF_DEPTH-1'b1;
	dest_short_addr = 4'h3;
	word_counter = 2;
    state = TASK7;
	@ (posedge c0_tx_succ|c0_tx_fail);
	word_counter = 0;

    #100000;
    $fdisplay(handle, "\nTASK7, write to Layer 1 invalid RF address, part 4");
	rf_addr = LC_RF_DEPTH-1'b1;
	dest_short_addr = 4'h3;
	word_counter = 3;
    state = TASK7;
	@ (posedge c0_tx_succ|c0_tx_fail);
	word_counter = 0;

    #100000;
    $fdisplay(handle, "\nTASK9, write to Layer 1 invalid MEM address");
	mem_addr = LC_MEM_DEPTH;
	dest_short_addr = 4'h3;
    state = TASK9;
	@ (posedge c0_tx_succ|c0_tx_fail);

    #100000;
    $fdisplay(handle, "\nTASK9, write to Layer 1 invalid MEM address, part 2");
	mem_addr = LC_MEM_DEPTH - 1'b1;
	dest_short_addr = 4'h3;
	word_counter = 1;
    state = TASK9;
	@ (posedge c0_tx_succ|c0_tx_fail);
	word_counter = 0;

    #100000;
    $fdisplay(handle, "\nTASK9, write to Layer 1 invalid MEM address, part 3");
	mem_addr = LC_MEM_DEPTH - 1'b1;
	dest_short_addr = 4'h3;
	word_counter = 2;
    state = TASK9;
	@ (posedge c0_tx_succ|c0_tx_fail);
	word_counter = 0;

    #100000;
    $fdisplay(handle, "\nTASK9, write to Layer 1 invalid MEM address, part 4");
	mem_addr = LC_MEM_DEPTH - 1'b1;
	dest_short_addr = 4'h3;
	word_counter = 3;
    state = TASK9;
	@ (posedge c0_tx_succ|c0_tx_fail);
	word_counter = 0;

    #100000;
    $fdisplay(handle, "\nN1 request interrupt with vecto 8'h2");
	n1_int_vector <= 8'h2;
	@ (posedge layer1.tx_succ|layer1.tx_fail);

    #100000;
    $fdisplay(handle, "\nN1 request interrupt with vecto 8'h4");
	n1_int_vector <= 8'h4;
	@ (posedge layer1.tx_succ|layer1.tx_fail);

    #100000;
    $fdisplay(handle, "\nN1 request interrupt with vecto 8'h8");
	n1_int_vector <= 8'h8;
	@ (posedge layer1.tx_succ|layer1.tx_fail);

    #100000;
    $fdisplay(handle, "\nN1 request interrupt with vecto 8'h10");
	n1_int_vector <= 8'h10;
    #300000;

    #100000;
    $fdisplay(handle, "\nN1 request interrupt with vecto 8'h20");
	n1_int_vector <= 8'h20;
    #300000;

    #100000;
    $fdisplay(handle, "\nN1 request interrupt with vecto 8'h40");
	n1_int_vector <= 8'h40;
    #300000;

    #100000;
    $fdisplay(handle, "\nN1 request interrupt with vecto 8'h80");
	n1_int_vector <= 8'h80;
    #300000;

    #100000;
    $fdisplay(handle, "\nN1 request interrupt with vecto 8'h5");
	n1_int_vector <= 8'h5;
	@ (posedge layer1.tx_succ|layer1.tx_fail);
	@ (posedge layer1.tx_succ|layer1.tx_fail);

    #300000;
    $display("*************************************");
    $display("************TASK0 Complete***********");
    $display("*************************************");
    $finish;
end
endtask // task0


//****************************************
//Task 1 testbench: DMA between layers
//****************************************
task task1;
begin
    handle=$fopen("result_task1.txt");

    #100000;
    $fdisplay(handle, "\nTASK0, Master node and Processor wake up");
    state = TASK0;
	@ (posedge SCLK);
	c0_req_int = 0;
    #50000;

    #100000;
    $fdisplay(handle, "\nTASK1, Master node sends out querry");
    state = TASK1;
	@ (posedge c0_rx_req);
	@ (posedge c0_rx_req);
	@ (posedge c0_rx_req);
	@ (posedge c0_rx_req);

    #100000;
    $fdisplay(handle, "\nTASK2, Master node enumerate with address 4'h2");
    state = TASK2;
	@ (posedge c0_rx_req);

    #100000;
    $fdisplay(handle, "\nTASK3, Master node enumerate with address 4'h3");
    state = TASK3;
	@ (posedge c0_rx_req);

    #100000;
    $fdisplay(handle, "\nTASK4, Master node enumerate with address 4'h4");
    state = TASK4;
	@ (posedge c0_rx_req);

    #100000;
    $fdisplay(handle, "\nTASK5, Master node enumerate with address 4'h5");
    state = TASK5;
	@ (posedge c0_rx_req);

    #100000;
    $fdisplay(handle, "\nTASK13, write 1 word to Layer 0 MEM address 0");
	mem_addr = 0;
	dest_short_addr = 4'h2;
	mem_data = (1<<2);	// DMA destination ptr
    state = TASK13;
	@ (posedge c0_tx_succ|c0_tx_fail);

    #100000;
    $fdisplay(handle, "\nTASK9, write 63 words to Layer 0 MEM address 1");
	mem_addr = 1;
	dest_short_addr = 4'h2;
	word_counter = 62;
    state = TASK9;
	@ (posedge c0_tx_succ|c0_tx_fail);
	word_counter = 0;

    #100000;
    $fdisplay(handle, "\nTASK10, DMA copy 64 words from Layer 0 MEM address 0 to Layer 1 MEM address 0");
	mem_addr = 0;
	dest_short_addr = 4'h2;
	relay_addr = {4'h3, `LC_CMD_MEM_WRITE};
	word_counter = 63;
    state = TASK10;
	@ (posedge layer0.tx_succ|layer0.tx_fail);
	word_counter = 0;
	
	// Layer 0 and 1 has consistent memory except address 0

    #100000;
    $fdisplay(handle, "\nTASK10, CPU reads 63 words from Layer 1 MEM address 0");
	mem_addr = 1;
	dest_short_addr = 4'h3;
	relay_addr = {4'h0, `CHANNEL_MEMBER_EVENT};
	word_counter = 62;
    state = TASK10;
	@ (posedge layer1.tx_succ|layer1.tx_fail);
	word_counter = 0;

	// write to layer 2 MEM
    #100000;
    $fdisplay(handle, "\nTASK14, write 64-word to Layer 2 MEM address 0 in RF-write type");
	mem_addr = 0;
	dest_short_addr = 4'h4;
	rf_addr = 0;
	word_counter = 63;
    state = TASK14;
	@ (posedge c0_tx_succ|c0_tx_fail);
	word_counter = 0;

	// read from layer 2 MEM write to layer 3 RF
    #100000;
    $fdisplay(handle, "\nTASK10, layer 2 reads its MEM and relay to layer 3 RF");
	mem_addr = 0;
	dest_short_addr = 4'h4;
	relay_addr = {4'h5, `LC_CMD_RF_WRITE};
	word_counter = 63;
    state = TASK10;
	@ (posedge layer2.tx_succ|layer2.tx_fail);
	word_counter = 0;

	// read from layer 3 RF to CPU
    #100000;
    $fdisplay(handle, "\nTASK8, read from Layer 3 RF address 0");
	rf_addr = 0;
	dest_short_addr = 4'h5;
	relay_addr = {4'h0, `CHANNEL_MEMBER_EVENT};
	word_counter = 63;
    state = TASK8;
	@ (posedge c0_tx_succ|c0_tx_fail);
	@ (posedge layer3.tx_succ|layer3.tx_fail);


    #300000;
    $display("*************************************");
    $display("************TASK1 Complete***********");
    $display("*************************************");
    $finish;
end
endtask // task1
