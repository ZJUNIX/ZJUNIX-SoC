`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/22/2016 05:13:45 PM
// Design Name: 
// Module Name: Cp0Reg
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
//module Cp0FF #(
//	parameter SOFTWARE_EN = 1'b0,
//	parameter RESET_STATE = 1'b0
//)(
//	input clk, input rst,
//	input sDin, input sWe,
//	input hDin, input hWe,
//	output reg dout = RESET_STATE
//);
//	always @ (posedge clk)
//	begin
//		if(rst)
//			dout <= RESET_STATE;
//		else
//		begin
//			//Software write overrides hardware write
//			if(SOFTWARE_EN & sWe)
//				dout <= sDin;
//			else if(hWe)
//				dout <= hDin;
//		end
//	end

//endmodule

module Cp0Reg #(
	parameter SOFTWARE_MASK = 32'b0000_0000_0000_0000_0000_0000_0000_0000,
	parameter RESET_STATE = 32'b0000_0000_0000_0000_0000_0000_0000_0000
)
(
	input clk, input rst,
	input [31:0] sDin, input sWe,
	input [31:0] hDin, input [31:0] hWe,
	output [31:0] dout
);
	
	genvar i;
	generate
	for(i = 0; i < 32; i = i+1)
	begin: Cp0Reg_1b
//			Cp0FF #(
//				.SOFTWARE_EN(SOFTWARE_MASK[i]),
//				.RESET_STATE(RESET_STATE[i]))
//			cp0FF(.clk(clk), .rst(rst), .sDin(sDin[i]), .sWe(sWe),
//				.hDin(hDin[i]), .hWe(hWe[i]), .dout(dout[i]));
		reg regBit = RESET_STATE[i];
		assign dout[i] = regBit;
		always @ (posedge clk)
		begin
			if(rst)
				regBit <= RESET_STATE[i];
			else
			begin
				if(SOFTWARE_MASK[i] & sWe)
					regBit <= sDin[i];
				else if(hWe[i])
					regBit <= hDin[i];
			end
		end
	end
	endgenerate
	
endmodule
