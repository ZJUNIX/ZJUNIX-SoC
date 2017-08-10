`timescale 1ns / 1ps

module Div_CPU(
		input wire clk,
		input wire rst,
		input wire [31:0] a,
		input wire [31:0] b,
		output wire [31:0] q,
		output wire [31:0] r,
		output reg done
 	);
	
//	reg [5:0] state; 
//	reg [63:0] temp;
//	reg [31:0] divider;
	
//	wire [31:0] remain = temp[62:31] - divider;
	
//	always @(posedge clk) begin
//		if (rst) begin
//			divider <= b;
//			temp <= {32'b0, a};
//			if (b!=32'b0) begin
//				state <= 6'b0;
//				done <= 0;
//			end else begin
//				state <= 6'b111111;
//				done <= 1;
//			end
//		end else begin
//			if (state[5] == 0) begin
//				state <= state + 1'b1;
//				temp <= (temp[62:31]>=divider) ? {remain[31:0], temp[30:0], 1'b1} : {temp[62:0], 1'b0};
//			end else begin
//				done <= 1;
//			end
//		end
//	end
	
//	assign q = temp[31:0]; 
//	assign r = temp[63:32];
//---
	reg [4:0] state;
	reg [63:0] work;
	reg [31:0] divider;
	wire [31:0] remain = work[62:31] - divider;

	always @ (posedge clk)
	begin
		if(rst)
		begin
			divider <= b;
			work <= {32'h0, a};
			done <= (b == 32'h0);
			state <= 5'h0;
		end
		else if(~done)
		begin
			done <= &state;
			work <= remain[31]? {work[62:0], 1'b0}: {remain[31:0], work[30:0], 1'b1};
			state <= state + 1'b1;
		end
	end
	assign q = work[31:0];
	assign r = work[63:32];

//	reg [3:0] state;
//	reg [31:0] divider;
//	reg [63:0] work0;
//	wire [63:0] work1, nextWork0;
//	wire [31:0] remain0 = work0[62:31] - divider;
//	wire [31:0] remain1 = work1[62:31] - divider;
//	assign work1 = remain0[31]? {work0[62:0], 1'b0}: {remain0[31:0], work0[30:0], 1'b1};
//    assign nextWork0 = remain1[31]? {work1[62:0], 1'b0}: {remain1[31:0], work1[30:0], 1'b1};
//    assign q = work1[31:0];
//    assign r = work1[63:32];
    
//    always @ (posedge clk)
//    begin
//    	if(rst)
//    	begin
//    		divider <= b;
//    		work0 <= {32'h0, a};
//    		done <= (b == 32'h0);
//    		state <= 4'h0;
//    	end
//    	else if(~done)
//    	begin
//    		done <= &state;
//    		work0 <= nextWork0;
//    		state <= state + 1'b1;
//    	end
//    end
    
	
endmodule
