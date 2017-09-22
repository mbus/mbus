//*******************************************************************************************
//Author:         Ye-sheng Kuo, Yejoong Kim
//Last Modified:  Dec 16 2016
//Description:    Functions for MBus Verilog
//Update History: May 21 2016 - Updated for MBus r03 (Yejoong Kim)
//                Dec 16 2016 - Included in MBus r04 (Yejoong Kim)
//******************************************************************************************* 

function integer log2;
	input [31:0] value;
	for (log2=0; value>0; log2=log2+1)
	value = value>>1;
endfunction

function integer log2long;
	input [255:0] value;
	for (log2long=0; value>0; log2long=log2long+1)
	value = value>>1;
endfunction
