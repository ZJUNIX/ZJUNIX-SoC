`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/09/26 17:08:48
// Design Name: 
// Module Name: TLB
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
`include "TLBDefines.vh"

module TLB(input clk, input rst, input statusERL,
	//Address translation interface: instruction
	input [31:0] vAddrI, output [31:0] pAddrI,
	output missI, output invalidI, output [2:0] cacheI,
	output IOAddrI,
	output [15:0] pageMaskI_out,//Used for translation prediction logic
	//Address translation interface: data
	input [31:0] vAddrD, input reqD, input writeD, output [31:0] pAddrD,
	output missD, output invalidD, output modifiedD, output [2:0] cacheD,
	output IOAddrD,
	//Duplicate match exception: not yet implemented, leave n/c.
	output dupMatch,
	//TLB to COP0 interface
	input [31:0] regEntryLo0In, output [31:0] regEntryLo0Out,
	input [31:0] regEntryLo1In, output [31:0] regEntryLo1Out,
	input [31:0] regEntryHiIn, output [31:0] regEntryHiOut,
	input [31:0] regPageMaskIn, output [31:0] regPageMaskOut,
	input [31:0] regIndexIn, output [31:0] regIndexOut,
	input [4:0] regWired, output [4:0] regRandom,
	input [1:0] op//00=normal, 01=TLBR, 10=TLBWI, 11=TLBWR; TLBP and TLBR are always enabled
);
//Note: VIOLATION OF MIPS32 SPECIFICATION:
//1. The value of Random register will not change to 31 after the Wired register is written,
//   instead it points to the least-recently written, non-wired TLB entry.
//2. Odd numbers of 1 bits in PageMask are also valid encoding(0x0001, 0x0007, etc),
//   resulting in 17 possible page sizes(instead of 9).

//TLB size 32 entries, LRU replacement strategy

	wire [43:0] dataInHeader;
	wire [49:0] dataInEntry;
	wire [49:0] dataOutEntryR;
	wire [4:0] indexInHeader;
	
	wire [31:0] matchI, matchD, probeMatch, indexMatch;

	wire [43:0] dataOutHeader;
	wire [5:0] entryIndexI, entryIndexD;
	wire [15:0] pageMaskI, pageMaskD;
	wire [4:0] probeIndex;
	
	wire [31:0] shift;
	
