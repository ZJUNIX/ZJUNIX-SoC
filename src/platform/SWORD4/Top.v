`timescale 1ns / 1ps
/**
 * The top module of SoC project.
 * 
 * @auther Yunye Pu
 */
module Top(
//	input clk, 
	input rstn,
	input sysclk_p,
	input sysclk_n,
	input [15:0] SW, inout [4:0] btnX, inout [4:0] btnY,
	output [2:0] seg_sout, output [1:0] led_sout,
	output [11:0] VGAColor, output HSync, output VSync,
	inout ps2Clk, inout ps2Dat,
	input uartRx, output uartTx,
	inout [3:0] sdDat, inout sdCmd, input sdCd, output sdClk,
	
	//Arduino basic I/O
	output [7:0] segment,
	output [1:0] anode,
	output [7:0] LED,
	inout btnL, input btnR,
	
	//DDR3 interface
	output [13:0] ddr3_addr,
	output [2:0] ddr3_ba,
	output ddr3_cas_n,
	output [0:0] ddr3_ck_n,
	output [0:0] ddr3_ck_p,
	output [0:0] ddr3_cke,
	output ddr3_ras_n,
	output ddr3_reset_n,
	output ddr3_we_n,
	inout [31:0] ddr3_dq,
	inout [3:0] ddr3_dqs_n,
	inout [3:0] ddr3_dqs_p,
	output ddr3_cs_n,
	output [3:0] ddr3_dm,
	output [0:0] ddr3_odt,
	output sdRst,
	
	//SRAM
	output [2:0]sram_ce_n,
	output [2:0]sram_oe_n,
	output [2:0]sram_we_n,
	output [2:0]sram_ub_n,
	output [2:0]sram_lb_n,
    output [19:0]sram_addr,
    inout [47:0]sram_data
);

	//Unused I/O signals
	wire buzzer;
	//Clock and reset signal
	wire clk_100M, clkCPU, clkVGA, clkDDR, globlRst;
	
	//IBus signals
	wire [31:0] addrIBus, dinIBus;
	//DBus signals
	//(* MARK_DEBUG = "true" *)
	wire [31:0] addrDBus;
	wire [31:0] doutDBus, dinDBus;
	wire stbDBus, weDBus, nakDBus;
	wire [3:0] dmDBus;
	//Wishbone DDR3 signals
	wire [31:0] addrDDR;
	wire [511:0] doutDDR, dinDDR;
	wire stbDDR, cycDDR, weDDR, ackDDR;
	wire [63:0] dmDDR;
	//Peripheral signals
	wire [31:0] progMemData, cVramData, gVramData, ioData, sdCtrlData, sdDataData, sramData;
	wire progMemEN, cVramEN, gVramEN, ioEN, sdCtrlEN, sdDataEN;
	//(* MARK_DEBUG = "true" *)
	wire sramEN, sramNak;
	
	wire [4:0] cpuInterrupt;
	
	//Debug signals
	wire [31:0] dbg_vPC, dbg_vAddr;
	wire [2:0] dbg_ddrState;
	
	//VGA control registers
	wire [31:0] vgaCtrlReg0, vgaCtrlReg1;
	
	wire [31:0]ddbusData;
	//(* MARK_DEBUG = "true" *)
	wire [31:0]sramAddr, sramInData;
	//(* MARK_DEBUG = "true" *)
	wire ddbusNak, ddbusEN;
	//(* MARK_DEBUG = "true" *)
    wire [3:0] sram_we;
    

	CPUCacheTop core(
		.clkCPU(clkCPU), .clkDDR(clkDDR), .rst(globlRst), .interrupt(cpuInterrupt),
		.addrIBus(addrIBus), .dinIBus(dinIBus), .stbIBus(), .nakIBus(1'b0),
		.addrDBus(addrDBus), .doutDBus(doutDBus), .dinDBus(dinDBus),
		.stbDBus(stbDBus), .weDBus(weDBus), .dmDBus(dmDBus), .nakDBus(nakDBus),
		.addrDDR(addrDDR), .doutDDR(doutDDR), .dinDDR(dinDDR), .dmDDR(dmDDR),
		.cycDDR(cycDDR), .stbDDR(stbDDR), .weDDR(weDDR), .ackDDR(ackDDR),
		.dbg_vPC(dbg_vPC), .dbg_vAddr(dbg_vAddr), .dbg_IDPC(), .dbg_EXPC(), .dbg_MEMPC()
	);
	
	Infrastructure_Sword #(.DEBUG(1'b1)) infrastructure(.clk(clkDDR),  .rstn(rstn),
		.clk_100M(clk_100M), .clkCPU(clkCPU), .clkVGA(clkVGA), .globlRst(globlRst),
		.SW(SW), .btnX(btnX), .btnY(btnY), .btnL(btnL), .btnR(btnR),
		.segment(segment), .anode(anode), .led_sout(led_sout), .seg_sout(seg_sout),
		.ps2Clk(ps2Clk), .ps2Dat(ps2Dat), .uartRx(uartRx), .uartTx(uartTx),
		
		.vgaCtrlReg0(vgaCtrlReg0), .vgaCtrlReg1(vgaCtrlReg1),
		
		.dataInBus(doutDBus), .addrBus(addrDBus), .weBus(dmDBus),
		.en(ioEN), .dataOutBus(ioData), .ps2Int(cpuInterrupt[0]), .uartInt(cpuInterrupt[1]),
		
		.dbg_dat1(addrIBus), .dbg_dat2(dbg_vPC), .dbg_dat3(dinIBus), .dbg_dat4(addrDBus),
		.dbg_dat5(dbg_vAddr), .dbg_dat6(doutDBus), .dbg_dat7(dinDBus),
//		.dbg_flags({dmDBus, stbDBus, progMemEN, cVramEN, gVramEN, ioEN, sdCtrlEN, sdDataEN, cpuInterrupt[4:0]})
		.dbg_flags({dmDBus, stbDBus, stbDDR, cycDDR, weDDR, ackDDR, dbg_ddrState, cpuInterrupt[3:0]})
	);
	assign LED = {stbDBus, stbDDR, cycDDR, weDDR, ackDDR, dbg_ddrState};
	//(* MARK_DEBUG = "true" *)
	wire vga_stb, vga_nak;
	wire [31:0]vga_addr, vga_dout, vga_din;
	wire [3:0]vga_we;
	
	VGADevice #(.GRAPHIC_VRAM(1)) vga(.rst(globlRst), .clkVGA(clkVGA), .clkMem(clkCPU),
        .ctrl0(vgaCtrlReg0), .ctrl1(vgaCtrlReg1),
        .dataInBus(doutDBus), .addrBus(addrDBus), .weBus(dmDBus),
        .en_Char(cVramEN), .dataOut_Char(cVramData),
        .videoOut(VGAColor), .HSync(HSync), .VSync(VSync),
        .wb_stb(vga_stb), .wb_addr(vga_addr),.wb_we(vga_we),.wb_din(vga_din),.wb_dout(vga_dout), .wb_nak(vga_nak));
    assign gVramData = 32'h0;
	
	SDWrapper sdc(.clkCPU(clkCPU), .clkSD(clk_100M), .globlRst(globlRst),
		.dataInBus(doutDBus), .addrBus(addrDBus), .weBus(dmDBus),
		.en_ctrl(sdCtrlEN), .en_data(sdDataEN), .dataOut_ctrl(sdCtrlData),
		.dataOut_data(sdDataData), .sdInt(cpuInterrupt[2]),
		.sd_dat(sdDat), .sd_cmd(sdCmd), .sd_clk(sdClk), .sd_rst(sdRst), .sd_cd(sdCd));
	
	CPUBus bus0(.clk(clkCPU), .rst(globlRst), .masterEN(stbDBus),
		.addrBus(addrDBus), .dataToCPU(dinDBus), .nakDBus(nakDBus),
		.progMemEN(progMemEN), .progMemData(progMemData), .progMemNak(1'b0),
		.cVramEN(cVramEN), .cVramData(cVramData), .cVramNak(1'b0),
		.gVramEN(gVramEN), .gVramData(gVramData), .gVramNak(1'b0),
		.ioEN(ioEN), .ioData(ioData), .ioNak(1'b0),
		.sdCtrlEN(sdCtrlEN), .sdCtrlData(sdCtrlData), .sdCtrlNak(1'b0),
		.sdDataEN(sdDataEN), .sdDataData(sdDataData), .sdDataNak(1'b0),
		.sramEN(ddbusEN), .sramData(ddbusData), .sramNak(ddbusNak));
	
	BiosMem mem0(.clka(clkCPU), .addra(addrDBus[13:2]), .dina(doutDBus),
		.wea(dmDBus), .ena(progMemEN), .douta(progMemData),
		.clkb(~clkCPU), .addrb(addrIBus[13:2]), .dinb(32'h0),
		.web(4'h0), .enb(1'b1), .doutb(dinIBus),
		.clkProg(clk_100M), .uartRx(uartRx), .progEN(globlRst));
	
	DDR3_wsWrapper ddr3(
		.sysclk_p(sysclk_p), .sysclk_n(sysclk_n),
		.clkOut(clkDDR), .rst(globlRst),
		.ws_addr(addrDDR), .ws_din(doutDDR), .ws_dm(dmDDR),
		.ws_cyc(cycDDR), .ws_stb(stbDDR), .ws_we(weDDR),
		.ws_dout(dinDDR), .ws_ack(ackDDR),
		
		.dbg_state(dbg_ddrState),
		
		.ddr3_addr(ddr3_addr),
		.ddr3_ba(ddr3_ba),
		.ddr3_cas_n(ddr3_cas_n),
		.ddr3_ck_n(ddr3_ck_n),
		.ddr3_ck_p(ddr3_ck_p),
		.ddr3_cke(ddr3_cke),
		.ddr3_ras_n(ddr3_ras_n),
		.ddr3_reset_n(ddr3_reset_n),
		.ddr3_we_n(ddr3_we_n),
		.ddr3_dq(ddr3_dq),
		.ddr3_dqs_n(ddr3_dqs_n),
		.ddr3_dqs_p(ddr3_dqs_p),
		.ddr3_cs_n(ddr3_cs_n),
		.ddr3_dm(ddr3_dm),
		.ddr3_odt(ddr3_odt)
	);

	DBusArbiter dbusarb(
	   .clk(clkCPU),
	   .rst(globlRst),
	   //Master 0
	   .addrM0(addrDBus),.doutM0(doutDBus),.stbM0(ddbusEN),.weM0(),
	   .dmM0(dmDBus),.dinM0(ddbusData),.nakM0(ddbusNak),
	   //Master 1
	   .addrM1(vga_addr),.doutM1(vga_din),.stbM1(vga_stb),.weM1(),
       .dmM1(vga_we),.dinM1(vga_dout),.nakM1(vga_nak),
       //slave
       .addrS(sramAddr),.dinS(sramInData),.stbS(sramEN),
       .weS(),.dmS(sram_we),.doutS(sramData),
       .nakS(sramNak)
	);
	
	SRAM sram(
	   .clk(clkCPU),
	   .rst(globlRst),
	   .sram_ce_n(sram_ce_n),
	   .sram_oe_n(sram_oe_n),
	   .sram_we_n(sram_we_n),
	   .sram_ub_n(sram_ub_n),
	   .sram_lb_n(sram_lb_n),
	   .sram_addr(sram_addr),
       .sram_data(sram_data),
       
        // wishbone slave interfaces
        .wb_stb(sramEN),
        .wb_addr(sramAddr),
        .wb_we(sram_we),
        .wb_din(sramInData),
        .wb_dout(sramData),
        .wb_nak(sramNak)
        );

	assign buzzer = 1'b1;

endmodule
