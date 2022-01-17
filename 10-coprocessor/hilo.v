`include "define.v"
module HILO(
    input wire              rst,
    input wire              clk,
    input wire              we,
    input wire [`RegBus]    hi_in,
    input wire [`RegBus]    lo_in,

    output reg [`RegBus]    hi_o,
    output reg [`RegBus]    lo_o
);
    always @(posedge clk) begin
        if (rst == `RstEnable) begin
            hi_o <= `ZeroWord;
            lo_o <= `ZeroWord;
        end
        else if(we == `WriteEnable) begin
            hi_o <= hi_in;
            lo_o <= lo_in;
        end  
        // else begin
        //     hi_o <= `ZeroWord;
        //     lo_o <= `ZeroWord;
        // end      
    end
endmodule 