// Verilog HDL and netlist files of
// "SLEEP_CONTROL SLEEP_CONTROLv4 schematic"

// Library - SLEEP_CONTROL, Cell - SLEEP_CONTROLv4, View - schematic
// LAST TIME SAVED: Apr 10 15:16:23 2013
// NETLIST TIME: Apr 10 15:41:53 2013
`timescale 1ns / 1ns 
`include "/afs/eecs.umich.edu/kits/ARM/TSMC_cl018g/mosis_2009q1/sc-x_2004q3v1/aci/sc/verilog/tsmc18_neg.v"

module SLEEP_CONTROLv4 ( 
	output	MBC_ISOLATE, 
	output	MBC_ISOLATE_B,
	output	MBC_RESET,
	output	MBC_RESET_B,
	output	MBC_SLEEP,
	output	MBC_SLEEP_B,
	output	SYSTEM_ACTIVE,
	output	WAKEUP_REQ_ORED,

	input	CLK,
	input	MBUS_DIN,
	input	PMU_FORCE_WAKE,		// Added compared to SLEEP_CONTROLv4
	input	RESETn,
	input	SLEEP_REQ,
	input	WAKEUP_REQ0,
	input	WAKEUP_REQ1,
	input	WAKEUP_REQ2 
);

	reg	set_tran_to_wake;
	reg	rst_tran_to_wake;	// act as tran to "sleep"

	reg	MBC_ISOLATE;
	wire	MBC_ISOLATE_B;
	assign	MBC_ISOLATE_B = ~MBC_ISOLATE;
	reg	MBC_RESET;
	wire	MBC_RESET_B;
	assign	MBC_RESET_B = ~MBC_RESET;
	reg	MBC_SLEEP_int;
	wire	MBC_SLEEP;
	wire	MBC_SLEEP_B;
	assign	MBC_SLEEP_B = ~MBC_SLEEP;

	reg	tran_to_wake;

	wire	SYSTEM_ACTIVE;
	assign	SYSTEM_ACTIVE = PMU_FORCE_WAKE | MBC_SLEEP_B | MBC_ISOLATE_B;

	wire	WAKEUP_REQ_ORED;
	assign	WAKEUP_REQ_ORED	= WAKEUP_REQ0 | WAKEUP_REQ1 | WAKEUP_REQ2;


	// set_tran_to_wake
	always @ *
	begin
		if( ~RESETn )
		    set_tran_to_wake	<= 1'b0;
		else if( MBC_SLEEP ) begin	// While MBC is in sleep
			if( WAKEUP_REQ_ORED || ~MBUS_DIN )	// Wake up if there is internal req or DIN pulled down
			    set_tran_to_wake	<= 1'b1;
			else
			    set_tran_to_wake	<= 1'b0;
		end
		else
		    set_tran_to_wake	<= 1'b0;
	end

	// rst_tran_to_wake
	always @ *
	begin
		if( ~RESETn )
		    rst_tran_to_wake	<= 1'b0;
		else if( set_tran_to_wake | ~SLEEP_REQ )
		    rst_tran_to_wake	<= 1'b0;
		else
		    rst_tran_to_wake	<= 1'b1;
	end

	// tran_to_wake
	always @ ( posedge rst_tran_to_wake or posedge set_tran_to_wake )
	begin
		if( rst_tran_towake ) 
			tran_to_wake	<= 1'b0;
		else 
			tran_to_wake	<= 1'b1;
	end

	// MBC_ISOLATE
	always @ ( negedge RESETn or posedge CLK )
	begin
		if( ~RESETn )
			MBC_ISOLATE	<= 1'b1;
		else begin
			MBC_ISOLATE	<= MBC_SLEEP_int | ~tran_to_wake;
		end
	end

	// MBC_SLEEP
	always @ ( negedge RESETn or posedge CLK )
	begin
		if( ~RESETn )
			MBC_SLEEP_int	<= 1'b1;
		else begin
			MBC_SLEEP_int	<= MBC_ISOLATE & ~tran_to_wake;
		end
	end

	assign	MBC_SLEEP = MBC_SLEEP & ~SET_TRAN_TO_WAKE_ifnoporeset;

	// MBC_RESET
	always @ ( negedge RESETn or posedge CLK )
	begin
		if( ~RESETn )
			MBC_SLEEP_int	<= 1'b1;
		else begin
			MBC_SLEEP_int	<= MBC_ISOLATE;
		end
	end

