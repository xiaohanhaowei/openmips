`include "define.v"
module id_ex(
	input Clk, 
	input Rst_n,
	input wire [5:0]			stall,
	input wire [`AluOpBus]  	id_aluop,
	input wire [`AluSelBus] 	id_alusel,
	input wire [`RegBus]    	id_reg1,
	input wire [`RegBus]    	id_reg2,
	input wire [`RegAddrBus] 	id_wd,
	input wire               	id_wreg,

	output reg [`AluOpBus]   	ex_aluop,
	output reg [`AluSelBus] 	ex_alusel,
	output reg [`RegBus] 		ex_reg1,
	output reg [`RegBus] 		ex_reg2,
	output reg [`RegAddrBus]	ex_wd,
	output reg 					ex_wreg
);

	always@(posedge Clk) begin
		if (Rst_n == `RstEnable) begin 
			ex_aluop <= `EXE_NOP_OP;
			ex_alusel <= `EXE_RES_NOP;
			ex_reg1 <= `ZeroWord;
			ex_reg2 <= `ZeroWord;
			ex_wd <= `NOPRegAddr;
			ex_wreg <= `WriteDisable;
		end
		else if (stall[2] == `STOP && stall[3] == `NOSTOP) begin
			//译码阶段暂停,发空指令
			ex_aluop <= `EXE_NOP_OP;
			ex_alusel <= `EXE_RES_NOP;
			ex_reg1 <= `ZeroWord;
			ex_reg2 <= `ZeroWord;
			ex_wd <= `NOPRegAddr;
			ex_wreg <= `WriteDisable;
		end 
		else if(stall[2] == `NOSTOP) begin 
			ex_aluop <= id_aluop;
			ex_alusel <= id_alusel;
			ex_reg1 <= id_reg1;
			ex_reg2 <= id_reg2;
			ex_wd <= id_wd;
			ex_wreg <= id_wreg;
		end
	end
endmodule 