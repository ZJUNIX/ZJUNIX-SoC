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
	input clr, output reg [15:0] crc, output crc_out
);
	
	wire inv = clr? 1'b0: crc_out ^ din;
	assign crc_out = crc[15];
	
	always @ (posedge clk)
	if(ce || clr)
	begin
		crc[15] <= crc[14];
		crc[14] <= crc[13];
		crc[13] <= crc[12];
		crc[12] <= crc[11] ^ inv;
		crc[11] <= crc[10];
		crc[10] <= crc[ 9];
		crc[ 9] <= crc[ 8];
		crc[ 8] <= crc[ 7];
		crc[ 7] <= crc[ 6];
		crc[ 6] <= crc[ 5];
		crc[ 5] <= crc[ 4] ^ inv;
		crc[ 4] <= crc[ 3];
		crc[ 3] <= crc[ 2];
		crc[ 2] <= crc[ 1];
		crc[ 1] <= crc[ 0];
		crc[ 0] <= inv;
	end
	
endmodule

module SDC_CRC7(
	input clk, input ce, input din,
	input clr, output reg [6:0] crc, output crc_out
);
	wire inv = clr? 1'b0: crc_out ^ din;
	assign crc_out = crc[6];
	
	always @ (posedge clk)
	if(ce || clr)
	begin
		crc[6] <= crc[5];
		crc[5] <= crc[4];
		crc[4] <= crc[3];
		crc[3] <= crc[2] ^ inv;
		crc[2] <= crc[1];
		crc[1] <= crc[0];
		crc[0] <= inv;
	end
	
endmodule
