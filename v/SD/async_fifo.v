`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/17/2016 01:12:46 AM
// Design Name: 
// Module Name: async_fifo
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
module async_fifo #(
	parameter dw = 16,
	parameter aw = 8
)(
	input rd_clk, input wr_clk, input rst, input clr,
	input [dw-1:0] din, input we,
	output reg [dw-1:0] dout, input re,
	output full, output empty, output [1:0] wr_level, output [1:0] rd_level
);
	localparam DEPTH = 1 << aw;
	reg [dw-1:0] data[DEPTH-1:0];
	
	//rd_clk clock domain logic
	reg [aw:0] rd_ptr, wr_ptr_sync;
	wire [aw:0] rd_level_internal;
	always @ (posedge rd_clk)
	begin
		if(!rst)
			rd_ptr <= 0;
		else if(re)
			rd_ptr <= rd_ptr + 1;
		dout <= data[rd_ptr[aw-1:0]];
	end
	assign empty = (rd_ptr == wr_ptr_sync);
	assign rd_level = rd_level_internal[aw-1:aw-2];
	assign rd_level_internal = wr_ptr_sync - rd_ptr;
//	assign dout = data[rd_ptr[aw-1:0]];
	
	//wr_clk clock domain logic
	reg [aw:0] wr_ptr, rd_ptr_sync;
	wire [aw:0] wr_level_internal;
	always @ (posedge wr_clk)
	begin
		if(we) data[wr_ptr[aw-1:0]] <= din;
		
		if(!rst)
			wr_ptr <= 0;
		else if(we)
			wr_ptr <= wr_ptr + 1;
	end
	assign full = (wr_ptr[aw-1:0] == rd_ptr_sync[aw-1:0]) & (wr_ptr[aw] != rd_ptr_sync[aw]);
	assign wr_level = wr_level_internal[aw-1:aw-2];
	assign wr_level_internal = wr_ptr - rd_ptr_sync;
	
	//Sync logic
	always @ (posedge rd_clk)
		wr_ptr_sync <= wr_ptr;
	always @ (posedge wr_clk)
		rd_ptr_sync <= rd_ptr;
endmodule
