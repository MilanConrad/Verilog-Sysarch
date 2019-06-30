module MealyPattern(
	input        clock,
	input        i,
	output [1:0] o
);

// TODO Implementierung
reg b=1'b0;
reg a=1'b0;
reg m2=2'b00;
reg m1=2'b00;
always@ (posedge clock)
begin
	m1 <= a&!b&!i; //(b==1'b0)&&(a==1'b1)&&(i==1'b0); 
	m2 <= !a&b&i; //(b==1'b1)&&(a==1'b0)&&(i==1'b1);
	a<=i;
	b<=a;
end
assign o[1]=m1;
assign o[0]=m2;
endmodule

module MealyPatternTestbench();
	reg clock,i;
	wire [1:0] out;
initial begin
	clock <=1;
	i=1'b0; 
	#10; i=1;
	#10; i=1;
	#10; i=0;
	#10; i=1;
	#10; i=0;
	#10; i=1;
	#10; i=0;
	#10; i=1;
	#10; i=1;

end

always
	begin
		#5; clock <= !clock;
	end
	// TODO Input Stimuli

MealyPattern machine(.clock(clock), .i(i), .o(out));

	// TODO Überprüfe Ausgaben
initial begin
	//$monitor ("%b%b",o[1],o[0]);
	$display("\t\ttime,\tcl,\tout\ti"); 
    $monitor("%d,\t%b,\t%b\t%b",$time, clock,out,i); 
end
initial
#110 $finish;
endmodule

