`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/05/2017 02:02:02 AM
// Design Name: 
// Module Name: ResetGen
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
module ResetGen #(
	parameter NUM_CLOCKS = 1,
	parameter FILTER_BITS = 22
)(
	input [NUM_CLOCKS-1:0] clk, input rstIn,
	input mmcmLocked, output [NUM_CLOCKS-1:0] rstOut
);
	
	reg [FILTER_BITS-1:0] filterCounter = 0;
	reg rstFiltered = 1'b1;
	always @ (posedge clk[0] or posedge rstIn)
	if(rstIn)
		filterCounter <= 0;
	else if(~&filterCounter & mmcmLocked)
		filterCounter <= filterCounter + 1'b1;
	always @ (posedge clk[0] or negedge mmcmLocked)
	if(~mmcmLocked)
		rstFiltered <= 1'b1;
	else
		rstFiltered <= ~&filterCounter;
	
	
	genvar i;
	generate for(i = 0; i < NUM_CLOCKS; i = i+1)
	begin:RST_SYNC
		reg rst_reg = 1'b1;
		always @ (posedge clk[i] or negedge mmcmLocked)
		if(~mmcmLocked)
			rst_reg <= 1'b1;
		else
			rst_reg <= rstFiltered;
		assign rstOut[i] = rst_reg;
	end
	endgenerate
	
endmodule
