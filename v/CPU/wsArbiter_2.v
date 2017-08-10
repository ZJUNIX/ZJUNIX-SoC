`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/27/2016 08:18:27 PM
// Design Name: 
// Module Name: wsArbiter_2
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
module wsArbiter_2 #(
	parameter ADDR_WIDTH = 32,
	parameter DATA_WIDTH = 256,
	parameter DM_WIDTH = 32
)(
	input clk, input rst,
	//Master #0
	input [ADDR_WIDTH-1:0] ws_addr_m0, input [DATA_WIDTH-1:0] ws_dout_m0,
	input [DM_WIDTH-1:0] ws_dm_m0, input ws_cyc_m0, input ws_stb_m0, input ws_we_m0,
	output ws_ack_m0, output [DATA_WIDTH-1:0] ws_din_m0,
	//Master #1
	input [ADDR_WIDTH-1:0] ws_addr_m1, input [DATA_WIDTH-1:0] ws_dout_m1,
	input [DM_WIDTH-1:0] ws_dm_m1, input ws_cyc_m1, input ws_stb_m1, input ws_we_m1,
	output ws_ack_m1, output [DATA_WIDTH-1:0] ws_din_m1,
	//Slave
	output [ADDR_WIDTH-1:0] ws_addr_s, output [DATA_WIDTH-1:0] ws_din_s,
	output [DM_WIDTH-1:0] ws_dm_s, output ws_cyc_s, output ws_stb_s, output ws_we_s,
	input ws_ack_s, input [DATA_WIDTH-1:0] ws_dout_s
);
	
	reg master = 1'b0;
	
	assign ws_cyc_s  = master? ws_cyc_m1 : ws_cyc_m0;
	assign ws_stb_s  = master? ws_stb_m1 : ws_stb_m0;
	assign ws_we_s   = master? ws_we_m1  : ws_we_m0;
	assign ws_dm_s   = master? ws_dm_m1  : ws_dm_m0;
	assign ws_din_s  = master? ws_dout_m1: ws_dout_m0;
	assign ws_addr_s = master? ws_addr_m1: ws_addr_m0;
	assign ws_din_m0 = ws_dout_s;
	assign ws_din_m1 = ws_dout_s;
	assign ws_ack_m0 = ws_ack_s & ~master;
	assign ws_ack_m1 = ws_ack_s & master;
	
	always @ (posedge clk)
	begin
		if(rst)
			master <= 1'b0;
		else if(~ws_cyc_s)
			master <= ~master;
	end
	
endmodule
