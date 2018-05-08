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
    input rst,
    
	input clkVGA, input clkMem,
	//Control registers
	input [31:0] ctrl0, input [31:0] ctrl1,
	//CPU data bus
	input [31:0] addrBus, input [31:0] dataInBus, input [3:0] weBus,
	//CPU IO interface(Character); appears 128x32, uses addr[13:2]
	input en_Char, output [31:0] dataOut_Char,
	//Wishbone bus for reading from SRAM
	output wb_stb,
    output [31:0] wb_addr,
    output reg [3:0] wb_we = 4'b0,
    output reg [31:0] wb_din = 32'b0,
    input [47:0] wb_dout,
    input wb_nak,
	//VGA O: internal
	output [9:0] HCoord, output [8:0] VCoord, output frameStart,
	//VGA O: external
	output [11:0] videoOut, output HSync, output VSync
);
	
	//Graphic VRAM logic
    
	wire [11:0] colorG;
	wire videoOn;
	generate
	if(GRAPHIC_VRAM != 0)
	begin: GRAPHIC_VRAM_EXIST
        
        wire buf_full_, buf_empty_;
        reg reading = 0;
        always @(posedge clkMem) begin
            if (~reading & wb_stb) reading <= 1'b1;
            if (reading & ~wb_nak) reading <= 1'b0;
        end
        assign wb_stb = buf_full_ & ~reading & ~rst;
        
        reg [9:0]curReadX = 0;
        reg [8:0]curReadY = 0;
        always @(posedge clkMem) begin
            if (rst) begin
                curReadX <= 0;
                curReadY <= 0;
            end
            else if (reading & ~wb_nak) begin
                curReadX <= (curReadX == 638) ? 0 : curReadX + 2;
                curReadY <= (curReadX == 638) ? ((curReadY == 479) ? 0 : curReadY + 1) : curReadY;
            end
        end
        assign wb_addr = curReadY * 640 + curReadX[9:1];
        
        reg high_low = 0;
        wire buf_next;
        wire [31:0]bufData;
        always @(posedge clkVGA)begin
            if (rst)
                high_low <= 1'b0;
            else
                high_low <= videoOn ? ~high_low : 1'b0;
        end
        assign buf_next = high_low & videoOn;
        //once buf is empty a serious error will occure
        //this is a bug
        assign colorG = buf_empty_ ? (high_low ? bufData[27:16] : bufData[11:0]) : 0;
            
        AxisFifo #(.WIDTH(32), .DEPTH_BITS(5), .SYNC_STAGE_I(0), .SYNC_STAGE_O(1))
            Fifo ( .s_rst(rst), .m_rst(rst),
            .s_clk(clkMem),  .s_valid(reading & ~wb_nak), .s_ready(buf_full_),.s_data(wb_dout[31:0]), .s_load(),
            .m_clk(clkVGA),  .m_valid(buf_empty_),.m_ready(buf_next), .m_data(bufData), .m_load()
        );
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
		.videoIn(colorMixed), .frameStart(frameStart), .videoOn(videoOn), .videoOut(videoOut));
	
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

module VGADevice_sim();
    reg rst = 0;
    reg clk = 1;
    reg clk_vga = 1;
    wire wb_stb;
    wire [31:0]wb_addr;
    wire [3:0]wb_we;
    wire [31:0]wb_din;
    reg  [31:0]wb_dout;
    reg wb_nak;
    wire [8:0]HCoord;
    wire [9:0]VCoord;
    VGADevice vga(
        .rst(rst),
        .clkVGA(clk_vga),.clkMem(clk),
        .ctrl0(32'b0), .ctrl1(32'b1),
        .addrBus(32'b0), .dataInBus(32'b0), .weBus(4'b0),
        .en_Char(1'b0), .dataOut_Char(),
        .wb_stb(wb_stb),
        .wb_addr(wb_addr),
        .wb_we(wb_we),
        .wb_din(wb_din),
        .wb_dout(wb_dout),
        .wb_nak(wb_nak),
        .HCoord(HCoord),.VCoord(VCoord), .frameStart(),
        .videoOut(), .HSync(), .VSync()
    );
    
    initial forever #5 clk = !clk;
    initial forever #25 clk_vga = !clk_vga;
    
    initial begin
        rst = 1;
        #11
        rst = 0;
        wb_nak = 0;
        wb_dout = 32'b0;
        #10
        wb_nak = 1;
        #50
        wb_nak = 0;
        wb_dout = 32'h01234567;
        
    end
endmodule