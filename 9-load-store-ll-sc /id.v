//inst decoder
`include "define.v"

module id(
	input wire 				  Rst_n,
	input wire [`InstAddrBus] pc_i,
	input wire [`InstBus]     inst_i,


	input wire [`RegBus]      reg1_data_i,
	input wire [`RegBus]      reg2_data_i,
	
	//数据前推
	input wire 				  ex_wreg_i,
	input wire [`RegBus]	  ex_wdata_i,
	input wire [`RegAddrBus]  ex_wd_i,

	input wire 				  mem_wreg_i,
	input wire [`RegBus]	  mem_wdata_i,
	input wire [`RegAddrBus]  mem_wd_i,

	input wire  			  is_in_delayslot_i,

	input wire [`AluOpBus]    ex_aluop_i,

	output reg                reg1_read_o,
	output reg 				  reg2_read_o,
	output reg [`RegAddrBus]  reg1_addr_o,
	output reg [`RegAddrBus]  reg2_addr_o,

	output reg [`AluOpBus]    aluop_o,
	output reg [`AluSelBus]   alusel_o,
	output reg [`RegBus]      reg1_o,
	output reg [`RegBus] 	  reg2_o,
	output reg [`RegAddrBus]  wd_o,
	output reg 				  wreg_o,
	//branch&jump
	output reg  			  branch_flag_o,
	output reg [`RegBus] 	  branch_target_addr_o,
	output reg  			  is_in_delayslot_o,
	output reg [`RegBus]	  link_addr_o,
	output reg   			  next_inst_in_delayslot_o,

	//load&store
	output wire [`RegBus] 	  inst_o,

	output wire 				  stall_req_id
);
	wire [5:0] op = inst_i[31:26];
	wire [4:0] op2 = inst_i[10:6];
	wire [5:0] op3 = inst_i[5:0];
	wire [4:0] op4 = inst_i[20:16];
	reg [`RegBus] imm;
	reg 		  inst_valid;

	wire [`RegBus] pc_plus_8;
	wire [`RegBus] pc_plus_4;
	wire [`RegBus] imm_sll2_signedext;
	assign pc_plus_8 = pc_i + 8;
	assign pc_plus_4 = pc_i + 4;
	assign imm_sll2_signedext = {{14{inst_i[15]}}, inst_i[15:0], 2'b00};
	assign inst_o = inst_i;

	// load relation
	reg stallreq_for_reg1_loadrelate;
	reg stallreq_for_reg2_loadrelate;
	wire pre_inst_is_load;
	assign pre_inst_is_load = ((ex_aluop_i == `EXE_LB_OP)  ||  
							 (ex_aluop_i == `EXE_LBU_OP) ||
							 (ex_aluop_i == `EXE_LH_OP)  ||
							 (ex_aluop_i == `EXE_LHU_OP) ||
							 (ex_aluop_i == `EXE_LW_OP)  ||
							 (ex_aluop_i == `EXE_LWR_OP) ||
							 (ex_aluop_i == `EXE_LWL_OP) ||
							 (ex_aluop_i == `EXE_LL_OP)  ||
							 (ex_aluop_i == `EXE_SC_OP)) ? 1'b1 : 1'b0;
	assign stall_req_id = stallreq_for_reg1_loadrelate || stallreq_for_reg2_loadrelate;
	always @ (*) begin
		if (Rst_n == `RstEnable) begin
			aluop_o  <= `EXE_NOP_OP;
			alusel_o <= `EXE_RES_NOP;
			wd_o     <= `NOPRegAddr;
			wreg_o <= `WriteDisable;
			inst_valid <= `InstValid;

			reg1_read_o <= 1'b0;
			reg2_read_o <= 1'b0;
			reg1_addr_o <= `NOPRegAddr;
			reg2_addr_o <= `NOPRegAddr;
			imm         <= 32'h0;
			link_addr_o <= `ZeroWord;
			branch_target_addr_o <= `ZeroWord;
			branch_flag_o <= `NoBranch;
			next_inst_in_delayslot_o <= `NotInDelaySlot;

		end else begin
			aluop_o <= `EXE_NOP_OP;
			alusel_o <= `EXE_RES_NOP;
			wd_o <= inst_i[15:11];
			wreg_o <= `WriteDisable;
			inst_valid <= `InstInvalid;
			reg1_read_o <= 1'b0;
			reg2_read_o <= 1'b0;
			reg1_addr_o <= inst_i[25:21];
			reg2_addr_o <= inst_i[20:16];
			imm <= `ZeroWord;
			link_addr_o <= `ZeroWord;
			branch_target_addr_o <= `ZeroWord;
			branch_flag_o <= `NoBranch;
			next_inst_in_delayslot_o <= `NotInDelaySlot;
			case (op)
				`EXE_ORI: begin                 //ORI指令
					wreg_o <= `WriteEnable;
					aluop_o <= `EXE_OR_OP;
					alusel_o <= `EXE_RES_LOGIC;
					reg1_read_o <= 1'b1;
					reg2_read_o <= 1'b0;
					imm        <= {16'h0, inst_i[15:0]};
					wd_o       <= inst_i[20:16];
					inst_valid <= `InstValid;
				end
				`EXE_ANDI: begin				//ANDI指令
					wreg_o <= `WriteEnable;
					aluop_o <= `EXE_AND_OP;
					alusel_o <= `EXE_RES_LOGIC;
					reg1_read_o <= 1'b1;
					reg2_read_o <= 1'b0;
					imm        <= {16'h0, inst_i[15:0]};
					wd_o       <= inst_i[20:16];
					inst_valid <= `InstValid;
				end
				`EXE_XORI: begin				//XORI指令
					wreg_o <= `WriteEnable;
					aluop_o <= `EXE_XOR_OP;
					alusel_o <= `EXE_RES_LOGIC;
					reg1_read_o <= 1'b1;
					reg2_read_o <= 1'b0;
					imm        <= {16'h0, inst_i[15:0]};
					wd_o       <= inst_i[20:16];
					inst_valid <= `InstValid;
				end
				`EXE_LUI: begin					//LUI指令
					wreg_o <= `WriteEnable;
					aluop_o <= `EXE_OR_OP;
					alusel_o <= `EXE_RES_LOGIC;
					reg1_read_o <= 1'b1;
					reg2_read_o <= 1'b0;
					imm        <= {inst_i[15:0], 16'h0};
					wd_o       <= inst_i[20:16];
					inst_valid <= `InstValid;
				end
				`EXE_PREF: begin                 //pref指令看作是nop指令
					wreg_o <= `WriteDisable;
					aluop_o <= `EXE_NOP_OP;
					alusel_o <= `EXE_RES_NOP;
					reg1_read_o <= 1'b0;
					reg2_read_o <= 1'b0;
					inst_valid <= `InstValid;
				end
				//arithmetic 相关的指令
				`EXE_ADDI: begin
					wreg_o <= `WriteEnable;
					aluop_o <= `EXE_ADDI_OP;
					alusel_o <= `EXE_RES_ARITH;
					reg1_read_o <= 1'b1;
					reg2_read_o <= 1'b0;
					wd_o <= inst_i[20:16];
					imm <= {{16{inst_i[15]}}, inst_i[15:0]};
					inst_valid <= `InstValid;
				end
				`EXE_ADDIU: begin
					wreg_o <= `WriteEnable;
					aluop_o <= `EXE_ADDIU_OP;
					alusel_o <= `EXE_RES_ARITH;
					reg1_read_o <= 1'b1;
					reg2_read_o <= 1'b0;
					wd_o <= inst_i[20:16];
					imm <= {{16{inst_i[15]}}, inst_i[15:0]};
					inst_valid <= `InstValid;
				end
				`EXE_SLTI: begin
					wreg_o <= `WriteEnable;
					aluop_o <= `EXE_SLT_OP;
					alusel_o <= `EXE_RES_ARITH;
					reg1_read_o <= 1'b1;
					reg2_read_o <= 1'b0;
					wd_o <= inst_i[20:16];
					imm <= {{16{inst_i[15]}}, inst_i[15:0]};
					inst_valid <= `InstValid;
				end
				`EXE_SLTIU: begin
					wreg_o <= `WriteEnable;
					aluop_o <= `EXE_SLTU_OP;
					alusel_o <= `EXE_RES_ARITH;
					reg1_read_o <= 1'b1;
					reg2_read_o <= 1'b0;
					wd_o <= inst_i[20:16];
					imm <= {{16{inst_i[15]}}, inst_i[15:0]};
					inst_valid <= `InstValid;
				end
				//Jump add branch
				`EXE_J: begin
					wreg_o <= `WriteDisable;
					aluop_o <= `EXE_J_OP;
					alusel_o <= `EXE_RES_JUMP_BRANCH;
					reg1_read_o <= 1'b0;
					reg2_read_o <= 1'b0;
					link_addr_o <= `ZeroWord;
					branch_flag_o <= `Branch;
					next_inst_in_delayslot_o <= `InDelaySlot;
					inst_valid <= `InstValid;
					branch_target_addr_o <= {pc_plus_4[31:28], inst_i[25:0], 2'b00};
				end
				`EXE_JAL: begin
					wreg_o <= `WriteEnable;
					aluop_o <= `EXE_JAL_OP;
					alusel_o <= `EXE_RES_JUMP_BRANCH;
					reg1_read_o <= 1'b0;
					reg2_read_o <= 1'b0;
					wd_o <= 5'b11111;
					link_addr_o <= pc_plus_8;
					branch_flag_o <= `Branch;
					next_inst_in_delayslot_o <= `InDelaySlot;
					inst_valid <= `InstValid;
					branch_target_addr_o <= {pc_plus_4[31:28], inst_i[25:0], 2'b00};
				end
				`EXE_BEQ: begin
					wreg_o <= `WriteDisable;
					aluop_o <= `EXE_BEQ_OP;
					alusel_o <= `EXE_RES_JUMP_BRANCH;
					reg1_read_o <= 1'b1;
					reg2_read_o <= 1'b1;
					inst_valid <= `InstValid;
					if (reg1_o == reg2_o)begin
						branch_target_addr_o <= pc_plus_4 + imm_sll2_signedext;
						branch_flag_o <= `Branch;
						next_inst_in_delayslot_o <= `InDelaySlot;
					end
				end
				`EXE_BGTZ: begin
					wreg_o <= `WriteDisable;
					aluop_o <= `EXE_BGTZ_OP;
					alusel_o <= `EXE_RES_JUMP_BRANCH;
					reg1_read_o <= 1'b1;
					reg2_read_o <= 1'b0;
					inst_valid <= `InstValid;
					if ((reg1_o[31] == 1'b0) && (reg1_o != `ZeroWord))begin
						branch_target_addr_o <= pc_plus_4 + imm_sll2_signedext;
						branch_flag_o <= `Branch;
						next_inst_in_delayslot_o <= `InDelaySlot;
					end
				end
				`EXE_BLEZ: begin
					wreg_o <= `WriteDisable;
					aluop_o <= `EXE_BLEZ_OP;
					alusel_o <= `EXE_RES_JUMP_BRANCH;
					reg1_read_o <= 1'b1;
					reg2_read_o <= 1'b0;
					inst_valid <= `InstValid;
					if ((reg1_o[31] == 1'b0) || (reg1_o == `ZeroWord))begin
						branch_target_addr_o <= pc_plus_4 + imm_sll2_signedext;
						branch_flag_o <= `Branch;
						next_inst_in_delayslot_o <= `InDelaySlot;
					end
				end
				`EXE_BNE: begin
					wreg_o <= `WriteDisable;
					aluop_o <= `EXE_BLEZ_OP;
					alusel_o <= `EXE_RES_JUMP_BRANCH;
					reg1_read_o <= 1'b1;
					reg2_read_o <= 1'b1;
					inst_valid <= `InstValid;
					if (reg1_o != reg2_o)begin
						branch_target_addr_o <= pc_plus_4 + imm_sll2_signedext;
						branch_flag_o <= `Branch;
						next_inst_in_delayslot_o <= `InDelaySlot;
					end
				end

				`EXE_LB: begin //LB inst
					wreg_o <= `WriteEnable;
					aluop_o <= `EXE_LB_OP;
					alusel_o <= `EXE_RES_LOAD_STORE;
					wd_o <= inst_i[20:16];
					reg1_read_o <= 1'b1;
					reg2_read_o <= 1'b0;
					inst_valid <= `InstValid;
				end
				`EXE_LBU: begin
					wreg_o <= `WriteEnable;
					aluop_o <= `EXE_LBU_OP;
					alusel_o <= `EXE_RES_LOAD_STORE;
					wd_o <= inst_i[20:16];
					reg1_read_o <= 1'b1;
					reg2_read_o <= 1'b0;
					inst_valid <= `InstValid;
				end
				`EXE_LH: begin
					wreg_o <= `WriteEnable;
					aluop_o <= `EXE_LH_OP;
					alusel_o <= `EXE_RES_LOAD_STORE;
					wd_o <= inst_i[20:16];
					reg1_read_o <= 1'b1;
					reg2_read_o <= 1'b0;
					inst_valid <= `InstValid;
				end
				`EXE_LHU: begin
					wreg_o <= `WriteEnable;
					aluop_o <= `EXE_LHU_OP;
					alusel_o <= `EXE_RES_LOAD_STORE;
					wd_o <= inst_i[20:16];
					reg1_read_o <= 1'b1;
					reg2_read_o <= 1'b0;
					inst_valid <= `InstValid;
				end
				`EXE_LW: begin
					wreg_o <= `WriteEnable;
					aluop_o <= `EXE_LW_OP;
					alusel_o <= `EXE_RES_LOAD_STORE;
					wd_o <= inst_i[20:16];
					reg1_read_o <= 1'b1;
					reg2_read_o <= 1'b0;
					inst_valid <= `InstValid;
				end
				`EXE_LWL: begin
					wreg_o <= `WriteEnable;
					aluop_o <= `EXE_LWL_OP;
					alusel_o <= `EXE_RES_LOAD_STORE;
					wd_o <= inst_i[20:16];
					reg1_read_o <= 1'b1;
					reg2_read_o <= 1'b1;
					inst_valid <= `InstValid;
				end
				`EXE_LWR: begin
					wreg_o <= `WriteEnable;
					aluop_o <= `EXE_LWR_OP;
					alusel_o <= `EXE_RES_LOAD_STORE;
					wd_o <= inst_i[20:16];
					reg1_read_o <= 1'b1;
					reg2_read_o <= 1'b1;
					inst_valid <= `InstValid;
				end
				`EXE_SB: begin
					wreg_o <= `WriteDisable;
					aluop_o <= `EXE_SB_OP;
					alusel_o <= `EXE_RES_LOAD_STORE;
					reg1_read_o <= 1'b1;
					reg2_read_o <= 1'b1;
					inst_valid <= `InstValid;
				end
				`EXE_SH: begin
					wreg_o <= `WriteDisable;
					aluop_o <= `EXE_SH_OP;
					alusel_o <= `EXE_RES_LOAD_STORE;
					reg1_read_o <= 1'b1;
					reg2_read_o <= 1'b1;
					inst_valid <= `InstValid;
				end
				`EXE_SW: begin
					wreg_o <= `WriteDisable;
					aluop_o <= `EXE_SW_OP;
					alusel_o <= `EXE_RES_LOAD_STORE;
					reg1_read_o <= 1'b1;
					reg2_read_o <= 1'b1;
					inst_valid <= `InstValid;
				end
				`EXE_SWL: begin
					wreg_o <= `WriteDisable;
					aluop_o <= `EXE_SWL_OP;
					alusel_o <= `EXE_RES_LOAD_STORE;
					reg1_read_o <= 1'b1;
					reg2_read_o <= 1'b1;
					inst_valid <= `InstValid;
				end
				`EXE_SWR: begin
					wreg_o <= `WriteDisable;
					aluop_o <= `EXE_SWR_OP;
					alusel_o <= `EXE_RES_LOAD_STORE;
					reg1_read_o <= 1'b1;
					reg2_read_o <= 1'b1;
					inst_valid <= `InstValid;
				end
				`EXE_LL: begin
					wreg_o <= `WriteEnable;
					aluop_o <= `EXE_LL_OP;
					alusel_o <= `EXE_RES_LOAD_STORE;
					reg1_read_o <= 1'b1;
					reg2_read_o <= 1'b0;
					wd_o <= inst_i[20:16];
					inst_valid <= `InstValid;
				end
				`EXE_SC: begin
					wreg_o <= `WriteEnable;
					aluop_o <= `EXE_SC_OP;
					alusel_o <= `EXE_RES_LOAD_STORE;
					reg1_read_o <= 1'b1;
					reg2_read_o <= 1'b1;
					inst_valid <= `InstValid;
				end
				`EXE_REGIMM_INST: begin 
					case(op4)
						`EXE_BGEZ: begin
							wreg_o <= `WriteDisable;
							aluop_o <= `EXE_BGEZ_OP;
							alusel_o <= `EXE_RES_JUMP_BRANCH;
							reg1_read_o <= 1'b1;
							reg2_read_o <= 1'b0;
							inst_valid <= `InstValid;
							if(reg1_o[31] == 1'b0) begin
								branch_target_addr_o <= pc_plus_4 + imm_sll2_signedext;
								branch_flag_o <= `Branch;
								next_inst_in_delayslot_o <= `InDelaySlot;
							end
						end 
						`EXE_BGEZAL: begin
							wreg_o <= `WriteEnable;
							aluop_o <= `EXE_BGEZAL_OP;
							alusel_o <= `EXE_RES_JUMP_BRANCH;
							reg1_read_o <= 1'b1;
							reg2_read_o <= 1'b0;
							inst_valid <= `InstValid;
							link_addr_o <= pc_plus_8;
							wd_o <= 5'b11111;
							if(reg1_o[31] == 1'b0) begin
								branch_target_addr_o <= pc_plus_4 + imm_sll2_signedext;
								branch_flag_o <= `Branch;
								next_inst_in_delayslot_o <= `InDelaySlot;
							end
						end
						`EXE_BLTZ: begin
							wreg_o <= `WriteDisable;
							aluop_o <= `EXE_BLTZ_OP;
							alusel_o <= `EXE_RES_JUMP_BRANCH;
							reg1_read_o <= 1'b1;
							reg2_read_o <= 1'b0;
							inst_valid <= `InstValid;
							if(reg1_o[31] == 1'b1) begin
								branch_target_addr_o <= pc_plus_4 + imm_sll2_signedext;
								branch_flag_o <= `Branch;
								next_inst_in_delayslot_o <= `InDelaySlot;
							end
						end
						`EXE_BLTZAL: begin
							wreg_o <= `WriteEnable;
							aluop_o <= `EXE_BLTZAL_OP;
							alusel_o <= `EXE_RES_JUMP_BRANCH;
							reg1_read_o <= 1'b1;
							reg2_read_o <= 1'b0;
							inst_valid <= `InstValid;
							link_addr_o <= pc_plus_8;
							wd_o <= 5'b11111;
							if(reg1_o[31] == 1'b1) begin
								branch_target_addr_o <= pc_plus_4 + imm_sll2_signedext;
								branch_flag_o <= `Branch;
								next_inst_in_delayslot_o <= `InDelaySlot;
							end
						end 
					endcase
				end
				`EXE_SPECIAL_INST: begin
					case(op2)
						5'b00000: begin 
							case(op3)
								`EXE_OR: begin
									wreg_o <= `WriteEnable;
									aluop_o <= `EXE_OR_OP;
									alusel_o <= `EXE_RES_LOGIC;
									reg1_read_o <= 1'b1;
									reg2_read_o <= 1'b1;
									inst_valid <= `InstValid;
								end
								`EXE_AND: begin
									wreg_o <= `WriteEnable;
									aluop_o <= `EXE_AND_OP;
									alusel_o <= `EXE_RES_LOGIC;
									reg1_read_o <= 1'b1;
									reg2_read_o <= 1'b1;
									inst_valid <= `InstValid;
								end
								`EXE_XOR: begin
									wreg_o <= `WriteEnable;
									aluop_o <= `EXE_XOR_OP;
									alusel_o <= `EXE_RES_LOGIC;
									reg1_read_o <= 1'b1;
									reg2_read_o <= 1'b1;
									inst_valid <= `InstValid;
								end
								`EXE_NOR: begin
									wreg_o <= `WriteEnable;
									aluop_o <= `EXE_NOR_OP;
									alusel_o <= `EXE_RES_LOGIC;
									reg1_read_o <= 1'b1;
									reg2_read_o <= 1'b1;
									inst_valid <= `InstValid;
								end
								`EXE_SLLV: begin
									wreg_o <= `WriteEnable;
									aluop_o <= `EXE_SLL_OP;  //op一开始没写对
									alusel_o <= `EXE_RES_SHIFT;
									reg1_read_o <= 1'b1;
									reg2_read_o <= 1'b1;
									inst_valid <= `InstValid;
								end
								`EXE_SRLV: begin
									wreg_o <= `WriteEnable;
									aluop_o <= `EXE_SRL_OP;
									alusel_o <= `EXE_RES_SHIFT;
									reg1_read_o <= 1'b1;
									reg2_read_o <= 1'b1;
									inst_valid <= `InstValid;
								end
								`EXE_SRAV: begin
									wreg_o <= `WriteEnable;
									aluop_o <= `EXE_SRA_OP;
									alusel_o <= `EXE_RES_SHIFT;
									reg1_read_o <= 1'b1;
									reg2_read_o <= 1'b1;
									inst_valid <= `InstValid;
								end
								`EXE_SYNC: begin
									wreg_o <= `WriteDisable;
									aluop_o <= `EXE_NOP_OP;
									alusel_o <= `EXE_RES_NOP;
									reg1_read_o <= 1'b0;
									reg2_read_o <= 1'b1;  //nop情况下这必须为1
									inst_valid <= `InstValid;
								end
								`EXE_MOVN: begin
									aluop_o <= `EXE_MOVN_OP;
									alusel_o <= `EXE_RES_MOV;
									reg1_read_o <= 1'b1;
									reg2_read_o <= 1'b1;
									inst_valid <= `InstValid;
									if (reg2_o != `ZeroWord) begin
										wreg_o <= `WriteEnable;
									end
									else begin
										wreg_o <= `WriteDisable;
									end
								end
								`EXE_MOVZ: begin
									aluop_o <= `EXE_MOVZ_OP;
									alusel_o <= `EXE_RES_MOV;
									reg1_read_o <= 1'b1;
									reg2_read_o <= 1'b1;
									inst_valid <= `InstValid;
									if (reg2_o == `ZeroWord) begin
										wreg_o <= `WriteEnable;
									end
									else begin
										wreg_o <= `WriteDisable;
									end
								end
								`EXE_MFHI: begin
									wreg_o <= `WriteEnable;
									aluop_o <= `EXE_MFHI_OP;
									alusel_o <= `EXE_RES_MOV;
									reg1_read_o <= 1'b0;
									reg2_read_o <= 1'b0;
									inst_valid <= `InstValid;
								end
								`EXE_MFLO: begin
									wreg_o <= `WriteEnable;
									aluop_o <= `EXE_MFLO_OP;
									alusel_o <= `EXE_RES_MOV;
									reg1_read_o <= 1'b0;
									reg2_read_o <= 1'b0;
									inst_valid <= `InstValid;
								end
								`EXE_MTHI: begin
									wreg_o <= `WriteDisable;
									aluop_o <= `EXE_MTHI_OP;
									// alusel_o <= `EXE_RES_MOV; //这个不需要有,因为并不是写到寄存器的,这个可有可无
									reg1_read_o <= 1'b1;
									reg2_read_o <= 1'b0;
									inst_valid <= `InstValid;
								end
								`EXE_MTLO: begin
									wreg_o <= `WriteDisable;
									aluop_o <= `EXE_MTLO_OP;
									// alusel_o <= `EXE_RES_MOV; //这个不需要有,因为并不是写到寄存器的,这个可有可无
									reg1_read_o <= 1'b1;
									reg2_read_o <= 1'b0;
									inst_valid <= `InstValid;
								end
								//arithmetic相关
								`EXE_ADD: begin
									wreg_o <= `WriteEnable;
									aluop_o <= `EXE_ADD_OP;
									alusel_o <= `EXE_RES_ARITH;
									reg1_read_o <= 1'b1;
									reg2_read_o <= 1'b1;
									inst_valid <= `InstValid;
								end
								`EXE_ADDU: begin
									wreg_o <= `WriteEnable;
									aluop_o <= `EXE_ADDU_OP;
									alusel_o <= `EXE_RES_ARITH;
									reg1_read_o <= 1'b1;
									reg2_read_o <= 1'b1;
									inst_valid <= `InstValid;
								end
								`EXE_SUB: begin
									wreg_o <= `WriteEnable;
									aluop_o <= `EXE_SUB_OP;
									alusel_o <= `EXE_RES_ARITH;
									reg1_read_o <= 1'b1;
									reg2_read_o <= 1'b1;
									inst_valid <= `InstValid;
								end
								`EXE_SUBU: begin
									wreg_o <= `WriteEnable;
									aluop_o <= `EXE_SUBU_OP;
									alusel_o <= `EXE_RES_ARITH;
									reg1_read_o <= 1'b1;
									reg2_read_o <= 1'b1;
									inst_valid <= `InstValid;
								end
								`EXE_SLT: begin
									wreg_o <= `WriteEnable;
									aluop_o <= `EXE_SLT_OP;
									alusel_o <= `EXE_RES_ARITH;
									reg1_read_o <= 1'b1;
									reg2_read_o <= 1'b1;
									inst_valid <= `InstValid;
								end
								`EXE_SLTU: begin
									wreg_o <= `WriteEnable;
									aluop_o <= `EXE_SLTU_OP;
									alusel_o <= `EXE_RES_ARITH;
									reg1_read_o <= 1'b1;
									reg2_read_o <= 1'b1;
									inst_valid <= `InstValid;
								end
								`EXE_MULT: begin
									wreg_o <= `WriteDisable;
									aluop_o <= `EXE_MULT_OP;
									// alusel_o <= `EXE_RES_ARITH;
									reg1_read_o <= 1'b1;
									reg2_read_o <= 1'b1;
									inst_valid <= `InstValid;
								end
								`EXE_MULTU: begin
									wreg_o <= `WriteDisable;
									aluop_o <= `EXE_MULTU_OP;
									// alusel_o <= `EXE_RES_ARITH;
									reg1_read_o <= 1'b1;
									reg2_read_o <= 1'b1;
									inst_valid <= `InstValid;
								end
								`EXE_DIV: begin
									wreg_o <= `WriteDisable;
									aluop_o <= `EXE_DIV_OP;
									reg1_read_o <= 1'b1;
									reg2_read_o <= 1'b1;
									inst_valid <= `InstValid;
								end
								`EXE_DIVU: begin
									wreg_o <= `WriteDisable;
									aluop_o <= `EXE_DIVU_OP;
									reg1_read_o <= 1'b1;
									reg2_read_o <= 1'b1;
									inst_valid <= `InstValid;
								end
								`EXE_JR: begin
									wreg_o <= `WriteDisable;
									aluop_o <= `EXE_JR_OP;
									alusel_o <= `EXE_RES_JUMP_BRANCH;
									reg1_read_o <= 1'b1;
									reg2_read_o <= 1'b0;
									link_addr_o <= `ZeroWord;
									branch_target_addr_o <= reg1_o;
									branch_flag_o <= `Branch;
									next_inst_in_delayslot_o <= `InDelaySlot;
									inst_valid <= `InstValid;
								end
								`EXE_JALR: begin
									wreg_o <= `WriteEnable;
									aluop_o <= `EXE_JALR_OP;
									alusel_o <= `EXE_RES_JUMP_BRANCH;
									reg1_read_o <= 1'b1;
									reg2_read_o <= 1'b0;
									wd_o <= inst_i[15:11];
									link_addr_o <= pc_plus_8;
									branch_target_addr_o <= reg1_o;
									branch_flag_o <= `Branch;
									next_inst_in_delayslot_o <= `InDelaySlot;
									inst_valid <= `InstValid;
								end
								default: begin
									
								end
							endcase
						end
						default: begin 
						end
					endcase
				end
				`EXE_SPECIAL2_INST: begin
					case(op3) 
						`EXE_CLZ: begin
							wreg_o <= `WriteEnable;
							aluop_o <= `EXE_CLZ_OP;
							alusel_o <= `EXE_RES_ARITH;
							reg1_read_o <= 1'b1;
							reg2_read_o <= 1'b0;
							inst_valid <= `InstValid;
						end
						`EXE_CLO: begin
							wreg_o <= `WriteEnable;
							aluop_o <= `EXE_CLO_OP;
							alusel_o <= `EXE_RES_ARITH;
							reg1_read_o <= 1'b1;
							reg2_read_o <= 1'b0;
							inst_valid <= `InstValid;
						end
						`EXE_MUL: begin
							wreg_o <= `WriteEnable;
							aluop_o <= `EXE_MUL_OP;
							alusel_o <= `EXE_RES_MUL;
							reg1_read_o <= 1'b1;
							reg2_read_o <= 1'b1;
							inst_valid <= `InstValid;
						end
						`EXE_MADD: begin
							wreg_o <= `WriteDisable;
							aluop_o <= `EXE_MADD_OP;
							alusel_o <= `EXE_RES_MUL; 
							reg1_read_o <= 1'b1;
							reg2_read_o <= 1'b1;
							inst_valid <= `InstValid;
						end
						`EXE_MADDU: begin
							wreg_o <= `WriteDisable;
							aluop_o <= `EXE_MADDU_OP;
							alusel_o <= `EXE_RES_MUL; 
							reg1_read_o <= 1'b1;
							reg2_read_o <= 1'b1;
							inst_valid <= `InstValid;
						end
						`EXE_MSUB: begin
							wreg_o <= `WriteDisable;
							aluop_o <= `EXE_MSUB_OP;
							alusel_o <= `EXE_RES_MUL; 
							reg1_read_o <= 1'b1;
							reg2_read_o <= 1'b1;
							inst_valid <= `InstValid;
						end
						`EXE_MSUBU: begin
							wreg_o <= `WriteDisable;
							aluop_o <= `EXE_MSUBU_OP;
							alusel_o <= `EXE_RES_MUL; 
							reg1_read_o <= 1'b1;
							reg2_read_o <= 1'b1;
							inst_valid <= `InstValid;
						end
					endcase
				end 
				default: begin
				end
			endcase  //case op
			if (inst_i[31:21] == 11'b00000000000) begin
				case (op3)
					`EXE_SLL: begin
						wreg_o <= `WriteEnable;
						aluop_o <= `EXE_SLL_OP;
						alusel_o <= `EXE_RES_SHIFT;
						reg1_read_o <= 1'b0;
						reg2_read_o <= 1'b1;
						imm[4:0] <= inst_i[10:6];
						wd_o <= inst_i[15:11];
						inst_valid <= `InstValid;
					end
					`EXE_SRL: begin
						wreg_o <= `WriteEnable;
						aluop_o <= `EXE_SRL_OP;
						alusel_o <= `EXE_RES_SHIFT;
						reg1_read_o <= 1'b0;
						reg2_read_o <= 1'b1;
						imm[4:0] <= inst_i[10:6];
						wd_o <= inst_i[15:11];
						inst_valid <= `InstValid;
					end
					`EXE_SRA: begin
						wreg_o <= `WriteEnable;
						aluop_o <= `EXE_SRA_OP;
						alusel_o <= `EXE_RES_SHIFT;
						reg1_read_o <= 1'b0;
						reg2_read_o <= 1'b1;
						imm[4:0] <= inst_i[10:6];
						wd_o <= inst_i[15:11];
						inst_valid <= `InstValid;
					end
					default: begin  //在load store以前基本上都没有写这个,波形里边会出现一个7c的aluop_o这个显然是不对的.
						wreg_o <= `WriteDisable;
						aluop_o <= `EXE_NOP_OP;
						alusel_o <= `EXE_RES_NOP;
						reg1_read_o <= 1'b0;
						reg2_read_o <= 1'b0;
						inst_valid <= `InstInvalid;
					end
				endcase
			end
		end
	end

	always @ (*) begin
		stallreq_for_reg1_loadrelate <= `NOSTOP;
		if(Rst_n == `RstEnable) begin
			reg1_o <= `ZeroWord;
		//数据前推
		end else if ((pre_inst_is_load == 1'b1) && (ex_wd_i == reg1_addr_o) && (reg1_read_o == 1'b1)) begin
			stallreq_for_reg1_loadrelate <= `STOP;
		end else if(reg1_read_o == 1'b1 && ex_wreg_i == 1'b1 && ex_wd_i == reg1_addr_o) begin 
			reg1_o <= ex_wdata_i;
		end else if (reg1_read_o == 1'b1 && mem_wreg_i == 1'b1 && mem_wd_i == reg1_addr_o)begin
			reg1_o <= mem_wdata_i;
		end else if (reg1_read_o == 1'b1) begin
			reg1_o <= reg1_data_i;
		end else if (reg1_read_o == 1'b0) begin
			reg1_o <= imm;
		end else begin
			reg1_o <= `ZeroWord;
		end
	end

	always @ (*) begin
		stallreq_for_reg2_loadrelate <= `NOSTOP;
		if(Rst_n == `RstEnable) begin
			reg2_o <= `ZeroWord;
		end else if ((pre_inst_is_load == 1'b1) && (ex_wd_i == reg2_addr_o) && (reg2_read_o == 1'b1)) begin
			stallreq_for_reg2_loadrelate <= `STOP; 
		end else if(reg2_read_o == 1'b1 && ex_wreg_i == 1'b1 && ex_wd_i == reg2_addr_o) begin 
			reg2_o <= ex_wdata_i;
		end else if (reg2_read_o == 1'b1 && mem_wreg_i == 1'b1 && mem_wd_i == reg2_addr_o)begin
			reg2_o <= mem_wdata_i;
		end else if (reg2_read_o == 1'b1) begin
			reg2_o <= reg2_data_i;
		end else if (reg2_read_o == 1'b0) begin
			reg2_o <= imm;
		end else begin
			reg2_o <= `ZeroWord;
		end
	end
	always @(*) begin
		if(Rst_n == `RstEnable) begin
			is_in_delayslot_o <= `NotInDelaySlot;
		end
		else begin
			is_in_delayslot_o <= is_in_delayslot_i;
		end
	end

	// always @(*) begin
	// 	if(Rst_n == `RstEnable) begin
	// 		stall_req_id <= `NOSTOP;
	// 	end
	// 	else begin
	// 		stall_req_id <= `NOSTOP;
	// 	end
	// end
endmodule