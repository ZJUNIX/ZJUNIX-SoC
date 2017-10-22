`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/17/2017 06:37:57 PM
// Design Name: 
// Module Name: CPUCacheTop
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
module CPUCacheTop(
	input clkCPU, input clkDDR, input rst, input [4:0] interrupt,
	//IBus signals, referenced to ~clkCPU
	output [31:0] addrIBus, input [31:0] dinIBus,
	output stbIBus, input nakIBus,
	//DBus signals, referenced to clkCPU
	output [31:0] addrDBus, output [31:0] doutDBus, input [31:0] dinDBus,
	output stbDBus, output [3:0] dmDBus, output weDBus, input nakDBus,
	//DDR memory signals as wishbone master
	output [31:0] addrDDR, output [511:0] doutDDR, input [511:0] dinDDR,
	output stbDDR, output cycDDR, output weDDR, output [63:0] dmDDR, input ackDDR,
	//Debug signals
	output [31:0] dbg_vPC, output [31:0] dbg_vAddr,
	output [31:0] dbg_IDPC, output [31:0] dbg_EXPC, output [31:0] dbg_MEMPC
);

	
	wire iStall, dStall;
	wire iCacheStall, dCacheStall;
	wire ioAddrI, ioAddrD;
	reg ioAddrD_reg;
	wire [31:0] cpuInstIn, cpuDataIn;
	wire [31:0] iCacheOut, dCacheOut;
	wire [31:0] addrIBusMapped, addrDBusMapped;
	wire instStb, memStb;
	wire iCacheOp, dCacheOp;
	
	wire [31:0] dbg_dcacheWay0, dbg_dcacheWay1;
	
	PCPU cpu(.clk(clkCPU), .rst(rst), .iStall(iStall), .dStall(dStall),
		.iBusAddr(addrIBus), .iBusAddrMapped(addrIBusMapped),
		.instReq(instStb), .IOAddrI(ioAddrI), .instIn(cpuInstIn),
		.dBusAddr(addrDBus), .dBusAddrMapped(addrDBusMapped),
		.memReq(memStb), .IOAddrD(ioAddrD), .dataOut(doutDBus),
		.dataMask(dmDBus), .memWE(weDBus), .dataIn(cpuDataIn),
		.iCacheOp(iCacheOp), .dCacheOp(dCacheOp),
		.INT(interrupt),
		.dbg_vPC(dbg_vPC), .dbg_vAddr(dbg_vAddr),
		.dbg_IDPC(dbg_IDPC), .dbg_EXPC(dbg_EXPC), .dbg_MEMPC(dbg_MEMPC));

	always @ (posedge clkCPU)
		if(~dStall) ioAddrD_reg <= ioAddrD;
	
	assign cpuInstIn = ioAddrI? dinIBus: iCacheOut;
	assign cpuDataIn = ioAddrD_reg? dinDBus: dCacheOut;
	assign stbIBus = instStb & ioAddrI;
	assign stbDBus = memStb & ioAddrD;
	assign iStall = iCacheStall | nakIBus;
	assign dStall = dCacheStall | nakDBus;
	
	wire [31:0] ws_addr_m0, ws_addr_m1;
	wire [511:0] ws_dout_m0, ws_dout_m1, ws_din_m0, ws_din_m1;
	wire [63:0] ws_dm_m0, ws_dm_m1;
	wire ws_cyc_m0, ws_cyc_m1;
	wire ws_stb_m0, ws_stb_m1;
	wire ws_we_m0, ws_we_m1;
	wire ws_ack_m0, ws_ack_m1;

	ICache icache(.clkCPU(clkCPU), .clkDDR(clkDDR), .rst(rst),
		.PCIn(addrIBusMapped), .req(instStb & ~ioAddrI), .instOut(iCacheOut), .iStall(iCacheStall),
		.invalidateAddr(addrDBusMapped), .invalidateReq(iCacheOp),
		.ws_addr(ws_addr_m0), .ws_din(ws_din_m0), .ws_cyc(ws_cyc_m0),
		.ws_stb(ws_stb_m0), .ws_ack(ws_ack_m0));
	assign ws_dout_m0 = 128'h0;
	assign ws_dm_m0 = 16'h0;
	assign ws_we_m0 = 1'b0;
	
	DCache dcache(.clkCPU(clkCPU), .clkDDR(clkDDR), .rst(rst),
		.addrIn(addrDBusMapped), .req(memStb & ~ioAddrD), .dataIn(doutDBus),
		.dm(dmDBus), .we(weDBus), .dataOut(dCacheOut), .dStall(dCacheStall), .invalidate(dCacheOp),
		.ws_addr(ws_addr_m1), .ws_dout(ws_dout_m1), .ws_dm(ws_dm_m1),
		.ws_we(ws_we_m1), .ws_cyc(ws_cyc_m1), .ws_stb(ws_stb_m1), .ws_ack(ws_ack_m1),
		.ws_din(ws_din_m1)
	);
	
	//Wishbone Arbiter logic
	//Master data output(Slave input) not multiplexed, since only DCache actually will output data
	reg wsMaster = 1'b0;
	always @ (posedge clkDDR)
	begin
		if(rst)
			wsMaster <= 1'b0;
		else if(~cycDDR)
			wsMaster <= ~wsMaster;
	end
	assign cycDDR  = wsMaster? ws_cyc_m1 : ws_cyc_m0;
	assign stbDDR  = wsMaster? ws_stb_m1 : ws_stb_m0;
	assign weDDR   = wsMaster? ws_we_m1  : ws_we_m0;
	assign addrDDR = wsMaster? ws_addr_m1: ws_addr_m0;
	assign dmDDR   = ws_dm_m1;
	assign doutDDR  = ws_dout_m1;
	assign ws_din_m0 = dinDDR;
	assign ws_din_m1 = dinDDR;
	assign ws_ack_m0 = ackDDR & ~wsMaster;
	assign ws_ack_m1 = ackDDR &  wsMaster;

//	dbgModule dbg(.clk(clkCPU),
//		.probe0(addrIBus), .probe1(cpuInstIn),
//		.probe2(addrDBus), .probe3(cpuDataIn), .probe4(doutDBus),
//		.probe5(dmDBus),
//		.probe6(memStb), .probe7(dCacheStall), .probe8(iCacheStall),
//		.probe9(dbg_dcacheWay0), .probe10(dbg_dcacheWay1)
//	);
	
//	dbgModule dbg(.clk(clkDDR),
//		.probe0(addrDDR), .probe1(dinDDR), .probe2(doutDDR), .probe3(dmDDR),
//		.probe4(cycDDR), .probe5(stbDDR), .probe6(weDDR), .probe7(ackDDR));

endmodule
