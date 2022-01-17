`include "define.v"
module mem_wb (
    input wire                clk,
    input wire                rst,
    input wire [`RegAddrBus]  mem_wd,
    input wire                mem_wreg,
    input wire [`RegBus]      mem_wdata,

    input wire                mem_whilo_i,
    input wire [`RegBus]      mem_hi_i,
    input wire [`RegBus]      mem_lo_i,

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
        end
        else begin
            wb_wd <= mem_wd;
            wb_wreg <= mem_wreg;
            wb_wdata <= mem_wdata;
        end
    end
    always @(posedge clk) begin
        if (rst == `RstEnable) begin
            wb_whilo_o <= `WriteDisable;
            wb_hi_o <= `ZeroWord;
            wb_lo_o <= `ZeroWord;
        end else begin
            wb_whilo_o <= mem_whilo_i;
            wb_hi_o <= mem_hi_i;
            wb_lo_o <= mem_lo_i;
        end
    end
endmodule