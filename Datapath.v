module Datapath(
	input         clk, reset,
	input         memtoreg,
	input         dobranch,
	input         alusrcbimm,
	input  [4:0]  destreg,
	input         regwrite,
	input         jump,
	input  [2:0]  alucontrol,
	output        zero,
	output [31:0] pc,
	input  [31:0] instr,
	output [31:0] aluout,
	output [31:0] writedata,
	input  [31:0] readdata,
	input OrImm,
	input lui,
	input dojal,
	input jr
);
	wire [31:0] pc;
	wire [31:0] signimm;
	wire [31:0] srca, srcb, srcbimm;
	wire [31:0] result;
	wire [31:0] newpc,pcresult,rAddress;

	// Fetch: Reiche PC an Instruktionsspeicher weiter und update PC
	ProgramCounter pcenv(clk, reset, dobranch, signimm, jump,dojal,jr,rAddress, instr[25:0], pc,pcresult);

	// Execute:
	// (a) Wähle Operanden aus
	SignExtension se(instr[15:0], signimm, OrImm, lui);
	assign srcbimm = alusrcbimm ? signimm : srcb;
	// (b) Führe Berechnung in der ALU durch
	ArithmeticLogicUnit alu(srca, srcbimm, alucontrol, aluout, zero);
	// (c) Wähle richtiges Ergebnis aus
	assign result = memtoreg ? readdata : aluout;

	// Memory: Datenwort das zur (möglichen) Speicherung an den Datenspeicher übertragen wird
	assign writedata = srcb;

	// Write-Back: Stelle Operanden bereit und schreibe das jeweilige Resultat zurück
	RegisterFile gpr(clk, regwrite, instr[25:21], instr[20:16],
	               destreg, result, pcresult,srca, srcb,rAddress);
endmodule

module ProgramCounter(
	input         clk,
	input         reset,
	input         dobranch,
	input  [31:0] branchoffset,
	input         dojump,
	input         dojal,
	input 				jr,
	input  [31:0] rAddress,
	input  [25:0] jumptarget,
	output [31:0] progcounter,
	output [31:0] pcresult
);
	reg  [31:0] pc;
	wire [31:0] incpc, branchpc, nextpc;



	// Inkrementiere Befehlszähler um 4 (word-aligned)
	Adder pcinc(.a(pc), .b(32'b100), .cin(1'b0), .y(incpc));

	assign pcresult = dojal ? incpc : 0;

	// Berechne mögliches (PC-relatives) Sprungziel
	Adder pcbranch(.a(incpc), .b({branchoffset[29:0], 2'b00}), .cin(1'b0), .y(branchpc));
	// Wähle den nächsten Wert des Befehlszählers aus
	assign nextpc = dojump   ? {incpc[31:28], jumptarget, 2'b00} :
	                dobranch ? branchpc :
	                           incpc;

	// Der Befehlszähler ist ein Speicherbaustein
	always @(posedge clk)
	begin
		if (reset) begin // Initialisierung mit Adresse 0x00400000
			pc <= 'h00400000;
		end else begin
			//pc <= nextpc;
			pc <= jr ? rAddress : nextpc;
		end
	end

	// Ausgabe
	assign progcounter = pc;

endmodule

module RegisterFile(
	input         clk,
	input         we3,
	input  [4:0]  ra1, ra2, wa3,
	input  [31:0] wd3,
	input [31:0] newpc,
	output [31:0] rd1, rd2,rd3
);
	reg [31:0] registers[31:0];




	initial begin
		$monitor("Reg 1: %b \t Reg 2 : %b \t Reg 3 : %b \t Reg 4 : %b \t",registers[1],registers[2],registers[3],registers[4]);
	end

	always @(posedge clk)
		if (we3) begin
			registers[wa3] <= (newpc==0) ? wd3 : newpc;
		end

	assign rd1 = (ra1 != 0) ? registers[ra1] : 0;
	assign rd2 = (ra2 != 0) ? registers[ra2] : 0;
	assign rd3 = (ra1 != 0) ? registers[ra1] : 0;

endmodule

module Adder(
	input  [31:0] a, b,
	input         cin,
	output [31:0] y,
	output        cout
);
	assign {cout, y} = a + b + cin;
endmodule

module SignExtension(
	input  [15:0] a,
	output [31:0] y,
	input OrImm,
	input lui

);

reg [31:0] out;

always @*
begin

if (OrImm) begin
  out = {{16'b0},a}; end
	 else
	 	 	begin if(lui) begin
	 	  out = {a,{16'b0}}; end
	  		else begin
	 			out = {{16{a[15]}}, a}; end
	 end

end

assign y = out;

endmodule

module ArithmeticLogicUnit(
	input  [31:0] a, b,
	input  [2:0]  alucontrol,
	output [31:0] result,
	output        zero
);
 reg[31:0] lo;
 reg[31:0] hi;
 reg [64:0] temp;
 reg result;
 reg zero;
	//ALU

always @* begin

case (alucontrol)

 0: result = a & b ;
 1: result = a | b ;
 2: result = a + b ;

 3: begin temp = {{1'b0},a} * {{1'b0},b}; lo = temp[31:0];hi = temp[63:32]; end
 4: result = hi ;
 5: result = lo ;
 6: result = a - b ;

 7: begin

		if ($signed(a)<$signed(b)) begin
		result <= 32'b00000000000000000000000000000001;
		end else begin
		result <= 32'b00000000000000000000000000000000;
		end
		$display("Content of a: %b \t Content of b: %b \t Content of result: %b",a,b,result);
		end

endcase

	if(result == 0) begin
	 zero <= 1;
	 end else begin
	 zero <= 0;
	 end

 	 end

endmodule
