`include "define.v"
module ex(
	input wire 					Rst_n,
	input wire [`AluOpBus] 		aluop_i,
	input wire [`AluSelBus] 	alusel_i,
	input wire [`RegBus]    	reg1_i,
	input wire [`RegBus]    	reg2_i,
	input wire [`RegAddrBus] 	wd_i,
	input wire               	wreg_i,
	
	input wire 					mem_wen_hilo,
	input wire [`RegBus]		mem_hi_i,
	input wire [`RegBus]		mem_lo_i,
	input wire 					wb_wen_hilo,
	input wire [`RegBus]		wb_hi_i,
	input wire [`RegBus]		wb_lo_i,
	input wire [`RegBus]		hi_i,
	input wire [`RegBus]		lo_i,

	output reg [`RegAddrBus] 	wd_o,
	output reg               	wreg_o,
	output reg [`RegBus]     	wdata_o,

	output reg [`RegBus] 		hi_o,
	output reg [`RegBus]		lo_o,
	output reg 					whilo_o

);
	reg [`RegBus] logicout;
	reg [`RegBus] shiftres;
	reg [`RegBus] movres;
	reg [`RegBus] HI;
	reg [`RegBus] LO;

	always @(*) begin
		if(Rst_n == `RstEnable) begin
			{HI, LO} <= {`ZeroWord, `ZeroWord};
		end else if(mem_wen_hilo ==`WriteEnable) begin  //访存阶段数据前推
			{HI, LO} <= {mem_hi_i, mem_lo_i};
		end else if(wb_wen_hilo == `WriteEnable)begin //回写阶段数据前推
			{HI, LO} <= {wb_hi_i, wb_lo_i};
		end else begin
			{HI, LO} <= {hi_i, lo_i};
		end
	end
	always @(*) begin
		if(Rst_n == `RstEnable) begin
			logicout <= `ZeroWord;
		end
		else begin
			case (aluop_i)
				`EXE_OR_OP: begin
					logicout <= reg1_i | reg2_i;
				end
				`EXE_AND_OP: begin
					logicout <= reg1_i & reg2_i;
				end
				`EXE_NOR_OP: begin
					logicout <= ~(reg1_i | reg2_i);
				end
				`EXE_XOR_OP: begin
					logicout <= reg1_i ^ reg2_i;
				end
				default: begin
					logicout <= `ZeroWord;
				end
			endcase
		end
	end

	always @(*) begin
		if(Rst_n == `RstEnable) begin
			shiftres <= `ZeroWord;
		end else begin
			case(aluop_i)
				`EXE_SLL_OP: begin
					shiftres <= reg2_i << reg1_i[4:0];
				end
				`EXE_SRL_OP: begin
					shiftres <= reg2_i >> reg1_i[4:0];
				end
				`EXE_SRA_OP: begin  //算术右移
					shiftres <= ({32{reg2_i[31]}} << (6'd32 - {1'b0, reg1_i[4:0]})) | reg2_i >> reg1_i[4:0];
				end
			endcase
		end
		
	end
	always @(*) begin
		if(Rst_n == `RstEnable) begin
			movres <= `ZeroWord;
		end
		else begin
			movres <= `ZeroWord;
			case(aluop_i)
				`EXE_MOVN_OP: begin
					movres <= reg1_i;
				end
				`EXE_MOVZ_OP: begin
					movres <= reg1_i;
				end
				`EXE_MFHI_OP: begin
					movres <= HI;
				end
				`EXE_MFLO_OP: begin
					movres <= LO;
				end
				default: begin
					
				end
			endcase
		end
	end

	always @(*) begin
		wd_o <= wd_i;
		wreg_o <= wreg_i;
		case (alusel_i)
			`EXE_RES_LOGIC: begin
				wdata_o <= logicout;
			end
			`EXE_RES_SHIFT: begin
				wdata_o <= shiftres;
			end
			`EXE_RES_MOV: begin
				wdata_o <= movres;
			end
			default: begin
				wdata_o <= `ZeroWord;
			end
		endcase	
	end
	always @(*) begin
		if (Rst_n == `RstEnable) begin
			hi_o <= `ZeroWord;
			lo_o <= `ZeroWord;
			whilo_o <= `WriteDisable;
		end
		else if (aluop_i == `EXE_MTHI_OP) begin
			whilo_o <= `WriteEnable;
			hi_o <= reg1_i;
			lo_o <= LO;
		end
		else if (aluop_i == `EXE_MTLO_OP) begin
			whilo_o <= `WriteEnable;
			lo_o <= reg1_i;
			hi_o <= HI;
		end
		else begin
			whilo_o <= `WriteDisable;
			lo_o <= `ZeroWord;
			hi_o <= `ZeroWord;
		end
	end
endmodule