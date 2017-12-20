`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:31:12 08/05/2016 
// Design Name: 
// Module Name:    ReprogInterface 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module ReprogInterface #(
	parameter ADDR_WIDTH = 10
)(
	input clkMem, input [7:0] progData, input progValid, input progEn,
	input [ADDR_WIDTH-1:0] addrIn, input [31:0] dataIn, input [3:0] weIn, input enIn,
	output [ADDR_WIDTH-1:0] addrOut, output [31:0] dataOut, output [3:0] weOut, output enOut
);
	
	reg [ADDR_WIDTH-1:0] addr_internal;
	reg [31:0] data_internal;
	reg we_internal;
	reg [1:0] byteCnt;
	
	assign addrOut = we_internal? addr_internal: addrIn;
	assign dataOut = we_internal? data_internal: dataIn;
	assign weOut = we_internal? 4'hf: weIn;
	assign enOut = progEn? 1'b1: enIn;
	
	always @ (posedge clkMem)
	begin
		if(progEn)
		begin
			if(progValid)
			begin
				if(byteCnt == 2'b11)
				begin
					we_internal <= 1'b1;
					addr_internal <= addr_internal + 1'b1;
				end
				else
					we_internal <= 1'b0;
				data_internal <= {progData, data_internal[31:8]};
				byteCnt <= byteCnt + 1'b1;
			end
			else
				we_internal <= 1'b0;
		end
		else
		begin
			addr_internal <= -1;
			data_internal <= 32'h0;
			we_internal <= 1'b0;
			byteCnt <= 2'b00;
		end
	end

endmodule
