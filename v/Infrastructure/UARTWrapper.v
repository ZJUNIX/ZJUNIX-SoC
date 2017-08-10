`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/22/2016 06:56:16 PM
// Design Name: 
// Module Name: UARTWrapper
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
module UARTWrapper #(
	parameter DEPTH = 7
)(
	input clk, input clkUART, input rst,
	input [31:0] din, input [3:0] we, input en, input sel,
	output [7:0] datRegOut, output [31:0] ctrlRegOut,
	output interrupt,
	input uartRx, output uartTx
);
	
	
	wire [7:0] uartDin, uartDout;
	wire [7:0] uartDin_sync, uartDout_sync;
	wire txBufRead, rxBufWe;
	wire txBufWe, rxBufRead;
	wire txEmpty, rxFull;
	wire clkUART_gen;
	wire rxInt, rxInt_sync;
	wire rxBusy, txAck, txBusy;
	wire txEmpty_sync, txAck_sync;

	reg intEn;
	reg [2:0] baudReg;
	wire [2:0] baudReg_sync;
	

	FIFO #(.WIDTH(8), .DEPTH(DEPTH), .WRITE_TRIGGER("HIGH"), .READ_TRIGGER("POSEDGE"))
		uartTxBuffer(.clk(clk), .rst(rst), .din(din[7:0]), .write(txBufWe),
		.dout(uartDin), .read(txBufRead), .load(ctrlRegOut[15:8]),
		.full(), .empty(txEmpty));
	FIFO #(.WIDTH(8), .DEPTH(DEPTH), .WRITE_TRIGGER("POSEDGE"), .READ_TRIGGER("HIGH"))
		uartRxBuffer(.clk(clk), .rst(rst), .din(uartDout), .write(rxBufWe),
		.dout(datRegOut), .read(rxBufRead), .load(ctrlRegOut[7:0]),
		.full(rxFull), .empty());
	
	UART_R #(.HALF_PERIOD(125), .COUNTER_MSB(7)) rx(.clk(clkUART_gen), .Rx(uartRx),
		.dout(uartDout_sync), .ready(rxInt_sync), .busy(rxBusy));
	UART_T #(.PERIOD(250), .COUNTER_MSB(7)) tx(.clk(clkUART_gen), .Tx(uartTx),
		.din(uartDin_sync), .ready(~txEmpty_sync), .ack(txAck_sync), .busy(txBusy));
	
	ClockDomainCross #(1, 1) dc0[7:0](.clki(clkUART_gen), .clko(clk), .i(uartDout_sync), .o(uartDout));
	ClockDomainCross #(1, 1) dc1[7:0](.clki(clk), .clko(clkUART_gen), .i(uartDin), .o(uartDin_sync));
	ClockDomainCross #(1, 1) dc2(.clki(clkUART_gen), .clko(clk), .i(txAck_sync), .o(txAck));
	ClockDomainCross #(1, 1) dc4(.clki(clk), .clko(clkUART_gen), .i(txEmpty), .o(txEmpty_sync));
	ClockDomainCross #(1, 1) dc5(.clki(clkUART_gen), .clko(clk), .i(rxInt_sync), .o(rxInt));
	ClockDomainCross #(1, 1) dc7[2:0](.clki(clk), .clko(clkUART), .i(baudReg), .o(baudReg_sync));
	
	assign txBufRead = txAck;
	assign rxBufWe = rxInt;
	assign txBufWe = we[0] & en & ~sel;
	assign rxBufRead = ~|we & en & ~sel;
	
	assign interrupt = (intEn & rxInt) | rxFull;
	
	always @ (posedge clk)
	begin
		if(rst)
		begin
			intEn <= 1'b1;
			baudReg <= 3'h0;
		end
		else if(en & sel)
		begin
			if(we[3])
				intEn <= din[31];
			if(we[2])
				baudReg <= din[18:16];
		end
	end
	
	assign ctrlRegOut[31] = intEn;
	assign ctrlRegOut[30:19] = 0;
	assign ctrlRegOut[18:16] = baudReg;
	
	UART_clkDivider C0(.clk(clkUART), .sel(baudReg_sync), .uartBusy(rxBusy | txBusy), .uartClk(clkUART_gen));
	
endmodule

module UART_clkDivider(
	input clk,
	input [2:0] sel, input uartBusy,
	output reg uartClk = 0
);
	reg [7:0] counter = 0;
	reg [7:0] cntLimit = 0;
	
	always @ (posedge clk)
	begin
		if(~uartBusy)
		begin
			case(sel)
			3'h0: cntLimit <= 9'd0;//115200
			3'h1: cntLimit <= 9'd1;//57600
			3'h2: cntLimit <= 9'd2;//38400
			3'h3: cntLimit <= 9'd5;//19200
			3'h4: cntLimit <= 9'd11;//9600
			3'h5: cntLimit <= 9'd23;//4800
			3'h6: cntLimit <= 9'd47;//2400
			3'h7: cntLimit <= 9'd95;//1200
			endcase
		end
		if(~|counter)
		begin
			uartClk <= ~uartClk;
			counter <= cntLimit;
		end
		else
			counter <= counter - 1'b1;
	end

endmodule