//Interface to COP0
	assign dataInHeader[`PageMask] = regPageMaskIn[28:13];
	assign dataInHeader[`VPN2] = regEntryHiIn[31:13];
	assign dataInHeader[`G] = regEntryLo0In[0] & regEntryLo1In[0];
	assign dataInHeader[`ASID] = regEntryHiIn[7:0];
	assign dataInEntry[`PFN1] = regEntryLo1In[29:6];
	assign dataInEntry[`C1] = regEntryLo1In[5:3];
	assign dataInEntry[`D1] = regEntryLo1In[2];
	assign dataInEntry[`V1] = regEntryLo1In[1];
	assign dataInEntry[`PFN0] = regEntryLo0In[29:6];
	assign dataInEntry[`C0] = regEntryLo0In[5:3];
	assign dataInEntry[`D0] = regEntryLo0In[2];
	assign dataInEntry[`V0] = regEntryLo0In[1];
	
	assign regPageMaskOut = {3'h0, dataOutHeader[`PageMask], 13'h0};
	assign regEntryHiOut = {dataOutHeader[`VPN2], 5'h0, dataOutHeader[`ASID]};
	assign regEntryLo1Out = {6'h0, dataOutEntryR[`PFN1], dataOutEntryR[`C1], dataOutEntryR[`D1], dataOutEntryR[`V1], dataOutHeader[`G]};
	assign regEntryLo0Out = {6'h0, dataOutEntryR[`PFN0], dataOutEntryR[`C0], dataOutEntryR[`D0], dataOutEntryR[`V0], dataOutHeader[`G]};

	assign shift = op[1]? 32'hffffffff + {indexMatch[30:0], 1'b0}: 32'h0;
	assign indexInHeader = (op == 2'b11)? regRandom: regIndexIn[4:0];
	
//Address translation logic
	wire [24:0] entryDataI;
	wire [24:0] entryDataD;
	wire [31:0] pAddrI_internal, pAddrD_internal;
	wire unmapI = (vAddrI[31:30] == 2'b10) | (statusERL & vAddrI[31:29] == 3'b0);
	wire unmapD = (vAddrD[31:30] == 2'b10) | (statusERL & vAddrD[31:29] == 3'b0);
	wire reqD_internal = reqD & ~unmapD;
	wire uncacheI = (vAddrI[31:29] == 3'b101) | (vAddrI[31:29] == 3'b000 & statusERL);
	wire uncacheD = (vAddrD[31:29] == 3'b101) | (vAddrD[31:29] == 3'b000 & statusERL);
	assign missI = (~|matchI) & ~unmapI;
	assign missD = (~|matchD) & reqD_internal;
	assign cacheI = uncacheI? 3'b010: entryDataI[`C0];
	assign cacheD = uncacheD? 3'b010: entryDataD[`C0];
	assign invalidI = ~entryDataI[`V0] & ~unmapI;
	assign invalidD = ~entryDataD[`V0] & reqD_internal;
	assign modifiedD = ~entryDataD[`D0] & reqD_internal & writeD;
	assign IOAddrI = (vAddrI[31:29] == 3'b101);
	assign IOAddrD = (vAddrD[31:29] == 3'b101);
	wire [19:0] PFNI = entryDataI[`PFN0];
	wire [19:0] PFND = entryDataD[`PFN0];
	assign pAddrI_internal[31:28] = PFNI[19:16];
	assign pAddrI_internal[11:0] = vAddrI[11:0];
	assign pAddrI_internal[27:12] = (PFNI[15:0] & ~pageMaskI) | (vAddrI[27:12] & pageMaskI);
	assign pAddrD_internal[31:28] = PFND[19:16];
	assign pAddrD_internal[11:0] = vAddrD[11:0];
	assign pAddrD_internal[27:12] = (PFND[15:0] & ~pageMaskD) | (vAddrD[27:12] & pageMaskD);
	assign pAddrI = unmapI? {3'b0, vAddrI[28:0]}: pAddrI_internal;
	assign pAddrD = unmapD? {3'b0, vAddrD[28:0]}: pAddrD_internal;
	
	TLBEntry entryPool (.clk(clk), .we(op[1]),
		.indexA(entryIndexI), .entryA(entryDataI), .pageMaskA(pageMaskI),
		.indexB(entryIndexD), .entryB(entryDataD), .pageMaskB(pageMaskD),
		.indexC(regIndexIn[4:0]), .entryC(dataOutEntryR), .headerC(dataOutHeader),
		.indexD(indexInHeader), .entryD(dataInEntry), .headerD(dataInHeader));
	
	assign regIndexOut[4:0] = probeIndex;
	assign regIndexOut[31] = ~|probeMatch;
	assign regIndexOut[30:5] = 0;
	
	TLBHeaderInst headers(.clk(clk), .rst(rst),
		.vAddrI(vAddrI), .matchI(matchI), .entryIndexI(entryIndexI), .pageMaskI(),
		.vAddrD(vAddrD), .matchD(matchD), .entryIndexD(entryIndexD), .pageMaskD(),
		.ASID(dataInHeader[`ASID]), .VPN2(dataInHeader[`VPN2]), .probeMatch(probeMatch), .probeIndex(probeIndex),
		.dataInHeader(dataInHeader),
		.indexInHeader(indexInHeader), .regWired(regWired), .indexMatch(indexMatch),
		.shift(shift), .regRandom(regRandom));
	
	assign dupMatch = 1'b0;//TODO
	
	assign pageMaskI_out = unmapI? 16'hffff: pageMaskI;
	
endmodule
