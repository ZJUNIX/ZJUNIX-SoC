`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/05/2016 12:26:15 AM
// Design Name: 
// Module Name: Seg7Device
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
module Seg7Device #(
	parameter DIGITS = 8,
	parameter SEG_POLARITY = 1'b0,
	parameter AN_POLARITY = 1'b0
) (
	input clk, input blink, input [DIGITS*4-1:0] data, input [DIGITS-1:0] point,
	input [DIGITS-1:0] en, output reg [7:0] segment, output reg [DIGITS-1:0] anode
);
	wire [6:0] pattern;
	
	reg [DIGITS-1:0] anode_reg = 1;
	reg [DIGITS*4-1:0] dataShift;
	reg [DIGITS-1:0] pointShift;
	
	always @ (posedge clk)
	begin
		anode_reg <= {anode_reg[DIGITS-2:0], anode_reg[DIGITS-1]};
		dataShift <= anode_reg[DIGITS-1]? data: {4'h0, dataShift[DIGITS*4-1:4]};
		pointShift <= anode_reg[DIGITS-1]? point: {1'b0, pointShift[DIGITS-1:1]};
		segment[7] <= pointShift[0] ^~ SEG_POLARITY;
		segment[6:0] <= pattern;
		anode <= (anode_reg & (en | {DIGITS{blink}})) ^~ {DIGITS{AN_POLARITY}};
	end
	
	SegmentDecoder #(.POLARITY(SEG_POLARITY)) decoder(.hex(dataShift[3:0]), .segment(pattern));
	
endmodule

module SegmentDecoder #(
	parameter POLARITY = 1'b0
)(
	input [3:0] hex, output reg [6:0] segment
);

	generate
	if(POLARITY)
	begin: POLARITY_P
		always @*
		case(hex)
		4'h0: segment[6:0] <= 7'b0111111;
		4'h1: segment[6:0] <= 7'b0000110;
		4'h2: segment[6:0] <= 7'b1011011;
		4'h3: segment[6:0] <= 7'b1001111;
		4'h4: segment[6:0] <= 7'b1100110;
		4'h5: segment[6:0] <= 7'b1101101;
		4'h6: segment[6:0] <= 7'b1111101;
		4'h7: segment[6:0] <= 7'b0000111;
		4'h8: segment[6:0] <= 7'b1111111;
		4'h9: segment[6:0] <= 7'b1101111;
		4'hA: segment[6:0] <= 7'b1110111;
		4'hB: segment[6:0] <= 7'b1111100;
		4'hC: segment[6:0] <= 7'b0111001;
		4'hD: segment[6:0] <= 7'b1011110;
		4'hE: segment[6:0] <= 7'b1111001;
		4'hF: segment[6:0] <= 7'b1110001;
		endcase
	end
	else
	begin: POLARITY_N
		always @*
		case(hex)
		4'h0: segment[6:0] <= 7'b1000000;
		4'h1: segment[6:0] <= 7'b1111001;
		4'h2: segment[6:0] <= 7'b0100100;
		4'h3: segment[6:0] <= 7'b0110000;
		4'h4: segment[6:0] <= 7'b0011001;
		4'h5: segment[6:0] <= 7'b0010010;
		4'h6: segment[6:0] <= 7'b0000010;
		4'h7: segment[6:0] <= 7'b1111000;
		4'h8: segment[6:0] <= 7'b0000000;
		4'h9: segment[6:0] <= 7'b0010000;
		4'hA: segment[6:0] <= 7'b0001000;
		4'hB: segment[6:0] <= 7'b0000011;
		4'hC: segment[6:0] <= 7'b1000110;
		4'hD: segment[6:0] <= 7'b0100001;
		4'hE: segment[6:0] <= 7'b0000110;
		4'hF: segment[6:0] <= 7'b0001110;
		endcase
	end
	endgenerate

endmodule
