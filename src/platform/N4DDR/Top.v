`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/23/2016 07:21:03 PM
// Design Name: 
// Module Name: Top
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
module Top(
	input clk, input rstn,
	input [15:0] SW, input [4:0] BTN,
	output [7:0] segment, output [7:0] anode, output [15:0] LED,
	output [11:0] VGAColor, output HSync, output VSync,
	inout ps2Clk, inout ps2Dat,
	input uartRx, output uartTx,
	inout [3:0] sdDat, inout sdCmd, input sdCd, output sdClk, output sdRst,

	//DDR2 interface
	output [12:0] ddr2_addr,
	output [2:0] ddr2_ba,
	output ddr2_cas_n,
	output [0:0] ddr2_ck_n,
	output [0:0] ddr2_ck_p,
	output [0:0] ddr2_cke,
	output ddr2_ras_n,
//	output ddr2_reset_n,
	output ddr2_we_n,
	inout [15:0] ddr2_dq,
	inout [1:0] ddr2_dqs_n,
	inout [1:0] ddr2_dqs_p,
	output ddr2_cs_n,
	output [1:0] ddr2_dm,
	output [0:0] ddr2_odt
);
	//Unused I/O signals
	
	//Clock and reset signal
	wire clk_100M, clkCPU, clkVGA, clkDDR, globlRst;
	
	//IBus signals
	wire [31:0] addrIBus, dinIBus;
	//DBus signals
	wire [31:0] addrDBus, doutDBus, dinDBus;
	wire stbDBus, weDBus;
	wire [3:0] dmDBus;
	//Wishbone DDR3 signals
	wire [31:0] addrDDR;
	wire [511:0] doutDDR, dinDDR;
	wire stbDDR, cycDDR, weDDR, ackDDR;
	wire [63:0] dmDDR;
	//Peripheral signals
	wire [31:0] progMemData, cVramData, gVramData, ioData, sdCtrlData, sdDataData;
	wire progMemEN, cVramEN, gVramEN, ioEN, sdCtrlEN, sdDataEN;
	
	wire [4:0] cpuInterrupt;
	
	//Debug signals
	wire [31:0] dbg_vPC, dbg_vAddr;
	wire [2:0] dbg_ddrState;
	
	//VGA control registers
	wire [31:0] vgaCtrlReg0, vgaCtrlReg1;
	
	CPUCacheTop #(.CLKCPU_PERIOD(20), .CLKDDR_PERIOD(12)) core (
		.clkCPU(clkCPU), .clkDDR(clkDDR), .rst(globlRst), .interrupt(cpuInterrupt),
		.addrIBus(addrIBus), .dinIBus(dinIBus), .stbIBus(), .nakIBus(1'b0),
		.addrDBus(addrDBus), .doutDBus(doutDBus), .dinDBus(dinDBus),
		.stbDBus(stbDBus), .weDBus(weDBus), .dmDBus(dmDBus), .nakDBus(1'b0),
		.addrDDR(addrDDR), .doutDDR(doutDDR), .dinDDR(dinDDR), .dmDDR(dmDDR),
		.cycDDR(cycDDR), .stbDDR(stbDDR), .weDDR(weDDR), .ackDDR(ackDDR),
		.dbg_vPC(dbg_vPC), .dbg_vAddr(dbg_vAddr), .dbg_IDPC(), .dbg_EXPC(), .dbg_MEMPC()
	);
	
	Infrastructure_Nexys4 #(.DEBUG(1'b1)) infrastructure(.clk(clkDDR),  .rstn(rstn),
		.clk_100M(clk_100M), .clkCPU(clkCPU), .clkVGA(clkVGA), .globlRst(globlRst),
		.SW(SW), .BTN(BTN), .digitSeg(segment), .digitAnode(anode), .LED(LED),
		.ps2Clk(ps2Clk), .ps2Dat(ps2Dat), .uartRx(uartRx), .uartTx(uartTx),
		
		.vgaCtrlReg0(vgaCtrlReg0), .vgaCtrlReg1(vgaCtrlReg1),
		
		.dataInBus(doutDBus), .addrBus(addrDBus), .weBus(dmDBus),
		.en(ioEN), .dataOutBus(ioData), .ps2Int(cpuInterrupt[0]), .uartInt(cpuInterrupt[1]),
		
		.dbg_dat1(addrIBus), .dbg_dat2(dbg_vPC), .dbg_dat3(dinIBus), .dbg_dat4(addrDBus),
		.dbg_dat5(dbg_vAddr), .dbg_dat6(doutDBus), .dbg_dat7(dinDBus),
//		.dbg_flags({dmDBus, stbDBus, progMemEN, cVramEN, gVramEN, ioEN, sdCtrlEN, sdDataEN, cpuInterrupt[4:0]})
		.dbg_flags({dmDBus, stbDBus, stbDDR, cycDDR, weDDR, ackDDR, dbg_ddrState, cpuInterrupt[3:0]})
	);
	
	VGADevice #(.GRAPHIC_VRAM(0)) vga(.clkVGA(clkVGA), .clkMem(clkCPU),
		.ctrl0(vgaCtrlReg0), .ctrl1(vgaCtrlReg1),
		.dataInBus(doutDBus), .addrBus(addrDBus), .weBus(dmDBus),
		.en_Graphic(gVramEN), .en_Char(cVramEN), .dataOut_Char(cVramData),
		.videoOut(VGAColor), .HSync(HSync), .VSync(VSync));
	assign gVramData = 32'h0;
	
	SDWrapper sdc(.clkCPU(clkCPU), .clkSD(clk_100M), .globlRst(globlRst),
		.dataInBus(doutDBus), .addrBus(addrDBus), .weBus(dmDBus),
		.en_ctrl(sdCtrlEN), .en_data(sdDataEN), .dataOut_ctrl(sdCtrlData),
		.dataOut_data(sdDataData), .sdInt(cpuInterrupt[2]),
		.sd_dat(sdDat), .sd_cmd(sdCmd), .sd_clk(sdClk), .sd_rst(sdRst), .sd_cd(sdCd));
	
	CPUBus bus0(.clk(clkCPU), .rst(globlRst), .masterEN(stbDBus),
		.addrBus(addrDBus), .dataToCPU(dinDBus),
		.progMemEN(progMemEN), .progMemData(progMemData),
		.cVramEN(cVramEN), .cVramData(cVramData),
		.gVramEN(gVramEN), .gVramData(gVramData),
		.ioEN(ioEN), .ioData(ioData),
		.sdCtrlEN(sdCtrlEN), .sdCtrlData(sdCtrlData),
		.sdDataEN(sdDataEN), .sdDataData(sdDataData));
	
	BiosMem mem0(.clka(clkCPU), .addra(addrDBus[13:2]), .dina(doutDBus),
		.wea(dmDBus), .ena(progMemEN), .douta(progMemData),
		.clkb(~clkCPU), .addrb(addrIBus[13:2]), .dinb(32'h0),
		.web(4'h0), .enb(1'b1), .doutb(dinIBus),
		.clkProg(clk_100M), .uartRx(uartRx), .progEN(globlRst));
	
	DDR2_wsWrapper ddr2(.clkIn(clk), .clkOut(clkDDR), .rst(globlRst),
		.ws_addr(addrDDR), .ws_din(doutDDR), .ws_dm(dmDDR),
		.ws_cyc(cycDDR), .ws_stb(stbDDR), .ws_we(weDDR),
		.ws_dout(dinDDR), .ws_ack(ackDDR),
		
		.dbg_state(dbg_ddrState),
		
		.ddr2_addr(ddr2_addr),
		.ddr2_ba(ddr2_ba),
		.ddr2_cas_n(ddr2_cas_n),
		.ddr2_ck_n(ddr2_ck_n),
		.ddr2_ck_p(ddr2_ck_p),
		.ddr2_cke(ddr2_cke),
		.ddr2_ras_n(ddr2_ras_n),
//		.ddr2_reset_n(ddr2_reset_n),
		.ddr2_we_n(ddr2_we_n),
		.ddr2_dq(ddr2_dq),
		.ddr2_dqs_n(ddr2_dqs_n),
		.ddr2_dqs_p(ddr2_dqs_p),
		.ddr2_cs_n(ddr2_cs_n),
		.ddr2_dm(ddr2_dm),
		.ddr2_odt(ddr2_odt)
	);
	
	assign buzzer = 1'b1;
	
endmodule
