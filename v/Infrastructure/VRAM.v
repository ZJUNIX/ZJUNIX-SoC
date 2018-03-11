`timescale 1ns / 1ps
/**
 * Character mode VRAM and character generator ROM.
 * VRAM size is 128x32 characters; character size is 8x16 pixels.
 * 
 * @author Yunye Pu
 */
module CharROM(
	input clk,
	input [7:0] ascii, input [2:0] x, input [3:0] y,
	output reg dot
);
	reg data[0:32767];
	wire [14:0] addr = {ascii, y, x};
	
	always @ (posedge clk)
		dot <= data[addr];
	
	initial
		$readmemh("../../coe/CharROM.hex", data);
	
endmodule

module CharVRAM(
	input clka, input [11:0] addra, input [3:0] wea, input ena,
	input [31:0] dina, output reg [31:0] douta,
	input clkb, input [11:0] addrb, output reg [31:0] doutb
);
	reg [31:0] data[4095:0];
	
	always @ (posedge clka)
	if(ena)
	begin
		if(wea[0]) data[addra][ 7: 0] = dina[ 7: 0];
		if(wea[1]) data[addra][15: 8] = dina[15: 8];
		if(wea[2]) data[addra][23:16] = dina[23:16];
		if(wea[3]) data[addra][31:24] = dina[31:24];
		douta <= data[addra];
	end
	
	always @ (posedge clkb)
		doutb <= data[addrb];

endmodule
