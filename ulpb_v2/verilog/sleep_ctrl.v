module sleep_controller (
	input CLKIN,
	input RESETn,
	input SHTDOWN,
	output reg RELEASE_ISO,
	output reg RELEASE_RST,
	output reg POWER_ON,
	output CLKOUT
);

reg [2:0] fsm;
reg	CLK_EN;

parameter HOLD = 1'b1;
parameter RELEASE = ~HOLD;

parameter ON = 1'b1;
parameter OFF = ~ON;

parameter RST_EN = 1'b0;
parameter RST_DIS = ~RST_EN;

assign CLKOUT = (CLKIN & CLK_EN);

always @ (posedge CLKIN or negedge RESETn)
begin
	if (~RESETn)
	begin
		fsm <= 0;
		RELEASE_ISO <= HOLD;
		RELEASE_RST <= RST_EN;
		POWER_ON <= OFF;
		CLK_EN <= 0;
	end
	else
	begin
		case (fsm)
			0:
			begin
				POWER_ON <= ON;
				fsm <= 1;
			end

			1:
			begin
				CLK_EN <= 1;
				fsm <= 2;
			end

			2:
			begin
				RELEASE_RST <= RST_DIS;
				fsm <= 3;
			end

			3:
			begin
				RELEASE_ISO <= RELEASE;
				fsm <= 4;
			end

			4:
			begin
				if (SHTDOWN)
				begin
					fsm <= 5;
					RELEASE_ISO <= HOLD;
				end
			end

			5:
			begin
				RELEASE_RST <= RST_EN;
				CLK_EN <= 0;
				POWER_ON <= OFF;
				fsm <= 0;
			end
		endcase
	end
end


endmodule
