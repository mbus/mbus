
// this block is for simulation only, NOT synthesisable

`include "include/mbus_def.v"

module rf_ctrl( RESETn, DIN, LOAD, DOUT);

parameter RF_DEPTH = 128; // this depth SHOULD less or equal than `LC_RF_DEPTH

input	RESETn;
input	[`LC_RF_DATA_WIDTH-1:0] DIN;
input	[RF_DEPTH-1:0] LOAD;
output 	[`LC_RF_DATA_WIDTH*RF_DEPTH-1:0] DOUT;

reg	[`LC_RF_DATA_WIDTH-1:0] rf_array [0:RF_DEPTH-1];

genvar idx;
generate 

	for (idx=0; idx<(RF_DEPTH); idx=idx+1)
	begin: PACK
		assign DOUT[`LC_RF_DATA_WIDTH*(idx+1)-1:`LC_RF_DATA_WIDTH*idx] = rf_array[idx];
	end

	for (idx=0; idx<RF_DEPTH; idx = idx+1)
	begin: RF_WRITE
		always @ (posedge LOAD[idx] or negedge RESETn)
		begin
			if (~RESETn)
				rf_array[idx] <= 0;
			else
				rf_array[idx] <= DIN;
		end
	end
endgenerate

endmodule


module sensor_rom(DOUT);

parameter ROM_DEPTH = 128;

output [(ROM_DEPTH*`LC_RF_DATA_WIDTH)-1:0] DOUT;

reg [`LC_RF_DATA_WIDTH-1:0] rom_array [0:ROM_DEPTH-1];

genvar idx;
generate
	for (idx=0; idx<(ROM_DEPTH); idx=idx+1)
	begin: PACK
		assign DOUT[`LC_RF_DATA_WIDTH*(idx+1)-1:`LC_RF_DATA_WIDTH*idx] = rom_array[idx];
	end
endgenerate

integer i;
initial
begin
	for (i=0; i<(ROM_DEPTH); i=i+1)
		rom_array[i] <= i;
end

endmodule
