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
      clk_en = 1;
      handle=$fopen("node_tb.txt");

      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      `SD resetn = 0;
      @ (posedge clk);
      @ (posedge clk);
      `SD resetn = 1;
      @ (posedge clk);
      @ (posedge clk);
      clk_en = 0;

      #10000;
      clk_en = 1;
      $fdisplay(handle, "TASK0, Correct result: N1 TX Success");
      state = TASK0;
      @ (posedge n1_tx_succ | n1_tx_fail);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      clk_en = 0;

      #10000;
      clk_en = 1;
      $fdisplay(handle, "TASK1, Correct result: N1 TX Success");
      word_counter = 7;
      state = TASK1;
      @ (posedge n1_tx_succ | n1_tx_fail);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      clk_en = 0;

      #10000;
      clk_en = 1;
      $fdisplay(handle, "TASK2, Correct result: N1 TX Success");
      state = TASK2;
      @ (posedge n1_tx_succ | n1_tx_fail);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      clk_en = 0;

      #10000;
      clk_en = 1;
      $fdisplay(handle, "TASK3, Correct result: N1 TX Success");
      word_counter = 7;
      state = TASK3;
      @ (posedge n1_tx_succ | n1_tx_fail);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      clk_en = 0;

      #10000;
      clk_en = 1;
      $fdisplay(handle, "TASK4, Correct result: N1 TX Fail");
      state = TASK4;
      @ (posedge n1_tx_succ | n1_tx_fail);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      clk_en = 0;

      #10000;
      clk_en = 1;
      $fdisplay(handle, "TASK5, Correct result: N1 TX Fail");
      word_counter = 7;
      state = TASK5;
      @ (posedge n1_tx_succ | n1_tx_fail);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      clk_en = 0;

      #10000;
      clk_en = 1;
      $fdisplay(handle, "TASK6, Correct result: N1 TX Fail");
      word_counter = 7;
      state = TASK6;
      @ (posedge n1_tx_succ | n1_tx_fail);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      clk_en = 0;

      #10000;
      clk_en = 1;
      $fdisplay(handle, "TASK7, Correct result: N1 TX Fail");
      word_counter = 7;
      state = TASK7;
      n2_auto_rx_ack = 0;
      @ (posedge n1_tx_succ | n1_tx_fail);
      n2_auto_rx_ack = 1;
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      clk_en = 0;
      
      #10000;
      clk_en = 1;
      $fdisplay(handle, "TASK8, Correct result: N1 TX Fail");
      word_counter = 7;
      state = TASK8;
      n0_auto_rx_ack = 0;
      @ (posedge n1_tx_succ | n1_tx_fail);
      n0_auto_rx_ack = 1;
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      clk_en = 0;

      #10000;
      clk_en = 1;
      $fdisplay(handle, "TASK9, Correct result: N1 TX Fail");
      word_counter = 1;
      state = TASK9;
      n2_auto_rx_ack = 0;
      @ (posedge n1_tx_succ | n1_tx_fail);
      n2_auto_rx_ack = 1;
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      clk_en = 0;

      #10000;
      clk_en = 1;
      $fdisplay(handle, "TASK10, Correct result: N1 TX Fail");
      word_counter = 1;
      state = TASK10;
      n0_auto_rx_ack = 0;
      @ (posedge n1_tx_succ | n1_tx_fail);
      n0_auto_rx_ack = 1;
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      clk_en = 0;

      #10000;
      clk_en = 1;
      $fdisplay(handle, "TASK1l, Correct result: N0, N1 TX Success");
      state = TASK11;
      @ (posedge n0_tx_succ | n0_tx_fail);
      @ (posedge n1_tx_succ | n1_tx_fail);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      clk_en = 0;

      #10000;
      clk_en = 1;
      $fdisplay(handle, "TASK12, Correct result: N1, N0 TX Success");
      state = TASK12;
      @ (posedge n1_tx_succ | n1_tx_fail);
      @ (posedge n0_tx_succ | n0_tx_fail);
      n1_priority = 0;
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      clk_en = 0;

      #10000;
      clk_en = 1;
      $fdisplay(handle, "TASK13, Correct result: N0, N1 TX Success");
      state = TASK13;
      @ (posedge n0_tx_succ | n0_tx_fail);
      @ (posedge n1_tx_succ | n1_tx_fail);
      n0_priority = 0;
      n1_priority = 0;
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      clk_en = 0;

      #10000;
      clk_en = 1;
      $fdisplay(handle, "TASK14, Correct result: N0 TX Success");
      state = TASK14;
      @ (posedge n0_tx_succ | n0_tx_fail);
      n0_priority = 0;
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      clk_en = 0;

      #10000;
      clk_en = 1;
      $fdisplay(handle, "TASK15, Correct result: N0 TX Success, N1, N2, C0 Received");
      state = TASK15;
      @ (posedge n0_tx_succ | n0_tx_fail);
      n0_priority = 0;
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      clk_en = 0;

      #10000;
      clk_en = 1;
      $fdisplay(handle, "TASK16, Correct result: N1 TX Success");
      state = TASK16;
      @ (posedge n1_tx_succ | n1_tx_fail);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      clk_en = 0;

      #10000;
      clk_en = 1;
      $fdisplay(handle, "TASK17, Correct result: N1 TX Success");
      state = TASK17;
      @ (posedge n1_tx_succ | n1_tx_fail);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      clk_en = 0;

      #10000;
      clk_en = 1;
      $fdisplay(handle, "TASK18, Correct result: N0 TX Success");
      state = TASK18;
      @ (posedge n0_tx_succ | n0_tx_fail);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      clk_en = 0;

      #10000;
      clk_en = 1;
      $fdisplay(handle, "TASK19, Correct result: N2 TX Success");
      state = TASK19;
      @ (posedge n2_tx_succ | n2_tx_fail);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      clk_en = 0;

      #10000;
      clk_en = 1;
      $fdisplay(handle, "TASK20, Correct result: N0 TX Success");
      state = TASK20;
      @ (posedge n0_tx_succ | n0_tx_fail);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      clk_en = 0;

      #10000;
      clk_en = 1;
      $fdisplay(handle, "TASK21, Correct result: N2 TX Success");
      state = TASK21;
      @ (posedge n2_tx_succ | n2_tx_fail);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      clk_en = 0;

      #10000;
      clk_en = 1;
      $fdisplay(handle, "TASK22, Correct result: N0 TX Fail");
      word_counter = 7;
      state = TASK22;
      n1_auto_rx_ack = 0;
      @ (posedge n0_tx_succ | n0_tx_fail);
      n1_auto_rx_ack = 1;
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      clk_en = 0;

      #10000;
      clk_en = 1;
      $fdisplay(handle, "TASK23, Correct result: N2 TX Fail");
      word_counter = 7;
      state = TASK23;
      n1_auto_rx_ack = 0;
      @ (posedge n2_tx_succ | n2_tx_fail);
      n1_auto_rx_ack = 1;
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      clk_en = 0;

      #10000;
      clk_en = 1;
      $fdisplay(handle, "TASK24, Correct result: N0 TX Fail");
      word_counter = 1;
      state = TASK24;
      n1_auto_rx_ack = 0;
      @ (posedge n0_tx_succ | n0_tx_fail);
      n1_auto_rx_ack = 1;
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      clk_en = 0;

      #10000;
      clk_en = 1;
      $fdisplay(handle, "TASK25, Correct result: N2 TX Fail");
      word_counter = 1;
      state = TASK25;
      n1_auto_rx_ack = 0;
      @ (posedge n2_tx_succ | n2_tx_fail);
      n1_auto_rx_ack = 1;
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      clk_en = 0;

      #10000;
      clk_en = 1;
      $fdisplay(handle, "TASK26, Correct result: N1 TX Fail");
      state = TASK26;
      @ (posedge n1_tx_succ | n1_tx_fail);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      clk_en = 0;

      #10000;
      clk_en = 1;
      $fdisplay(handle, "TASK27, Correct result: C0 TX Fail");
      state = TASK27;
      @ (posedge c0_tx_succ | c0_tx_fail);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      clk_en = 0;

      #10000;
      $display("*************************************");
      $display("************TASK0 Complete***********");
      $display("*************************************");
      $finish;
   end
