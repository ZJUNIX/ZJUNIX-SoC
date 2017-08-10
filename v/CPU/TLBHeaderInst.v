`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/28/2016 07:23:08 PM
// Design Name: 
// Module Name: TLBHeaderInst
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
module TLBHeaderInst(input clk, input rst,
	input [31:0] vAddrI, output [31:0] matchI, output [5:0] entryIndexI, output [15:0] pageMaskI,
	input [31:0] vAddrD, output [31:0] matchD, output [5:0] entryIndexD, output [15:0] pageMaskD,
	input [7:0] ASID, input [18:0] VPN2, output [31:0] probeMatch, output [4:0] probeIndex,
	input [43:0] dataInHeader,
	input [4:0] indexInHeader, input [4:0] regWired, output [31:0] indexMatch,
	input [31:0] shift, output [4:0] regRandom
);
	wire [49*33-1:0] cascadeData;

	wire [5:0] iI[31:0];//index I
	wire [5:0] iD[31:0];//index D
	wire [4:0] pi[31:0];//probe index
	wire [15:0] pmI[31:0];//page mask I
	wire [15:0] pmD[31:0];//page mask D
	wire [31:0] i0, i1, i2, i3, i4;
	wire [31:0] wired;
	
	genvar i;
	generate
		for(i = 0; i < 32; i = i + 1)
		begin: TLBHeaderInst
			TLBHeader #(.RST_INDEX(i)) header(.clk(clk), .rst(rst),
				.vAddrI(vAddrI), .matchI(matchI[i]), .entryIndexI(iI[i]), .pageMaskI(pmI[i]),
				.vAddrD(vAddrD), .matchD(matchD[i]), .entryIndexD(iD[i]), .pageMaskD(pmD[i]),
				.ASID(ASID), .VPN2(VPN2), .probeMatch(probeMatch[i]), .probeIndex(pi[i]),
				.cascadeDin(cascadeData[i*49+48:i*49]), .cascadeDout(cascadeData[(i+1)*49+48:(i+1)*49]),
				.indexIn(indexInHeader), .wiredIndex(regWired), .wired(wired[i]), .indexMatch(indexMatch[i]),
				.shift(shift[i]), .indexOut({i4[i], i3[i], i2[i], i1[i], i0[i]}));
		end
	endgenerate
    
	assign entryIndexI =
		iI[ 0] | iI[ 1] | iI[ 2] | iI[ 3] | iI[ 4] | iI[ 5] | iI[ 6] | iI[ 7] |
		iI[ 8] | iI[ 9] | iI[10] | iI[11] | iI[12] | iI[13] | iI[14] | iI[15] |
		iI[16] | iI[17] | iI[18] | iI[19] | iI[20] | iI[21] | iI[22] | iI[23] |
		iI[24] | iI[25] | iI[26] | iI[27] | iI[28] | iI[29] | iI[30] | iI[31];
	assign entryIndexD =
		iD[ 0] | iD[ 1] | iD[ 2] | iD[ 3] | iD[ 4] | iD[ 5] | iD[ 6] | iD[ 7] |
		iD[ 8] | iD[ 9] | iD[10] | iD[11] | iD[12] | iD[13] | iD[14] | iD[15] |
		iD[16] | iD[17] | iD[18] | iD[19] | iD[20] | iD[21] | iD[22] | iD[23] |
		iD[24] | iD[25] | iD[26] | iD[27] | iD[28] | iD[29] | iD[30] | iD[31];
	assign probeIndex =
		pi[ 0] | pi[ 1] | pi[ 2] | pi[ 3] | pi[ 4] | pi[ 5] | pi[ 6] | pi[ 7] |
		pi[ 8] | pi[ 9] | pi[10] | pi[11] | pi[12] | pi[13] | pi[14] | pi[15] |
		pi[16] | pi[17] | pi[18] | pi[19] | pi[20] | pi[21] | pi[22] | pi[23] |
		pi[24] | pi[25] | pi[26] | pi[27] | pi[28] | pi[29] | pi[30] | pi[31];
	assign pageMaskI = 
		pmI[ 0] | pmI[ 1] | pmI[ 2] | pmI[ 3] | pmI[ 4] | pmI[ 5] | pmI[ 6] | pmI[ 7] |
		pmI[ 8] | pmI[ 9] | pmI[10] | pmI[11] | pmI[12] | pmI[13] | pmI[14] | pmI[15] |
		pmI[16] | pmI[17] | pmI[18] | pmI[19] | pmI[20] | pmI[21] | pmI[22] | pmI[23] |
		pmI[24] | pmI[25] | pmI[26] | pmI[27] | pmI[28] | pmI[29] | pmI[30] | pmI[31];
	assign pageMaskD = 
		pmD[ 0] | pmD[ 1] | pmD[ 2] | pmD[ 3] | pmD[ 4] | pmD[ 5] | pmD[ 6] | pmD[ 7] |
		pmD[ 8] | pmD[ 9] | pmD[10] | pmD[11] | pmD[12] | pmD[13] | pmD[14] | pmD[15] |
		pmD[16] | pmD[17] | pmD[18] | pmD[19] | pmD[20] | pmD[21] | pmD[22] | pmD[23] |
		pmD[24] | pmD[25] | pmD[26] | pmD[27] | pmD[28] | pmD[29] | pmD[30] | pmD[31];

	assign cascadeData[48:0] = {indexInHeader, dataInHeader};
	
	rndIndexCascade rc0(.indexIn(i0), .wiredIn(wired), .indexOut(regRandom[0]));
	rndIndexCascade rc1(.indexIn(i1), .wiredIn(wired), .indexOut(regRandom[1]));
	rndIndexCascade rc2(.indexIn(i2), .wiredIn(wired), .indexOut(regRandom[2]));
	rndIndexCascade rc3(.indexIn(i3), .wiredIn(wired), .indexOut(regRandom[3]));
	rndIndexCascade rc4(.indexIn(i4), .wiredIn(wired), .indexOut(regRandom[4]));
    
endmodule

module rndIndexCascade(
	input [31:0] indexIn, input [31:0] wiredIn, output indexOut
);
	//Use muxes in the carry logic for fast operation
	wire [32:0] cascadeLine;
	genvar i;
	generate
		for(i = 0; i < 32; i = i + 1)
		begin: carry
			MUXCY mux(.S(wiredIn[i]), .DI(indexIn[i]), .CI(cascadeLine[i]), .O(cascadeLine[i+1]));
		end
	endgenerate
	assign cascadeLine[0] = 1'b0;
	assign indexOut = cascadeLine[32];
	
endmodule
