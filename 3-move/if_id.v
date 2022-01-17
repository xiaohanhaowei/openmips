`include "define.v"
module if_id(
	input wire  Clk,
	input wire  Rst_n,
	input wire [`InstAddrBus] if_pc,
	input wire [`InstBus] if_inst,

	output reg [`InstAddrBus] id_pc,
	output reg [`InstBus]     id_inst
);
	always @(posedge Clk) begin
		if (Rst_n == `RstEnable) begin
			// reset
			id_pc <= `ZeroWord;	
			id_inst <= `ZeroWord;
		end
		else begin
			id_pc <= if_pc;
			id_inst <= if_inst;		
		end 
	end

endmodule