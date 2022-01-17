`include "define.v"
module LLbit_reg(
    input wire      clk,
    input wire      Rst_n,

    input wire      flush,

    input wire      LLbit_i,
    input wire      we,

    output reg      LLbit_o
);
    always @(clk) begin
        if(Rst_n == `RstEnable) begin
            LLbit_o <= 1'b0;
        end else if (flush == 1'b1) begin
            LLbit_o <= 1'b0;
        end else if (we == `WriteEnable) begin
            LLbit_o <= LLbit_i;
        end
    end
endmodule