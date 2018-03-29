`timescale 1ns / 1ps
/**
 * VGA driver with character mode and graphics mode. Graphics mode can be disabled
 * (excluded from synthesis & implementation) by setting the parameter to 0.
 * Contains a hardware cursor in character mode.
 * 
 * @author Yunye Pu
 */
module VGADevice #(
	parameter GRAPHIC_VRAM = 1
)(
	input clkVGA, input clkMem,
	//Control registers
	input [31:0] ctrl0, input [31:0] ctrl1,
	//CPU data bus
	input [31:0] addrBus, input [31:0] dataInBus, input [3:0] weBus,
	//CPU IO interface(Graphic); addr[11:2]=X, addr[20:12]=Y
	input en_Graphic,
	//CPU IO interface(Character); appears 128x32, uses addr[13:2]
	input en_Char, output [31:0] dataOut_Char,
	//VGA O: internal
	output [9:0] HCoord, output [8:0] VCoord, output frameStart,
	//VGA O: external
	output [11:0] videoOut, output HSync, output VSync
);
	
	//Graphic VRAM logic
	wire [11:0] colorG;
	generate
	if(GRAPHIC_VRAM != 0)
	begin: GRAPHIC_VRAM_EXIST
		reg [18:0] addrBus_reg, addra_reg;
		reg [1:0] ena_reg, wea_reg;
		wire [18:0] addra, addrb;
		reg [11:0] dina_reg0, dina_reg1;
	
		assign addra = addrBus_reg[18:10] * 640 + addrBus_reg[9:0];
		assign addrb = VCoord * 640 + HCoord;
		GraphicVRAM RAM0 (.clka(clkMem), .ena(ena_reg[1]), .wea(wea_reg[1]), .addra(addra_reg),
			.dina(dina_reg1), .clkb(clkVGA), .addrb(addrb), .doutb(colorG));
	
		always @ (posedge clkMem)
		begin
			dina_reg0 <= dataInBus[11:0];
			addrBus_reg <= addrBus[20:2];
			wea_reg[0] <= &weBus;
			ena_reg[0] <= en_Graphic;
			
			dina_reg1 <= dina_reg0;
			addra_reg <= addra;
			wea_reg[1] <= wea_reg[0];
			ena_reg[1] <= ena_reg[0];
		end
	end
	else
	begin: GRAPHIC_VRAM_NOTEXIST
		assign colorG = 12'h0;
	end
	endgenerate
	
	//Character VRAM logic
	wire [31:0] chData;//+1 cycle
	reg [11:0] colorC_F, colorC_B;//+2 cycle
	reg [2:0] HCoord_reg;//+1 cycle
	wire charDot;//+2 cycle
	wire inCursor;//+1 cycle
	
	CharVRAM RAM1(.clka(clkMem), .ena(en_Char), .wea(weBus), .addra(addrBus[13:2]),
		.dina(dataInBus), .douta(dataOut_Char), .clkb(clkVGA),
		.addrb({VCoord[8:4], HCoord[9:3]}), .doutb(chData));
	CharROM ROM0(.clk(clkVGA), .ascii(chData[7:0]), .x(HCoord_reg), .y(VCoord[3:0]), .dot(charDot));

	reg [11:0] colorMixed;
	VGAScan #(.HCALIBRATE(0), .VCALIBRATE(0)) U0(
		.clk(clkVGA), .HAddr(HCoord), .VAddr(VCoord), .HSync(HSync), .VSync(VSync),
		.videoIn(colorMixed), .frameStart(frameStart), .videoOut(videoOut));
	
	always @ (posedge clkVGA)
	begin
		HCoord_reg <= HCoord[2:0];
		if(inCursor)
		begin
			colorC_F <= chData[31:20];
			colorC_B <= chData[19:8];
		end
		else
		begin
			colorC_F <= chData[19:8];
			colorC_B <= chData[31:20];
		end
	end
	
	always @*
	begin
		if(charDot)
			colorMixed <= colorC_F;
		else if((colorC_B == 12'h0) & ctrl1[0])
			colorMixed <= colorG;
		else
			colorMixed <= colorC_B;
		
	end
	
	vgaCursorGen cursor(.clk(clkVGA), .ctrl(ctrl0), .HCoord(HCoord), .VCoord(VCoord), .en(inCursor));

endmodule

module vgaCursorGen(
	input clk, input [31:0] ctrl,
	input [9:0] HCoord, input [8:0] VCoord, output reg en
);
`define CURSOR_X ctrl[6:0]
`define CURSOR_Y ctrl[12:8]
`define CURSOR_FREQ ctrl[23:16]
	
	reg blink = 0;
	reg [18:0] counter0 = 0;
	reg [7:0] counter1 = 0;
	wire en_ascii;
	always @ (posedge clk)
	begin
		if(counter0 == 0)
		begin
			counter0 <= 19'd390625;
			if(`CURSOR_FREQ == 0)
				blink <= 1'b0;
			else if(counter1 == 0)
				blink <= ~blink;
			
			if(counter1 == 0)
				counter1 <= `CURSOR_FREQ;
			else
				counter1 <= counter1 - 1'b1;
		end
		else
			counter0 <= counter0 - 1'b1;
		
		en <= blink & en_ascii;
	end
	
	assign en_ascii = (HCoord[9:3] == `CURSOR_X) & (VCoord[8:4] == `CURSOR_Y);
	
endmodule