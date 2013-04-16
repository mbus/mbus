
//****************************************
//Task 0 testbench: Comprehensive testbench
//****************************************
task task0;
   begin
      clk = 0;
      resetn = 1;
      handle=$fopen("result_task0.txt");

      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      `SD resetn = 0;
      @ (posedge clk);
      @ (posedge clk);
      `SD resetn = 1;
      @ (posedge clk);
      @ (posedge clk);

      #10000;
      $fdisplay(handle, "TASK0, Master node and Processor wake up");
      state = TASK0;
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
	  @ (posedge SCLK);
	  c0_req_int = 0;
      #50000;

      #10000;
      $fdisplay(handle, "TASK1, Master node sends out querry");
      state = TASK1;
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
	  @ (posedge c0_rx_req);
	  @ (posedge c0_rx_req);
	  @ (posedge c0_rx_req);
	  @ (posedge c0_rx_req);

      #10000;
      $fdisplay(handle, "TASK2, Master node enumerate with address 4'h2");
      state = TASK2;
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
	  @ (posedge c0_rx_req);

      #10000;
      $fdisplay(handle, "TASK3, Master node enumerate with address 4'h3");
      state = TASK3;
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
	  @ (posedge c0_rx_req);

      #10000;
      $fdisplay(handle, "TASK4, Master node enumerate with address 4'h4");
      state = TASK4;
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
	  @ (posedge c0_rx_req);

      #10000;
      $fdisplay(handle, "TASK5, Master node enumerate with address 4'h5");
      state = TASK5;
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
	  @ (posedge c0_rx_req);

      #10000;
      $fdisplay(handle, "TASK6, N1 to N0 using long address");
      $fdisplay(handle, "Result: N1 TX Success");
      $fdisplay(handle, "Result: N0 RX Success");
      state = TASK6;
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
	  @ (posedge n1_tx_succ|n1_tx_fail);

      #10000;
      $fdisplay(handle, "TASK7, N1 to N2 using long address");
      $fdisplay(handle, "Result: N1 TX Success");
      $fdisplay(handle, "Result: N2 RX Success");
      $fdisplay(handle, "Result: N3 RX Success");
      state = TASK7;
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
	  @ (posedge n1_tx_succ|n1_tx_fail);

      #10000;
      $fdisplay(handle, "TASK8, N1 to N0 using short address");
      $fdisplay(handle, "Result: N1 TX Success");
      $fdisplay(handle, "Result: N0 RX Success");
      state = TASK8;
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
	  @ (posedge n1_tx_succ|n1_tx_fail);

      #10000;
      $fdisplay(handle, "TASK9, N1 to N2 using short address");
      $fdisplay(handle, "Result: N1 TX Success");
      $fdisplay(handle, "Result: N2 RX Success");
      state = TASK9;
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
	  @ (posedge n1_tx_succ|n1_tx_fail);

      #10000;
      $fdisplay(handle, "TASK10, N1 to N3 using short address");
      $fdisplay(handle, "Result: N1 TX Success");
      $fdisplay(handle, "Result: N3 RX Success");
      state = TASK10;
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
	  @ (posedge n1_tx_succ|n1_tx_fail);

      #10000;
      $fdisplay(handle, "TASK11, invalidate 4'h2 (n0) short address");
      state = TASK11;
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
	  @ (posedge c0_tx_succ|c0_tx_fail);
	  // n0 -> 4'hf (invalid)
	  // n1 -> 4'h3
	  // n2 -> 4'h4
	  // n3 -> 4'h5

      #10000;
      $fdisplay(handle, "TASK8, N1 to N0 using short address");
      $fdisplay(handle, "Result: N1 TX Fail");
      state = TASK8;
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
	  @ (posedge n1_tx_succ|n1_tx_fail);

      #10000;
      $fdisplay(handle, "TASK12, Master node enumerate with address 4'h8");
      state = TASK12;
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
	  @ (posedge c0_rx_req);
	  // n0 -> 4'h8
	  // n1 -> 4'h3
	  // n2 -> 4'h4
	  // n3 -> 4'h5

      #10000;
      $fdisplay(handle, "TASK13, N1 to N0 using short address");
      $fdisplay(handle, "Result: N1 TX Success");
      $fdisplay(handle, "Result: N0 RX Success");
      state = TASK13;
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
	  @ (posedge n1_tx_succ|n1_tx_fail);

      #10000;
      $fdisplay(handle, "TASK14, Selective sleep N0, N2");
      state = TASK14;
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
	  @ (posedge c0_tx_succ | c0_tx_fail);

      #10000;
      $fdisplay(handle, "TASK15, N2 asserts ext_int");
      $fdisplay(handle, "Result: C0, N1, N2, N3 RX Fail");
      state = TASK15;
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
	  @ (posedge SCLK);
	  n2_req_int = 0;
      #50000;

      #10000;
      $fdisplay(handle, "TASK16, N2 to N0 using short address");
      $fdisplay(handle, "Result: N2 TX Success");
      $fdisplay(handle, "Result: N0 RX Success");
      state = TASK16;
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
	  @ (posedge n2_tx_succ|n2_tx_fail);
	  
      #10000;
      $fdisplay(handle, "TASK14, Selective sleep N0, N2");
      state = TASK14;
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
	  @ (posedge c0_tx_succ | c0_tx_fail);

      #10000;
      $fdisplay(handle, "TASK10, N1 to N3 using short address");
      $fdisplay(handle, "Result: N1 TX Success");
      $fdisplay(handle, "Result: N3 RX Success");
      state = TASK10;
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
	  @ (posedge n1_tx_succ|n1_tx_fail);

      #10000;
      $fdisplay(handle, "TASK17, Master node sends out long querry");
      state = TASK17;
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
	  @ (posedge c0_rx_req);
	  @ (posedge c0_rx_req);
	  @ (posedge c0_rx_req);
	  @ (posedge c0_rx_req);

      #10000;
      $fdisplay(handle, "TASK18, All sleep");
      state = TASK18;
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
	  @ (posedge c0_tx_succ | c0_tx_fail);

      #10000;
      $fdisplay(handle, "TASK0, Master node and Processor wake up");
      state = TASK0;
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
	  @ (posedge SCLK);
	  c0_req_int = 0;
      #50000;

      #10000;
      $fdisplay(handle, "TASK17, Master node sends out long querry");
      state = TASK17;
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
	  @ (posedge c0_rx_req);
	  @ (posedge c0_rx_req);
	  @ (posedge c0_rx_req);
	  @ (posedge c0_rx_req);

      #10000;
      $fdisplay(handle, "TASK18, All sleep");
      state = TASK18;
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
	  @ (posedge c0_tx_succ | c0_tx_fail);

      #10000;
      $fdisplay(handle, "TASK0, Master node and Processor wake up");
      state = TASK0;
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
	  @ (posedge SCLK);
	  c0_req_int = 0;
      #50000;

      #10000;
      $fdisplay(handle, "TASK19, All Wake");
      state = TASK19;
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
	  @ (posedge c0_tx_succ | c0_tx_fail);

      #10000;
      $fdisplay(handle, "TASK20, Invalidate all short address");
      state = TASK20;
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
	  @ (posedge c0_tx_succ | c0_tx_fail);

      #10000;
      $fdisplay(handle, "TASK1, Master node sends out querry");
      state = TASK1;
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
	  @ (posedge c0_rx_req);
	  @ (posedge c0_rx_req);
	  @ (posedge c0_rx_req);
	  @ (posedge c0_rx_req);

      #10000;
      $fdisplay(handle, "TASK21, Selective sleep N1 using long prefix");
      state = TASK21;
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
	  @ (posedge c0_tx_succ | c0_tx_fail);

      #10000;
      $fdisplay(handle, "TASK22, Selective sleep processor using long prefix");
      state = TASK22;
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
	  @ (posedge c0_tx_succ | c0_tx_fail);

      #10000;
      $fdisplay(handle, "TASK23, N2 node sends out querry");
      state = TASK23;
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
	  @ (posedge n2_rx_req);
	  @ (posedge n2_rx_req);
	  @ (posedge n2_rx_req);
	  @ (posedge n2_rx_req);


      #10000;
      $display("*************************************");
      $display("************TASK0 Complete***********");
      $display("*************************************");
      $finish;
   end
endtask // task0
