`include "define.v"
module ex_mem (
    input wire                  clk,
    input wire                  Rst_n,
    input wire [1:0]            cnt_i,
    input wire [`DoubleRegBus]  hilo_temp_i,
    input wire [5:0]            stall,
    input wire[`RegAddrBus]     ex_wd,
    input wire                  ex_wreg,
    input wire [`RegBus]        ex_wdata,

    input wire                  ex_whilo,
    input wire [`RegBus]        ex_hi_i,
    input wire [`RegBus]        ex_lo_i,

    input wire [`AluOpBus]      ex_aluop,
    input wire [`RegBus]        ex_mem_addr,
    input wire [`RegBus]        ex_reg2,  

    input wire                  ex_cp0_reg_we_i,
    input wire [4:0]            ex_cp0_reg_write_addr_i,
    input wire [`RegBus]        ex_cp0_reg_data_i,

    output reg                  mem_cp0_reg_we_o,
    output reg [4:0]            mem_cp0_reg_write_addr_o,
    output reg [`RegBus]        mem_cp0_reg_data_o,

    output reg[`RegAddrBus]     mem_wd,
    output reg                  mem_wreg,
    output reg[`RegBus]         mem_wdata,

    output reg [`AluOpBus]      mem_aluop_o,
    output reg [`RegBus]        mem_mem_addr_o,
    output reg [`RegBus]        mem_reg2_o,

    output reg                  mem_whilo,
    output reg [`RegBus]        mem_hi_o,
    output reg [`RegBus]        mem_lo_o,
    output reg [1:0]            cnt_o,
    output reg [`DoubleRegBus]  hilo_temp_o
);
    always @(posedge clk) begin
        if (Rst_n == `RstEnable) begin 
            mem_wd <= `NOPRegAddr;
            mem_wreg <= `WriteDisable;
            mem_wdata <= `ZeroWord;

            mem_cp0_reg_we_o <= 1'b0;
            mem_cp0_reg_write_addr_o <= 5'd0;
            mem_cp0_reg_data_o <= `ZeroWord;
        end 
        else if (stall[3] == `STOP && stall[4] == `NOSTOP) begin
            mem_wd <= `NOPRegAddr;
            mem_wreg <= `WriteDisable;
            mem_wdata <= `ZeroWord;
            hilo_temp_o <= hilo_temp_i;
            cnt_o <= cnt_i;
            mem_cp0_reg_we_o <= 1'b0;
            mem_cp0_reg_write_addr_o <= 5'd0;
            mem_cp0_reg_data_o <= `ZeroWord;
        end
        else if (stall[3] == `NOSTOP) begin 
            mem_wd <= ex_wd;
            mem_wreg <= ex_wreg;
            mem_wdata <= ex_wdata;
            hilo_temp_o <= {`ZeroWord,`ZeroWord};
            cnt_o <= 2'b00;
            mem_cp0_reg_we_o <= ex_cp0_reg_we_i;
            mem_cp0_reg_write_addr_o <= ex_cp0_reg_write_addr_i;
            mem_cp0_reg_data_o <= ex_cp0_reg_data_i;
        end
        else begin
            hilo_temp_o <= hilo_temp_i;
            cnt_o <= cnt_i;
        end
    end

    always @(posedge clk) begin
        if (Rst_n == `RstEnable) begin
            mem_whilo <= `WriteDisable;
            mem_hi_o <= `ZeroWord;
            mem_lo_o <= `ZeroWord;
            mem_aluop_o <= `EXE_NOP_OP;
            mem_mem_addr_o <= `ZeroWord;
            mem_reg2_o <= `ZeroWord;
        end
        else if (stall[3] == `STOP && stall[4] == `NOSTOP) begin
            mem_whilo <= `WriteDisable;
            mem_hi_o <= `ZeroWord;
            mem_lo_o <= `ZeroWord;
            mem_aluop_o <= `EXE_NOP_OP;
            mem_mem_addr_o <= `ZeroWord;
            mem_reg2_o <= `ZeroWord;
        end
        else if (stall[3] == `NOSTOP)begin
            mem_whilo <= ex_whilo;
            mem_hi_o <= ex_hi_i;
            mem_lo_o <= ex_lo_i;
            mem_aluop_o <= ex_aluop;
            mem_mem_addr_o <= ex_mem_addr;
            mem_reg2_o <= ex_reg2;
        end
    end

endmodule