/*
NOR3X1 I1 ( .C(WAKEUP_REQ2), .B(WAKEUP_REQ1), .A(WAKEUP_REQ0), .Y(WAKEUP_REQ_ORED_B_int) );
INVX2 I2 ( .Y(WAKEUP_REQ_ORED), .A(WAKEUP_REQ_ORED_B_int));
INVX1 I27 ( .Y(net071), .A(net02));
INVX1 I13 ( .Y(RESET), .A(RESETn));
INVX1 I10 ( .Y(MBUS_DIN_B), .A(MBUS_DIN));
INVX1 I3 ( .Y(SLEEP_REQ_B), .A(SLEEP_REQ));
DFFSRX1 I19 ( .SN(RESETn), .RN(1'b1), .CK(CLK), .Q(MBC_RESET_int), .QN(MBC_RESET_B_int), .D(MBC_ISOLATE_int));
DFFSRX1 I15 ( .SN(RESETn), .RN(1'b1), .CK(CLK), .Q(MBC_ISOLATE_int), .QN(MBC_ISOLATE_B_int), .D(net057));
DFFSRX1 I7 ( .SN(SETn_TRAN_TO_WAKE), .RN(RSTn_TRAN_TO_WAKE), .CK(1'b0),   .Q(TRAN_TO_WAKE), .QN(net035), .D(1'b0));
DFFSRX1 I4 ( .SN(RESETn), .RN(1'b1), .CK(CLK), .Q(MBC_SLEEP_int), .QN(MBC_SLEEP_B_int), .D(net014));
NAND2X1 I29 ( .Y(SYSTEM_ACTIVE), .A(MBC_SLEEP), .B(MBC_ISOLATE_int));
NAND2X1 I22 ( .Y(net057), .A(TRAN_TO_WAKE), .B(MBC_SLEEP_B_int));
NAND2X1 I11 ( .Y(net034), .A(MBC_SLEEP_int), .B(MBUS_DIN_B));
NAND2X1 I9 ( .Y(SET_TRAN_TO_WAKE_ifnoporeset), .A(WAKEUP_REQ_ORED_B_int), .B(net034));
NAND2X1 I8 ( .B(RESETn), .A(SET_TRAN_TO_WAKE_ifnoporeset), .Y(SETn_TRAN_TO_WAKE));
NOR2X1 I26 ( .B(MBC_SLEEP_B_int), .A(SET_TRAN_TO_WAKE_ifnoporeset), .Y(net02));
NOR2X1 I21 ( .B(MBC_ISOLATE_B_int), .A(TRAN_TO_WAKE), .Y(net014));
NOR2X1 I14 ( .B(SLEEP_REQ_B), .A(SET_TRAN_TO_WAKE_ifnoporeset), .Y(net033));
NOR2X1 I12 ( .Y(RSTn_TRAN_TO_WAKE), .A(net033), .B(RESET));
INVX12 I28 ( .Y(MBC_SLEEP_B), .A(net02));
INVX12 I25 ( .Y(MBC_ISOLATE_B), .A(MBC_ISOLATE_int));
INVX12 I24 ( .Y(MBC_RESET_B), .A(MBC_RESET_int));
INVX12 I23 ( .Y(MBC_SLEEP), .A(net071));
INVX12 I20 ( .Y(MBC_RESET), .A(MBC_RESET_B_int));
INVX12 I18 ( .Y(MBC_ISOLATE), .A(MBC_ISOLATE_B_int));
*/


endmodule


// End HDL models
