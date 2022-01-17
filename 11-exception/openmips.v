`include "define.v"
`include "pc.v"
`include "if_id.v"
`include "id.v"
`include "regfile.v"
`include "id_ex.v"
`include "ex.v"
`include "ex_mem.v"
`include "mem.v"
`include "mem_wb.v"
`include "hilo.v"
`include "ctrl.v"
`include "div.v"
`include "LLbit.v"
`include "cp0.v"
module openmips (
    input                           clk,
    input                           rst,
    input [`RegBus]                 rom_data_i,
    input wire [`RegBus]            ram_data_i,
    input wire [5:0]                int_i,

    output wire [`RegBus]           ram_addr_o,
    output wire                     ram_we_o,
    output wire [3:0]               ram_sel_o,
    output wire[`RegBus]            ram_data_o,
    output wire                     ram_ce_o, 
    output  wire [`RegBus]          rom_addr_o,
    output  wire                    rom_ce_o,
    output wire                     timer_int_o
);
    wire [`InstAddrBus]     pc;
    wire [`InstBus]         id_inst_i;
    wire [`InstAddrBus]     id_pc_i;

    wire [`AluOpBus]        id_aluop_o;
    wire [`AluSelBus]       id_alusel_o;
    wire [`RegBus]          id_reg1_o;
    wire [`RegBus]          id_reg2_o;
    wire                    id_wreg_o;
    wire [`RegAddrBus]      id_wd_o;

    wire [`AluOpBus]        ex_aluop_i;
    wire [`AluSelBus]       ex_alusel_i;
    wire [`RegBus]          ex_reg1_i;
    wire [`RegBus]          ex_reg2_i;
    wire                    ex_wreg_i;
    wire [`RegAddrBus]      ex_wd_i;
    
    wire                    ex_wreg_o;
    wire [`RegAddrBus]      ex_wd_o;
    wire [`RegBus]          ex_wdata_o;
    
    wire                    mem_wreg_i;
    wire [`RegAddrBus]      mem_wd_i;
    wire [`RegBus]          mem_wdata_i;

    wire                    mem_wreg_o;
    wire [`RegAddrBus]      mem_wd_o;
    wire [`RegBus]          mem_wdata_o;

    wire                    wb_wreg_i;
    wire [`RegAddrBus]      wb_wd_i;
    wire [`RegBus]          wb_wdata_i;

    wire                    reg1_read;
    wire                    reg2_read;
    wire [`RegBus]          reg1_data;    
    wire [`RegBus]          reg2_data;
    wire [`RegAddrBus]      reg1_addr;
    wire [`RegAddrBus]      reg2_addr;    

    wire [`RegBus]          hilo_hi_o;
    wire [`RegBus]          hilo_lo_o;
    
    wire                    wb_whilo;
    wire [`RegBus]          wb_hi;
    wire [`RegBus]          wb_lo;

    wire                    ex_whilo_o;
    wire [`RegBus]          ex_hi_o;
    wire [`RegBus]          ex_lo_o;
    wire                    exmem_whilo_o;
    wire [`RegBus]          exmem_hi_o;
    wire [`RegBus]          exmem_lo_o;
    wire                    mem_whilo_o;
    wire [`RegBus]          mem_hi_o;
    wire [`RegBus]          mem_lo_o;
    wire                    stall_from_id;
    wire                    stall_from_ex;
    wire [5:0]              ctrl_stall_o;
    wire [`DoubleRegBus]    ex_hilo_temp_i;
    wire [1:0]              ex_cnt_i;
    wire [`DoubleRegBus]    ex_hilo_temp_o;
    wire [1:0]              ex_cnt_o;

    wire            id_pc_branch_flag;
    wire [`RegBus]  id_pc_branch_target_address;
    wire [`RegBus]  id_inst_o;
    assign rom_addr_o = pc;

    wire flush;
    // wire[31:0]  mem_except_type_o;  
    wire [`RegBus] latest_epc;
    wire [`RegBus] ctrl_new_pc;
    ctrl ctrl0(
        .rst(rst),
        .stall_from_id(stall_from_id),
        .stall_from_ex(stall_from_ex),
        .excepttype_i(mem_except_type_o),
        .cp0_epc_i(latest_epc),
        .new_pc(ctrl_new_pc),
        .flush_o(flush),
        .stall(ctrl_stall_o)
    );
   
    pc_reg pc_reg0(
        .Clk(clk),
        .Rst(rst),
        .stall(ctrl_stall_o),
        .flush(flush),
        .new_pc(ctrl_new_pc),
        .branch_flag_i(id_pc_branch_flag),
	    .branch_target_address_i(id_pc_branch_target_address),
        .pc(pc),
        .ce(rom_ce_o)
    );

    if_id if_id0(
        .Clk(clk),
        .Rst_n(rst),
        .stall(ctrl_stall_o),
        .if_pc(pc),
        .if_inst(rom_data_i),
        .flush(flush),
        .id_pc(id_pc_i),
        .id_inst(id_inst_i)
    );
    wire            idex_id_is_in_delayslot;  //这是从id_ex模块到id模块
    wire            id_idex_is_in_delayslot;
    wire [`RegBus]  id_idex_link_addr;
    wire            id_idex_next_inst_in_delayslot;
    wire [`RegBus]  id2id_ex_except_type;		   	
    wire [`InstAddrBus]  id2id_ex_current_inst_addr_o;	
    id id0(
        .Rst_n(rst),
        .pc_i(id_pc_i),
        .inst_i(id_inst_i),

        .reg1_data_i(reg1_data),
        .reg2_data_i(reg2_data),
        .ex_wreg_i(ex_wreg_o),
        .ex_wdata_i(ex_wdata_o),
        .ex_wd_i(ex_wd_o),

        .mem_wreg_i(mem_wreg_o),
        .mem_wdata_i(mem_wdata_o),
        .mem_wd_i(mem_wd_o),
        .is_in_delayslot_i(idex_id_is_in_delayslot),
        .reg1_read_o(reg1_read),
        .reg2_read_o(reg2_read),
        .reg1_addr_o(reg1_addr),
        .reg2_addr_o(reg2_addr),
        .ex_aluop_i(ex_aluop_o),


        .aluop_o(id_aluop_o),
        .alusel_o(id_alusel_o),
        .reg1_o(id_reg1_o),
        .reg2_o(id_reg2_o),
        .wd_o(id_wd_o),
        .wreg_o(id_wreg_o),

        .branch_flag_o(id_pc_branch_flag),
	    .branch_target_addr_o(id_pc_branch_target_address),

	    .is_in_delayslot_o(id_idex_is_in_delayslot),
	    .link_addr_o(id_idex_link_addr),
	    .next_inst_in_delayslot_o(id_idex_next_inst_in_delayslot),
        .inst_o(id_inst_o),
        .except_type_o(id2id_ex_except_type),
        .current_inst_addr_o(id2id_ex_current_inst_addr_o),
        .stall_req_id(stall_from_id)
    );
    

    regfile reg_file0(
		.Clk(clk),
		.Rst_n(rst),

	 	.we(wb_wreg_i),
	 	.waddr(wb_wd_i),
		.wdata(wb_wdata_i),
        
		.re1(reg1_read),
	 	.raddr1(reg1_addr),
		.rdata1(reg1_data),

		.re2(reg2_read),
	 	.raddr2(reg2_addr),
	    .rdata2(reg2_data)
    );
    wire [`RegBus] id_ex2ex_inst_o;
    wire [`InstAddrBus] id_ex2ex_current_inst_addr;   
    wire [`RegBus] 	   id_ex2ex_except_type;	 
    id_ex id_ex0(
	    .Clk(clk), 
	    .Rst_n(rst),
        .stall(ctrl_stall_o),
	    .id_aluop(id_aluop_o),
	    .id_alusel(id_alusel_o),
	    .id_reg1(id_reg1_o),
	    .id_reg2(id_reg2_o),
	    .id_wd(id_wd_o),
	    .id_wreg(id_wreg_o),
        .id_link_address_i(id_idex_link_addr),
	    .id_is_in_delayslot_i(id_idex_is_in_delayslot),
	    .next_inst_in_delayslot_i(id_idex_next_inst_in_delayslot),
        .id_inst_i(id_inst_o),
        .flush_i(flush),
        .id_excepte_type_i(id2id_ex_except_type),
        .id_current_inst_addr_i(id2id_ex_current_inst_addr_o),
        .ex_current_inst_addr_o(id_ex2ex_current_inst_addr), 
        .ex_except_type_o(id_ex2ex_except_type),
        .ex_inst_o(id_ex2ex_inst_o),
	    .ex_aluop(ex_aluop_i),
	    .ex_alusel(ex_alusel_i),
	    .ex_reg1(ex_reg1_i),
	    .ex_reg2(ex_reg2_i),
	    .ex_wd(ex_wd_i),
	    .ex_wreg(ex_wreg_i),
        .ex_link_address_o(idex_ex_link_address),
	    .ex_is_in_delayslot_o(idex_ex_is_in_delayslot),
	    .is_in_delayslot_o(idex_id_is_in_delayslot)
    );

    
    wire [`DoubleRegBus] ex_div_result_i;
    wire                 ex_div_ready_i;
    wire [`RegBus]       ex_div_opdata1_o;
    wire [`RegBus]       ex_div_opdata2_o;
    wire                 ex_div_start_o;
    wire                 ex_signed_div_o;
    wire                 idex_ex_is_in_delayslot;
    wire [`RegBus]       idex_ex_link_address;

    wire [`AluOpBus] 	ex_aluop_o;
    wire [`RegBus] 		ex_mem_addr_o;
    wire [`RegBus]		ex_reg2_o;
    wire                  ex2ex_mem_cp0_reg_we;
    wire [4:0]            ex2ex_mem_cp0_reg_write_addr;
    wire [`RegBus]        ex2ex_mem_cp0_reg_data;
     
    wire [`RegBus] 	      ex2ex_mem_except_type;	    
    wire [`InstAddrBus]   ex2ex_mem_current_inst_addr;  
    wire  				  ex2ex_mem_is_in_delayslot; 
    ex ex0(
        .Rst_n(rst),
        .aluop_i(ex_aluop_i),
        .alusel_i(ex_alusel_i),
        .reg1_i(ex_reg1_i),
        .reg2_i(ex_reg2_i),
        .wd_i(ex_wd_i),
        .wreg_i(ex_wreg_i),
        .hilo_temp_i(ex_hilo_temp_i),
        .cnt_i(ex_cnt_i),
        .inst_i(id_ex2ex_inst_o),

        .link_addres_i(idex_ex_link_address),
	    .is_in_delayslot_i(idex_ex_is_in_delayslot),
        .mem_wen_hilo(mem_whilo_o),
        .mem_hi_i(mem_hi_o),
        .mem_lo_i(mem_lo_o),
        .wb_wen_hilo(wb_whilo),
        .wb_hi_i(wb_hi),
        .wb_lo_i(wb_lo),
        .hi_i(hilo_hi_o),
        .lo_i(hilo_lo_o),
        .div_result_i(ex_div_result_i),
	    .div_ready_i(ex_div_ready_i),
        .mem_cp0_reg_we(mem2wb_cp0_reg_we),
        .mem_cp0_reg_write_addr(mem2wb_cp0_reg_write_addr),
        .mem_cp0_reg_data(mem2wb_cp0_reg_data),
        .wb_cp0_reg_we(wb_cp0_reg_we_o),
        .wb_cp0_reg_write_addr(wb_cp0_reg_write_addr_o),
        .wb_cp0_reg_data(wb_cp0_reg_data_o),
        .cp0_reg_data_i(cp0_data_o),
        .except_type_i(id_ex2ex_except_type),
        .current_inst_addr_i(id_ex2ex_current_inst_addr),
        .except_type_o(ex2ex_mem_except_type),
        .current_inst_addr_o(ex2ex_mem_current_inst_addr),
        .is_in_delayslot_o(ex2ex_mem_is_in_delayslot),

        .cp0_reg_read_addr_o(cp0_raddr_i),
        .cp0_reg_we_o(ex2ex_mem_cp0_reg_we),
        .cp0_reg_write_addr_o(ex2ex_mem_cp0_reg_write_addr),
        .cp0_reg_data_o(ex2ex_mem_cp0_reg_data),


        .wd_o(ex_wd_o),
        .wreg_o(ex_wreg_o),
        .wdata_o(ex_wdata_o),

        .hi_o(ex_hi_o),
        .lo_o(ex_lo_o),
        .whilo_o(ex_whilo_o),
        .stall_req_ex(stall_from_ex),
        .hilo_temp_o(ex_hilo_temp_o),
        .cnt_o(ex_cnt_o),
        .aluop_o(ex_aluop_o),
	    .mem_addr_o(ex_mem_addr_o),
	    .reg2_o(ex_reg2_o),
        .div_opdata1_o(ex_div_opdata1_o),
	    .div_opdata2_o(ex_div_opdata2_o),
	    .div_start_o(ex_div_start_o),

	    .signed_div_o(ex_signed_div_o)

    );

    wire [`AluOpBus] 	mem_aluop_o;
    wire [`RegBus] 		mem_mem_addr_o;
    wire [`RegBus]		mem_reg2_o;

    wire                  ex_mem2mem_cp0_reg_we;
    wire [4:0]            ex_mem2mem_cp0_reg_write_addr;
    wire [`RegBus]        ex_mem2mem_cp0_reg_data;
    wire [`RegBus]        ex_mem2mem_except_type;
    wire [`InstAddrBus]   ex_mem2mem_current_inst_addr;
    wire                  ex_mem2mem_is_in_delayslot;
    ex_mem ex_mem0(
        .clk(clk),
        .Rst_n(rst),
        .hilo_temp_i(ex_hilo_temp_o),
        .cnt_i(ex_cnt_o),
        .stall(ctrl_stall_o),
        .ex_wd(ex_wd_o),
        .ex_wreg(ex_wreg_o),
        .ex_wdata(ex_wdata_o),
        .ex_whilo(ex_whilo_o),
        .ex_hi_i(ex_hi_o),
        .ex_lo_i(ex_lo_o), 
        .ex_aluop(ex_aluop_o),
        .ex_mem_addr(ex_mem_addr_o),
        .ex_reg2(ex_reg2_o), 
        .ex_cp0_reg_we_i(ex2ex_mem_cp0_reg_we),
        .ex_cp0_reg_write_addr_i(ex2ex_mem_cp0_reg_write_addr),
        .ex_cp0_reg_data_i(ex2ex_mem_cp0_reg_data),
        .flush_i(flush),
        .ex_except_type_i(ex2ex_mem_except_type),
        .ex_current_inst_addr_i(ex2ex_mem_current_inst_addr),
        .ex_is_in_delayslot_i(ex2ex_mem_is_in_delayslot),
        .mem_except_type_o(ex_mem2mem_except_type),
        .mem_current_inst_addr_o(ex_mem2mem_current_inst_addr),
        .mem_is_in_delayslot_o(ex_mem2mem_is_in_delayslot),
        .mem_cp0_reg_we_o(ex_mem2mem_cp0_reg_we),
        .mem_cp0_reg_write_addr_o(ex_mem2mem_cp0_reg_write_addr),
        .mem_cp0_reg_data_o(ex_mem2mem_cp0_reg_data), 

        .mem_aluop_o(mem_aluop_o),
        .mem_mem_addr_o(mem_mem_addr_o),
        .mem_reg2_o(mem_reg2_o),
        .mem_wd(mem_wd_i),
        .mem_wreg(mem_wreg_i),
        .mem_wdata(mem_wdata_i),
        .mem_whilo(exmem_whilo_o),
        .mem_hi_o(exmem_hi_o),
        .mem_lo_o(exmem_lo_o),
        .cnt_o(ex_cnt_i),
        .hilo_temp_o(ex_hilo_temp_i)
    );
    wire LLbit_reg_LLbit_o;
    wire wb_LLbit_value_o;
    wire wb_LLbit_we_o;
    wire mem_LLbit_value_o;
    wire mem_LLbit_we_o;
    wire                    mem2wb_cp0_reg_we;
    wire [4:0]              mem2wb_cp0_reg_write_addr;
    wire [`RegBus]          mem2wb_cp0_reg_data;
    wire                    wb_cp0_reg_we_o;
    wire [4:0]              wb_cp0_reg_write_addr_o;
    wire [`RegBus]          wb_cp0_reg_data_o;
    wire [`RegBus]        mem_except_type_o;
    // wire [`RegBus]       mem_cp0_epc_o;
    wire                 mem_is_in_delay_slot_o;
    wire [`InstAddrBus]  mem_current_inst_addr_o;
    
    mem mem0(
        .rst(rst),
        .wd_i(mem_wd_i),
        .wreg_i(mem_wreg_i),
        .wdata_i(mem_wdata_i),
        .whilo_i(exmem_whilo_o),
        .hi_i(exmem_hi_o),
        .lo_i(exmem_lo_o),
        .aluop_i(mem_aluop_o),
        .mem_addr_i(mem_mem_addr_o),
        .reg2_i(mem_reg2_o),
        .mem_data_i(ram_data_i),
        .LLbit_i(LLbit_reg_LLbit_o),
        .wb_LLbit_value_i(wb_LLbit_value_o),
        .wb_LLbit_we_i(wb_LLbit_we_o),
        .cp0_reg_we_i(ex_mem2mem_cp0_reg_we),
        .cp0_reg_write_addr_i(ex_mem2mem_cp0_reg_write_addr),
        .cp0_reg_data_i(ex_mem2mem_cp0_reg_data),

        .is_in_delay_slot_i(ex_mem2mem_is_in_delayslot),
        .except_type_i(ex_mem2mem_except_type),
        .current_inst_addr_i(ex_mem2mem_current_inst_addr),
        .cp0_status_i(cp0_status_o),
        .cp0_cause_i(cp0_cause_o),
        .cp0_epc_i(cp0_epc_o),
        .wb_cp0_reg_we(wb_cp0_reg_we_o),
        .wb_cp0_reg_write_addr(wb_cp0_reg_write_addr_o),
        .wb_cp0_reg_data(wb_cp0_reg_data_o),

        .except_type_o(mem_except_type_o),
        .cp0_epc_o(latest_epc),
        .is_in_delay_slot_o(mem_is_in_delay_slot_o),
        .current_inst_addr_o(mem_current_inst_addr_o),

        .cp0_reg_we_o(mem2wb_cp0_reg_we),
        .cp0_reg_write_addr_o(mem2wb_cp0_reg_write_addr),
        .cp0_reg_data_o(mem2wb_cp0_reg_data),
        .LLbit_we_o(mem_LLbit_we_o),
        .LLbit_value_o(mem_LLbit_value_o),
        .mem_addr_o(ram_addr_o),
        .mem_we_o(ram_we_o),
        .mem_sel_o(ram_sel_o),
        .mem_data_o(ram_data_o),
        .mem_ce_o(ram_ce_o), 
        .wd_o(mem_wd_o),
        .wreg_o(mem_wreg_o),
        .wdata_o(mem_wdata_o),
        .whilo_o(mem_whilo_o),
        .hi_o(mem_hi_o),
        .lo_o(mem_lo_o)
    );

    

    mem_wb mem_wb0(
        .clk(clk),
        .rst(rst),
        .stall(ctrl_stall_o),
        .mem_wd(mem_wd_o),
        .mem_wreg(mem_wreg_o),
        .mem_wdata(mem_wdata_o),
        .mem_whilo_i(mem_whilo_o),
        .mem_hi_i(mem_hi_o),
        .mem_lo_i(mem_lo_o),
        .mem_LLbit_we_i(mem_LLbit_we_o),
        .mem_LLbit_value_i(mem_LLbit_value_o),
        .mem_cp0_reg_we_i(mem2wb_cp0_reg_we),
        .mem_cp0_reg_write_addr_i(mem2wb_cp0_reg_write_addr),
        .mem_cp0_reg_data_i(mem2wb_cp0_reg_data),
        .flush_i(flush),

        .wb_cp0_reg_we_o(wb_cp0_reg_we_o),
        .wb_cp0_reg_write_addr_o(wb_cp0_reg_write_addr_o),
        .wb_cp0_reg_data_o(wb_cp0_reg_data_o),
        .wb_LLbit_we(wb_LLbit_we_o),
        .wb_LLbit_value(wb_LLbit_value_o),
        .wb_wd(wb_wd_i),
        .wb_wreg(wb_wreg_i),
        .wb_wdata(wb_wdata_i),
        .wb_whilo_o(wb_whilo),
        .wb_hi_o(wb_hi),
        .wb_lo_o(wb_lo)

    );
   
    HILO hilo(
    .rst(rst),
    .clk(clk),
    .we(wb_whilo),
    .hi_in(wb_hi),
    .lo_in(wb_lo),

    .hi_o(hilo_hi_o),
    .lo_o(hilo_lo_o)
    );

    div div0(
        .clk(clk),
        .Rst_n(rst),
        .signed_div_i(ex_signed_div_o),
        .opdata1_i(ex_div_opdata1_o),
        .opdata2_i(ex_div_opdata2_o),
        .start_i(ex_div_start_o),
        .annul_i(flush), 
        .result_o(ex_div_result_i),
        .ready_o(ex_div_ready_i)
    );

    LLbit_reg LLbit_reg0(
        .clk(clk),
        .Rst_n(rst),

        .flush(flush),

        .LLbit_i(wb_LLbit_value_o),
        .we(wb_LLbit_we_o),

        .LLbit_o(LLbit_reg_LLbit_o)
    );
    wire [`RegBus] cp0_data_o;
    wire [`RegBus] cp0_status_o;
    wire [`RegBus] cp0_cause_o;
    wire [`RegBus] cp0_epc_o;
    wire [4:0]     cp0_raddr_i;
    
    cp0 cp0(
    .clk(clk),
    .rst(rst),
    .raddr_i(cp0_raddr_i),
    .int_i(int_i),//外部中断声明
    .we_i(wb_cp0_reg_we_o),
    .waddr_i(wb_cp0_reg_write_addr_o),
    .wdata_i(wb_cp0_reg_data_o),
    .except_type_i(mem_except_type_o),
    .current_inst_addr_i(mem_current_inst_addr_o),
    .is_in_delayslot_i(mem_is_in_delay_slot_o),

    .data_o(cp0_data_o),
    .count_o(),
    .compare_o(),
    .status_o(cp0_status_o),
    .cause_o(cp0_cause_o),
    .epc_o(cp0_epc_o),
    .config_o(),
    .prid_o(),
    .timer_int_o(timer_int_o)  //定时器中断
);

endmodule