`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/26/2016 10:30:43 AM
// Design Name: 
// Module Name: TranslatePredict
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
module TranslatePredict(
	input clk, input rst, input stall,
	input [15:0] pageMask, input [31:0] pPCin,
	input [31:0] vPC, output [31:0] pPCOut,
	output flush
);
	
	reg [15:0] pageMask_reg;
	reg [31:0] pPC_reg;
	reg [31:0] pPCPred_reg;
	wire [31:0] pPCPredict;
	
	assign pPCPredict[31:28] = pPC_reg[31:28];
	assign pPCPredict[11:0] = vPC[11:0];
	assign pPCPredict[27:12] = (pPC_reg[27:12] & ~pageMask_reg) | (vPC[27:12] & pageMask_reg);
	
	assign pPCOut = flush? pPC_reg: pPCPredict;
	assign flush = (pPC_reg != pPCPred_reg);
	
	always @ (posedge clk)
	begin
		if(rst)
		begin
			pageMask_reg <= 16'hffff;
			pPC_reg <= 32'h1fc00000;
			pPCPred_reg <= 32'h1fc00000;
		end
		else if(~stall)
		begin
			pageMask_reg <= pageMask;
			pPC_reg <= pPCin;
			pPCPred_reg <= pPCPredict;
		end
	end
	
endmodule