endtask // task0

//****************************************
//Task 1: Only CLK_EXT is being toggled
//****************************************
task task1;
   begin
      clk = 0;
      resetn = 1;
      n0_auto_rx_ack = 1;
      n1_auto_rx_ack = 1;
      n2_auto_rx_ack = 1;
      c0_auto_rx_ack = 1;
      clk_en = 1;
      handle=$fopen("task1_tb.txt");
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      `SD resetn = 0;
      @ (posedge clk);
      @ (posedge clk);
      `SD resetn = 1;
      @ (posedge clk);
      @ (posedge clk);
      #500000;
      $display("*************************************");
      $display("************TASK1 Complete***********");
      $display("*************************************");
      $finish;
   end
endtask // task1

//****************************************
//Task 2: ctrl_wrapper transmits word to node_ab
//****************************************
task task2;
   begin
      clk = 0;
      resetn = 1;
      n0_auto_rx_ack = 1;
      n1_auto_rx_ack = 1;
      n2_auto_rx_ack = 1;
      c0_auto_rx_ack = 1;
      clk_en = 1;
      handle=$fopen("task2_tb.txt");
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      `SD resetn = 0;
      @ (posedge clk);
      @ (posedge clk);
      `SD resetn = 1;
      @ (posedge clk);
      @ (posedge clk);
      $fdisplay(handle, "TASK0, Correct result: C0 TX Success");
      state = TASK0;
      @ (posedge c0_tx_succ | c0_tx_fail);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      clk_en = 0;
      $display("*************************************");
      $display("************TASK2 Complete***********");
      $display("*************************************");
      $finish;
   end
