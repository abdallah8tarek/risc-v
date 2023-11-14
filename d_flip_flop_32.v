module d_flip_flop (in,out,clk,reset);
input [31:0] in;
input clk,reset;
output reg [31:0] out;

always@(posedge clk)
	if (reset)
		out <= 0;
	else
		out <= in;
	
endmodule