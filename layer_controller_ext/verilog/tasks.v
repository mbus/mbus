
//****************************************
//Task 0 testbench: Comprehensive testbench
//****************************************
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
    $fdisplay(handle, "TASK%d, RF Write", task_counter);
    $fdisplay(handle, "CPU configures Layer 0 default sys register bulk mem message control");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	rf_addr = 242;
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
	rf_addr = 242;
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
	rf_addr = 242;
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
	rf_addr = 242;
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

/*
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
    $fdisplay(handle, "TASK%d, MEM Write", task_counter);
    $fdisplay(handle, "CPU writes random data to Layer 1's MEM address 65540 (overflow)");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	dest_short_addr = 4'h3;
	mem_addr = 65540;
	word_counter = 0;
    state = TB_MEM_WRITE;
	@ (posedge c0_tx_succ|c0_tx_fail);

    #100000;
	task_counter = task_counter + 1;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK%d, MEM Write", task_counter);
    $fdisplay(handle, "CPU bulk writes random data to Layer 1's MEM address 65533-6 (overflow)");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	dest_short_addr = 4'h3;
	mem_addr = 65533;
	word_counter = 9;
    state = TB_MEM_WRITE;
	@ (posedge c0_tx_succ|c0_tx_fail);

    #100000;
	task_counter = task_counter + 1;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK%d, MEM Read", task_counter);
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
	task_counter = task_counter + 1;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK%d, MEM Read", task_counter);
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
    $fdisplay(handle, "Layer 1, Interrupt vector 1, Read layer 1's RF address 1, and write to layer 2's RF address 1");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	layer_number = 1;
	int_vec = 1;	
    state = TB_SINGLE_INTERRUPT;
	@ (posedge n1_clr_int[int_vec]);

    #100000;
	task_counter = task_counter + 1;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK%d, Interrupt", task_counter);
    $fdisplay(handle, "Layer 1, Interrupt vector 2, Bulk read layer 1's RF address 2-6, and write to layer 2's RF address 2");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	layer_number = 1;
	int_vec = 2;	
    state = TB_SINGLE_INTERRUPT;
	@ (posedge n1_clr_int[int_vec]);

    #100000;
	task_counter = task_counter + 1;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK%d, Interrupt", task_counter);
    $fdisplay(handle, "Layer 1, Interrupt vector 3, Bulk read layer 1's RF address 126-3 (overflow), and write to layer 2's RF address 7");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	layer_number = 1;
	int_vec = 3;	
    state = TB_SINGLE_INTERRUPT;
	@ (posedge n1_clr_int[int_vec]);

    #100000;
	task_counter = task_counter + 1;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK%d, Interrupt", task_counter);
    $fdisplay(handle, "Layer 1, Interrupt vector 4, Write to layer 1's RF address 0");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	layer_number = 1;
	int_vec = 4;	
    state = TB_SINGLE_INTERRUPT;
	@ (posedge n1_clr_int[int_vec]);

    #100000;
	task_counter = task_counter + 1;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK%d, Interrupt", task_counter);
    $fdisplay(handle, "Layer 1, Interrupt vector 5, Write to layer 1's RF address 1, 3");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	layer_number = 1;
	int_vec = 5;	
    state = TB_SINGLE_INTERRUPT;
	@ (posedge n1_clr_int[int_vec]);

    #100000;
	task_counter = task_counter + 1;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK%d, Interrupt", task_counter);
    $fdisplay(handle, "Layer 1, Interrupt vector 6, Write to layer 1's RF address 2, 4, 6");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	layer_number = 1;
	int_vec = 6;	
    state = TB_SINGLE_INTERRUPT;
	@ (posedge n1_clr_int[int_vec]);

    #100000;
	task_counter = task_counter + 1;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK%d, Interrupt", task_counter);
    $fdisplay(handle, "Layer 1, Interrupt vector 7, Write to layer 1's RF address 5, 127 (non-writable), 128 (non-exist)");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	layer_number = 1;
	int_vec = 7;	
    state = TB_SINGLE_INTERRUPT;
	@ (posedge n1_clr_int[int_vec]);

    #100000;
	task_counter = task_counter + 1;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK%d, Interrupt", task_counter);
    $fdisplay(handle, "Layer 1, Interrupt vector 8, Read from layer 1's MEM address 0, and write to layer 2's MEM, address 0x1");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	layer_number = 1;
	int_vec = 8;	
    state = TB_SINGLE_INTERRUPT;
	@ (posedge n1_clr_int[int_vec]);

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
    $fdisplay(handle, "Layer 1, Interrupt vector 9, Bulk read from layer 1's MEM address 1-5, and write to layer 2's MEM, address 2-6");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	layer_number = 1;
	int_vec = 9;	
    state = TB_SINGLE_INTERRUPT;
	@ (posedge n1_clr_int[int_vec]);

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
    $fdisplay(handle, "Layer 1, Interrupt vector 12, Wakeup only");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	layer_number = 1;
	int_vec = 12;	
    state = TB_SINGLE_INTERRUPT;
	@ (posedge n1_clr_int[int_vec]);

    #100000;
	task_counter = task_counter + 1;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK%d, Interrupt", task_counter);
    $fdisplay(handle, "Layer 1, Interrupt vector 10, Read from layer 1's MEM address 65538 (overflow), and write to layer 2's MEM, address 3");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	layer_number = 1;
	int_vec = 10;	
    state = TB_SINGLE_INTERRUPT;
	@ (posedge n1_clr_int[int_vec]);

    #100000;
	task_counter = task_counter + 1;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK%d, Interrupt", task_counter);
    $fdisplay(handle, "Layer 1, Interrupt vector 11, Bulk read from layer 1's MEM address 65533-6 (overflow), and write to layer 2's MEM, address 3");
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
    $fdisplay(handle, "TASK%d, Error command test", task_counter);
    $fdisplay(handle, "CPU sends a command with an unknown functional ID");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	dest_short_addr = 4'h3;
	functional_id = 4'b0100;
	word_counter = 1;
    state = TB_ARBITRARY_CMD;
	@ (posedge c0_tx_succ|c0_tx_fail);

    #100000;
	task_counter = task_counter + 1;
    $fdisplay(handle, "\n-------------------------------------------------------------------------");
    $fdisplay(handle, "TASK%d, Error command test", task_counter);
    $fdisplay(handle, "CPU bulk writes random data to Layer 1 RF address 128-130");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	rf_addr = 128;
	dest_short_addr = 4'h3;
	word_counter = 2;
    state = TB_RF_WRITE;
	@ (posedge c0_tx_succ|c0_tx_fail);

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
	word_counter = 1;
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
    $fdisplay(handle, "Invalid MEM wriet command");
    $fdisplay(handle, "-------------------------------------------------------------------------");
	dest_short_addr = 4'h3;
	functional_id = `LC_CMD_MEM_WRITE;
	word_counter = 0;
    state = TB_ARBITRARY_CMD;
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
*/

    #300000;
    $display("*************************************");
    $display("************TASK0 Complete***********");
    $display("*************************************");
    $finish;
end
endtask // task0

