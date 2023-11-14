module top_tb ();

localparam t = 20;

reg clk,reset,ram_load_en;
reg [31:0] ram_load_address,ram_load_data_in;
wire [31:0] instr,pc_out,write_data,alu_result;
wire [31:0] ram_data,read_data;
reg [31:0] ram_add;
wire write_en,load_ram_en;

//top_module (clk,reset,instr,read_data,pc_out,write_en,write_data,alu_result);
top_module t1(.clk(clk),
			  .reset(reset),
			  .instr(instr),
			  .read_data(read_data),
			  .pc_out(pc_out),
			  .write_en(write_en),
			  .write_data(write_data),
			  .alu_result(alu_result));

//instruction_memory (address,data_out,clk);
instruction_memory instruct(.address (pc_out),
					  .data_out (instr),
					  .clk (clk));
					  
assign load_ram_en = ram_load_en | write_en;
assign ram_data = ram_load_en ? ram_load_address : write_data;
assign ram_add = ram_load_en ? ram_load_data_in : alu_result;
//ram (address,data_in,data_out,clk,we);
ram data_mem(.address(ram_add),
			 .data_in(ram_data),
			 .data_out(read_data),
			 .clk(clk),
			 .we(load_ram_en));

initial 
begin
	clk = 0;
	forever #(t/2) clk = ~clk;
end

initial 
begin	
	reset = 1;
	ram_load_en = 0;
	#t
	reset = 0;
	#(t*30)    ///wait for the program to finish
	ram_add = 32'h60;#t
	if (read_data == 32'h7)
	begin
			$display ("success in add 0x60");
			ram_add = 32'h64;#t
			if (read_data == 32'h19)
			begin 
				$display ("success in add 0x64");
				ram_add = 32'h2;#t
				if (read_data == 32'h7)
				begin
					$display ("success in add 0x2");
					ram_add = 32'hf;#t
					if (read_data != 32'h44)
						begin
							$display ("success jalr jumping");
							ram_add = 32'h14;#t
							if (read_data == 32'h68)
								$display ("success in add 0x14");
							else 
								$display ("failure in add 0x64");
						end
					else 
						$display ("failure jalr jumping");
				end
				else
					$display ("failure in add 0x2");
			end
			else
				$display ("failure in add 0x64");			
	end
	else
		$display ("failure in 0x60");
	$stop;
end
endmodule