`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:46:40 05/05/2016 
// Design Name: 
// Module Name:    InstDecoder 
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
`define RI 32
`define FWD 31:30
`define ALUA 29:28
`define ALUB 27:26
`define B 25:24
`define BCOND 23:21
`define ALU 20:17
`define MUL 16:13
`define ALUVALID 12
`define MULWAIT 11
`define TRAP 10:8
`define WBDEST 7:6
`define WBSRC 5:3
`define WBCOND 2:0

module Op0Decoder(
	input [5:0] func, output reg [32:0] signals
);
	always @*
		case(func)
		//------------------------RI  ALUA   B      ALU      ALUV TRAP   WBS
		//------------------------  FWD  ALUB  BCOND     MUL   MULW   WBD    WBC
		6'b000000: signals <= 33'b0_01_10_01_00_111_1100_0000_1_0_000_11_000_000;
		6'b000010: signals <= 33'b0_01_10_01_00_111_1110_0000_1_0_000_11_000_000;
		6'b000011: signals <= 33'b0_01_10_01_00_111_1111_0000_1_0_000_11_000_000;
		6'b000100: signals <= 33'b0_11_01_01_00_111_1100_0000_1_0_000_11_000_000;
		6'b000110: signals <= 33'b0_11_01_01_00_111_1110_0000_1_0_000_11_000_000;
		6'b000111: signals <= 33'b0_11_01_01_00_111_1111_0000_1_0_000_11_000_000;
		6'b001000: signals <= 33'b0_10_00_00_10_111_1100_0000_0_0_000_00_000_000;
		6'b001001: signals <= 33'b0_10_11_00_10_111_0101_0000_1_0_000_11_000_000;
		6'b001010: signals <= 33'b0_11_01_00_00_111_0101_0000_1_0_000_11_000_100;
		6'b001011: signals <= 33'b0_11_01_00_00_111_0101_0000_1_0_000_11_000_101;
		6'b010000: signals <= 33'b0_00_00_00_00_111_1100_0000_0_1_000_11_010_000;
		6'b010001: signals <= 33'b0_10_01_00_00_111_1100_0110_0_1_000_00_000_000;
		6'b010010: signals <= 33'b0_00_00_00_00_111_1100_0000_0_1_000_11_011_000;
		6'b010011: signals <= 33'b0_10_01_00_00_111_1100_0100_0_1_000_00_000_000;
		6'b011000: signals <= 33'b0_11_00_00_00_111_1100_1000_0_0_000_00_000_000;
		6'b011001: signals <= 33'b0_11_00_00_00_111_1100_1001_0_0_000_00_000_000;
		6'b011010: signals <= 33'b0_11_00_00_00_111_1100_1010_0_0_000_00_000_000;
		6'b011011: signals <= 33'b0_11_00_00_00_111_1100_1011_0_0_000_00_000_000;
		6'b100000: signals <= 33'b0_11_01_01_00_111_0000_0000_1_0_000_11_000_000;
		6'b100001: signals <= 33'b0_11_01_01_00_111_0001_0000_1_0_000_11_000_000;
		6'b100010: signals <= 33'b0_11_01_01_00_111_0010_0000_1_0_000_11_000_000;
		6'b100011: signals <= 33'b0_11_01_01_00_111_0011_0000_1_0_000_11_000_000;
		6'b100100: signals <= 33'b0_11_01_01_00_111_0100_0000_1_0_000_11_000_000;
		6'b100101: signals <= 33'b0_11_01_01_00_111_0101_0000_1_0_000_11_000_000;
		6'b100110: signals <= 33'b0_11_01_01_00_111_0110_0000_1_0_000_11_000_000;
		6'b100111: signals <= 33'b0_11_01_01_00_111_0111_0000_1_0_000_11_000_000;
		6'b101010: signals <= 33'b0_11_01_01_00_111_1010_0000_1_0_000_11_000_000;
		6'b101011: signals <= 33'b0_11_01_01_00_111_1011_0000_1_0_000_11_000_000;
		6'b110000: signals <= 33'b0_11_01_01_00_111_1100_0000_0_0_101_00_000_000;
		6'b110001: signals <= 33'b0_11_01_01_00_111_1100_0000_0_0_111_00_000_000;
		6'b110010: signals <= 33'b0_11_01_01_00_111_1100_0000_0_0_100_00_000_000;
		6'b110011: signals <= 33'b0_11_01_01_00_111_1100_0000_0_0_110_00_000_000;
		6'b110100: signals <= 33'b0_11_01_01_00_111_1100_0000_0_0_010_00_000_000;
		6'b110110: signals <= 33'b0_11_01_01_00_111_1100_0000_0_0_011_00_000_000;
		6'b001101: signals <= 33'b0_00_00_00_00_111_1100_0000_0_0_000_00_000_000;//break
		6'b001100: signals <= 33'b0_00_00_00_00_111_1100_0000_0_0_000_00_000_000;//syscall
		default:   signals <= 33'b1_00_00_00_00_111_1100_0000_0_0_000_00_000_000;
		endcase
endmodule

module Op1Decoder(
	input [4:0] rtField, output reg [32:0] signals
);
	always @*
		case(rtField)
		//-----------------------RI  ALUA   B      ALU      ALUV TRAP   WBS
		//-----------------------  FWD  ALUB  BCOND     MUL   MULW   WBD    WBC
		5'b00000: signals <= 33'b0_10_00_00_01_101_1100_0000_0_0_000_00_000_000;
		5'b00001: signals <= 33'b0_10_00_00_01_100_1100_0000_0_0_000_00_000_000;
		5'b10000: signals <= 33'b0_10_11_00_01_101_0101_0000_1_0_000_01_000_110;
		5'b10001: signals <= 33'b0_10_11_00_01_100_0101_0000_1_0_000_01_000_111;
		5'b01000: signals <= 33'b0_10_01_10_00_111_1100_0000_0_0_101_00_000_000;
		5'b01001: signals <= 33'b0_10_01_10_00_111_1100_0000_0_0_111_00_000_000;
		5'b01010: signals <= 33'b0_10_01_10_00_111_1100_0000_0_0_100_00_000_000;
		5'b01011: signals <= 33'b0_10_01_10_00_111_1100_0000_0_0_110_00_000_000;
		5'b01100: signals <= 33'b0_10_01_10_00_111_1100_0000_0_0_010_00_000_000;
		5'b01110: signals <= 33'b0_10_01_10_00_111_1100_0000_0_0_011_00_000_000;
		default:  signals <= 33'b1_00_00_00_00_111_1100_0000_0_0_000_00_000_000;
		endcase
endmodule

module OpSpec2Decoder(
	input [5:0] func, output reg [32:0] signals
);
	always @*
		case(func)
		//------------------------RI  ALUA   B      ALU      ALUV TRAP   WBS
		//------------------------  FWD  ALUB  BCOND     MUL   MULW   WBD    WBC
		6'b000000: signals <= 33'b0_11_00_00_00_111_1100_1100_0_0_000_00_000_000;//madd
		6'b000001: signals <= 33'b0_11_00_00_00_111_1100_1101_0_0_000_00_000_000;//maddu
		6'b000100: signals <= 33'b0_11_00_00_00_111_1100_1110_0_0_000_00_000_000;//msub
		6'b000101: signals <= 33'b0_11_00_00_00_111_1100_1111_0_0_000_00_000_000;//msubu
		6'b100000: signals <= 33'b0_10_01_00_00_111_1000_0000_1_0_000_11_000_000;//clz
		6'b100001: signals <= 33'b0_10_01_00_00_111_1001_0000_1_0_000_11_000_000;//clo
		6'b000010: signals <= 33'b0_11_00_00_00_111_1100_1000_0_0_000_11_011_000;//mul
		default:   signals <= 33'b1_00_00_00_00_111_1100_0000_0_0_000_00_000_000;
		endcase
	
endmodule

module OpCp0Decoder(
	input [31:0] inst, output reg [32:0] signals, output [2:0] cp0Op
);
	reg [2:0] cp0_internal;

`define SIG {signals, cp0_internal}
	always @*
		casex({inst[25:21], inst[5:0]})
		//----------------------------RI  ALUA   B      ALU      ALUV TRAP   WBS     cp0
		//----------------------------  FWD  ALUB  BCOND     MUL   MULW   WBD    WBC
		11'b00000_xxxxxx: `SIG <= 36'b0_00_00_00_00_111_1100_0000_0_0_000_10_100_000_001;//MFC0
		11'b00100_xxxxxx: `SIG <= 36'b0_01_00_01_00_111_0101_0000_0_0_000_00_000_000_010;//MTC0
		11'b1xxxx_000001: `SIG <= 36'b0_00_00_00_00_111_1100_0000_0_0_000_00_000_000_011;//TLBR
		11'b1xxxx_000010: `SIG <= 36'b0_00_00_00_00_111_1100_0000_0_0_000_00_000_000_100;//TLBWI
		11'b1xxxx_000110: `SIG <= 36'b0_00_00_00_00_111_1100_0000_0_0_000_00_000_000_101;//TLBWR
		11'b1xxxx_001000: `SIG <= 36'b0_00_00_00_00_111_1100_0000_0_0_000_00_000_000_110;//TLBP
		11'b1xxxx_011000: `SIG <= 36'b0_00_00_00_00_111_1100_0000_0_0_000_00_000_000_111;//ERET
		default:          `SIG <= 36'b1_00_00_00_00_111_1100_0000_0_0_000_00_000_000_000;
		endcase

	assign cp0Op = (inst[31:26] == 6'b010000)? cp0_internal: 3'b000;
	
endmodule

module InstDecoder(
	input [31:0] inst,
	
//	output [2:0] branchCond, output [1:0] branch, output [2:0] wbCond, output [1:0] wbDest,
//	output ALUSrcA, output [2:0] ALUSrcB, output [8:0] exCtrl, output [3:0] memCtrl,
//	output reservedInstruction
	output [1:0] forward, output [1:0] ALUSrcA, output [1:0] ALUSrcB,
	output [1:0] branch, output [2:0] branchCond, output [3:0] ALUOp,
	output [3:0] mulOp, output ALUValid, output mulWait, output [2:0] trap,
	output [1:0] wbDest, output [2:0] wbSrc, output [2:0] wbCond,
	output RIexception, output syscall, output breakpoint,
	output [2:0] cp0Op, output [3:0] memCtrl
);
	wire [32:0] op0Signals;
	wire [32:0] op1Signals;
	wire [32:0] opSpec2Signals;
	wire [32:0] opCp0Signals;
	reg [32:0] signals;
	
	assign memCtrl = ((inst[31:30] == 2'b10)? inst[29:26]: 4'b1111);
	assign syscall    = {inst[31:26], inst[5:0]} == 12'b000000_001100;
	assign breakpoint = {inst[31:26], inst[5:0]} == 12'b000000_001101;
	
	assign RIexception = signals[`RI];
	assign forward     = signals[`FWD];
	assign ALUSrcA     = signals[`ALUA];
	assign ALUSrcB     = signals[`ALUB];
	assign branch      = signals[`B];
	assign branchCond  = signals[`BCOND];
	assign ALUOp       = signals[`ALU];
	assign mulOp       = signals[`MUL];
	assign ALUValid    = signals[`ALUVALID];
	assign mulWait     = signals[`MULWAIT];
	assign trap        = signals[`TRAP];
	assign wbDest      = signals[`WBDEST];
	assign wbSrc       = signals[`WBSRC];
	assign wbCond      = signals[`WBCOND];
	
	
	always @*
	begin
		case(inst[31:26])
		//------------------------RI  ALUA   B      ALU      ALUV TRAP   WBS
		//------------------------  FWD  ALUB  BCOND     MUL   MULW   WBD    WBC
		//arithmetic
		6'b001000: signals <= 33'b0_10_01_10_00_111_0000_0000_1_0_000_10_000_000;
		6'b001001: signals <= 33'b0_10_01_10_00_111_0001_0000_1_0_000_10_000_000;
		6'b001010: signals <= 33'b0_10_01_10_00_111_1010_0000_1_0_000_10_000_000;
		6'b001011: signals <= 33'b0_10_01_10_00_111_1011_0000_1_0_000_10_000_000;
		6'b001100: signals <= 33'b0_10_01_11_00_111_0100_0000_1_0_000_10_000_000;
		6'b001101: signals <= 33'b0_10_01_11_00_111_0101_0000_1_0_000_10_000_000;
		6'b001110: signals <= 33'b0_10_01_11_00_111_0110_0000_1_0_000_10_000_000;
		6'b001111: signals <= 33'b0_00_00_11_00_111_1101_0000_1_0_000_10_000_000;
		//load
		6'b100000: signals <= 33'b0_10_01_10_00_111_0001_0000_0_0_000_10_001_000;
		6'b100001: signals <= 33'b0_10_01_10_00_111_0001_0000_0_0_000_10_001_000;
		6'b100010: signals <= 33'b0_10_01_10_00_111_0001_0000_0_0_000_10_001_000;
		6'b100011: signals <= 33'b0_10_01_10_00_111_0001_0000_0_0_000_10_001_000;
		6'b100100: signals <= 33'b0_10_01_10_00_111_0001_0000_0_0_000_10_001_000;
		6'b100101: signals <= 33'b0_10_01_10_00_111_0001_0000_0_0_000_10_001_000;
		6'b100110: signals <= 33'b0_10_01_10_00_111_0001_0000_0_0_000_10_001_000;
		//store
		6'b101000: signals <= 33'b0_11_01_10_00_111_0001_0000_0_0_000_00_000_000;
		6'b101001: signals <= 33'b0_11_01_10_00_111_0001_0000_0_0_000_00_000_000;
		6'b101010: signals <= 33'b0_11_01_10_00_111_0001_0000_0_0_000_00_000_000;
		6'b101011: signals <= 33'b0_11_01_10_00_111_0001_0000_0_0_000_00_000_000;
		6'b101110: signals <= 33'b0_11_01_10_00_111_0001_0000_0_0_000_00_000_000;
		//branch&jump
		6'b000100: signals <= 33'b0_11_00_00_01_001_1100_0000_0_0_000_00_000_000;
		6'b000101: signals <= 33'b0_11_00_00_01_000_1100_0000_0_0_000_00_000_000;
		6'b000110: signals <= 33'b0_10_00_00_01_010_1100_0000_0_0_000_00_000_000;
		6'b000111: signals <= 33'b0_10_00_00_01_011_1100_0000_0_0_000_00_000_000;
		6'b000010: signals <= 33'b0_00_00_00_11_111_1100_0000_0_0_000_00_000_000;
		6'b000011: signals <= 33'b0_00_11_00_11_111_0101_0000_1_0_000_01_000_000;
		//Cache
		6'b101111: signals <= 33'b0_10_01_10_00_111_0001_0000_0_0_000_00_000_000;
		
		6'b000000: signals <= op0Signals;
		6'b000001: signals <= op1Signals;
		6'b011100: signals <= opSpec2Signals;
		6'b010000: signals <= opCp0Signals;
		6'b010001: signals <= 33'b0_00_00_00_00_111_1100_0000_0_0_000_00_000_000;//COP 1 to 3
		6'b010010: signals <= 33'b0_00_00_00_00_111_1100_0000_0_0_000_00_000_000;
		6'b010011: signals <= 33'b0_00_00_00_00_111_1100_0000_0_0_000_00_000_000;
		default:   signals <= 33'b1_00_00_00_00_111_1100_0000_0_0_000_00_000_000;
		endcase
	end
		
	Op0Decoder U0(.func(inst[5:0]), .signals(op0Signals));
	Op1Decoder U1(.rtField(inst[20:16]), .signals(op1Signals));
	OpSpec2Decoder U2(.func(inst[5:0]), .signals(opSpec2Signals));
	OpCp0Decoder U3(.inst(inst), .signals(opCp0Signals), .cp0Op(cp0Op));

endmodule
