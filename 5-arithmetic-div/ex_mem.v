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

    output reg[`RegAddrBus]     mem_wd,
    output reg                  mem_wreg,
    output reg[`RegBus]         mem_wdata,

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
        end 
        else if (stall[3] == `STOP && stall[4] == `NOSTOP) begin
            mem_wd <= `NOPRegAddr;
            mem_wreg <= `WriteDisable;
            mem_wdata <= `ZeroWord;
            hilo_temp_o <= hilo_temp_i;
            cnt_o <= cnt_i;
        end
        else if (stall[3] == `NOSTOP) begin 
            mem_wd <= ex_wd;
            mem_wreg <= ex_wreg;
            mem_wdata <= ex_wdata;
            hilo_temp_o <= {`ZeroWord,`ZeroWord};
            cnt_o <= 2'b00;
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
        end
        else if (stall[3] == `STOP && stall[4] == `NOSTOP) begin
            mem_whilo <= `WriteDisable;
            mem_hi_o <= `ZeroWord;
            mem_lo_o <= `ZeroWord;
        end
        else if (stall[3] == `NOSTOP)begin
            mem_whilo <= ex_whilo;
            mem_hi_o <= ex_hi_i;
            mem_lo_o <= ex_lo_i;
        end
    end

endmodule