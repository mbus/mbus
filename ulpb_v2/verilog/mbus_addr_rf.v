
`include "include/mbus_func.v"
// simulate the always on register file which holds the assigned address

module mbus_addr_rf(
	input		RESETn,
	input		RELEASE_ISO_FROM_SLEEP_CTRL,
	output	reg	[`DYNA-1:0] ADDR_OUT,
	input		[`DYNA-1:0] ADDR_IN,
	output	reg	ADDR_VALID,
	input		ADDR_WR_EN,
	input		ADDR_CLRn
);

wire	RESETn_local = ((RESETn & ADDR_CLRn) | RELEASE_ISO_FROM_SLEEP_CTRL);
wire	ADDR_UPDATE = (ADDR_WR_EN & (~RELEASE_ISO_FROM_SLEEP_CTRL));

always @ (posedge ADDR_UPDATE or negedge RESETn_local)
begin
	if (~RESETn_local)
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
