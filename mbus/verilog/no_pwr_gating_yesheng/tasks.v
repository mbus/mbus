
//****************************************
//Task 0 testbench: Comprehensive testbench
//****************************************
task task0;
begin
    handle=$fopen("result_task0.txt");

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
    $fdisplay(handle, "\nTASK6, N1 to N0 using long address");
    $fdisplay(handle, "Result: N1 TX Success");
    $fdisplay(handle, "Result: N0 RX Success");
    state = TASK6;
	@ (posedge n1_tx_succ|n1_tx_fail);
    #100000;
    $fdisplay(handle, "\nTASK7, N1 to N2 using long address");
    $fdisplay(handle, "Result: N1 TX Success");
    $fdisplay(handle, "Result: N2 RX Success");
    $fdisplay(handle, "Result: N3 RX Success");
    state = TASK7;
	@ (posedge n1_tx_succ|n1_tx_fail);

    #100000;
    $fdisplay(handle, "\nTASK8, N1 to N0 using short address");
    $fdisplay(handle, "Result: N1 TX Success");
    $fdisplay(handle, "Result: N0 RX Success");
    state = TASK8;
	@ (posedge n1_tx_succ|n1_tx_fail);

    #100000;
    $fdisplay(handle, "\nTASK9, N1 to N2 using short address");
    $fdisplay(handle, "Result: N1 TX Success");
    $fdisplay(handle, "Result: N2 RX Success");
    state = TASK9;
	@ (posedge n1_tx_succ|n1_tx_fail);

    #100000;
    $fdisplay(handle, "\nTASK10, N1 to N3 using short address");
    $fdisplay(handle, "Result: N1 TX Success");
    $fdisplay(handle, "Result: N3 RX Success");
    state = TASK10;
	@ (posedge n1_tx_succ|n1_tx_fail);

    #100000;
    $fdisplay(handle, "\nTASK11, invalidate 4'h2 (n0) short address");
    state = TASK11;
	@ (posedge c0_tx_succ|c0_tx_fail);
	// n0 -> 4'hf (invalid)
	// n1 -> 4'h3
	// n2 -> 4'h4
	// n3 -> 4'h5

    #100000;
    $fdisplay(handle, "\nTASK8, N1 to N0 using short address");
    $fdisplay(handle, "Result: N1 TX Fail");
    state = TASK8;
	@ (posedge n1_tx_succ|n1_tx_fail);

    #100000;
    $fdisplay(handle, "\nTASK12, Master node enumerate with address 4'h8");
    state = TASK12;
	@ (posedge c0_rx_req);
	// n0 -> 4'h8
	// n1 -> 4'h3
	// n2 -> 4'h4
	// n3 -> 4'h5

    #100000;
    $fdisplay(handle, "\nTASK13, N1 to N0 using short address");
    $fdisplay(handle, "Result: N1 TX Success");
    $fdisplay(handle, "Result: N0 RX Success");
    state = TASK13;
	@ (posedge n1_tx_succ|n1_tx_fail);

