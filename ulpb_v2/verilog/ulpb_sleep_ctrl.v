
module ulpb_sleep_ctrl(
	input	CLKIN,
	input	RESETn,
	input	SLEEP_REQ,
	output	reg POWER_ON,
	output	reg RELEASE_CLK,
	output	reg RELEASE_RST,
	output	reg RELEASE_ISO
);

`include "include/ulpb_def.v"

reg	[1:0] fsm_pos, fsm_neg;

parameter HOLD = `IO_HOLD;			// During sleep
parameter RELEASE = `IO_RELEASE;	// During wake-up

reg	POWER_ON_POS, POWER_ON_NEG;
reg	RELEASE_CLK_POS, RELEASE_CLK_NEG;
reg RELEASE_RST_POS, RELEASE_RST_NEG;
reg	RELEASE_ISO_POS, RELEASE_ISO_NEG;

always @ *
begin
	if ((POWER_ON_POS==HOLD)||(POWER_ON_NEG==HOLD))
		POWER_ON = HOLD;
	else
		POWER_ON = RELEASE;

	if ((RELEASE_CLK_POS==HOLD)||(RELEASE_CLK_NEG==HOLD))
		RELEASE_CLK = HOLD;
	else
		RELEASE_CLK = RELEASE;

	if ((RELEASE_RST_POS==HOLD)||(RELEASE_RST_NEG==HOLD))
		RELEASE_RST = HOLD;
	else
		RELEASE_RST = RELEASE;
	
	if ((RELEASE_ISO_POS==HOLD)||(RELEASE_ISO_NEG==HOLD))
		RELEASE_ISO = HOLD;
	else
		RELEASE_ISO = RELEASE;
end

always @ (posedge CLKIN or negedge RESETn)
begin
	if (~RESETn)
	begin
		fsm_pos <= 0;
		POWER_ON_POS <= HOLD;
		RELEASE_CLK_POS <= RELEASE;
		RELEASE_ISO_POS <= HOLD;
		RELEASE_RST_POS <= RELEASE;
	end
	else
	begin
		case (fsm_pos)
			0:
			begin
				POWER_ON_POS <= RELEASE;
				RELEASE_CLK_POS <= RELEASE;
				fsm_pos <= 1;
			end

			1:
			begin
				RELEASE_ISO_POS <= RELEASE;
				RELEASE_RST_POS <= RELEASE;
				fsm_pos <= 2;
			end

			2:
			begin
				if (SLEEP_REQ)
				begin
					RELEASE_ISO_POS <= HOLD;
					fsm_pos <= 3;
				end
			end

			3:
			begin
				fsm_pos <= 0;
				RELEASE_RST_POS <= HOLD;
				POWER_ON_POS <= HOLD;
				RELEASE_CLK_POS <= HOLD;
			end

		endcase
	end
end

always @ (negedge CLKIN or negedge RESETn)
begin
	if (~RESETn)
	begin
		fsm_neg <= 0;
		POWER_ON_NEG <= RELEASE;
		RELEASE_CLK_NEG <= HOLD;
		RELEASE_ISO_NEG <= RELEASE;
		RELEASE_RST_NEG <= HOLD;
	end
	else
	begin
		case (fsm_neg)
			0:
			begin
				if (fsm_pos==2'b1)
				begin
					RELEASE_CLK_NEG <= RELEASE;
					fsm_neg <= 1;
				end
				else
				begin
					POWER_ON_NEG <= RELEASE;
					RELEASE_CLK_NEG <= HOLD;
					RELEASE_ISO_NEG <= RELEASE;
					RELEASE_RST_NEG <= HOLD;
				end
			end

			1:
			begin
				RELEASE_RST_NEG <= RELEASE;
				fsm_neg <= 2;
			end

			2:
			begin
				if (fsm_pos==2'b11)
				begin
					POWER_ON_NEG <= HOLD;
					RELEASE_CLK_NEG <= HOLD;
					RELEASE_RST_NEG <= HOLD;
					fsm_neg <= 0;
				end
			end
		endcase
	end
end


endmodule
