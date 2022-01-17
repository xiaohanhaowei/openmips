`include "define.v"
module ctrl (
    input wire          rst,
    input wire          stall_from_id,
    input wire          stall_from_ex,
    output reg [5:0]    stall
);
    always @(*) begin
        if (rst == `RstEnable) begin
            stall <= 6'd0;
        end
        else if (stall_from_ex == `STOP) begin
            stall <= 6'b001111;
        end
        else if(stall_from_id == `STOP) begin
            stall <= 6'b000111;
        end
        else begin
            stall <= 6'd0;
        end
    end
endmodule
    