/*
    #100000;
    $fdisplay(handle, "\nTASK14, Selective sleep N0, N2");
    state = TASK14;
	@ (posedge c0_tx_succ | c0_tx_fail);

    #100000;
    $fdisplay(handle, "\nTASK15, N2 asserts ext_int");
    $fdisplay(handle, "Result: C0, N0, N1, N3 RX Fail");
    state = TASK15;
	@ (posedge SCLK);
    #50000;

    #100000;
    $fdisplay(handle, "\nTASK16, N2 to N0 using short address");
    $fdisplay(handle, "Result: N2 TX Success");
    $fdisplay(handle, "Result: N0 RX Success");
    state = TASK16;
	@ (posedge n2_tx_succ|n2_tx_fail);
	
    #100000;
    $fdisplay(handle, "\nTASK14, Selective sleep N0, N2");
    state = TASK14;
	@ (posedge c0_tx_succ | c0_tx_fail);

    #100000;
    $fdisplay(handle, "\nTASK10, N1 to N3 using short address");
    $fdisplay(handle, "Result: N1 TX Success");
    $fdisplay(handle, "Result: N3 RX Success");
    state = TASK10;
	@ (posedge n1_tx_succ|n1_tx_fail);

    #100000;
    $fdisplay(handle, "\nTASK17, Master node sends out long querry");
    state = TASK17;
	@ (posedge c0_rx_req);
	@ (posedge c0_rx_req);
	@ (posedge c0_rx_req);
	@ (posedge c0_rx_req);

    #100000;
    $fdisplay(handle, "\nTASK18, All sleep");
    state = TASK18;
	@ (posedge c0_tx_succ | c0_tx_fail);

    #100000;
    $fdisplay(handle, "\nTASK0, Master node and Processor wake up");
    state = TASK0;
	@ (posedge SCLK);
    #50000;

    #100000;
    $fdisplay(handle, "\nTASK17, Master node sends out long querry");
    state = TASK17;
	@ (posedge c0_rx_req);
	@ (posedge c0_rx_req);
	@ (posedge c0_rx_req);
	@ (posedge c0_rx_req);

    #100000;
    $fdisplay(handle, "\nTASK18, All sleep");
    state = TASK18;
	@ (posedge c0_tx_succ | c0_tx_fail);

    #100000;
    $fdisplay(handle, "\nTASK0, Master node and Processor wake up");
    state = TASK0;
	@ (posedge SCLK);
    #50000;

    #10000;
    $fdisplay(handle, "\nTASK19, All Wake");
    state = TASK19;
	@ (posedge c0_tx_succ | c0_tx_fail);

    #100000;
    $fdisplay(handle, "\nTASK20, Invalidate all short address");
    state = TASK20;
	@ (posedge c0_tx_succ | c0_tx_fail);

    #100000;
    $fdisplay(handle, "\nTASK1, Master node sends out querry");
    state = TASK1;
	@ (posedge c0_rx_req);
	@ (posedge c0_rx_req);
	@ (posedge c0_rx_req);
	@ (posedge c0_rx_req);

    #100000;
    $fdisplay(handle, "\nTASK21, Selective sleep N1 using long prefix");
    state = TASK21;
	@ (posedge c0_tx_succ | c0_tx_fail);

    #100000;
    $fdisplay(handle, "\nTASK22, Selective sleep processor using long prefix");
    state = TASK22;
	@ (posedge c0_tx_succ | c0_tx_fail);

    #100000;
    $fdisplay(handle, "\nTASK23, N2 node sends out querry");
    state = TASK23;
    #700000;

    #100000;
    $fdisplay(handle, "\nTASK24, N2 node sends to control");
    $fdisplay(handle, "Result: C0 should NOT assert RX_REQ, the message should be handled in mbus_ctrl_wrapper");
    state = TASK24;
    #300000;

    #10000;
    $fdisplay(handle, "\nTASK19, All Wake");
    state = TASK19;
	@ (posedge c0_tx_succ | c0_tx_fail);

    #100000;
    $fdisplay(handle, "\nTASK15, N2 asserts ext_int");
    $fdisplay(handle, "Result: C0, N0, N1, N3 RX Fail");
    state = TASK15;
    #50000;

    #100000;
    $fdisplay(handle, "\nTASK18, All sleep");
    state = TASK18;
	@ (posedge c0_tx_succ | c0_tx_fail);

    #100000;
    $fdisplay(handle, "\nTASK0, Master node and Processor wake up");
    state = TASK0;
	@ (posedge SCLK);
    #50000;

    #100000;
    $fdisplay(handle, "\nTASK15, N2 asserts ext_int");
    $fdisplay(handle, "Result: C0, N0, N1, N3 RX Fail");
    state = TASK15;
    #50000;

    #100000;
    $fdisplay(handle, "\nTASK25, N3 asserts ext_int between transmission");
	word_counter = 4;
    state = TASK25;
	@ (posedge n2_tx_succ | n2_tx_fail);
    #50000;

    #100000;
    $fdisplay(handle, "\nTASK18, All sleep");
    state = TASK18;
	@ (posedge c0_tx_succ | c0_tx_fail);

    #100000;
    $fdisplay(handle, "\nBoth N1 and N2 assert interrupt");
	#33600;
    #50000;
	*/

    #300000;
    $display("*************************************");
    $display("************TASK0 Complete***********");
    $display("*************************************");
    $finish;
end
endtask // task0