endtask // task2

//****************************************
//Task 3_1: node_cd transmit word to node_ef
//****************************************
task task3_1;
   begin
      clk = 0;
      resetn = 1;
      n0_auto_rx_ack = 1;
      n1_auto_rx_ack = 1;
      n2_auto_rx_ack = 1;
      c0_auto_rx_ack = 1;
      clk_en = 1;
      handle=$fopen("task3_1_tb.txt");
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      `SD resetn = 0;
      @ (posedge clk);
      @ (posedge clk);
      `SD resetn = 1;
      @ (posedge clk);
      @ (posedge clk);
      $fdisplay(handle, "TASK0, Correct result: N1 TX Success");
      state = TASK0;
      @ (posedge n1_tx_succ | n1_tx_fail);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      clk_en = 0;
      $display("*************************************");
      $display("**********TASK3_1 Complete***********");
      $display("*************************************");
      $finish;
   end
endtask // task3_1

//****************************************
//Task 3_1: node_cd transmit 256 words to node_ef
//****************************************
task task3_2;
   begin
      clk = 0;
      resetn = 1;
      n0_auto_rx_ack = 1;
      n1_auto_rx_ack = 1;
      n2_auto_rx_ack = 1;
      c0_auto_rx_ack = 1;
      clk_en = 1;
      handle=$fopen("task3_2_tb.txt");
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      `SD resetn = 0;
      @ (posedge clk);
      @ (posedge clk);
      `SD resetn = 1;
      @ (posedge clk);
      @ (posedge clk);
      $fdisplay(handle, "TASK0, Correct result: N1 TX Success");
      word_counter = 255;
      state = TASK0;
      @ (posedge n1_tx_succ | n1_tx_fail);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      clk_en = 0;
      $display("*************************************");
      $display("**********TASK3_2 Complete***********");
      $display("*************************************");
      $finish;
   end
endtask // task3_2

