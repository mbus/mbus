
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
    $fdisplay(handle, "Bulk read Layer 1's MEM address 65533-6 (overflow), and write to layer 2's MEM, address 65533");
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

    #100000;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK22, Interrupt");
    $fdisplay(handle, "Layer 1, Interrupt vector 0, Read layer 1's RF address 0, and write to layer 2's RF address 0");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	layer_number = 1;
	int_vec = 0;	
    state = TB_SINGLE_INTERRUPT;
	@ (posedge n1_clr_int[int_vec]);

    #100000;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK23, Interrupt");
    $fdisplay(handle, "Layer 1, Interrupt vector 1, Read layer 1's RF address 1, and write to layer 2's RF address 1");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	layer_number = 1;
	int_vec = 1;	
    state = TB_SINGLE_INTERRUPT;
	@ (posedge n1_clr_int[int_vec]);

    #100000;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK24, Interrupt");
    $fdisplay(handle, "Layer 1, Interrupt vector 2, Bulk read layer 1's RF address 2-6, and write to layer 2's RF address 2");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	layer_number = 1;
	int_vec = 2;	
    state = TB_SINGLE_INTERRUPT;
	@ (posedge n1_clr_int[int_vec]);

    #100000;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK25, Interrupt");
    $fdisplay(handle, "Layer 1, Interrupt vector 3, Bulk read layer 1's RF address 126-3 (overflow), and write to layer 2's RF address 7");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	layer_number = 1;
	int_vec = 3;	
    state = TB_SINGLE_INTERRUPT;
	@ (posedge n1_clr_int[int_vec]);

    #100000;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK26, Interrupt");
    $fdisplay(handle, "Layer 1, Interrupt vector 4, Write to layer 1's RF address 0");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	layer_number = 1;
	int_vec = 4;	
    state = TB_SINGLE_INTERRUPT;
	@ (posedge n1_clr_int[int_vec]);

    #100000;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK27, Interrupt");
    $fdisplay(handle, "Layer 1, Interrupt vector 5, Write to layer 1's RF address 1, 3");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	layer_number = 1;
	int_vec = 5;	
    state = TB_SINGLE_INTERRUPT;
	@ (posedge n1_clr_int[int_vec]);

    #100000;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK28, Interrupt");
    $fdisplay(handle, "Layer 1, Interrupt vector 6, Write to layer 1's RF address 2, 4, 6");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	layer_number = 1;
	int_vec = 6;	
    state = TB_SINGLE_INTERRUPT;
	@ (posedge n1_clr_int[int_vec]);

    #100000;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK29, Interrupt");
    $fdisplay(handle, "Layer 1, Interrupt vector 7, Write to layer 1's RF address 5, 127 (non-writable), 128 (non-exist)");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	layer_number = 1;
	int_vec = 7;	
    state = TB_SINGLE_INTERRUPT;
	@ (posedge n1_clr_int[int_vec]);

    #100000;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK30, Interrupt");
    $fdisplay(handle, "Layer 1, Interrupt vector 8, Read from layer 1's MEM address 0, and write to layer 2's MEM, address 0x1");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	layer_number = 1;
	int_vec = 8;	
    state = TB_SINGLE_INTERRUPT;
	@ (posedge n1_clr_int[int_vec]);

    #100000;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK31, Select sleep");
    $fdisplay(handle, "Select sleep using long prefix, Sleep layer 1");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	long_addr = 20'hbbbb1;
	state = TB_SEL_SLEEP_FULL_PREFIX;
	@ (posedge c0_tx_succ|c0_tx_fail);

    #100000;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK32, Interrupt");
    $fdisplay(handle, "Layer 1, Interrupt vector 9, Bulk read from layer 1's MEM address 1-5, and write to layer 2's MEM, address 2-6");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	layer_number = 1;
	int_vec = 9;	
    state = TB_SINGLE_INTERRUPT;
	@ (posedge n1_clr_int[int_vec]);

    #100000;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK33, Sleep all");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	state = TB_ALL_SLEEP;
	@ (posedge c0_tx_succ|c0_tx_fail);

    #100000;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK34, Interrupt");
    $fdisplay(handle, "Layer 1, Interrupt vector 12, Wakeup only");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	layer_number = 1;
	int_vec = 12;	
    state = TB_SINGLE_INTERRUPT;
	@ (posedge n1_clr_int[int_vec]);

    #100000;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK35, Interrupt");
    $fdisplay(handle, "Layer 1, Interrupt vector 10, Read from layer 1's MEM address 65538 (overflow), and write to layer 2's MEM, address 3");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	layer_number = 1;
	int_vec = 10;	
    state = TB_SINGLE_INTERRUPT;
	@ (posedge n1_clr_int[int_vec]);

    #100000;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK36, Interrupt");
    $fdisplay(handle, "Layer 1, Interrupt vector 11, Bulk read from layer 1's MEM address 65533-6 (overflow), and write to layer 2's MEM, address 3");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	layer_number = 1;
	int_vec = 11;	
    state = TB_SINGLE_INTERRUPT;
	@ (posedge n1_clr_int[int_vec]);

    #100000;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK37, Master node and Processor wake up");
    $fdisplay(handle, "-------------------------------------------------------------------------");
    state = TB_PROC_UP;
	@ (posedge SCLK);
	c0_req_int = 0;
    #50000;


    #100000;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK37, Error command test");
    $fdisplay(handle, "Bulk read Layer 1's MEM address 0-1, and read layer 3's RF");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	dest_short_addr = 4'h3;
	mem_read_length = 1;
	mem_addr = 0;
	relay_addr = ((4'h5<<4) | `LC_CMD_RF_READ);		// Fake RF read
	// Read RF from 192-197 (non-existing location), write to layer 2's RF location 0 <- This is an invalid RF read command
	mem_relay_loc = (8'd192<<22 | 8'd5<<14 | 4'h4<<10 | `LC_CMD_RF_WRITE<<6 | 6'h0);
    state = TB_MEM_READ;
	@ (posedge c0_tx_succ|c0_tx_fail);
	@ (posedge layer1.tx_succ | layer1.tx_fail);

    #100000;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK38, Error command test");
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
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK39, Error command test");
    $fdisplay(handle, "CPU sends a command with an unknown functional ID");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	dest_short_addr = 4'h3;
	functional_id = 4'b0100;
	word_counter = 1;
    state = TB_ARBITRARY_CMD;
	@ (posedge c0_tx_succ|c0_tx_fail);

    #100000;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK40, Error command test");
    $fdisplay(handle, "CPU bulk writes random data to Layer 1 RF address 128-130");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	rf_addr = 128;
	dest_short_addr = 4'h3;
	word_counter = 2;
    state = TB_RF_WRITE;
	@ (posedge c0_tx_succ|c0_tx_fail);

    #100000;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK41, Error command test");
    $fdisplay(handle, "Invalid MEM read command");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	dest_short_addr = 4'h3;
	functional_id = `LC_CMD_MEM_READ;
	word_counter = 0;
    state = TB_ARBITRARY_CMD;
	@ (posedge c0_tx_succ|c0_tx_fail);

    #100000;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK42, Error command test");
    $fdisplay(handle, "Invalid MEM read command");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	dest_short_addr = 4'h3;
	functional_id = `LC_CMD_MEM_READ;
	word_counter = 1;
    state = TB_ARBITRARY_CMD;
	@ (posedge c0_tx_succ|c0_tx_fail);

    #100000;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK43, Error command test");
    $fdisplay(handle, "Invalid MEM read command");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	dest_short_addr = 4'h3;
	functional_id = `LC_CMD_MEM_READ;
	word_counter = 5;
    state = TB_ARBITRARY_CMD;
	@ (posedge c0_tx_succ|c0_tx_fail);

    #100000;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK44, Error command test");
    $fdisplay(handle, "Invalid MEM wriet command");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	dest_short_addr = 4'h3;
	functional_id = `LC_CMD_MEM_WRITE;
	word_counter = 0;
    state = TB_ARBITRARY_CMD;
	@ (posedge c0_tx_succ|c0_tx_fail);

    #100000;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK45, MEM Write");
    $fdisplay(handle, "CPU bulk writes random data to Layer 1's MEM address 0-63");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	dest_short_addr = 4'h3;
	mem_addr = 0;
	word_counter = 63;
    state = TB_MEM_WRITE;
	@ (posedge c0_tx_succ|c0_tx_fail);

    #100000;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK46, MEM Read");
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


    #300000;
    $display("*************************************");
    $display("************TASK0 Complete***********");
    $display("*************************************");
    $finish;
end
endtask // task0

