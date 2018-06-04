`timescale 1ns / 1ps

module DBusArbiter (
	input clk, input rst,
	//Master 0
	input [31:0] addrM0, input [31:0] doutM0,
	input stbM0, input weM0, input [3:0] dmM0,
	output [31:0] dinM0, output nakM0,
	//Master 1
	input [31:0] addrM1, input [31:0] doutM1,
	input stbM1, input weM1, input [3:0] dmM1,
	output [31:0] dinM1, output nakM1,
	//Slave
	output [31:0] addrS, output [31:0] dinS,
	output stbS, output weS, output [3:0] dmS,
	input [31:0] doutS, input nakS
);
    //(* MARK_DEBUG = "true" *)
	reg master = 0;//control addr din dm to Slave
	//(* MARK_DEBUG = "true" *)
	reg nakMaster = 0;//control nak to M0 or M1

	reg [68:0] m0Reg, m1Reg;
	reg stbM0Reg, stbM1Reg;//Master has a waiting request
	
	always @ (posedge clk)
	begin
		if(!nakM0) m0Reg <= {addrM0, doutM0, weM0, dmM0};
		if(!nakM1) m1Reg <= {addrM1, doutM1, weM1, dmM1};
		if(~stbS & ~nakS) master <= !master;//master:nakS0 -> nakS1 -> nakS0
	end
	
	assign stbS = master? (stbM1 || stbM1Reg): (stbM0 || stbM0Reg);
	
	assign {addrS, dinS, weS, dmS} = master?
		(stbM1Reg? m1Reg: {addrM1, doutM1, weM1, dmM1}):
		(stbM0Reg? m0Reg: {addrM0, doutM0, weM0, dmM0});
	
	assign dinM0 = doutS;
	assign dinM1 = doutS;
	
	always @ (posedge clk)
	begin
		if(!nakS) nakMaster <= master;//nakMaster:nakS1->nakS0
		
		if(stbM0 && master != 0)//have to wait
			stbM0Reg <= 1;//no mantter how nakS is
		else if(!nakS && master == 0)//start to handle
			stbM0Reg <= 0;//give handle to nakS
		
		if(stbM1 && master != 1)//have to wait
			stbM1Reg <= 1;
		else if(!nakS && master == 1)//sart to handle
			stbM1Reg <= 0;
	end
	
	assign nakM0 = stbM0Reg || (nakMaster == 0 && nakS);
	assign nakM1 = stbM1Reg || (nakMaster == 1 && nakS);
	
	
endmodule

module DBusArbiter_sim();

	reg clk = 0; reg rst = 0;
	//Master 0
	reg [31:0] addrM0 = 32'h01234567;
	reg [31:0] doutM0 = 32'h01234567;
	reg stbM0 = 0;
	reg weM0 = 1;
	reg [3:0] dmM0 = 4'b1011;
	wire [31:0] dinM0;
	wire nakM0;
	//Master 1
	reg [31:0] addrM1 = 32'h89abcdef;
	reg [31:0] doutM1 = 32'h89abcdef;
	reg stbM1 = 0;
	reg weM1 = 1;
	reg [3:0] dmM1 = 4'b1101;
	wire [31:0] dinM1;
	wire nakM1;
	//Slave
	wire [31:0] addrS, dinS;
	wire stbS, weS;
	wire [3:0] dmS;
	reg [31:0] doutS = 32'h76543210;
	reg nakS = 0;

	DBusArbiter uut(
	clk, rst,
	//Master 0
	addrM0, doutM0,
	stbM0, weM0, dmM0,
	dinM0, nakM0,
	//Master 1
	addrM1, doutM1,
	stbM1, weM1, dmM1,
	dinM1, nakM1,
	//Slave
	addrS, dinS,
	stbS, weS, dmS,
	doutS, nakS);
	
	initial forever #5 clk = !clk;
	
	initial begin
		#55.1;
		stbM0 = 1;
		#10;
		stbM0 = 0;
		nakS = 1;
		#10
		stbM1 = 1;
		#10;
		stbM1 = 0;
		#40;
		nakS = 0; doutS = 32'hffffeeee;
		#20;
		nakS = 1;
		#40;
		nakS = 0; doutS = 32'hddddcccc;
	
	end


endmodule



