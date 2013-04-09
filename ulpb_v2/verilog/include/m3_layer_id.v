
// layer ID definition, cannot go above 23
`ifdef M3
	`ifdef CPU
		`define M3_LAYER_ID 24'd0
	`elsif IMAGER
		`define M3_LAYER_ID 24'd1
	`elsif UWB 
		`define M3_LAYER_ID 24'd11
	`else
		`define M3_LAYER_ID 24'd23
	`endif
`endif
