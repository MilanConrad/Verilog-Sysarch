module Division(
	input         clock,
	input         start,
	input  [31:0] a,
	input  [31:0] b,
	output [31:0] q,
	output [31:0] r
);

reg [31:0] r,q,rs;
reg [6:0] i;

always @ (posedge clock) begin
	if(start) begin
		//a<=a;b<=b;
		q<=0;i<=31; r<=0;rs<=0;
	end else
	if(i<60) begin
		begin
			rs= 2* r + a[i];
			if(rs<b) begin
				q[i]=0;r=rs; i=i-1;
			end else
				begin
					q[i]=1;r=rs-b; i=i-1;
				end
			
		end
	end

end


endmodule

