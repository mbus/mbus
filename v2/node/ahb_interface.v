
module ahb_int(	HSEL, HADDR, HWRITE, HSIZE, HBURST, HPROT, HTRANS, 
				HMASTLOCK, HREADY, HWDATA, HRESETn, HCLK,
				HREADYOUT, HRESP, HRDATA,
				DIN, DOUT, SCLK,
				rx_int, ack_rx_int, req_tx);

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
output			rx_int, ack_rx_int;

output			req_tx;

reg				hwrite_reg;
reg		[7:0]	haddr_reg;
reg		[2:0]	fsm;
reg		[31:0]	HRDATA;
reg				HREADYOUT;
reg		[31:0]	HWDATA_REG;

assign HRESP		= 2'b00;

wire	[31:0]	data_out;
wire			ack_tx;
reg				ack_rx, req_tx;

parameter ADDRESS = 8'hab;

always @ (posedge HCLK)
begin
	if (~HRESETn)
	begin
		fsm	    <= 0;
		HRDATA <= 0;
		HREADYOUT <= 1;
		hwrite_reg <= 0;
		haddr_reg <= 0;
		ack_rx <= 0;
		req_tx <= 0;
		HWDATA_REG <= 0;
	end
	else
	begin
		if (ack_rx)
		begin
			if (~rx_int)
				ack_rx <= 0;
		end

		if (ack_tx)
		begin
			req_tx <= 0;
		end

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
					req_tx <= 1;
					HWDATA_REG <= HWDATA;
				end
				else
				begin
					HRDATA <= data_out;
					ack_rx <= 1;
				end
				fsm <= 2;
			end

			2:
			begin
				/*
				if (req_tx)
				begin
					if (ack_tx)
					begin
						req_tx <= 0;
						fsm <= 3;
					end
				end
				else
					fsm <= 3;
				*/
			   fsm <= 3;
			end

			3:
			begin
				fsm <= 0;
				HREADYOUT <= 1;
			end


		endcase
	end
end


ulpb_node #(.ADDRESS(ADDRESS)) n0 (.CLK(SCLK), .RESET(HRESETn), .DIN(DIN), .DOUT(DOUT), 
			.ADDR_IN(haddr_reg), .DATA_IN(HWDATA_REG), .REQ_TX(req_tx), .ACK_TX(ack_tx), 
			.ADDR_OUT(), .DATA_OUT(data_out), .REQ_RX(rx_int), .ACK_RX(ack_rx), .ACK_RECEIVED(ack_rx_int));
endmodule
