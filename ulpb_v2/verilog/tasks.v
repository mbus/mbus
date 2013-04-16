
//****************************************
//Task 0 testbench: Comprehensive testbench
//****************************************
task task0;
   begin
      clk = 0;
      resetn = 1;
      n0_auto_rx_ack = 1;
      n1_auto_rx_ack = 1;
      n2_auto_rx_ack = 1;
      c0_auto_rx_ack = 1;
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
      $fdisplay(handle, "TASK4, Master node enumerate with address 4'h4");
      state = TASK4;
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
	  @ (posedge c0_tx_succ|c0_tx_fail);

      #10000;
      $fdisplay(handle, "TASK5, n1 to n0 using long address");
      $fdisplay(handle, "Result: N1 TX success");
      state = TASK5;
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
	  @ (posedge n1_tx_succ|n1_tx_fail);

      #10000;
      $fdisplay(handle, "TASK6, n1 to n2 using long address");
      $fdisplay(handle, "Result: N1 TX success");
      state = TASK6;
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
	  @ (posedge n1_tx_succ|n1_tx_fail);

      #10000;
      $fdisplay(handle, "TASK7, n1 to n0 using short address");
      $fdisplay(handle, "Result: N1 TX success");
      state = TASK7;
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
	  @ (posedge n1_tx_succ|n1_tx_fail);

      #10000;
      $fdisplay(handle, "TASK8, n1 to n2 using short address");
      $fdisplay(handle, "Result: N1 TX success");
      state = TASK8;
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
	  @ (posedge n1_tx_succ|n1_tx_fail);

      #10000;
      $fdisplay(handle, "TASK9, invalidate 4'h2 (n0) short address");
      state = TASK9;
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
	  @ (posedge c0_tx_succ|c0_tx_fail);

      #10000;
      $fdisplay(handle, "TASK7, n1 to n0 using short address");
      $fdisplay(handle, "Result: N1 TX fail");
      state = TASK7;
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
	  @ (posedge n1_tx_succ|n1_tx_fail);

      #10000;
      $fdisplay(handle, "TASK10, Master node enumerate with address 4'h8");
      state = TASK10;
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
	  @ (posedge c0_rx_req);

      #10000;
      $fdisplay(handle, "TASK11, n1 to n0 using short address");
      $fdisplay(handle, "Result: N1 TX success");
      state = TASK11;
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
	  @ (posedge n1_tx_succ|n1_tx_fail);

      #10000;
      $fdisplay(handle, "TASK12, Selective sleep n0, n2");
      state = TASK12;
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
	  @ (posedge c0_tx_succ | c0_tx_fail);

      #10000;
      $fdisplay(handle, "TASK13, n2 asserts ext_int");
      $fdisplay(handle, "Result: c0, n1 RX fail");
      state = TASK13;
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
	  @ (posedge SCLK);
	  n2_req_int = 0;
      #50000;

      #10000;
      $fdisplay(handle, "TASK14, n2 to n0 using short address");
      $fdisplay(handle, "Result: N2 TX success");
      $fdisplay(handle, "Result: N0 RX success");
      state = TASK14;
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
	  @ (posedge n2_tx_succ|n2_tx_fail);
	  

      #10000;
      $display("*************************************");
      $display("************TASK0 Complete***********");
      $display("*************************************");
      $finish;
   end
endtask // task0
