`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:09:41 11/26/2015 
// Design Name: 
// Module Name:    VGAScan 
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
module VGAScan(
	input clk, input [11:0] videoIn,
	output [9:0] HAddr, output [8:0] VAddr,	output reg frameStart,
	output reg HSync,
	output reg VSync,
	output reg [11:0] videoOut
);
parameter PIPE_STAGE = 10'd2;//Must be at least 2.
parameter HCALIBRATE = 10'd0;
parameter VCALIBRATE = 10'd0;

localparam HSTART = 10'd143 + HCALIBRATE - PIPE_STAGE;
localparam HEND = 10'd783 + HCALIBRATE - PIPE_STAGE;
localparam VSTART = 10'd35 + VCALIBRATE;
localparam VEND = 10'd515 + VCALIBRATE;

	reg [9:0] HCount;
	reg [9:0] VCount;
	wire HActive, VActive;
	wire [9:0] _HAddr, _VAddr;
	
	reg [PIPE_STAGE-1:0] HActive_FF;

	assign HActive = (HCount >= HSTART && HCount < HEND);
	assign VActive = (VCount >= VSTART && VCount < VEND);
//	assign HSync = (HCount >= 10'd96);
//	assign VSync = (VCount >= 10'd2);
	assign _HAddr = HCount - HSTART;
	assign _VAddr = VCount - VSTART;

//	assign HAddr = (HActive && VActive)? _HAddr: 10'h0;
//	assign VAddr = VActive? _VAddr[8:0]: 9'h0;
	assign HAddr = _HAddr;
	assign VAddr = _VAddr[8:0];

	initial begin
		HCount = 10'h0;
		VCount = 10'h0;
	end

	always @ (posedge clk)
	begin
		if(HCount == 10'd799)
		begin
			HCount = 10'h0;
			if(VCount == 10'd524)
			begin
				VCount = 10'h0;
				frameStart <= 1'b1;
			end
			else
				VCount = VCount + 1'b1;
		end
		else
		begin
			HCount = HCount + 1'b1;
			frameStart <= 1'b0;
		end

		if(HActive_FF[0] && VActive)
			videoOut <= videoIn;
		else
			videoOut <= 8'h0;

		HActive_FF <= {HActive, HActive_FF[PIPE_STAGE-1:1]};
		HSync <= (HCount >= 10'd96);
		VSync <= (VCount >= 10'd2);
	end

endmodule
