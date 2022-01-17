`include "define.v"
module mem_wb (
    input wire                clk,
    input wire                rst,
    input wire [5:0]          stall,

    input wire [`RegAddrBus]  mem_wd,
    input wire                mem_wreg,
    input wire [`RegBus]      mem_wdata,

    input wire                mem_whilo_i,
    input wire [`RegBus]      mem_hi_i,
    input wire [`RegBus]      mem_lo_i,
    input wire                mem_LLbit_we_i,
    input wire                mem_LLbit_value_i,

    input wire                  mem_cp0_reg_we_i,
    input wire [4:0]            mem_cp0_reg_write_addr_i,
    input wire [`RegBus]        mem_cp0_reg_data_i,
    input wire                  flush_i,
    output reg                  wb_cp0_reg_we_o,
    output reg [4:0]            wb_cp0_reg_write_addr_o,
    output reg [`RegBus]        wb_cp0_reg_data_o,

    output reg                wb_LLbit_we,
    output reg                wb_LLbit_value,
    output reg [`RegAddrBus]  wb_wd,
    output reg                wb_wreg,
    output reg [`RegBus]      wb_wdata,

    output reg                wb_whilo_o,
    output reg [`RegBus]      wb_hi_o,
    output reg [`RegBus]      wb_lo_o
);
    always @(posedge clk) begin
        if (rst == `RstEnable) begin
            wb_wd <= `NOPRegAddr;
            wb_wreg <= `WriteDisable;
            wb_wdata <=`ZeroWord;
            wb_LLbit_value <= 1'b0;
            wb_LLbit_we <= 1'b0;
            wb_cp0_reg_we_o <= `WriteDisable;
            wb_cp0_reg_write_addr_o <= 5'd0;
            wb_cp0_reg_data_o <= `ZeroWord;
        end
        else if (flush_i == 1'b1) begin
            wb_wd <= `NOPRegAddr;
            wb_wreg <= `WriteDisable;
            wb_wdata <=`ZeroWord;
            wb_LLbit_value <= 1'b0;
            wb_LLbit_we <= 1'b0;
            wb_cp0_reg_we_o <= `WriteDisable;
            wb_cp0_reg_write_addr_o <= 5'd0;
            wb_cp0_reg_data_o <= `ZeroWord;
        end
        else if (stall[4]==`STOP && stall[5] == `NOSTOP) begin
            wb_wd <= `NOPRegAddr;
            wb_wreg <= `WriteDisable;
            wb_wdata <=`ZeroWord;
            wb_LLbit_we <= 1'b0;
            wb_LLbit_value <= 1'b0;

            wb_cp0_reg_we_o <= `WriteDisable;
            wb_cp0_reg_write_addr_o <= 5'd0;
            wb_cp0_reg_data_o <= `ZeroWord;
        end
        else if (stall[4] == `NOSTOP) begin
            wb_wd <= mem_wd;
            wb_wreg <= mem_wreg;
            wb_wdata <= mem_wdata;
            wb_LLbit_value <= mem_LLbit_value_i;
            wb_LLbit_we <= mem_LLbit_we_i;
            wb_cp0_reg_we_o <= mem_cp0_reg_we_i;
            wb_cp0_reg_write_addr_o <= mem_cp0_reg_write_addr_i;
            wb_cp0_reg_data_o <= mem_cp0_reg_data_i;
        end
    end
    always @(posedge clk) begin
        if (rst == `RstEnable) begin
            wb_whilo_o <= `WriteDisable;
            wb_hi_o <= `ZeroWord;
            wb_lo_o <= `ZeroWord;
        end
        else if (stall[4] == `STOP && stall[5] == `NOSTOP) begin
            wb_whilo_o <= `WriteDisable;
            wb_hi_o <= `ZeroWord;
            wb_lo_o <= `ZeroWord;
        end
        else if (stall[4] == `NOSTOP)begin
            wb_whilo_o <= mem_whilo_i;
            wb_hi_o <= mem_hi_i;
            wb_lo_o <= mem_lo_i;
        end
    end
endmodule