/*
 * MBus Copyright 2015 Regents of the University of Michigan
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// This module only used for simulation, break the loop and injecting the
// glitch

module mbus_err_inject(
	input	CLK_FAST,
	input	RESETn,
	input	CLK_IN,
	output	reg CLK_OUT,
	input	DIN,
	output	reg DOUT,
	input	[2:0] ERR_TYPE,
	input	inject_start);

reg	[2:0] err_state;
reg	[2:0] error_type;

wire	int_flag;
reg		swap0_rstn;
reg	clk_ctrl;
`define ERR_DELAY #500

always @ (posedge CLK_FAST or negedge RESETn)
begin
	if (~RESETn)
	begin
		err_state <= 0;
		clk_ctrl <= 0;
		error_type <= 0;
	end
	else
	begin
		case (err_state)
			0:
			begin
				if (inject_start)
					err_state <= 1;
			end

			1:
			begin
				case (ERR_TYPE)
					// clk glitch
					0:
					begin
						error_type <= 0;
						if (~CLK_IN)
							err_state <= 2;
					end

					// missing clk edge
					1:
					begin
						error_type <= 1;
						if (~CLK_IN)
							err_state <= 2;
					end

					// clk glitch after interrupt
					2:
					begin
						error_type <= 0;
						if (int_flag & (~CLK_IN))
							err_state <= 2;
					end

					// missing clk edge after interrupt
					3:
					begin
						error_type <= 1;
						if (int_flag & (~CLK_IN))
							err_state <= 2;
					end

					// clock stuck at 0
					4:
					begin
						error_type <= 2;
						if (~CLK_IN)
							err_state <= 2;
					end

					// clock stuck at 1
					5:
					begin
						error_type <= 3;
						if (~CLK_IN)
							err_state <= 2;
					end
				endcase
			end

			2:
			begin
				err_state <= 3;
				case (error_type)
					0:
					begin
						clk_ctrl <= `ERR_DELAY 1;
					end

					1:
					begin
						clk_ctrl <= `ERR_DELAY 0;
					end

					2:
					begin
						clk_ctrl <= `ERR_DELAY 0;
					end

					3:
					begin
						clk_ctrl <= `ERR_DELAY 1;
					end

				endcase
			end

			3:
			begin
				case (error_type)
					0:
					begin
						if (CLK_OUT)
						begin
							clk_ctrl <= #100 0;
							err_state <= 4;
						end
					end

					1:
					begin
						if (CLK_IN)
						begin
							err_state <= 4;
						end
					end

					2:
					begin
						if (~inject_start)
							err_state <= 0;
					end

					3:
					begin
						if (~inject_start)
							err_state <= 0;
					end

				endcase
			end

			4:
			begin
				case (error_type)
					0:
					begin
						if (~CLK_OUT)
							err_state <= 5;
					end

					1:
					begin
						if (~CLK_IN)
							err_state <= 5;
					end
				endcase
			end

			5:
			begin
				if (~inject_start)
					err_state <= 0;
			end

		endcase
	end
end

always @ *
begin
	CLK_OUT = CLK_IN;
	DOUT = DIN;
	if ((err_state>1)&&(err_state<5))
	begin
		case(error_type)
			0:
			begin
				CLK_OUT = (CLK_IN | clk_ctrl);
			end

			1:
			begin
				CLK_OUT = (CLK_IN & clk_ctrl);
			end

			2:
			begin
				CLK_OUT = (CLK_IN & clk_ctrl);
			end

			3:
			begin
				CLK_OUT = (CLK_IN | clk_ctrl);
			end
		endcase
	end
end

mbus_swapper swap0(
	.CLK(CLK_IN),
    .RESETn(RESETn),
    .DATA(DIN),
    .INT_FLAG_RESETn(swap0_rstn),
   //Outputs
    .LAST_CLK(),
    .INT_FLAG(int_flag));

always @ (posedge CLK_IN or negedge RESETn)
begin
	if (~RESETn)
		swap0_rstn <= 1;
	else
	begin
		if (int_flag)
			swap0_rstn <= #500 0;
		else if (~swap0_rstn)
			swap0_rstn <= #500 1;
	end
end

endmodule
