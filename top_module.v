module top_module (clk,reset,instr,read_data,
				   pc_out,write_en,write_data,alu_result);

input clk,reset;
input [31:0] instr,read_data;
output [31:0] alu_result,write_data,pc_out;
output write_en;

//control_unit (instr,zero,pc_sel,result_sel,mem_write,
//              alu_sel,imm_sel,reg_write,alu_control,jalr_sel)
wire zero,pc_sel,alu_sel,reg_write,jalr_sel;
wire [1:0] result_sel,imm_sel;
wire [2:0] alu_control;
control_unit c1(.instr(instr),
				.zero(zero),
				.pc_sel(pc_sel),
				.result_sel(result_sel),
				.mem_write(write_en),
				.alu_sel(alu_sel),
				.imm_sel(imm_sel),
				.reg_write(reg_write),
				.alu_control(alu_control),
				.jalr_sel(jalr_sel));

//datapath (instr,read_data,clk,reset,reg_write,pc_sel,
//          alu_sel,alu_control,result_sel,imm_sel,zero,
//  		pc_out,alu_result,write_data,jalr_sel)
datapath d1(.instr(instr),
			.read_data(read_data),
			.clk(clk),
			.reset(reset),
			.reg_write(reg_write),
			.pc_sel(pc_sel),
			.alu_sel(alu_sel),
			.alu_control(alu_control),
			.result_sel(result_sel),
			.imm_sel(imm_sel),
			.zero(zero),
			.pc_out(pc_out),
			.alu_result(alu_result),
			.write_data(write_data),
			.jalr_sel(jalr_sel));
endmodule