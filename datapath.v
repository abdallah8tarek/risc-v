module datapath (instr,
				 read_data,
				 clk,
				 reset,
				 reg_write,
				 pc_sel,
				 alu_sel,
				 alu_control,
				 result_sel,
				 imm_sel,
				 zero,
				 pc_out,
				 alu_result,
				 write_data,
				 jalr_sel);

input [31:0] instr;
input [31:0] read_data;
input clk,reset;  
input reg_write,pc_sel,alu_sel,jalr_sel;
input [2:0] alu_control;
input [1:0] result_sel,imm_sel;

output zero;
output [31:0] pc_out;
output [31:0] alu_result;
output [31:0] write_data;

//mux2 (mux_out,in0,in1,sel)
wire [31:0] pc_next,pc_target,pc_plus4;
wire [31:0] pc_or_reg;    //for jalr selection
mux2 pc_mux(.mux_out (pc_next),
			.in0 (pc_plus4),
			.in1 (pc_or_reg),
			.sel (pc_sel));

//d_flip_flop (in,out,clk,reset)
wire [31:0] pc;
d_flip_flop f1(.in(pc_next),
			 .out(pc),
			 .clk(clk),
			 .reset(reset));

//full_adder_behave (f_sum,a,b)
full_adder_behave add_plus_4(.f_sum (pc_plus4),
					   .a (32'd4),
					   .b (pc));		 

//reg_file (a1,a2,a3,wd3,rd1,rd2,clk,we3)
wire [31:0] result,sourceA,reg2;
reg_file reg_file1(.a1 (instr[19:15]),
			  .a2 (instr[24:20]),
			  .a3 (instr[11:7]),
			  .wd3 (result),
			  .rd1 (sourceA),
			  .rd2 (reg2),
			  .clk (clk),
			  .we3 (reg_write));

wire [31:0] immout;
//sign_extend (in,out,sel)
sign_extend extend(.in (instr[31:7]),
				   .out (immout),
				   .sel (imm_sel));

//full_adder_behave (f_sum,a,b)
full_adder_behave add_imm(.f_sum (pc_target),
					   .a (immout),
					   .b (pc));						   			   

wire [31:0] sourceB;
//mux2 (mux_out,in0,in1,sel)
mux2 reg_out_mux(.mux_out (sourceB),
				 .in0 (reg2),
				 .in1 (immout),
				 .sel (alu_sel));

wire [31:0] alu_res;
//ALU (zero,ALUout,a,b,ALUControl)
ALU alu1(.zero (zero),
		 .ALUout (alu_res),
		 .a (sourceA),
		 .b (sourceB),
		 .ALUControl (alu_control));

//mux2 (mux_out,in0,in1,sel)
mux2 jalr_mux(.mux_out (pc_or_reg),
			.in0 (pc_target),
			.in1 (alu_res),
			.sel (jalr_sel));

//mux3 (mux_out,in0,in1,in2,sel)
mux3 result_mux(.mux_out (result),
				.in0 (alu_res),
				.in1 (read_data),
				.in2 (pc_plus4),
				.sel (result_sel));

//output assignment
assign pc_out = pc;
assign alu_result = alu_res;
assign write_data = reg2;

endmodule