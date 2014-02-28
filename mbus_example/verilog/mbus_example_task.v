task check_reset;
   begin
      $display("***********************************************");
      $display("******************!Executing!******************");
      $display("********************!Check!********************");
      $display("********************!Reset!********************");
      $display("***********************************************");
      if (mbus_example_test.mbus_example_0.clkgen_0.CLK_TUNE	!== 4'hA ) failure;
      if (mbus_example_test.mbus_example_0.ablk_0.ABLK_PG	!== 1'h1 ) failure;
      if (mbus_example_test.mbus_example_0.ablk_0.ABLK_RESETn	!== 1'h0 ) failure;
      if (mbus_example_test.mbus_example_0.ablk_0.ABLK_EN	!== 1'h0 ) failure;
      if (mbus_example_test.mbus_example_0.ablk_0.ABLK_CONFIG_0	!== 4'h7 ) failure;
      if (mbus_example_test.mbus_example_0.ablk_0.ABLK_CONFIG_1	!== 4'hD ) failure;
      if (mbus_example_test.mbus_example_0.timer_0.TIMER_RESETn	!== 1'h0 ) failure;
      if (mbus_example_test.mbus_example_0.timer_0.TIMER_EN	!== 1'h0 ) failure;
      if (mbus_example_test.mbus_example_0.timer_0.TIMER_ROI	!== 1'h0 ) failure;
      if (mbus_example_test.mbus_example_0.timer_0.TIMER_SAT	!== 8'hFF ) failure;
   end
endtask // check_reset

task enumerate;
   begin
      $display("***********************************************");
      $display("*****************Enumeration*******************");
      $display("***********************************************");

      $display("* CTR: Sending enumeration Query Msg");
      Send_MBus(32'h00000000, 32'h00000000);

      @(posedge RX_REQ);	// Wait for RX_REQ (query reply)
      if( RX_ADDR[7:0] == 8'h00 && RX_DATA[31:28] == 4'h1 ) begin
            $display("* CTR: Query Response Rcvd");
	    $display("    Full prefix : 0x%5h ",RX_DATA[23:4]);
	    $display("    Short prefix: 0x%1h ",RX_DATA[3:0]);
      end
      else failure;
      @(posedge MBUS_CLKIN);
      RX_ACK = 1'b1;
      @(negedge RX_REQ);
      @(posedge MBUS_CLKIN);
      RX_ACK = 1'b0;
      @(posedge MBUS_CLKIN);

      $display("* CTR: Sending enumeration (0x4) Msg");
      Send_MBus(32'h00000000, 32'h24000000);

      @(posedge RX_REQ);	// Wait for RX_REQ (enumeration reply)
      if( RX_ADDR[7:0] == 8'h00 && RX_DATA[31:28] == 4'h1 ) begin
            $display("* CTR: Enumeration Response Rcvd");
	    $display("    Full prefix : 0x%5h ",RX_DATA[23:4]);
	    $display("    Short prefix: 0x%1h ",RX_DATA[3:0]);
      end
      else failure;
      @(posedge MBUS_CLKIN);
      RX_ACK = 1'b1;
      @(negedge RX_REQ);
      @(posedge MBUS_CLKIN);
      RX_ACK = 1'b0;
      @(posedge MBUS_CLKIN);
   end
endtask

task load_rf;
   begin
      $display("***********************************************");
      $display("*****************Read RegBank******************");
      $display("***********************************************");
      
      READ_REG( 8'h00, 6'd19, {15'h0, 4'hA});
      READ_REG( 8'h01, 6'd19, {8'h14, 8'hFF, 1'h0, 1'h0, 1'h0});
      READ_REG( 8'h02, 6'd19, {10'h0, 1'h0, 8'h0});
      READ_REG( 8'h03, 6'd19, {8'h0, 4'hD, 4'h7, 1'h0, 1'h0, 1'h1});

      $display("Checking CLK_TUNE");
      WRITE_REG(8'h00,        {15'h0, 4'h5});
      READ_REG( 8'h00, 6'd19, {15'h0, 4'h5});
      WRITE_REG(8'h00,        {15'h0, 4'hA});
      READ_REG( 8'h00, 6'd19, {15'h0, 4'hA});

      
      $display("Checking TIMER_RESETn");
      WRITE_REG(8'h01,        {8'h14, 8'hFF, 1'h0, 1'h0, 1'h1});
      READ_REG( 8'h01, 6'd19, {8'h14, 8'hFF, 1'h0, 1'h0, 1'h1});
      WRITE_REG(8'h01,        {8'h14, 8'hFF, 1'h0, 1'h0, 1'h0});
      READ_REG( 8'h01, 6'd19, {8'h14, 8'hFF, 1'h0, 1'h0, 1'h0});
      $display("Checking TIMER_ROI");
      WRITE_REG(8'h01,        {8'h14, 8'hFF, 1'h1, 1'h0, 1'h0});
      READ_REG( 8'h01, 6'd19, {8'h14, 8'hFF, 1'h1, 1'h0, 1'h0});
      WRITE_REG(8'h01,        {8'h14, 8'hFF, 1'h0, 1'h0, 1'h0});
      READ_REG( 8'h01, 6'd19, {8'h14, 8'hFF, 1'h0, 1'h0, 1'h0});
      $display("Checking TIMER_SAT");
      WRITE_REG(8'h01,        {8'h14, 8'h00, 1'h0, 1'h0, 1'h0});
      READ_REG( 8'h01, 6'd19, {8'h14, 8'h00, 1'h0, 1'h0, 1'h0});
      WRITE_REG(8'h01,        {8'h14, 8'hFF, 1'h0, 1'h0, 1'h0});
      READ_REG( 8'h01, 6'd19, {8'h14, 8'hFF, 1'h0, 1'h0, 1'h0});
      $display("Checking rf2lc_mbus_reply_address_timer");
      WRITE_REG(8'h01,        {8'hEB, 8'hFF, 1'h0, 1'h0, 1'h0});
      READ_REG( 8'h01, 6'd19, {8'hEB, 8'hFF, 1'h0, 1'h0, 1'h0});
      WRITE_REG(8'h01,        {8'h14, 8'hFF, 1'h0, 1'h0, 1'h0});
      READ_REG( 8'h01, 6'd19, {8'h14, 8'hFF, 1'h0, 1'h0, 1'h0});

      $display("Checking ABLK_PG");
      WRITE_REG(8'h03,        {8'h0, 4'hD, 4'h7, 1'h0, 1'h0, 1'h0});
      READ_REG( 8'h03, 6'd19, {8'h0, 4'hD, 4'h7, 1'h0, 1'h0, 1'h0});
      WRITE_REG(8'h03,        {8'h0, 4'hD, 4'h7, 1'h0, 1'h0, 1'h1});
      READ_REG( 8'h03, 6'd19, {8'h0, 4'hD, 4'h7, 1'h0, 1'h0, 1'h1});
      $display("Checking ABLK_RESETn");
      WRITE_REG(8'h03,        {8'h0, 4'hD, 4'h7, 1'h0, 1'h1, 1'h1});
      READ_REG( 8'h03, 6'd19, {8'h0, 4'hD, 4'h7, 1'h0, 1'h1, 1'h1});
      WRITE_REG(8'h03,        {8'h0, 4'hD, 4'h7, 1'h0, 1'h0, 1'h1});
      READ_REG( 8'h03, 6'd19, {8'h0, 4'hD, 4'h7, 1'h0, 1'h0, 1'h1});
      $display("Checking ABLK_EN");
      WRITE_REG(8'h03,        {8'h0, 4'hD, 4'h7, 1'h1, 1'h0, 1'h1});
      READ_REG( 8'h03, 6'd19, {8'h0, 4'hD, 4'h7, 1'h1, 1'h0, 1'h1});
      WRITE_REG(8'h03,        {8'h0, 4'hD, 4'h7, 1'h0, 1'h0, 1'h1});
      READ_REG( 8'h03, 6'd19, {8'h0, 4'hD, 4'h7, 1'h0, 1'h0, 1'h1});
      $display("Checking ABLK_CONFIG_0");
      WRITE_REG(8'h03,        {8'h0, 4'hD, 4'h8, 1'h0, 1'h0, 1'h1});
      READ_REG( 8'h03, 6'd19, {8'h0, 4'hD, 4'h8, 1'h0, 1'h0, 1'h1});
      WRITE_REG(8'h03,        {8'h0, 4'hD, 4'h7, 1'h0, 1'h0, 1'h1});
      READ_REG( 8'h03, 6'd19, {8'h0, 4'hD, 4'h7, 1'h0, 1'h0, 1'h1});
      $display("Checking ABLK_CONFIG_1");
      WRITE_REG(8'h03,        {8'h0, 4'h2, 4'h8, 1'h0, 1'h0, 1'h1});
      READ_REG( 8'h03, 6'd19, {8'h0, 4'h2, 4'h8, 1'h0, 1'h0, 1'h1});
      WRITE_REG(8'h03,        {8'h0, 4'hD, 4'h7, 1'h0, 1'h0, 1'h1});
      READ_REG( 8'h03, 6'd19, {8'h0, 4'hD, 4'h7, 1'h0, 1'h0, 1'h1});
   end
endtask // load_rf

task start_timer;
   begin
      $display("***********************************************");
      $display("*****************Start Timer*******************");
      $display("***********************************************");

      //Deassert Reset
      WRITE_REG(8'h01,        {8'h14, 8'hFF, 1'h0, 1'h0, 1'h1});
      //Set Saturation Value
      WRITE_REG(8'h01,        {8'h14, 8'h1F, 1'h0, 1'h0, 1'h1});
      //Go
      WRITE_REG(8'h01,        {8'h14, 8'h1F, 1'h0, 1'h1, 1'h1});
      @(posedge RX_REQ);	// Wait for RX_REQ
      $display("* CTR: Interrupt Message received");
      //Check Payload
      CheckValue( RX_DATA[31:0], {10'h0, 1'h0, 8'h0}, 32'h007FFFFF );
      @(posedge MBUS_CLKIN);
      //Acknolwedge
      RX_ACK = 1'b1;
      @(negedge RX_REQ);
      @(posedge MBUS_CLKIN);
      RX_ACK = 1'b0;
      //Check Register 2 again
      READ_REG( 8'h02, 6'd19, {10'h0, 1'h0, 8'h1F});
      //Disable completely
      //Go
      WRITE_REG(8'h01,        {8'h14, 8'h1F, 1'h0, 1'h0, 1'h1});
      //Check Register 2 again. Should be reset to 0
      READ_REG( 8'h02, 6'd19, {10'h0, 1'h0, 8'h0});
   end
endtask // start_timer

task target_sleep_long;
   begin
      $display("***********************************************");
      $display("*************Targeted Sleep (Long)*************");
      $display("***********************************************");
      
      $display("* Set every layer to sleep mode");
      Send_MBus( 32'h01, 32'h40000EAD );
   end
endtask // target_sleep_long


task READ_REG;
   input [7:0]	  REG_ID;
   input [5:0] 	  REG_WIDTH;
   input [31:0]   RESET_VALUE;
   reg [31:0] 	  REG_MASK;
   begin
      REG_MASK	<= ~(32'hFFFFFFFF << REG_WIDTH);
      @(posedge MBUS_CLKIN);
      $display( "* Checking Register Value :");
      Send_MBus( 32'h41, { REG_ID, 8'h0, 8'h13, 8'h00 } );
      @(posedge RX_REQ);	// Wait for RX_REQ
      CheckValue( RX_DATA[31:0], RESET_VALUE[31:0], REG_MASK );
      RX_ACK = 1'b1;
      @(negedge RX_REQ);
      @(posedge MBUS_CLKIN);
      RX_ACK = 1'b0;
      @(posedge MBUS_CLKIN);
   end
endtask // READ_REG

task WRITE_REG;
   input [31:0] REG_ID;
   input [23:0] REG_VALUE;
   begin
      $display( "* Writing Register: %x \t with: %x", REG_ID, REG_VALUE);
      Send_MBus( 32'h40, { (REG_ID << 24 ) | REG_VALUE } );
   end
endtask // WRITE_REG


task Send_MBus;
   input [31:0] target_addr;
   input [31:0] target_data;
   begin
      @(posedge MBUS_CLKIN);
      TX_ADDR = target_addr;
      TX_DATA = target_data;
      @(posedge MBUS_CLKIN);
      TX_REQ = 1'b1;
      @(posedge TX_ACK);	// Wait for TX_ACK
      $display("* CTR: MBus Msg sent");
      $display("    ADDR = 0x%8h  DATA = 0x%8h",target_addr, target_data);
      @(posedge MBUS_CLKIN);
      TX_REQ = 1'b0;
      TX_DATA = 32'h00000000;
   end
endtask // Send_MBus

task CheckValue;
   input [31:0] A;	// Actual
   input [31:0] B;	// Expected
   input [31:0] Mask;
   
   begin
      if( (A&Mask) == (B&Mask) ) 
	$display( "    PASS  (Value : 0x%h)", A );
      else begin
	 $display( "    FAIL  (Expected : 0x%h, Actual : 0x%h ) <==============", B, A );
	 failure;
      end
   end
endtask // CheckValue

task success;
   begin
      $write("%c[1;34m",27);
      $display("***********************************************");
      $display("*******************!SUCCESS!*******************");
      $display("***************SIMULATION PASSED***************");
      $display("***********************************************");
      $display("%c[0m",27);
      $finish;
   end
endtask // success

task failure;
   begin
      $display("%c[1;31m",27);
      $display("***********************************************");
      $display("*******************!FAILURE!*******************");
      $display("***************SIMULATION FALED****************");
      $display("***********************************************");
      $display("Failure @ Time:", $time);
      $display("%c[0m",27);
      #1000;
      $finish;
   end
endtask // success
