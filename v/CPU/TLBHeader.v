`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/09/26 14:42:39
// Design Name: 
// Module Name: TLBHeader
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
module TLBHeader(input clk, input rst,
	input [31:0] vAddrI, output matchI, output [5:0] entryIndexI, output [15:0] pageMaskI,
	input [31:0] vAddrD, output matchD, output [5:0] entryIndexD, output [15:0] pageMaskD,
	input [7:0] ASID, input [18:0] VPN2, output probeMatch, output [4:0] probeIndex,//Interface for TLBP instruction
	
	//Data cascade line
	input [48:0] cascadeDin, output [48:0] cascadeDout,
	
	input [4:0] indexIn, input [4:0] wiredIndex, output wired, output indexMatch,
	input shift, output [4:0] indexOut
);
//Information stored here:
//PageMask(16bit), VPN2(19bit), G(1bit), ASID(8bit)
parameter RST_INDEX = 5'd0;
`define Index 48:44
`define Content 43:0
`define PageMask 43:28
`define VPN2 27:9
`define G 8
`define ASID 7:0

	reg [43:0] headerData = 0;
	reg [4:0] headerIndex = RST_INDEX;
	wire evenOddBitI, evenOddBitD;
	wire [5:0] entryIndexI_internal, entryIndexD_internal;
	wire [4:0] probeIndex_internal;

	wire ASIDMatch = (headerData[`G] | (headerData[`ASID] == ASID));
	assign matchI = (((headerData[`VPN2] ^ vAddrI[31:13]) & {3'b111, ~headerData[`PageMask]}) == 19'h0) & ASIDMatch;
	assign matchD = (((headerData[`VPN2] ^ vAddrD[31:13]) & {3'b111, ~headerData[`PageMask]}) == 19'h0) & ASIDMatch;
	assign probeMatch = (((headerData[`VPN2] ^ VPN2) & {3'b111, ~headerData[`PageMask]}) == 19'h0) & ASIDMatch;
	assign indexMatch = (indexIn == headerIndex);
	
	assign entryIndexI_internal = {headerIndex, evenOddBitI};
	assign entryIndexD_internal = {headerIndex, evenOddBitD};
	assign probeIndex_internal = headerIndex;
	assign entryIndexI = matchI? entryIndexI_internal: 6'h0;
	assign entryIndexD = matchD? entryIndexD_internal: 6'h0;
	assign pageMaskI = matchI? headerData[`PageMask]: 16'h0;
	assign pageMaskD = matchD? headerData[`PageMask]: 16'h0;
	assign probeIndex = probeMatch? probeIndex_internal: 5'h0;
	
	wire [16:0] evenOddBitMask = {headerData[`PageMask], 1'b1} & {1'b1, ~headerData[`PageMask]};
	assign evenOddBitI = |(vAddrI[28:12] & evenOddBitMask);
	assign evenOddBitD = |(vAddrD[28:12] & evenOddBitMask);
	
	assign wired = headerIndex < wiredIndex;
	assign cascadeDout = {headerIndex, headerData};
	assign indexOut = headerIndex;

	always @ (posedge clk)
	begin
		if(rst)
		begin
			headerIndex <= RST_INDEX;
		end
		else if(shift)
		begin
			headerData <= cascadeDin[`Content];
			headerIndex <= cascadeDin[`Index];
		end
	end


//	initial headerData <= 49'h0;
	
endmodule
