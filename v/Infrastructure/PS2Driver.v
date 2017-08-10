`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/09/2016 10:13:28 PM
// Design Name: 
// Module Name: PS2Driver
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
module PS2Driver #(
	parameter PARITY = "ODD"
)(
	input clk, input rst, //inout ps2Clk, inout ps2Dat,
	input ps2Clk, input ps2Dat,
	output reg [7:0] dout, input [7:0] din, input send, output ack,
	output reg rxInt, output reg txInt, output reg [2:0] err, output busy
	
);

	localparam STATE_IDLE = 3'h0;
	localparam STATE_RX = 3'h1;
	localparam STATE_TX_INIT = 3'h2;
	localparam STATE_TX = 3'h3;
	localparam STATE_TX_END = 3'h4;
	reg [2:0] state = STATE_IDLE;

	wire frameValid;
	wire [10:0] sendData;

	reg [10:0] byteBuf;
	reg [3:0] count;
	reg [1:0] ps2ClkRecord = 2'b11;
	reg [1:0] send_reg = 2'b00;
	reg [19:0] idleCounter;
	
//	assign ps2Clk = (state == STATE_TX_INIT)? 1'b0: 1'bz;
//	assign ps2Dat = (state == STATE_TX)? (byteBuf[0]? 1'bz: 1'b0): 1'bz;
	assign busy = (state != STATE_IDLE);
	assign ack = (state == STATE_TX_INIT);
	
	localparam ERR_NONE = 3'h0;
	localparam ERR_RX_TIMEOUT = 3'h4;
	localparam ERR_RX_PARITY = 3'h5;
	localparam ERR_TX_TIMEOUT = 3'h6;
	localparam ERR_TX_NOACK = 3'h7;
	
	wire ps2ClkFall = (ps2ClkRecord == 2'b10);
	wire txReq = (send_reg == 2'b01);
	
	always @ (posedge clk)
	begin
		ps2ClkRecord <= {ps2ClkRecord[0], ps2Clk};
		send_reg <= {send_reg[0], send};
		if(rst)
		begin
			state <= STATE_IDLE;
			rxInt <= 1'b0;
			txInt <= 1'b0;
			err <= ERR_NONE;
		end
		else
		begin
			idleCounter <= idleCounter - 1'b1;
			case(state)
			STATE_IDLE: begin
				if(txReq)
				begin
					state <= STATE_TX_INIT;
					idleCounter <= 20'd624;//100us under clkdiv[3]
				end
				else if(ps2ClkFall)
				begin
					state <= STATE_RX;
					idleCounter <= 20'd12_499;//2ms under clkdiv[3]
				end
				if(txReq | ps2ClkFall | (~|idleCounter))
				begin
					rxInt <= 1'b0; txInt <= 1'b0; err <= ERR_NONE;				
				end
			end
			STATE_RX: begin
				if((count == 4'd11) | (~|idleCounter))
				begin
					dout <= byteBuf[8:1];
					rxInt <= 1'b1;
					err <= (count == 4'd11)? (frameValid? ERR_NONE: ERR_RX_PARITY): ERR_RX_TIMEOUT;
					idleCounter <= 20'hfffff;
					state <= STATE_IDLE;
				end
			end
			STATE_TX_INIT: begin
				if(~|idleCounter)
				begin
					state <= STATE_TX;
					idleCounter <= 20'd12_499;//2ms under clkdiv[3]
				end
			end
			STATE_TX: begin
				if(count == 4'd11)
				begin
					state <= STATE_TX_END;
					idleCounter <= 20'd624;
				end
				else if(~|idleCounter)
				begin
					state <= STATE_IDLE;
					txInt <= 1'b1;
					err <= ERR_TX_TIMEOUT;
					idleCounter <= 20'hfffff;
				end
			end
			STATE_TX_END: begin
				if((count == 4'd12) | (~|idleCounter))
				begin
					txInt <= 1'b1;
					state <= STATE_IDLE;
					idleCounter <= 20'hfffff;
					err <= (~|idleCounter | byteBuf[10])? ERR_TX_NOACK: ERR_NONE;
				end
			end
			endcase
			
			if((state == STATE_IDLE) & txReq)
				byteBuf <= sendData;
			else if(ps2ClkFall)
				byteBuf <= {ps2Dat, byteBuf[10:1]};
			
			if(ps2ClkFall)
				count <= count + 1'b1;
			else if(state == STATE_IDLE)
				count <= 4'h0;
		end
	end
	
	
	generate
		if(PARITY == "ODD")
		begin: PARITY_ODD
			assign frameValid = ~byteBuf[0] & byteBuf[10] & ^byteBuf[9:1];
			assign sendData = {~^din, din, 2'b00};
		end
		else if(PARITY == "EVEN")
		begin: PARITY_EVEN
			assign frameValid = ~byteBuf[0] & byteBuf[10] & ~^byteBuf[9:1];
			assign sendData = {^din, din, 2'b00};
		end
		else
		begin: PARITY_NONE
			assign frameValid = ~byteBuf[0] & byteBuf[10];
			assign sendData = {1'b1, din, 2'b00};
		end
	endgenerate
	
endmodule
