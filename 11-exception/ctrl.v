`include "define.v"
module ctrl (
    input wire              rst,
    input wire              stall_from_id,
    input wire              stall_from_ex,
    input wire[31:0]        excepttype_i,
    input wire [`RegBus]    cp0_epc_i,
    output reg [`RegBus]    new_pc,
    output reg              flush_o,
    output reg [5:0]        stall
);
    always @(*) begin
        if (rst == `RstEnable) begin
            stall <= 6'd0;
            flush_o <= 1'b0;
            new_pc <= `ZeroWord;
        end
        else if (excepttype_i != `ZeroWord) begin
            flush_o <= 1'b1;
            stall <= 6'd0;
            case (excepttype_i)
                32'h1: begin
                    new_pc <= 32'h00000020;
                end 
                32'h00000008:begin
                    new_pc<= 32'h00000040;
                end
                32'h0000000a: begin
                    new_pc <= 32'h00000040;
                end
                32'h0000000d: begin
                    new_pc <= 32'h00000040;
                end
                32'h0000000c: begin
                    new_pc <= 32'h00000040;
                end
                32'h0000000e: begin
                    new_pc <= cp0_epc_i;
                end
                default: begin
                    
                end
            endcase
        end
        else if (stall_from_ex == `STOP) begin
            stall <= 6'b001111;
            flush_o <= 1'b0;
        end
        else if(stall_from_id == `STOP) begin
            stall <= 6'b000111;
            flush_o <= 1'b0;
        end
        else begin
            stall <= 6'd0;
            flush_o <= 1'b0;
            new_pc <= `ZeroWord;
        end
    end
endmodule
    