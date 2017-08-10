`timescale 1ns / 1ps

/**
 * A simple general-purpose FIFO that can be used as a buffer 
 * between CPU and peripherals, for either input or output.
 * Maximum recommended depth is 256(parameter DEPTH bond to 8),
 * which is the maximun achievable depth within a single slice;
 * use block RAM as FIFO for larger requirements.
 */

module FIFO #(
	parameter WIDTH = 8,
	parameter DEPTH = 5,
	parameter WRITE_TRIGGER = "HIGH",
	parameter READ_TRIGGER = "HIGH"
)(
	input clk, input rst,
	input [WIDTH-1:0] din, input write,
	output [WIDTH-1:0] dout, input read,
	output [DEPTH:0] load, output full, output empty
);
//	localparam MEM_DEPTH = (1 << DEPTH);
	
//	wire writeValid, readValid;
//	reg [1:0] prevWrite, prevRead;
//	reg [DEPTH:0] writePtr, readPtr;
	
//	assign load = writePtr - readPtr;
//	assign full = load[DEPTH];
//	assign empty = (writePtr == readPtr);
	
//	reg [WIDTH-1:0] data[MEM_DEPTH-1:0];
	
//	always @ (posedge clk)
//	begin
//		prevWrite <= {prevWrite[0], write};
//		prevRead <= {prevRead[0], read};
//		if(rst)
//		begin
//			writePtr <= 0;
//			readPtr <= 0;
//		end
//		else
//		begin
//			if(writeValid)
//			begin
//				data[writePtr] <= din;
//				writePtr <= writePtr + 1'b1;
//			end
//			if(readValid)
//				readPtr <= readPtr + 1'b1;
//		end
//	end
//	assign dout = data[readPtr];
	
//	generate
//		case(WRITE_TRIGGER)
//		"HIGH": assign writeValid = write;
//		"LOW": assign writeValid = ~write;
//		"POSEDGE": assign writeValid = ~prevWrite[1] & prevWrite[0];
//		"NEGEDGE": assign writeValid = prevWrite[1] & ~prevWrite[0];
//		endcase
		
//		case(READ_TRIGGER)
//		"HIGH": assign readValid = read;
//		"LOW": assign readValid = ~read;
//		"POSEDGE": assign readValid = ~prevRead[1] & prevRead[0];
//		"NEGEDGE": assign readValid = prevRead[1] & ~prevRead[0];
//		endcase
//	endgenerate

	localparam SR_WIDTH = (1 << DEPTH);
	
	wire writeValid, readValid;
	reg [1:0] prevWrite, prevRead;
	reg [DEPTH:0] _load = -1;
	wire [DEPTH-1:0] addr = _load[DEPTH-1:0];
	
	assign load = _load + 1'b1;
	assign full = load[DEPTH];
	assign empty = _load[DEPTH];
	
	always @ (posedge clk)
	begin
		prevWrite <= {prevWrite[0], write};
		prevRead <= {prevRead[0], read};
		if(rst)
			_load <= -1;
		else if(writeValid != readValid)
		begin
			if(writeValid)
				_load <= _load + 1'b1;
			else
				_load <= _load - 1'b1;
		end
	end
	
	generate
		case(WRITE_TRIGGER)
		"HIGH": assign writeValid = write;
		"LOW": assign writeValid = ~write;
		"POSEDGE": assign writeValid = ~prevWrite[1] & prevWrite[0];
		"NEGEDGE": assign writeValid = prevWrite[1] & ~prevWrite[0];
		endcase
		
		case(READ_TRIGGER)
		"HIGH": assign readValid = read;
		"LOW": assign readValid = ~read;
		"POSEDGE": assign readValid = ~prevRead[1] & prevRead[0];
		"NEGEDGE": assign readValid = prevRead[1] & ~prevRead[0];
		endcase
	endgenerate
	
	genvar i;
	generate
		for(i = 0; i < WIDTH; i = i+1)
		begin: FIFO_1Bit
			reg [SR_WIDTH-1:0] data;
			always @ (posedge clk)
				if(writeValid) data <= {data[SR_WIDTH-2:0], din[i]};
			assign dout[i] = data[addr];
		end
	endgenerate

endmodule
