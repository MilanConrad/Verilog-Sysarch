module MIPScore(
	input clk,
	input reset,
	// Kommunikation Instruktionsspeicher
	output [31:0] pc,
	input  [31:0] instr,
	// Kommunikation Datenspeicher
	output        memwrite,
	output [31:0] aluout, writedata,
	input  [31:0] readdata
);
	wire       memtoreg, alusrcbimm, regwrite, dojump, dobranch, zero, OrImm, lui, dojal,jr;
	wire [4:0] destreg;
	wire [2:0] alucontrol;

	Decoder decoder(instr, zero, memtoreg, memwrite,
	                dobranch, alusrcbimm, destreg,
	                regwrite, dojump, alucontrol, OrImm, lui,dojal,jr);
	Datapath dp(clk, reset, memtoreg, dobranch,
	            alusrcbimm, destreg, regwrite, dojump,
	            alucontrol,
	            zero, pc, instr,
	            aluout, writedata, readdata, OrImm, lui, dojal,jr);
endmodule
