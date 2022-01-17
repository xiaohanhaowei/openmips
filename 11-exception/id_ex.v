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

	input wire [`RegBus] 		id_link_address_i,
	input wire 					id_is_in_delayslot_i,
	input wire  				next_inst_in_delayslot_i,
	input wire [`RegBus] 		id_inst_i,
	
	input wire 					flush_i,
	input wire [`RegBus] 		id_excepte_type_i,
	input wire [`InstAddrBus]   id_current_inst_addr_i,
	
	output reg [`InstAddrBus]   ex_current_inst_addr_o, 
	output reg [`RegBus] 		ex_except_type_o,
	output reg [`AluOpBus]   	ex_aluop,
	output reg [`AluSelBus] 	ex_alusel,
	output reg [`RegBus] 		ex_reg1,
	output reg [`RegBus] 		ex_reg2,
	output reg [`RegAddrBus]	ex_wd,
	output reg 					ex_wreg,

	output reg [`RegBus] 		ex_inst_o,

	output reg [`RegBus] 		ex_link_address_o,
	output reg    				ex_is_in_delayslot_o,
	output reg    				is_in_delayslot_o
);

	always@(posedge Clk) begin
		if (Rst_n == `RstEnable) begin 
			ex_aluop <= `EXE_NOP_OP;
			ex_alusel <= `EXE_RES_NOP;
			ex_reg1 <= `ZeroWord;
			ex_reg2 <= `ZeroWord;
			ex_wd <= `NOPRegAddr;
			ex_wreg <= `WriteDisable;
			
			ex_link_address_o <= `ZeroWord;
			ex_is_in_delayslot_o <= `NotInDelaySlot;
			is_in_delayslot_o <= `NotInDelaySlot;
			
			ex_inst_o <= `ZeroWord;
			ex_current_inst_addr_o <= `ZeroWord;
			ex_except_type_o <= `ZeroWord;
		end
		else if (flush_i == 1'b1) begin
			ex_aluop <= `EXE_NOP_OP;
			ex_alusel <= `EXE_RES_NOP;
			ex_reg1 <= `ZeroWord;
			ex_reg2 <= `ZeroWord;
			ex_wd <= `NOPRegAddr;
			ex_wreg <= `WriteDisable;
			
			ex_link_address_o <= `ZeroWord;
			ex_is_in_delayslot_o <= `NotInDelaySlot;
			is_in_delayslot_o <= `NotInDelaySlot;
			
			ex_inst_o <= `ZeroWord;
			ex_current_inst_addr_o <= `ZeroWord;
			ex_except_type_o <= `ZeroWord;
		end
		else if (stall[2] == `STOP && stall[3] == `NOSTOP) begin
			//译码阶段暂停,发空指令
			ex_aluop <= `EXE_NOP_OP;
			ex_alusel <= `EXE_RES_NOP;
			ex_reg1 <= `ZeroWord;
			ex_reg2 <= `ZeroWord;
			ex_wd <= `NOPRegAddr;
			ex_wreg <= `WriteDisable;
			ex_link_address_o <= `ZeroWord;
			ex_is_in_delayslot_o <= `NotInDelaySlot;
			ex_inst_o <= `ZeroWord;
			ex_except_type_o <= `ZeroWord;
			ex_current_inst_addr_o <=`ZeroWord;
			// is_in_delayslot_o <= `NotInDelaySlot; //FIXME:带不带这句?
		end 
		else if(stall[2] == `NOSTOP) begin 
			ex_aluop <= id_aluop;
			ex_alusel <= id_alusel;
			ex_reg1 <= id_reg1;
			ex_reg2 <= id_reg2;
			ex_wd <= id_wd;
			ex_wreg <= id_wreg;
			ex_link_address_o <= id_link_address_i;
			ex_is_in_delayslot_o <= id_is_in_delayslot_i;
			is_in_delayslot_o <= next_inst_in_delayslot_i;

			ex_inst_o <= id_inst_i;
			ex_except_type_o <= id_excepte_type_i;
			ex_current_inst_addr_o <= id_current_inst_addr_i;
		end
	end
endmodule 