task task1;
begin
   	handle=$fopen("result_task1.txt");

    #10000;
    $fdisplay(handle, "\nTASK0, Master node and Processor wake up");
    state = TASK0;
	@ (posedge SCLK);
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

    #10000;
    $fdisplay(handle, "\nTASK24, All Wake");
    state = TASK24;
	@ (posedge c0_tx_succ | c0_tx_fail);

    #100000;
    $fdisplay(handle, "\nTASK6, N1 sends multiple bytes down to N2 using short address");
    $fdisplay(handle, "Result: N2 RX Success");
    $fdisplay(handle, "Result: N1 TX Success");
	word_counter = 7;
    state = TASK6;
    @ (posedge n1_tx_succ | n1_tx_fail);

    #100000;
    $fdisplay(handle, "\nTASK6, N1 sends multiple bytes up to N0 using short address");
    $fdisplay(handle, "Result: N0 RX Success");
    $fdisplay(handle, "Result: N1 TX Success");
	word_counter = 7;
    state = TASK7;
    @ (posedge n1_tx_succ | n1_tx_fail);

    #100000;
    $fdisplay(handle, "\nTASK8, N1 sends multiple bytes down to N2 using long address");
    $fdisplay(handle, "Result: N2 RX Success");
    $fdisplay(handle, "Result: N3 RX Success");
    $fdisplay(handle, "Result: N1 TX Success");
	word_counter = 7;
    state = TASK8;
    @ (posedge n1_tx_succ | n1_tx_fail);

    #100000;
    $fdisplay(handle, "\nTASK9, N1 sends multiple bytes up to N0 using long address");
    $fdisplay(handle, "Result: N0 RX Success");
    $fdisplay(handle, "Result: N1 TX Success");
	word_counter = 7;
    state = TASK9;
    @ (posedge n1_tx_succ | n1_tx_fail);

    #100000;
    $fdisplay(handle, "\nTASK10, N1 sends to an unknown address");
    $fdisplay(handle, "Result: N1 TX Fail");
    state = TASK10;
    @ (posedge n1_tx_succ | n1_tx_fail);

    #100000;
    $fdisplay(handle, "\nTASK11, N1 sends multiple bytes down to N2 using short address, N1 TX buffer underflow");
    $fdisplay(handle, "Result: N2 RX Success then Fail");
    $fdisplay(handle, "Result: N1 TX Fail");
	word_counter = 7;
    state = TASK11;
    @ (posedge n1_tx_succ | n1_tx_fail);

    #100000;
    $fdisplay(handle, "\nTASK12, N1 sends multiple bytes down to N0 using short address, N1 TX buffer underflow");
    $fdisplay(handle, "Result: N0 RX Success then Fail");
    $fdisplay(handle, "Result: N1 TX Fail");
	word_counter = 7;
    state = TASK12;
    @ (posedge n1_tx_succ | n1_tx_fail);

    #100000;
    $fdisplay(handle, "\nTASK13, N1 sends multiple bytes down to N2 using short address, N2 RX buffer overflow");
    $fdisplay(handle, "Result: N2 RX Fail");
    $fdisplay(handle, "Result: N1 TX Fail");
	word_counter = 7;
    state = TASK13;
	n2_auto_rx_ack = 0;
    @ (posedge n1_tx_succ | n1_tx_fail);
	n2_auto_rx_ack = 1;

    #100000;
    $fdisplay(handle, "\nTASK14, N1 sends multiple bytes down to N0 using short address, N0 RX buffer overflow");
    $fdisplay(handle, "Result: N0 RX Fail");
    $fdisplay(handle, "Result: N1 TX Fail");
	word_counter = 7;
    state = TASK14;
	n0_auto_rx_ack = 0;
    @ (posedge n1_tx_succ | n1_tx_fail);
	n0_auto_rx_ack = 1;

    #100000;
    $fdisplay(handle, "\nTASK15, N1 sends multiple bytes down to N2 using short address, N2 RX buffer overflow");
    $fdisplay(handle, "Result: N2 RX Fail");
    $fdisplay(handle, "Result: N1 TX Fail");
	word_counter = 1;
    state = TASK15;
	n2_auto_rx_ack = 0;
    @ (posedge n1_tx_succ | n1_tx_fail);
	n2_auto_rx_ack = 1;

    #100000;
    $fdisplay(handle, "\nTASK16, N1 sends multiple bytes down to N0 using short address, N0 RX buffer overflow");
    $fdisplay(handle, "Result: N0 RX Fail");
    $fdisplay(handle, "Result: N1 TX Fail");
	word_counter = 1;
    state = TASK16;
	n0_auto_rx_ack = 0;
    @ (posedge n1_tx_succ | n1_tx_fail);
	n0_auto_rx_ack = 1;

    #100000;
    $fdisplay(handle, "\nTASK17, N0, N1 arbitrate. N0 wins");
    $fdisplay(handle, "Result: N0 TX Success");
    $fdisplay(handle, "Result: N3 RX Success");
    $fdisplay(handle, "Result: N1 TX Success");
    $fdisplay(handle, "Result: N3 RX Success");
    state = TASK17;
    @ (posedge n1_tx_succ | n1_tx_fail);

    #100000;
    $fdisplay(handle, "\nTASK18, N0, N1 arbitrate, N1 sets priority. N1 wins");
    $fdisplay(handle, "Result: N1 TX Success");
    $fdisplay(handle, "Result: N3 RX Success");
    $fdisplay(handle, "Result: N0 TX Success");
    $fdisplay(handle, "Result: N3 RX Success");
    state = TASK18;
    @ (posedge n0_tx_succ | n0_tx_fail);

    #100000;
    $fdisplay(handle, "\nTASK19, N0, N1 arbitrate. Both sets priority, N0 wins");
    $fdisplay(handle, "Result: N0 TX Success");
    $fdisplay(handle, "Result: N3 RX Success");
    $fdisplay(handle, "Result: N1 TX Success");
    $fdisplay(handle, "Result: N3 RX Success");
    state = TASK19;
    @ (posedge n1_tx_succ | n1_tx_fail);

    #100000;
    $fdisplay(handle, "\nTASK20, N0 transmits with priority set.");
    $fdisplay(handle, "Result: N0 TX Success");
    $fdisplay(handle, "Result: N3 RX Success");
    state = TASK20;
    @ (posedge n0_tx_succ | n0_tx_fail);

    #100000;
    $fdisplay(handle, "\nTASK21, Sleep all.");
    state = TASK21;
    @ (posedge c0_tx_succ | c0_tx_fail);

    #100000;
    $fdisplay(handle, "\nTASK22, N2 asserts ext_int");
    $fdisplay(handle, "Result: C0, N0, N1, N3 RX Fail");
    state = TASK22;
	@ (posedge SCLK);
    #50000;

    #100000;
    $fdisplay(handle, "\nTASK23, N2 sends to C0.");
    $fdisplay(handle, "Result: N2 TX Success");
    $fdisplay(handle, "Result: C0 RX Success");
    state = TASK23;
    @ (posedge n2_tx_succ | n2_tx_fail);

    #100000;
    $fdisplay(handle, "\nTASK25, N2 sends to N0.");
    $fdisplay(handle, "Result: N2 TX Fail");
    $fdisplay(handle, "Result: N0 RX Fail");
    state = TASK25;
    @ (posedge n2_tx_succ | n2_tx_fail);

    #300000;
    $display("*************************************");
    $display("************TASK1 Complete***********");
    $display("*************************************");
    $finish;
