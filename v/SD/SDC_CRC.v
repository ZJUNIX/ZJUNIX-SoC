`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/11/2018 03:22:19 AM
// Design Name: 
// Module Name: SDC_CRC
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
module SDC_CRC16(
	input clk, input ce, input din,
	input clr, output crc_out
);
	reg [15:0] crc;
	wire crc_in = clr? 1'b0: crc_out ^ din;
	assign crc_out = crc[3] ^ crc[10] ^ crc[15];
	always @ (posedge clk)
	if(ce || clr) crc <= {crc[14:0], crc_in};
	
endmodule

module SDC_CRC7(
	input clk, input ce, input din,
	input clr, output crc_out
);
	reg [6:0] crc;
	wire crc_in = clr? 1'b0: crc_out ^ din;
	assign crc_out = crc[3] ^ crc[6];
	always @ (posedge clk)
	if(ce || clr) crc <= {crc[5:0], crc_in};
	
endmodule
