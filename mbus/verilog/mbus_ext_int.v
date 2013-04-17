module mbus_ext_int(
	input	CLKIN, 
	input	RESETn,
	input	REQ_INT, 
	output 	reg EXTERNAL_INT_TO_WIRE, 
	output	reg EXTERNAL_INT_TO_BUS, 
	input	CLR_EXT_INT
);

wire RESETn_local = (RESETn & CLKIN);
wire RESETn_local2 = (RESETn & (~CLR_EXT_INT));

always @ (posedge REQ_INT or negedge RESETn_local)
begin
	if (~RESETn_local)
		EXTERNAL_INT_TO_WIRE <= 0;
	else
		EXTERNAL_INT_TO_WIRE <= 1;
end

always @ (posedge REQ_INT or negedge RESETn_local2)
begin
	if (~RESETn_local2)
		EXTERNAL_INT_TO_BUS <= 0;
	else
		EXTERNAL_INT_TO_BUS <= 1;
end

endmodule
