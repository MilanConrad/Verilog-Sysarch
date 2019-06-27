module Decoder(
	input     [31:0] instr,      // Instruktionswort
	input            zero,       // Liefert aktuelle Operation im Datenpfad 0 als Ergebnis?
	output reg       memtoreg,   // Verwende ein geladenes Wort anstatt des ALU-Ergebis als Resultat
	output reg       memwrite,   // Schreibe in den Datenspeicher
	output reg       dobranch,   // Führe einen relativen Sprung aus
	output reg       alusrcbimm, // Verwende den immediate-Wert als zweiten Operanden
	output reg [4:0] destreg,    // Nummer des (möglicherweise) zu schreibenden Zielregisters
	output reg       regwrite,   // Schreibe ein Zielregister
	output reg       dojump,     // Führe einen absoluten Sprung aus
	output reg [2:0] alucontrol,
	output reg OrImm,  // ALU-Kontroll-Bits
	output reg lui
);
	// Extrahiere primären und sekundären Operationcode
	wire [5:0] op = instr[31:26];
	wire [5:0] funct = instr[5:0];

	always @*
	begin
		case (op)
			6'b000000: // Rtype Instruktion
				begin
					regwrite = 1;
					destreg = instr[15:11];
					alusrcbimm = 0;
					dobranch = 0;
					memwrite = 0;
					memtoreg = 0;
					dojump = 0;
					OrImm = 0;
					lui = 0;
					case (funct)
						6'b100001: alucontrol = 3'b010;   //  Addition unsigned
						6'b100011: alucontrol = 3'b110;	 //  Subtraktion unsigned
						6'b100100: alucontrol = 3'b000;	 //  and
						6'b100101: alucontrol = 3'b001;	 //  or
						6'b101011: alucontrol = 3'b111; 	 //  set-less-than unsigned
						6'b011001: alucontrol = 3'b011;   //  Multiply unsigned
						6'b010000: alucontrol = 3'b100;   //  Move from HI
						6'b010000: alucontrol = 3'b101;   //  Move from LO
						default:   alucontrol = 3'bxxx;	   //  undefiniert
					endcase
				end
			6'b100011, // Lade Datenwort aus Speicher
			6'b101011: // Speichere Datenwort
				begin
					regwrite = ~op[3];
					destreg = instr[20:16];
					alusrcbimm = 1;
					dobranch = 0;
					memwrite = op[3];
					memtoreg = 1;
					dojump = 0;
					lui = 0;
					OrImm = 0;
					alucontrol = 3'b010;// TODO // Addition effektive Adresse: Basisregister + Offset
				end
			6'b000100: // Branch Equal
				begin
					regwrite = 0;
					destreg = 5'bx;
					alusrcbimm = 0;
					dobranch = zero; // Gleichheitstest
					memwrite = 0;
					memtoreg = 0;
					dojump = 0;
							lui = 0;
					OrImm = 0;
					alucontrol = 3'b110;// TODO // Subtraktion
				end
			6'b001001:     // Addition immediate unsigned
				begin
					regwrite = 1;
					destreg = instr[20:16];
					alusrcbimm = 1;
					dobranch = 0;
					memwrite = 0;
					memtoreg = 0;
					dojump = 0;
							lui = 0;
					OrImm = 0;
					alucontrol = 3'b010;    // TODO // Addition
				end

				6'b001101:     // Ori immediate unsigned
					begin
						regwrite = 1;
						destreg = instr[20:16];
						alusrcbimm = 1;
						dobranch = 0;
						memwrite = 0;
								lui = 0;
						memtoreg = 0;
						dojump = 0;
						OrImm = 1;
						alucontrol = 3'b001;    // TODO // Addition
					end
			6'b000010: // Jump immediate
				begin
					regwrite = 0;
					destreg = 5'bx;
					alusrcbimm = 0;
					dobranch = 0;
					memwrite = 0;
					lui = 0;
					memtoreg = 0;
					dojump = 1;
					OrImm = 0;
					alucontrol = 3'b010; // TODO

				end
			6'b001111: // Load upper immediate
			 	begin
				regwrite = 1 ;
				destreg = instr[20:16] ;
				dobranch = 0 ;
				dojump = 0 ;
				lui = 1;
				alusrcbimm = 1;
				memtoreg = 0;
				OrImm = 0;
				memwrite = 0;
				end
		  6'b001101: // Bitwise or immediate
				begin
				regwrite = 1;
				destreg = instr[20:16] ;
				dobranch = 0 ;
				dojump = 0;
				alusrcbimm = 1 ;
				memtoreg = 0 ;
				OrImm = 0;
				lui = 0;
				memwrite = 1 ;
				end
			6'b000111: // Branch on greater than or equal to zero and link
				begin
				regwrite = 1;
				destreg = 5'bx;
				dobranch = ~zero;
				lui = 0;
				dojump = 0;
				alucontrol = 3'b111; // a = First operand, b = 0: 1 if a < 0, 0 else
				alusrcbimm = 0;
				memwrite = 0;
				OrImm = 0;
				memtoreg = 0;
				end
			6'b000011:  // Jump and link
				begin
				destreg = 5'b11111;
				dobranch = 1;


				// TODO

				end
			6'b000000:
			begin

			// TODO

			end
			default: // Default Fall
				begin
				regwrite = 1'bx;
				destreg = 5'bx;
				alusrcbimm = 1'bx;
				dobranch = 1'bx;
				memwrite = 1'bx;
				memtoreg = 1'bx;
				dojump = 1'bx;
				OrImm = 1'bx;
						lui = 1'bx	;
				alucontrol = 3'bx; // TODO
				end
		endcase
	end
endmodule
