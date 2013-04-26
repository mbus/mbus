
// simulation only..

`include "include/mbus_def.v"

`define ROM_DEPTH (`LC_RF_DEPTH - `RF_DEPTH)

module sensor_rom(
	output [(`ROM_DEPTH*`LC_RF_DATA_WIDTH)-1:0] DOUT
);

wire [`LC_RF_DATA_WIDTH-1:0] rom_array [0:`ROM_DEPTH-1]

genvar idx;
generate
	for (idx=0; idx<(`ROM_DEPTH); idx=idx+1)
	begin: PACK
		assign DOUT[`LC_RF_DATA_WIDTH*(idx+1)-1:`LC_RF_DATA_WIDTH*idx] = rom_array[idx];
	end
end

integer i;
initial
begin
	for (i=0; i<(`ROM_DEPTH); i=i+1)
		assign rom_array[i] = $random;
end

endmodule
