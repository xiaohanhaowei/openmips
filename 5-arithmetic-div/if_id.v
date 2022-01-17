`include "define.v"
module if_id(
	input wire  				Clk,
	input wire  				Rst_n,
	input wire [5:0] 			stall,
	input wire [`InstAddrBus] 	if_pc,
	input wire [`InstBus] 		if_inst,

	output reg [`InstAddrBus] 	id_pc,
	output reg [`InstBus]     	id_inst
);
	always @(posedge Clk) begin
		if (Rst_n == `RstEnable) begin
			// reset
			id_pc <= `ZeroWord;	
			id_inst <= `ZeroWord;
		end
		else if(stall[1] == `STOP && stall[2] == `NOSTOP) begin
			id_pc <= `ZeroWord;
			id_inst <= `ZeroWord;
		end
		else if (stall[1] == `NOSTOP) begin
			id_pc <= if_pc;  //如果取值阶段不暂停
			id_inst <= if_inst;		
		end 
		// else begin //这一个也是时序电路中不用写保持逻辑
		// 	id_pc <= id_pc;
		// 	id_inst <= if_inst;
		// end
	end

endmodule