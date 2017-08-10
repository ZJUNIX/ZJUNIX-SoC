`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:15:31 03/29/2016 
// Design Name: 
// Module Name:    Regs 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module RegFile(
	input clk, input rst, input stall,
	input [4:0] rsAddr, input [4:0] rtAddr, input [4:0] rdAddr, input [4:0] rtAddrDelay,
	output [31:0] rs, output [31:0] rt, output [31:0] rtDelay, input [31:0] rd
);
	
	RAM32M U0[15:0] (.WCLK(clk), .WE(|rdAddr & ~stall),
        .ADDRA(rsAddr), .ADDRB(rtAddr), .ADDRC(rtAddrDelay), .ADDRD(rdAddr),
        .DIA(rd), .DIB(rd), .DIC(rd), .DID(rd),
        .DOA(rs), .DOB(rt), .DOC(rtDelay));
	
endmodule
