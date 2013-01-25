
`timescale 1ns/1ps

`ifdef SYNTH
	`include "/afs/eecs.umich.edu/kits/ARM/TSMC_cl018g/mosis_2009q1/sc-x_2004q3v1/aci/sc/verilog/tsmc18_neg.v"
`endif

module testbench();

reg 	RESET, CLK_IN;

wire	OUT, CLK_OUT;
wire	[3:0]	state_out;

reg		out_release;
reg		IN_REG;
reg		[4:0] data_counter;
reg		[1:0] state;
reg		[1:0] node_state;
reg		[1:0] mes_state;
reg		[1:0] clk_counter;

parameter WAIT = 0;
parameter TASK0 = 1;
parameter TASK1 = 2;

parameter INIT = 0;
parameter DRIVE = 1;
parameter MES = 2;
parameter ACK = 3;

wire	done = (state==WAIT)? 1 : 0;
wire	IN = (out_release)? OUT : IN_REG;

control c0(IN, OUT, RESET, CLK_OUT, CLK_IN, state_out);

`define SD #1

initial
begin
	`ifdef SYNTH
		$sdf_annotate("control.dc.sdf", c0);
	`endif

	CLK_IN = 0;
	RESET = 0;
	
	@ (negedge CLK_IN)
	@ (posedge CLK_IN)
	@ (posedge CLK_IN)
	@ (posedge CLK_IN)
	@ (posedge CLK_IN)
		`SD RESET = 1;

	@ (posedge CLK_IN)
	@ (posedge CLK_IN)
		`SD
		out_release = 0;
		state = TASK0;
	@ (posedge done)
	#3000
	
	@ (posedge CLK_IN)
		`SD
		out_release = 0;
		state = TASK1;
	@ (posedge done)
	#3000
		$stop;
end

always @ (posedge CLK_OUT or negedge RESET)
begin
	if (~RESET)
	begin
		clk_counter <= 0;
		data_counter <= 0;
		state <= WAIT;
		node_state <= INIT;
		mes_state <= 0;
		out_release <= 1;
		IN_REG <= 0;
	end
	else
	begin
		case (state)
			// normal bus transaction
			TASK0:
			begin
				clk_counter <= clk_counter + 1;
				case (node_state)
					INIT:
					begin
						if (clk_counter==1)
						begin
							node_state <= DRIVE;
							IN_REG <= `SD $random;
						end
					end

					DRIVE:
					begin
						if (clk_counter==1)
						begin
							data_counter <= data_counter + 1;
							IN_REG <= `SD $random;
						end
						else if (clk_counter==3)
						begin
							if (data_counter==31)
								node_state <= MES;
						end
					end

					MES:
					begin
						if ((clk_counter==1)||(clk_counter==3))
						begin
							case (mes_state)
								0: begin IN_REG <= `SD 0; mes_state <= mes_state + 1; end
								1: begin IN_REG <= `SD 1; mes_state <= mes_state + 1; end
								2: begin IN_REG <= `SD 1; mes_state <= mes_state + 1; end
								3: begin IN_REG <= `SD 0; mes_state <= mes_state + 1; node_state <= ACK; end
							endcase
						end
					end

					ACK:
					begin
						if ((clk_counter==1)||(clk_counter==3))
						begin
							case (mes_state)
								0: begin IN_REG <= `SD 0; mes_state <= mes_state + 1; end
								1: begin IN_REG <= `SD 1; mes_state <= mes_state + 1; end
								2: begin IN_REG <= `SD 1; mes_state <= mes_state + 1; end
								3: begin IN_REG <= `SD 0; mes_state <= mes_state + 1; state <= WAIT; end
							endcase
						end
					end
				endcase
			end

			// out of phase transaction
			TASK1:
			begin
				clk_counter <= clk_counter + 1;
				case (node_state)
					INIT:
					begin
						if (clk_counter==1)
						begin
							node_state <= DRIVE;
							IN_REG <= `SD $random;
						end
					end

					DRIVE:
					begin
						if (clk_counter==1)
						begin
							data_counter <= data_counter + 1;
							IN_REG <= `SD $random;
						end
						else if (clk_counter==3)
						begin
							if (data_counter==31)
								node_state <= MES;
						end
					end

					MES:
					begin
						if ((clk_counter==1)||(clk_counter==3))
						begin
							case (mes_state)
								0: begin IN_REG <= `SD 0; mes_state <= mes_state + 1; end
								1: begin IN_REG <= `SD 1; mes_state <= mes_state + 1; end
								2: begin IN_REG <= `SD 1; mes_state <= mes_state + 1; end
								3: begin IN_REG <= `SD 0; mes_state <= mes_state + 1; node_state <= ACK; end
							endcase
						end
					end

					ACK:
					begin
						if ((clk_counter==1)||(clk_counter==3))
						begin
							case (mes_state)
								0: begin IN_REG <= `SD 0; mes_state <= mes_state + 1; end
								1: begin IN_REG <= `SD 1; mes_state <= mes_state + 1; end
								2: begin IN_REG <= `SD 1; mes_state <= mes_state + 1; end
								3: begin IN_REG <= `SD 0; mes_state <= mes_state + 1; state <= WAIT; end
							endcase
						end
					end
				endcase
			end

			WAIT:
			begin
				out_release <= 1;
				clk_counter <= 0;
				data_counter <= 0;
				node_state <= INIT;
				mes_state <= 0;
			end
		endcase
	end
end

always #50 CLK_IN = ~CLK_IN;


endmodule
