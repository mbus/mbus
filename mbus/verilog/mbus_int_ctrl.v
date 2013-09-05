`include "include/mbus_def.v"

module mbus_int_ctrl
  (
    input	CLKIN,
    input	RESETn,
    input	MBC_ISOLATE,		// BC_RELEASE_ISO,
    input	SC_CLR_BUSY,
    input	MBUS_CLR_BUSY,
   
    input	REQ_INT, 
    input	MBC_SLEEP,		// BC_PWR_ON,
    input	LRC_SLEEP,		// LC_PWR_ON,
    output reg	EXTERNAL_INT_TO_WIRE, 
    output reg	EXTERNAL_INT_TO_BUS, 
    input	CLR_EXT_INT
   );

   //wire mbus_busyn;
   reg 		clr_busy_temp;
   reg 		BUS_BUSYn;

   always @ * begin
      if (MBC_ISOLATE /*BC_RELEASE_ISO*/ ==`IO_HOLD)
	clr_busy_temp = 0;
      else
	clr_busy_temp = MBUS_CLR_BUSY;
   end

   wire RESETn_BUSY = ((~clr_busy_temp) & (~SC_CLR_BUSY));

   // Use SRFF
   always @ (negedge CLKIN or negedge RESETn or negedge RESETn_BUSY) begin
      // set port
      if (~RESETn)
	BUS_BUSYn <= 1;
      // reset port
      else if (~CLKIN)
	BUS_BUSYn <= 0;
      // clk port
      else
	BUS_BUSYn <= 1;
   end


   wire RESETn_local = (RESETn & CLKIN);
   wire RESETn_local2 = (RESETn & (~CLR_EXT_INT));
   wire INT_BUSY = (REQ_INT & BUS_BUSYn);
   
   // EXTERNAL_INT_TO_WIRE
   always @ (posedge INT_BUSY or negedge RESETn_local) begin
      if (~RESETn_local)
	EXTERNAL_INT_TO_WIRE <= 0;
      else begin
	 case ({MBC_SLEEP, LRC_SLEEP})
	   // Both in sleep
	   {`IO_HOLD, `IO_HOLD}: begin EXTERNAL_INT_TO_WIRE <= 1; end
	   
	   // Both in sleep, BC is on, LC is off, 
	   // only interrupt when the bus is not busy
	   {`IO_RELEASE, `IO_HOLD}: begin if (BUS_BUSYn) EXTERNAL_INT_TO_WIRE <= 1; end
	   
	   // If both is on, doing nothing,
	   // BC is off, LC is on is a non-exist state
	   default: begin end
	 endcase
      end
   end

   // EXTERNAL_INT_TO_BUS
   always @ (posedge INT_BUSY or negedge RESETn_local2) begin
      if (~RESETn_local2)
	EXTERNAL_INT_TO_BUS <= 0;
      else begin
	 case ({MBC_SLEEP, LRC_SLEEP})
	   // Both in sleep
	   {`IO_HOLD, `IO_HOLD}: begin EXTERNAL_INT_TO_BUS <= 1; end
	   
	   // Both in sleep, BC is on, LC is off, 
	   // only interrupt when the bus is not busy
	   {`IO_RELEASE, `IO_HOLD}: begin if (BUS_BUSYn) EXTERNAL_INT_TO_BUS <= 1; end
	   
	   // If both is on, doing nothing,
	   // BC is off, LC is on is a non-exist state
	   default: begin end
	 endcase
      end
   end
   
endmodule // mbus_int_ctrl
