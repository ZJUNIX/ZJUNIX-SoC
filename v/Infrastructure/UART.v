`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:19:34 08/05/2016 
// Design Name: 
// Module Name:    UART 
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
module UART_R(
	input clk, input Rx,
	output reg [7:0] dout, output reg ready, output reg busy
);

parameter HALF_PERIOD = 434;//baud rate 115200 under 100MHz clock
parameter COUNTER_MSB = 9;

	reg [COUNTER_MSB:0] counter = 0;
	reg [8:0] shift = 9'h0;

	always @ (posedge clk)
	begin
		if(busy)
		begin
			if(counter == HALF_PERIOD * 2 - 1)
			begin
				counter <= 0;
				if(shift[0])
				begin
					dout <= shift[8:1];
					ready <= 1'b1;
					shift <= 8'h0;
					busy <= 1'b0;
				end
				else
					shift <= {Rx, shift[8:1]};
			end
			else
				counter <= counter + 1'b1;
		end
		else
		begin
			if(counter == HALF_PERIOD - 1)
			begin
				busy <= 1'b1;
				shift <= 9'b100000000;
				counter <= 0;
				ready <= 1'b0;
			end
			else
			begin
				if(Rx)
					counter <= 0;
				else
					counter <= counter + 1'b1;
			end
		end
	end

endmodule

module UART_T(
	input clk, output Tx,
	input [7:0] din, input ready, output reg ack, output reg busy
);

parameter PERIOD = 868;
parameter COUNTER_MSB = 9;

	reg [COUNTER_MSB:0] counter = 0;
	reg [9:0] shift;
	
	assign Tx = busy? shift[0]: 1'bz;

	always @ (posedge clk)
	begin
		if(busy)
		begin
			if(counter == PERIOD - 1)
			begin
				counter <= 0;
				if(shift == 10'b0000000001)
				begin
					if(ready)
					begin
						shift <= {1'b1, din, 1'b0};
						ack <= 1'b1;
					end
					else
						busy <= 1'b0;
				end
				else
				begin
					shift <= {1'b0, shift[9:1]};
					ack <= 1'b0;
				end
			end
			else
				counter <= counter + 1'b1;
		end
		else
		begin
			if(ready)
			begin
				shift <= {1'b1, din, 1'b0};
				busy <= 1'b1;
				ack <= 1'b1;
				counter <= 0;
			end
		end
		
	end

endmodule
