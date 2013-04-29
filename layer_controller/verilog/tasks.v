
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
    $fdisplay(handle, "\nTASK7, write to RF address 0");
	rf_addr = 0;
    state = TASK7;
	@ (posedge c0_tx_succ|c0_tx_fail);

    #100000;
    $fdisplay(handle, "\nTASK7, write to RF address 1-4");
	rf_addr = 1;
    state = TASK7;
	word_counter = 3;
	@ (posedge c0_tx_succ|c0_tx_fail);
	word_counter = 0;

    #100000;
    $fdisplay(handle, "\nTASK7, write to RF address 130 (ROM, not writable)");
	rf_addr = 130;
    state = TASK7;
	@ (posedge c0_tx_succ|c0_tx_fail);

    #100000;
    $fdisplay(handle, "\nTASK8, read from RF address 0");
	rf_addr = 0;
    state = TASK8;
	@ (posedge c0_tx_succ|c0_tx_fail);
	@ (posedge c0_rx_req|c0_rx_fail);
   	$fdisplay(handle, "RF Addr: 8'h%h,\tData: 24'h%h", rf_addr, (c0_rx_data & 32'h00ff_ffff));

    #100000;
    $fdisplay(handle, "\nTASK8, read from RF address 1-4");
	rf_addr = 1;
	word_counter = 3;	// 3 + 1 = 4
    state = TASK8;
	@ (posedge c0_tx_succ|c0_tx_fail);
	@ (posedge n1_tx_succ|n1_tx_fail);
	word_counter = 0;

    #100000;
    $fdisplay(handle, "\nTASK8, read from RF address 130 (ROM)");
	rf_addr = 130;
    state = TASK8;
	@ (posedge c0_tx_succ|c0_tx_fail);
	@ (posedge c0_rx_req|c0_rx_fail);
   	$fdisplay(handle, "RF Addr: 8'h%h,\tData: 24'h%h", rf_addr, (c0_rx_data & 32'h00ff_ffff));

    #100000;
    $fdisplay(handle, "\nTASK9, write to MEM address 0");
	mem_addr = 0;
    state = TASK9;
	@ (posedge c0_tx_succ|c0_tx_fail);
	mem_ptr_set = 0;

    #100000;
    $fdisplay(handle, "\nTASK10, read from MEM address 0");
	mem_addr = 0;
    state = TASK10;
	relay_addr = 8'h03;
	@ (posedge c0_tx_succ|c0_tx_fail);
	@ (posedge c0_rx_req|c0_rx_fail);
   	$fdisplay(handle, "MEM Addr: 32'h%h,\tData: 32'h%h", mem_addr, c0_rx_data);
	mem_ptr_set = 0;

    #100000;
    $fdisplay(handle, "\nTASK11, sleep N1");
    state = TASK11;
	@ (posedge c0_tx_succ|c0_tx_fail);

    #100000;
    $fdisplay(handle, "\nTASK9, write to MEM address 1");
	mem_addr = 1;
    state = TASK9;
	@ (posedge c0_tx_succ|c0_tx_fail);
	mem_ptr_set = 0;

    #100000;
    $fdisplay(handle, "\nTASK9, write to MEM address 2");
	mem_addr = 2;
    state = TASK9;
	@ (posedge c0_tx_succ|c0_tx_fail);
	mem_ptr_set = 0;

    #100000;
    $fdisplay(handle, "\nTASK10, read from MEM address 1");
	mem_addr = 1;
    state = TASK10;
	relay_addr = 8'h03;
	@ (posedge c0_tx_succ|c0_tx_fail);
	@ (posedge c0_rx_req|c0_rx_fail);
   	$fdisplay(handle, "MEM Addr: 32'h%h,\tData: 32'h%h", mem_addr, c0_rx_data);
	mem_ptr_set = 0;

    #100000;
    $fdisplay(handle, "\nTASK10, read from MEM address 2");
	mem_addr = 2;
    state = TASK10;
	relay_addr = 8'h03;
	@ (posedge c0_tx_succ|c0_tx_fail);
	@ (posedge c0_rx_req|c0_rx_fail);
   	$fdisplay(handle, "MEM Addr: 32'h%h,\tData: 32'h%h", mem_addr, c0_rx_data);
	mem_ptr_set = 0;

    #100000;
    $fdisplay(handle, "\nTASK9, DMA write 16-word to MEM address 3-18");
	mem_addr = 3;
	word_counter = 15;
    state = TASK9;
	@ (posedge c0_tx_succ|c0_tx_fail);
	word_counter = 0;
	mem_ptr_set = 0;

    #100000;
    $fdisplay(handle, "\nTASK10, DMA read 16-word from MEM address 3-18");
	mem_addr = 3;
	word_counter = 15;
    state = TASK10;
	relay_addr = 8'h03;
	@ (posedge c0_tx_succ|c0_tx_fail);
	@ (posedge n1_tx_succ|n1_tx_fail);
	word_counter = 0;
	mem_ptr_set = 0;

    #100000;
    $fdisplay(handle, "\nTASK11, sleep N1");
    state = TASK11;
	@ (posedge c0_tx_succ|c0_tx_fail);

    #100000;
    $fdisplay(handle, "\nN1 request interrupt");
    state = TASK14;
	@ (posedge c0_rx_req|c0_rx_fail);

    #300000;
    $display("*************************************");
    $display("************TASK0 Complete***********");
    $display("*************************************");
    $finish;
end
endtask // task0
