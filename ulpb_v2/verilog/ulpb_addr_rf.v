module ulpb_addr_rf(
	input		RESETn,
	output	reg	[`ADDR_WIDTH_SHORT-1:0] ADDR_OUT,
	input		[`ADDR_WIDTH_SHORT-1:0] ADDR_IN,
	output	reg	ADDR_VALID,
	input		ADDR_WR_EN	
);

always @ (posedge ADDR_WR_EN or negedge RESETn)
begin
	if (~RESETn)
	begin
		ADDR_OUT <= 4'hf;
		ADDR_VALID <= 0;
	end
	else
	begin
		ADDR_OUT <= ADDR_IN;
		ADDR_VALID <= 1;
	end
end

endmodule
