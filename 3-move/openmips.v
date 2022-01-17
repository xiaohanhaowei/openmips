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
module openmips (
    input                   clk,
    input                   rst,
    input [`RegBus]         rom_data_i,
    output  wire [`RegBus]  rom_addr_o,
    output  wire            rom_ce_o
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
    assign rom_addr_o = pc;
    
    pc_reg pc_reg0(
        .Clk(clk),
        .Rst(rst),
        .pc(pc),
        .ce(rom_ce_o)
    );

    if_id if_id0(
        .Clk(clk),
        .Rst_n(rst),
        .if_pc(pc),
        .if_inst(rom_data_i),
        .id_pc(id_pc_i),
        .id_inst(id_inst_i)
    );

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

        .reg1_read_o(reg1_read),
        .reg2_read_o(reg2_read),
        .reg1_addr_o(reg1_addr),
        .reg2_addr_o(reg2_addr),


        .aluop_o(id_aluop_o),
        .alusel_o(id_alusel_o),
        .reg1_o(id_reg1_o),
        .reg2_o(id_reg2_o),
        .wd_o(id_wd_o),
        .wreg_o(id_wreg_o)
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

    id_ex id_ex0(
	    .Clk(clk), 
	    .Rst_n(rst),

	    .id_aluop(id_aluop_o),
	    .id_alusel(id_alusel_o),
	    .id_reg1(id_reg1_o),
	    .id_reg2(id_reg2_o),
	    .id_wd(id_wd_o),
	    .id_wreg(id_wreg_o),

	    .ex_aluop(ex_aluop_i),
	    .ex_alusel(ex_alusel_i),
	    .ex_reg1(ex_reg1_i),
	    .ex_reg2(ex_reg2_i),
	    .ex_wd(ex_wd_i),
	    .ex_wreg(ex_wreg_i)
    );

    // ex ex0(
	//     .Rst_n(rst),
	//     .aluop_i(ex_aluop_i),
	//     .alusel_i(ex_alusel_i),
	//     .reg1_i(ex_reg1_i),
	//     .reg2_i(ex_reg2_i),
	//     .wd_i(ex_wd_i),
	//     .wreg_i(ex_wreg_i),
    //     .hi_i(hilo_hi_o),
    //     .lo_i(hilo_lo_o),
	//     .wd_o(ex_wd_o),
	//     .wreg_o(ex_wreg_o),
	//     .wdata_o(ex_wdata_o),
    //     .hi_o(ex_hi_o),
    //     .lo_o(ex_lo_o),
    //     .whilo_o(ex_whilo_o)

    // );
    ex ex0(
        .Rst_n(rst),
        .aluop_i(ex_aluop_i),
        .alusel_i(ex_alusel_i),
        .reg1_i(ex_reg1_i),
        .reg2_i(ex_reg2_i),
        .wd_i(ex_wd_i),
        .wreg_i(ex_wreg_i),

        .mem_wen_hilo(mem_whilo_o),
        .mem_hi_i(mem_hi_o),
        .mem_lo_i(mem_lo_o),
        .wb_wen_hilo(wb_whilo),
        .wb_hi_i(wb_hi),
        .wb_lo_i(wb_lo),
        .hi_i(hilo_hi_o),
        .lo_i(hilo_lo_o),

        .wd_o(ex_wd_o),
        .wreg_o(ex_wreg_o),
        .wdata_o(ex_wdata_o),

        .hi_o(ex_hi_o),
        .lo_o(ex_lo_o),
        .whilo_o(ex_whilo_o)
     );


    ex_mem ex_mem0(
        .clk(clk),
        .Rst_n(rst),

        .ex_wd(ex_wd_o),
        .ex_wreg(ex_wreg_o),
        .ex_wdata(ex_wdata_o),
        .ex_whilo(ex_whilo_o),
        .ex_hi_i(ex_hi_o),
        .ex_lo_i(ex_lo_o), 

        .mem_wd(mem_wd_i),
        .mem_wreg(mem_wreg_i),
        .mem_wdata(mem_wdata_i),
        .mem_whilo(exmem_whilo_o),
        .mem_hi_o(exmem_hi_o),
        .mem_lo_o(exmem_lo_o)
    );

    mem mem0(
        .rst(rst),
        .wd_i(mem_wd_i),
        .wreg_i(mem_wreg_i),
        .wdata_i(mem_wdata_i),
        .whilo_i(exmem_whilo_o),
        .hi_i(exmem_hi_o),
        .lo_i(exmem_lo_o),
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
        .mem_wd(mem_wd_o),
        .mem_wreg(mem_wreg_o),
        .mem_wdata(mem_wdata_o),
        .mem_whilo_i(mem_whilo_o),
        .mem_hi_i(mem_hi_o),
        .mem_lo_i(mem_lo_o),
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

endmodule