end
endtask

task task2;
begin
   	handle=$fopen("result_task2.txt");

    #10000;
    $fdisplay(handle, "\nTASK0, Master node and Processor wake up");
    state = TASK0;
	@ (posedge SCLK);
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

    #10000;
    $fdisplay(handle, "\nTASK24, All Wake");
    state = TASK24;
	@ (posedge c0_tx_succ | c0_tx_fail);

    #100000;
    $fdisplay(handle, "\nTASK6, introduce clock glitch");
    $fdisplay(handle, "Result: N1 TX Fail");
    $fdisplay(handle, "Result: N3 RX Fail");
	word_counter = 7;
    state = TASK6;
    @ (posedge n1_tx_succ | n1_tx_fail);

    #100000;
    $fdisplay(handle, "\nTASK7, N1 to N3");
    $fdisplay(handle, "Result: N1 TX Success");
    $fdisplay(handle, "Result: N3 RX Success");
    state = TASK7;
    @ (posedge n1_tx_succ | n1_tx_fail);

    #100000;
    $fdisplay(handle, "\nTASK8, missing 1 clock edge");
    $fdisplay(handle, "Result: N1 TX Fail");
    $fdisplay(handle, "Result: N3 RX Fail");
	word_counter = 7;
    state = TASK8;
    @ (posedge n1_tx_succ | n1_tx_fail);

    #100000;
    $fdisplay(handle, "\nTASK7, N1 to N3");
    $fdisplay(handle, "Result: N1 TX Success");
    $fdisplay(handle, "Result: N3 RX Success");
    state = TASK7;
    @ (posedge n1_tx_succ | n1_tx_fail);

    #100000;
    $fdisplay(handle, "\nTASK7, N1 to N3");
    $fdisplay(handle, "Result: N1 TX Success");
    $fdisplay(handle, "Result: N3 RX Success");
    state = TASK7;
    @ (posedge n1_tx_succ | n1_tx_fail);

    #100000;
    $fdisplay(handle, "\nTASK7, N1 to N3");
    $fdisplay(handle, "Result: N1 TX Success");
    $fdisplay(handle, "Result: N3 RX Success");
    state = TASK7;
    @ (posedge n1_tx_succ | n1_tx_fail);

    #100000;
    $fdisplay(handle, "\nTASK7, N1 to N3");
    $fdisplay(handle, "Result: N1 TX Success");
    $fdisplay(handle, "Result: N3 RX Success");
    state = TASK7;
    @ (posedge n1_tx_succ | n1_tx_fail);

    #300000;
    $display("*************************************");
    $display("************TASK2 Complete***********");
    $display("*************************************");
    $finish;
end
endtask
