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
	input lui
);
	wire [31:0] pc;
	wire [31:0] signimm;
	wire [31:0] srca, srcb, srcbimm;
	wire [31:0] result;

	// Fetch: Reiche PC an Instruktionsspeicher weiter und update PC
	ProgramCounter pcenv(clk, reset, dobranch, signimm, jump, instr[25:0], pc);

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
	               destreg, result, srca, srcb);
endmodule

module ProgramCounter(
	input         clk,
	input         reset,
	input         dobranch,
	input  [31:0] branchoffset,
	input         dojump,
	input  [25:0] jumptarget,
	output [31:0] progcounter
);
	reg  [31:0] pc;
	wire [31:0] incpc, branchpc, nextpc;

	// Inkrementiere Befehlszähler um 4 (word-aligned)
	Adder pcinc(.a(pc), .b(32'b100), .cin(1'b0), .y(incpc));
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
			pc <= nextpc;
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
	output [31:0] rd1, rd2
);
	reg [31:0] registers[31:0];

	always @(posedge clk)
		if (we3) begin
			registers[wa3] <= wd3;
		end

	assign rd1 = (ra1 != 0) ? registers[ra1] : 0;
	assign rd2 = (ra2 != 0) ? registers[ra2] : 0;
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

initial begin
//$display("%d",y);
$monitor("%b\t%b\t%b\t%b",a,y,OrImm,lui);
end

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
 reg [61:0] temp;
 reg result;
 reg zero;
<<<<<<< HEAD

=======
	//ALU
>>>>>>> 49477960bd517491f34b4ae01f976819e3add97b
always @* begin

case (alucontrol)

 0: result = a & b ;
 1: result = a | b ;
 2: result = a + b ;
 3: begin
 		temp <= (0 || a) * (0 || b);
		hi <= temp[61:32];
		lo <= temp[31:0];
		end
 4: result <= hi ;
 5: result <= lo ;
 6: result <= a - b ;

 7: begin

		if (a<b) begin
		result <= 32'b00000000000000000000000000000000;
		end else begin
		result <= 32'b00000000000000000000000000000001;
		end
		end

endcase

	if(result == 0) begin
	 zero <= 1;
	 end else begin
	 zero <= 0;
	 end

 	 end

endmodule
