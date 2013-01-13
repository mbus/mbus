
module ahb_int(	HSEL, HADDR, HWRITE, HSIZE, HBURST, HPROT, HTRANS, 
				HMASTLOCK, HREADY, HWDATA, HRESETn, HCLK,
				HREADYOUT, HRESP, HRDATA,
				DIN, DOUT, SCLK,
				TX_FAIL, TX_SUCCESS, 
				fifo_empty, req_out_to_lc);

// IOs for AHB bus
input 			HSEL, HWRITE, HMASTLOCK, HREADY, HRESETn, HCLK;
input 	[31:0] 	HADDR, HWDATA;
input 	[2:0] 	HSIZE, HBURST;
input 	[3:0] 	HPROT;
input 	[1:0] 	HTRANS;

output 			HREADYOUT;
output 	[1:0] 	HRESP;
output 	[31:0] 	HRDATA;

// IOS for M3 interface
input			DIN, SCLK;
output			DOUT;

// Interrups
output			TX_FAIL, TX_SUCCESS, req_out_to_lc;
output			fifo_empty;

reg				hwrite_reg;
reg		[7:0]	haddr_reg;
reg		[2:0]	fsm;
reg		[31:0]	HRDATA;
reg				HREADYOUT;
reg		[31:0]	HWDATA_REG;

assign HRESP		= 2'b00;
parameter ADDRESS = 8'hab;

reg				req_in_from_lc;
wire			ack_out_to_lc;
wire	[31:0]	DATA_OUT;
wire			req_out_to_lc;
reg				ack_in_from_lc;
reg				TX_ACK;

wire	[31:0]	fifo_dout;
reg				fifo_re, fifo_we;
wire			fifo_full, fifo_empty;

always @ (posedge HCLK)
begin
	if (~HRESETn)
	begin
		fsm	    <= 0;
		HRDATA <= 0;
		HREADYOUT <= 1;
		hwrite_reg <= 0;
		haddr_reg <= 0;
		HWDATA_REG <= 0;
		TX_ACK <= 0;
		fifo_re <= 0;
	end
	else
	begin
		if ((TX_SUCCESS | TX_FAIL) & (~TX_ACK))
			TX_ACK <= 1;

		if  ((~(TX_SUCCESS | TX_FAIL)) & TX_ACK)
			TX_ACK <= 0;

		case (fsm)
			0:
			begin
				if (HSEL && HREADY && HTRANS[1] && HSIZE==3'b010 )
				begin
					hwrite_reg	<= HWRITE;
					fsm			<= 1;
					HREADYOUT <= 0;
					haddr_reg <= HADDR[11:4];
				end
			end

			1:
			begin
				if (hwrite_reg)
				begin
					HWDATA_REG <= HWDATA;
				end
				else
				begin
					fifo_re <= 1;
				end
				fsm <= 2;
			end

			2:
			begin
				fifo_re <= 0;
				if (hwrite_reg)
					req_in_from_lc <= 1;
			   	fsm <= 3;
			end

			3:
			begin
				if (req_in_from_lc)
				begin
					if (~ack_out_to_lc)
					begin
						req_in_from_lc <= 0;
						fsm <= 0;
						HREADYOUT <= 1;
					end
				end
				else
				begin
					fsm <= 4;
				end
			end

			4:
			begin
				HRDATA <= fifo_dout;
				fsm <= 0;
				HREADYOUT <= 1;
			end


		endcase
	end
end

always @ (posedge HCLK)
begin
	if (~HRESETn)
	begin
		fifo_we <= 0;
		ack_in_from_lc <= 0;
	end
	else
	begin
		if (fifo_we)
		begin
			fifo_we <= 0;
			ack_in_from_lc <= 1;
		end

		if (ack_in_from_lc&(~req_out_to_lc))
			ack_in_from_lc <= 0;

		if (req_out_to_lc & (~fifo_full))
			fifo_we <= 1;

	end
end

ulpb_node_top #(.ADDRESS(ADDRESS)) n0 (.CLK(SCLK), .RESET(HRESETn), .DIN(DIN), .DOUT(DOUT), 
				.ADDR_IN(haddr_reg), .DATA_IN(HWDATA_REG), .REQ_IN_FROM_LC(req_in_from_lc), .ACK_OUT_TO_LC(ack_out_to_lc), 
				.ADDR_OUT(), .DATA_OUT(DATA_OUT), .REQ_OUT_TO_LC(req_out_to_lc), .ACK_IN_FROM_LC(ack_in_from_lc), 
				.TX_FAIL(TX_FAIL), .TX_SUCCESS(TX_SUCCESS), .TX_ACK(TX_ACK));

fifo8x32 rxfifo(
	.DATA(DATA_OUT),
	.Q(fifo_dout),
	.CLK(HCLK),
	.WE(fifo_we),
	.RE(fifo_re),
	.FULL(fifo_full),
	.EMPTY(fifo_empty));
endmodule
