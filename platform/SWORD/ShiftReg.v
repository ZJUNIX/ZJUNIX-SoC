`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:32:48 03/04/2016 
// Design Name: 
// Module Name:    ShiftReg 
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
module ShiftReg #(
	parameter WIDTH = 16,
	parameter DELAY = 12,
	parameter DIRECTION = 1,
	parameter ONTIME = 0,
	parameter inv = 1
)(
	input clk, input [WIDTH-1:0] pdata, output [2:0] sout
);
	wire sck;
	reg sdat;
	reg oe;
	assign sout = {sck, sdat, oe};
	
	reg [WIDTH-1:0] shift = 0;
	reg [DELAY-1:0] counter = -1;
	wire sckEn;
	
//	assign sckEn = DIRECTION? |shift[WIDTH-1:0]: |shift[WIDTH:1];
	assign sckEn = |shift;
//	assign sck = ~clk & sckEn;
	ODDR #(
		.INIT(1'b0)
	) sr_clk_fwd (
		.Q(sck),
		.C(clk),
		.CE(sckEn),
		.D1(1'b0),
		.D2(1'b1),
		.R(1'b0),
		.S(1'b0)
	);
//	assign sdat = DIRECTION? shift[WIDTH]: shift[0];
	
	always @ (posedge clk)
	begin
		if(sckEn)
		begin
			shift <= DIRECTION? {shift[WIDTH-2:0], 1'b0}: {1'b0, shift[WIDTH-1:1]};
			sdat <= DIRECTION? shift[WIDTH-1]: shift[0];
		end
		else
		begin
			if(&counter)
			begin
				shift <= DIRECTION? {pdata[WIDTH-2:0], 1'b1}: {1'b1, pdata[WIDTH-1:1]};
				sdat <= DIRECTION? pdata[WIDTH-1]: pdata[0];
				oe <= 1'b0;
			end
			else
				oe <= (counter > ONTIME);
			counter <= counter + 1'b1;
		end
	end

endmodule