//****************************************
//Task 4: test power gated layer (RX only)
//****************************************
task task4;
   begin
      clk = 0;
      resetn = 1;
      n0_auto_rx_ack = 1;
      n1_auto_rx_ack = 1;
      n2_auto_rx_ack = 1;
      c0_auto_rx_ack = 1;
      clk_en = 1;
      handle=$fopen("task4_tb.txt");

      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      `SD resetn = 0;
      @ (posedge clk);
      @ (posedge clk);
      `SD resetn = 1;
      @ (posedge clk);
      @ (posedge clk);
      clk_en = 0;

      #10000;
      clk_en = 1;
      $fdisplay(handle, "TASK0, Correct result: N1 TX Success");
      state = TASK0;
      @ (posedge n1_tx_succ | n1_tx_fail);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      clk_en = 0;

      #10000;
      clk_en = 1;
      $fdisplay(handle, "TASK1, Correct result: N1 TX Success");
      word_counter = 7;
      state = TASK1;
      @ (posedge n1_tx_succ | n1_tx_fail);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      clk_en = 0;

      #10000;
      clk_en = 1;
      $fdisplay(handle, "TASK2, Correct result: N1 TX Success");
      state = TASK2;
      @ (posedge n1_tx_succ | n1_tx_fail);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      clk_en = 0;

      #10000;
      clk_en = 1;
      $fdisplay(handle, "TASK3, Correct result: N1 TX Success");
      word_counter = 7;
      state = TASK3;
      @ (posedge n1_tx_succ | n1_tx_fail);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      clk_en = 0;

      #10000;
      clk_en = 1;
      $fdisplay(handle, "TASK4, Correct result: N1 TX Fail");
      state = TASK4;
      @ (posedge n1_tx_succ | n1_tx_fail);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      clk_en = 0;

      #10000;
      clk_en = 1;
      $fdisplay(handle, "TASK5, Correct result: N1 TX Fail");
      word_counter = 7;
      state = TASK5;
      @ (posedge n1_tx_succ | n1_tx_fail);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      clk_en = 0;

      #10000;
      clk_en = 1;
      $fdisplay(handle, "TASK6, Correct result: N1 TX Fail");
      word_counter = 7;
      state = TASK6;
      @ (posedge n1_tx_succ | n1_tx_fail);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      clk_en = 0;

      #10000;
      clk_en = 1;
      $fdisplay(handle, "TASK7, Correct result: N1 TX Fail");
      word_counter = 7;
      state = TASK7;
      n2_auto_rx_ack = 0;
      @ (posedge n1_tx_succ | n1_tx_fail);
      n2_auto_rx_ack = 1;
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      clk_en = 0;
      
      #10000;
      clk_en = 1;
      $fdisplay(handle, "TASK8, Correct result: N1 TX Fail");
      word_counter = 7;
      state = TASK8;
      n0_auto_rx_ack = 0;
      @ (posedge n1_tx_succ | n1_tx_fail);
      n0_auto_rx_ack = 1;
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      clk_en = 0;

      #10000;
      clk_en = 1;
      $fdisplay(handle, "TASK9, Correct result: N1 TX Fail");
      word_counter = 1;
      state = TASK9;
      n2_auto_rx_ack = 0;
      @ (posedge n1_tx_succ | n1_tx_fail);
      n2_auto_rx_ack = 1;
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      clk_en = 0;

      #10000;
      clk_en = 1;
      $fdisplay(handle, "TASK10, Correct result: N1 TX Fail");
      word_counter = 1;
      state = TASK10;
      n0_auto_rx_ack = 0;
      @ (posedge n1_tx_succ | n1_tx_fail);
      n0_auto_rx_ack = 1;
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      clk_en = 0;

      #10000;
      clk_en = 1;
      $fdisplay(handle, "TASK11, Correct result: N0 Sleep");
      state = TASK11;
      @ (posedge n1_tx_succ | n1_tx_fail);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      clk_en = 0;

      #10000;
      clk_en = 1;
      $fdisplay(handle, "TASK12, Correct result: N1 Sleep");
      state = TASK12;
      @ (posedge n1_tx_succ | n1_tx_fail);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      clk_en = 0;

      #10000;
      clk_en = 1;
      $fdisplay(handle, "TASK13, Correct result: N0, N1 Sleep");
      state = TASK13;
      @ (posedge n1_tx_succ | n1_tx_fail);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      @ (posedge clk);
      clk_en = 0;

      $display("*************************************");
      $display("**********TASK4 Complete***********");
      $display("*************************************");
      $finish;
   end
endtask // task4
