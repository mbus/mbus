
//****************************************
//Task 0 testbench: Comprehensive testbench
//****************************************
task task0;
begin
    handle=$fopen("result_task0.txt");

    #100000;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK0, Master node and Processor wake up");
    $fdisplay(handle, "-------------------------------------------------------------------------");
    state = TB_PROC_UP;
	@ (posedge SCLK);
	c0_req_int = 0;
    #50000;

    #100000;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK1, Query");
    $fdisplay(handle, "Master node sends out query");
    $fdisplay(handle, "-------------------------------------------------------------------------");
    state = TB_QUERY;
	@ (posedge c0_rx_req);
	@ (posedge c0_rx_req);
	@ (posedge c0_rx_req);
	@ (posedge c0_rx_req);

    #100000;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK2, Enumerate");
    $fdisplay(handle, "Master node enumerate with address 4'h2");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	enum_short_addr = 4'h2;
    state = TB_ENUM;
	@ (posedge c0_rx_req);

    #100000;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK3, Enumerate");
    $fdisplay(handle, "Master node enumerate with address 4'h3");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	enum_short_addr = 4'h3;
    state = TB_ENUM;
	@ (posedge c0_rx_req);

    #100000;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK4, Enumerate");
    $fdisplay(handle, "Master node enumerate with address 4'h4");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	enum_short_addr = 4'h4;
    state = TB_ENUM;
	@ (posedge c0_rx_req);

    #100000;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK5, Enumerate");
    $fdisplay(handle, "Master node enumerate with address 4'h5");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	enum_short_addr = 4'h5;
    state = TB_ENUM;
	@ (posedge c0_rx_req);

    #100000;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK6, All Wake");
    $fdisplay(handle, "-------------------------------------------------------------------------");
    state = TB_ALL_WAKEUP;
	@ (posedge c0_tx_succ | c0_tx_fail);

    #100000;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK7, RF Write");
    $fdisplay(handle, "CPU writes random data to Layer 1 RF address 0");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	rf_addr = 0;
	dest_short_addr = 4'h3;
    state = TB_RF_WRITE;
	@ (posedge c0_tx_succ|c0_tx_fail);

    #100000;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK8, RF Write");
    $fdisplay(handle, "CPU bulk writes random data to Layer 1 RF address 1-4");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	rf_addr = 1;
	dest_short_addr = 4'h3;
	word_counter = 3;
    state = TB_RF_WRITE;
	@ (posedge c0_tx_succ|c0_tx_fail);

    #100000;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK9, RF Write");
    $fdisplay(handle, "CPU write to Layer 1 non-existing location RF address 128");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	rf_addr = 128;
	dest_short_addr = 4'h3;
    state = TB_RF_WRITE;
	@ (posedge c0_tx_succ|c0_tx_fail);

    #100000;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK10, RF Read");
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
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK11, RF Read");
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
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK12, RF Read");
    $fdisplay(handle, "CPU read Layer 1's non-existing RF address 128, and send to layer 0");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	dest_short_addr = 4'h3;
	rf_addr = 128;
	rf_read_length = 3;
	relay_addr = ((4'h4<<0) | `LC_CMD_RF_WRITE);
	rf_relay_loc = 8'hff;		// Don't care
    state = TB_RF_READ;
	@ (posedge c0_tx_succ|c0_tx_fail);

    #100000;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK13, MEM Write");
    $fdisplay(handle, "CPU writes random data to Layer 1's MEM address 0");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	dest_short_addr = 4'h3;
	mem_addr = 0;
	word_counter = 0;
    state = TB_MEM_WRITE;
	@ (posedge c0_tx_succ|c0_tx_fail);

    #100000;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK14, MEM Read");
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
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK15, MEM Write");
    $fdisplay(handle, "CPU bulk writes random data to Layer 1's MEM address 1-10");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	dest_short_addr = 4'h3;
	mem_addr = 1;
	word_counter = 9;
    state = TB_MEM_WRITE;
	@ (posedge c0_tx_succ|c0_tx_fail);

    #100000;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK16, MEM Read");
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
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK17, MEM Write");
    $fdisplay(handle, "CPU writes random data to Layer 1's MEM address 65540 (overflow)");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	dest_short_addr = 4'h3;
	mem_addr = 65540;
	word_counter = 0;
    state = TB_MEM_WRITE;
	@ (posedge c0_tx_succ|c0_tx_fail);

    #100000;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK18, MEM Write");
    $fdisplay(handle, "CPU bulk writes random data to Layer 1's MEM address 65533-6 (overflow)");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	dest_short_addr = 4'h3;
	mem_addr = 65533;
	word_counter = 9;
    state = TB_MEM_WRITE;
	@ (posedge c0_tx_succ|c0_tx_fail);

    #100000;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK19, MEM Read");
    $fdisplay(handle, "Read Layer 1's MEM address 65540 (overflow), and write to layer 2's MEM, address 0x0");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	dest_short_addr = 4'h3;
	mem_read_length = 0;
	mem_addr = 65540;
	relay_addr = ((4'h4<<4) | `LC_CMD_MEM_WRITE);
	mem_relay_loc = 30'd0;
    state = TB_MEM_READ;
	@ (posedge c0_tx_succ|c0_tx_fail);
	@ (posedge layer1.tx_succ | layer1.tx_fail);

    #100000;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK20, MEM Read");
    $fdisplay(handle, "Bulk read Layer 1's MEM address 65533-6 (overflow), and write to layer 2's MEM, address 0x65533");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	dest_short_addr = 4'h3;
	mem_read_length = 9;
	mem_addr = 65533;
	relay_addr = ((4'h4<<4) | `LC_CMD_MEM_WRITE);
	mem_relay_loc = 30'd65533;
    state = TB_MEM_READ;
	@ (posedge c0_tx_succ|c0_tx_fail);
	@ (posedge layer1.tx_succ | layer1.tx_fail);


    #100000;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK21, Select sleep");
    $fdisplay(handle, "Select sleep using long prefix, Sleep layer 1");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	long_addr = 20'hbbbb1;
	state = TB_SEL_SLEEP_FULL_PREFIX;
	@ (posedge c0_tx_succ|c0_tx_fail);

    #100000;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK21, MEM Write");
    $fdisplay(handle, "CPU writes random data to Layer 1's MEM address 0xa");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	dest_short_addr = 4'h3;
	mem_addr = 30'ha;
	word_counter = 0;
    state = TB_MEM_WRITE;
	@ (posedge c0_tx_succ|c0_tx_fail);
/*

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
*/
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
//task task1;
//begin
//    handle=$fopen("result_task1.txt");
//
//    #100000;
//    $fdisplay(handle, "\nTASK0, Master node and Processor wake up");
//    state = TASK0;
//	@ (posedge SCLK);
//	c0_req_int = 0;
//    #50000;
//
//    #100000;
//    $fdisplay(handle, "\nTASK1, Master node sends out querry");
//    state = TASK1;
//	@ (posedge c0_rx_req);
//	@ (posedge c0_rx_req);
//	@ (posedge c0_rx_req);
//	@ (posedge c0_rx_req);
//
//    #100000;
//    $fdisplay(handle, "\nTASK2, Master node enumerate with address 4'h2");
//    state = TASK2;
//	@ (posedge c0_rx_req);
//
//    #100000;
//    $fdisplay(handle, "\nTASK3, Master node enumerate with address 4'h3");
//    state = TASK3;
//	@ (posedge c0_rx_req);
//
//    #100000;
//    $fdisplay(handle, "\nTASK4, Master node enumerate with address 4'h4");
//    state = TASK4;
//	@ (posedge c0_rx_req);
//
//    #100000;
//    $fdisplay(handle, "\nTASK5, Master node enumerate with address 4'h5");
//    state = TASK5;
//	@ (posedge c0_rx_req);
//
//    #100000;
//    $fdisplay(handle, "\nTASK13, write 1 word to Layer 0 MEM address 0");
//	mem_addr = 0;
//	dest_short_addr = 4'h2;
//	mem_data = (1<<2);	// DMA destination ptr
//    state = TASK13;
//	@ (posedge c0_tx_succ|c0_tx_fail);
//
//    #100000;
//    $fdisplay(handle, "\nTASK9, write 63 words to Layer 0 MEM address 1");
//	mem_addr = 1;
//	dest_short_addr = 4'h2;
//	word_counter = 62;
//    state = TASK9;
//	@ (posedge c0_tx_succ|c0_tx_fail);
//	word_counter = 0;
//
//    #100000;
//    $fdisplay(handle, "\nTASK10, DMA copy 64 words from Layer 0 MEM address 0 to Layer 1 MEM address 0");
//	mem_addr = 0;
//	dest_short_addr = 4'h2;
//	relay_addr = {4'h3, `LC_CMD_MEM_WRITE};
//	word_counter = 63;
//    state = TASK10;
//	@ (posedge layer0.tx_succ|layer0.tx_fail);
//	word_counter = 0;
//	
//	// Layer 0 and 1 has consistent memory except address 0
//
//    #100000;
//    $fdisplay(handle, "\nTASK10, CPU reads 63 words from Layer 1 MEM address 0");
//	mem_addr = 1;
//	dest_short_addr = 4'h3;
//	relay_addr = {4'h0, `CHANNEL_MEMBER_EVENT};
//	word_counter = 62;
//    state = TASK10;
//	@ (posedge layer1.tx_succ|layer1.tx_fail);
//	word_counter = 0;
//
//	// write to layer 2 MEM
//    #100000;
//    $fdisplay(handle, "\nTASK14, write 64-word to Layer 2 MEM address 0 in RF-write type");
//	mem_addr = 0;
//	dest_short_addr = 4'h4;
//	rf_addr = 0;
//	word_counter = 63;
//    state = TASK14;
//	@ (posedge c0_tx_succ|c0_tx_fail);
//	word_counter = 0;
//
//	// read from layer 2 MEM write to layer 3 RF
//    #100000;
//    $fdisplay(handle, "\nTASK10, layer 2 reads its MEM and relay to layer 3 RF");
//	mem_addr = 0;
//	dest_short_addr = 4'h4;
//	relay_addr = {4'h5, `LC_CMD_RF_WRITE};
//	word_counter = 63;
//    state = TASK10;
//	@ (posedge layer2.tx_succ|layer2.tx_fail);
//	word_counter = 0;
//
//	// read from layer 3 RF to CPU
//    #100000;
//    $fdisplay(handle, "\nTASK8, read from Layer 3 RF address 0");
//	rf_addr = 0;
//	dest_short_addr = 4'h5;
//	relay_addr = {4'h0, `CHANNEL_MEMBER_EVENT};
//	word_counter = 63;
//    state = TASK8;
//	@ (posedge c0_tx_succ|c0_tx_fail);
//	@ (posedge layer3.tx_succ|layer3.tx_fail);
//
//
//    #300000;
//    $display("*************************************");
//    $display("************TASK1 Complete***********");
//    $display("*************************************");
//    $finish;
//end
//endtask // task1
