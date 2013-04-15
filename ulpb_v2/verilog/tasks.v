
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
      $fdisplay(handle, "TASK5, n0 to n1 using long address");
      state = TASK5;
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
	  @ (posedge n1_tx_succ|n1_tx_fail);

      #10000;
      $fdisplay(handle, "TASK6, n0 to n1 using long address");
      state = TASK6;
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
	  @ (posedge n1_tx_succ|n1_tx_fail);

      #10000;
      $display("*************************************");
      $display("************TASK0 Complete***********");
      $display("*************************************");
      $finish;
   end
endtask // task0
