`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/27/2016 08:17:26 PM
// Design Name: 
// Module Name: DDR3_wsWrapper
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
module DDR2_wsWrapper(
	input clkIn, input rst, output clkOut,
	//Wishbone slave interface
	input [31:0] ws_addr, input [511:0] ws_din,
	input [63:0] ws_dm, input ws_cyc, input ws_stb, input ws_we,
	output reg ws_ack, output [511:0] ws_dout,
	
	//debug signals
	output [2:0] dbg_state, //output [7:0] dbg_signal,
	
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
	wire sysClk, refClk;
	ClockGen_DDR clockGen(.clk_in1(clkIn), .sysClk(sysClk), .refClk(refClk));
	
	localparam MEM_READ = 3'b001;
	localparam MEM_WRITE = 3'b000;
	
	reg [20:0] addr_reg;
	reg [1:0] addrLow = 2'b00;
	reg [511:0] rdData;
	reg [511:0] wrData;
	reg [63:0] wrDm;
	
	localparam STATE_READY = 3'b000;
	localparam STATE_READ = 3'b001;
	localparam STATE_READ_WAIT = 3'b010;
	localparam STATE_WRITE_DATA = 3'b011;
	localparam STATE_WRITE_CMD = 3'b100;
	localparam STATE_WS_END = 3'b111;
	reg [2:0] state = STATE_READY;
	
	wire [26:0] app_addr;
	wire [2:0] app_cmd;
	wire app_en;
	wire app_rdy;
	
	reg [127:0] app_wdf_data;
	reg [15:0] app_wdf_mask;
	wire app_wdf_end;
	wire app_wdf_wren;
	wire app_wdf_rdy;
	
	wire [127:0] app_rd_data;
	wire app_rd_data_valid;
	
	always @ (posedge clkOut)
	case(state)
	STATE_READY: begin
		addrLow <= 2'b00;
		if(ws_cyc & ws_stb)
		begin
			addr_reg <= ws_addr[26:6];
			if(ws_we)
			begin
				state <= STATE_WRITE_DATA;
				wrData <= ws_din;
				wrDm <= ws_dm;
				ws_ack <= 1'b1;
			end
			else
				state <= STATE_READ;
		end
	end
	STATE_WRITE_DATA: begin
		ws_ack <= 1'b0;
		if(app_wdf_rdy)
		begin
			addrLow <= addrLow + 1'b1;
			if(addrLow == 2'b11)
				state <= STATE_WRITE_CMD;
		end
	end
	STATE_WRITE_CMD: begin
		if(app_rdy)
		begin
			addrLow <= addrLow + 1'b1;
			if(addrLow == 2'b11)
				state <= STATE_READY;
		end
	end
	STATE_READ: begin
		if(app_rdy)
		begin
			addrLow <= addrLow + 1'b1;
			if(addrLow == 2'b11)
				state <= STATE_READ_WAIT;
		end
	end
	STATE_READ_WAIT: begin
		if(app_rd_data_valid)
		begin
			addrLow <= addrLow + 1'b1;
			rdData <= {app_rd_data, rdData[511:128]};
			if(addrLow == 2'b11)
			begin
				state <= STATE_WS_END;
				ws_ack <= 1'b1;
			end
		end
	end
	STATE_WS_END: begin
		ws_ack <= 1'b0;
		state <= STATE_READY;
	end
	default: state <= STATE_READY;
	endcase
	
	assign app_en = (state == STATE_WRITE_CMD) | (state == STATE_READ);
	assign app_wdf_wren = (state == STATE_WRITE_DATA);
	assign app_wdf_end = app_wdf_wren;
	assign app_cmd = (state == STATE_WRITE_CMD)? MEM_WRITE: MEM_READ;
//	assign app_addr = {addr_reg, addrLow, 4'h0};
	assign app_addr = {1'b0, addr_reg, addrLow, 3'h0};//This might be an issue in the MIG core
	
	assign ws_dout = rdData;
	
	always @*
	case(addrLow)
	2'b00: begin app_wdf_data <= wrData[127:  0]; app_wdf_mask <= wrDm[15: 0]; end
	2'b01: begin app_wdf_data <= wrData[255:128]; app_wdf_mask <= wrDm[31:16]; end
	2'b10: begin app_wdf_data <= wrData[383:256]; app_wdf_mask <= wrDm[47:32]; end
	2'b11: begin app_wdf_data <= wrData[511:384]; app_wdf_mask <= wrDm[63:48]; end
	endcase
	
	DDR ddr_inst(
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
		.ddr2_odt(ddr2_odt),
		.init_calib_complete(init_calib_comp),

		.app_addr(app_addr),
		.app_cmd(app_cmd),
		.app_en(app_en),
		.app_rdy(app_rdy),

		.app_wdf_data(app_wdf_data),
		.app_wdf_end(app_wdf_end),
		.app_wdf_wren(app_wdf_wren),
	    .app_wdf_mask(~app_wdf_mask),
		.app_wdf_rdy(app_wdf_rdy),

		.app_rd_data(app_rd_data),
		.app_rd_data_end(),
		.app_rd_data_valid(app_rd_data_valid),

		.app_sr_req(1'b0),
		.app_ref_req(1'b0),
		.app_zq_req(1'b0),
		.app_sr_active(),
		.app_ref_ack(),
		.app_zq_ack(),

		.sys_clk_i(sysClk),
		.clk_ref_i(refClk),
		.ui_clk(clkOut),
		.sys_rst(0),
		.ui_clk_sync_rst()
	);
	
	assign dbg_state = state;
	
//	dbgModule dbg(.clk(clkOut),
//		.probe0(app_addr), .probe1(app_cmd), .probe2(app_en), .probe3(app_rdy),
//		.probe4(app_wdf_wren), .probe5(app_wdf_rdy), .probe6(app_rd_data_valid),
//		.probe7(state), .probe8(ws_cyc), .probe9(ws_stb), .probe10(ws_we),
//		.probe11(ws_ack), .probe12(app_rd_data), .probe13(app_wdf_data));
	
endmodule
