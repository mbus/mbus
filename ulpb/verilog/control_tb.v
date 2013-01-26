
`timescale 1ns/1ps

`define SYNTH

`ifdef SYNTH
	`include "/afs/eecs.umich.edu/kits/ARM/TSMC_cl018g/mosis_2009q1/sc-x_2004q3v1/aci/sc/verilog/tsmc18_neg.v"
`endif

module testbench();

reg 	RESET, CLK_IN;

wire	OUT, CLK_OUT;
wire	[3:0]	state_out;
reg		IN;

parameter MODE_IDLE = 0;
parameter MODE_ARBI = 1;
parameter MODE_DRIVE1 = 2;
parameter MODE_LATCH1 = 3;
parameter MODE_DRIVE2 = 4;
parameter MODE_LATCH2 = 5;
parameter MODE_RESET = 6;

reg wait_reset;
reg	[4:0] data_counter;
reg [2:0] state;
reg	IN_REG;
reg	[3:0] tx_state;
reg [2:0] input_buffer;

reg tx_start;	// tb control

wire done = (state==MODE_RESET)? 1: 0;

control c0(.DIN(IN), .DOUT(OUT), .RESET(RESET), .CLK_OUT(CLK_OUT), .CLK(CLK_IN), .test_pt(state_out));

`define SD #1

initial
begin
	`ifdef SYNTH
		$sdf_annotate("control.dc.sdf", c0);
	`endif

	CLK_IN = 0;
	RESET = 0;
	tx_start = 0;
	
	@ (negedge CLK_IN)
	@ (posedge CLK_IN)
	@ (posedge CLK_IN)
	@ (posedge CLK_IN)
	@ (posedge CLK_IN)
		`SD RESET = 1;

	// TASK0, normal transaction
	@ (posedge CLK_IN)
	@ (posedge CLK_IN)
		`SD
		tx_start = 1;
	@ (posedge done)
		tx_start = 0;


	#3000
		$stop;
end

always @ (posedge CLK_OUT or negedge RESET)
begin
	if (~RESET)
	begin
		state <= MODE_IDLE;
		IN_REG <= 0;
		tx_state <= 0;
		data_counter <= 0;
		wait_reset <= 0;
	end
	else
	begin
		case (state)
			MODE_IDLE:
			begin
				state <= MODE_ARBI;
			end

			MODE_ARBI:
			begin
				state <= MODE_DRIVE1;
				IN_REG <= $random;
			end

			MODE_DRIVE1:
			begin
				if (input_buffer==3'b010)
					state <= MODE_RESET;
				else
					state <= MODE_LATCH1;
			end

			MODE_LATCH1:
			begin
				state <= MODE_DRIVE2;
				case (tx_state)
					1: begin IN_REG <= 1; tx_state <= 2; end
					3: begin IN_REG <= 0; tx_state <= 4; end
					5: begin IN_REG <= 1; tx_state <= 6; end
					7: begin IN_REG <= 0; tx_state <= 8; end
				endcase
			end

			MODE_DRIVE2:
			begin
				if (input_buffer==3'b010)
					state <= MODE_RESET;
				else
					state <= MODE_LATCH2;
			end

			MODE_LATCH2:
			begin
				state <= MODE_DRIVE1;
				case (tx_state)
					0:
					begin
						if (data_counter < 31)
						begin
							IN_REG <= $random;
							data_counter <= data_counter + 1;
						end
						else
						begin
							IN_REG <= 0;
							tx_state <= 1;
						end
					end
					2: begin IN_REG <= 1; tx_state <= 3; end
					4: begin IN_REG <= 0; tx_state <= 5; end
					6: begin IN_REG <= 1; tx_state <= 7; end
					8: begin IN_REG <= 0; tx_state <= 9; wait_reset = 1; end
				endcase
			end

			MODE_RESET:
			begin
				tx_state <= 0;
				data_counter <= 0;
				wait_reset <= 0;
				IN_REG <= 1;
				if (input_buffer[1:0]==2'b11)
					state = MODE_IDLE;
			end
		endcase
	end
end

always @ (posedge CLK_OUT or negedge RESET)
begin
	if (~RESET)
	begin
		input_buffer <= 0;
	end
	else
	begin
		if ((state==MODE_DRIVE1)||(state==MODE_DRIVE2)||(state==MODE_RESET))
			input_buffer <= {input_buffer[1:0], OUT};
	end
end

always @ *
begin
	IN = OUT;
	case (state)
		MODE_IDLE:
		begin
			if (tx_start)
				IN = 0;
			else
				IN = 1;
		end

		MODE_ARBI:
		begin
			if (tx_start)
				IN = 0;
			else
				IN = 1;
		end

		MODE_DRIVE1:
		begin
			if (~wait_reset)
				IN = IN_REG;
			else
				IN = OUT;
		end
		MODE_DRIVE2:
		begin
			if (~wait_reset)
			begin
				if (tx_state)
					IN = IN_REG;
				else
					IN = OUT;
			end
			else
				IN = OUT;
		end
	endcase
end

always #50 CLK_IN = ~CLK_IN;


endmodule
