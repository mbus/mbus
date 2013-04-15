
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

/*
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
	  */

      #10000;
      $display("*************************************");
      $display("************TASK0 Complete***********");
      $display("*************************************");
      $finish;
   end
endtask // task0
