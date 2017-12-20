`timescale 1ns / 1ps

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

module AxisFifo #(
	parameter WIDTH = 8,
	parameter DEPTH_BITS = 7,
	parameter SYNC_STAGE_I = 0,
	parameter SYNC_STAGE_O = 1
) (
	input rst,
	input s_clk, input s_valid, output s_ready,
	input [WIDTH-1:0] s_data, output [DEPTH_BITS-1:0] s_load,
	input m_clk, output m_valid, input m_ready,
	output reg [WIDTH-1:0] m_data, output [DEPTH_BITS-1:0] m_load
);
	localparam DEPTH = 1 << DEPTH_BITS;
	reg [WIDTH-1:0] data[DEPTH-1:0];
	
	//s_clk(write) domain logic
	reg [DEPTH_BITS-1:0] wrPtr = 0;
	wire [DEPTH_BITS-1:0] rdPtrSync;
	always @ (posedge s_clk)
	if(rst)
		wrPtr <= {DEPTH_BITS{1'b0}};
	else if(s_valid & s_ready)
	begin
		wrPtr <= wrPtr + 1'b1;
		data[wrPtr] <= s_data;
	end
	assign s_ready = (wrPtr + 1) != rdPtrSync;
	assign s_load = wrPtr - rdPtrSync;
	
	//m_clk(read) domain logic
	reg [DEPTH_BITS-1:0] rdPtr = 0;
	wire [DEPTH_BITS-1:0] wrPtrSync;
	always @ (posedge m_clk)
	if(rst)
		rdPtr = {DEPTH_BITS{1'b0}};
	else
	begin
		if(m_valid & m_ready)
			rdPtr = rdPtr + 1'b1;
		m_data <= data[rdPtr];
	end
	assign m_valid = (rdPtr != wrPtrSync);
	assign m_load = wrPtrSync - rdPtr;
	
	ClockDomainCross #(.I_REG(SYNC_STAGE_I), .O_REG(SYNC_STAGE_O))
		rdPtrCross[DEPTH_BITS-1:0] (.clki(m_clk), .clko(s_clk), .i(rdPtr), .o(rdPtrSync));

	ClockDomainCross #(.I_REG(SYNC_STAGE_I), .O_REG(SYNC_STAGE_O))
		wrPtrCross[DEPTH_BITS-1:0] (.clki(s_clk), .clko(m_clk), .i(wrPtr), .o(wrPtrSync));
	
endmodule
