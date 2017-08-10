`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/22/2016 04:57:20 PM
// Design Name: 
// Module Name: PS2Wrapper
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
module PS2Wrapper #(
	parameter DEPTH = 5
)(
	input clk, input clkdiv3, input rst,
	input [31:0] din, input [3:0] we, input en, input sel,
	output [7:0] datRegOut, output [31:0] ctrlRegOut,
	output interrupt,
//	inout ps2Clk, inout ps2Dat
	input ps2Clk, input ps2Dat
);
	
	
	wire [7:0] ps2Din, ps2Dout;
	wire txBufRead, rxBufWe;
	wire txBufWe, rxBufRead;
	wire txEmpty, rxFull;
	wire rxInt, txAck, ps2Busy;
	reg intEn;

	FIFO #(.WIDTH(8), .DEPTH(DEPTH), .WRITE_TRIGGER("HIGH"), .READ_TRIGGER("POSEDGE"))
		ps2TxBuffer(.clk(clk), .rst(rst), .din(din[7:0]), .write(txBufWe),
		.dout(ps2Din), .read(txBufRead), .load(ctrlRegOut[13:8]),
		.full(), .empty(txEmpty));
	FIFO #(.WIDTH(8), .DEPTH(DEPTH), .WRITE_TRIGGER("POSEDGE"), .READ_TRIGGER("HIGH"))
		ps2RxBuffer(.clk(clk), .rst(rst), .din(ps2Dout), .write(rxBufWe),
		.dout(datRegOut), .read(rxBufRead), .load(ctrlRegOut[5:0]),
		.full(rxFull), .empty());
	
	PS2Driver #(.PARITY("NONE")) U0(.clk(clkdiv3), .rst(rst), .ps2Clk(ps2Clk), .ps2Dat(ps2Dat),
		.dout(ps2Dout), .din(ps2Din), .send(~txEmpty & ~ps2Busy), .ack(txAck),
		.rxInt(rxInt), .txInt(), .err(ctrlRegOut[18:16]), .busy(ps2Busy));
	
	assign txBufRead = txAck;
	assign rxBufWe = rxInt;
	assign txBufWe = we[0] & en & ~sel;
	assign rxBufRead = ~|we & en & ~sel;
	
	assign interrupt = (intEn & rxInt) | rxFull;
//	assign interrupt = 1'b0;
	
	always @ (posedge clk)
	begin
		if(rst)
			intEn <= 1'b1;
		else if(we[3] & en & sel)
			intEn <= din[31];
	end
	
	assign ctrlRegOut[31] = intEn;
	assign ctrlRegOut[30:19] = 0;
	assign ctrlRegOut[15:14] = 0;
	assign ctrlRegOut[7:6] = 0;
	
endmodule
