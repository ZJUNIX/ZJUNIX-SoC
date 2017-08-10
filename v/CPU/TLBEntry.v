`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/09/26 15:13:55
// Design Name: 
// Module Name: TLBEntry
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module TLBEntry(input clk,
	input [4:0] indexA, output [49:0] entryA,//For instruction lookup
	input [4:0] indexB, output [49:0] entryB,//For data lookup
	input [4:0] indexC, output [49:0] entryC, output [43:0] headerC,//For TLBR; indexC connected to Index register
	input [4:0] indexD, output [49:0] entryD, output [43:0] headerD,//For TLBWI/TLBWR; indexD connected to Index or Random
	input we, input [49:0] dataIn, input [43:0] headerIn
);
	
	RAM32M #(.INIT_A(64'h0), .INIT_B(64'h0), .INIT_C(64'h0), .INIT_D(64'h0))
		entryPool[24:0] (.WCLK(clk), .WE(we),
		.ADDRA(indexA), .ADDRB(indexB), .ADDRC(indexC), .ADDRD(indexD),
		.DIA(dataIn), .DIB(dataIn), .DIC(dataIn), .DID(dataIn),
		.DOA(entryA), .DOB(entryB), .DOC(entryC), .DOD(entryD));
	RAM32M #(.INIT_A(64'h0), .INIT_B(64'h0), .INIT_C(64'h0), .INIT_D(64'h0))
		headerPool[10:0] (.WCLK(clk), .WE(we),
		.ADDRA(indexC), .ADDRB(indexC), .ADDRC(indexD), .ADDRD(indexD),
		.DIA(headerIn[43:22]), .DIB(headerIn[21:0]), .DIC(headerIn[43:22]), .DID(headerIn[21:0]),
		.DOA(headerC[43:22]), .DOB(headerC[21:0]), .DOC(headerD[43:22]), .DOD(headerD[21:0]));
	
endmodule
