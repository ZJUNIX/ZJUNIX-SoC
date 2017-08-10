`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:03:56 05/03/2016 
// Design Name: 
// Module Name:    FwdUnit 
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
module GprFwdUnit(
	input [31:0] regFile, input [31:0] ALUout, input [31:0] dataToReg,
	input [4:0] regRequest, input EN, input [4:0] IDEX_wb, input IDEX_dv, input [4:0] EXMEM_wb,
	output reg [31:0] dataOut, output stall
);
	
	wire [2:0] sel;
	assign sel[2] = (|regRequest & EN);
	assign sel[1] = (IDEX_wb == regRequest);
	assign sel[0] = (EXMEM_wb == regRequest);
	
	assign stall = &{sel[2], sel[1], ~IDEX_dv};
	
	always @*
		case(sel)
		3'b101: dataOut <= dataToReg;
		3'b110, 3'b111: dataOut <= ALUout;
		default: dataOut <= regFile;
		endcase
	
endmodule
