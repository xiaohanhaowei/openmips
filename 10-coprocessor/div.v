`include "define.v"
module div (
    input wire                  clk,
    input wire                  Rst_n,
    input wire                  signed_div_i,
    input wire [`RegBus]        opdata1_i,
    input wire [`RegBus]        opdata2_i,
    input wire                  start_i,
    input wire                  annul_i, 
    output reg [`DoubleRegBus]  result_o,
    output reg                  ready_o

);
    wire [32:0] div_temp;  //33bit?
    reg [5:0] cnt;
    reg [64:0] dividend;  //65bit?
    reg [1:0] state;
    reg [31:0] divisor;
    reg [31:0] temp_op1;
    reg [31:0] temp_op2;
    assign div_temp = {1'b0, dividend[63:32]} - {1'b0, divisor}; //时刻做减法
    always @(posedge clk) begin
        if(Rst_n == `RstEnable) begin
            result_o <= {`ZeroWord, `ZeroWord};
            ready_o <= `DivResNoReady;
            state <= `DivFree;
            dividend <= {1'b0, `ZeroWord, `ZeroWord};
        end 
        else begin
            case(state)
                `DivFree: begin
                    if (start_i == `DivStart && annul_i == 1'b0) begin
                        if (opdata2_i == 32'd0) begin
                            state <= `DivByZero;
                        end
                        else begin
                            state <= `DivOn;
                            cnt <= 6'd0;
                            dividend <= {1'b0, `ZeroWord, `ZeroWord};
                            if (signed_div_i == 1'b1 && opdata1_i[31] == 1'b1) begin
                                temp_op1 = ~opdata1_i + 1; // FixMe: 请记住,这是阻塞赋值
                            end
                            else begin
                                temp_op1 = opdata1_i;
                            end
                            if (signed_div_i == 1'b1 && opdata2_i[31] == 1'b1) begin
                                temp_op2 = ~opdata2_i + 1;  // TODO: 竟然是阻塞赋值?
                            end
                            else begin
                                temp_op2 = opdata2_i;
                            end
                            dividend[32:1] <= temp_op1;  //被除数所存的位置要注意!
                            divisor <= temp_op2;
                        end  
                    end
                    else begin
                        ready_o <= `DivResNoReady;
                        result_o <= {32'd0, 32'd0};
                    end
                end
                `DivByZero: begin
                    state <= `DivEnd;
                    dividend <= {`ZeroWord, `ZeroWord};
                end
                `DivOn: begin
                    if (annul_i == 1'b0) begin
                        if (cnt != 6'd32) begin
                            if (div_temp[32] == 1'b1) begin //
                                dividend <= {dividend[63:0], 1'b0};
                            end
                            else begin
                                dividend <= {div_temp[31:0], dividend[31:0], 1'b1};
                            end
                            cnt <= cnt + 1'b1;
                        end
                        else begin
                            state <= `DivEnd;
                            cnt <= 6'd0;
                            if ((signed_div_i == 1'b1) && ( (opdata1_i[31] ^ opdata2_i[31]) == 1'b1))begin
                                dividend[31:0] <= ~dividend[31:0] + 1'b1;
                            end
                            if ((signed_div_i == 1'b1) && ( (opdata1_i[31] ^ dividend[64]) == 1'b1)) begin
                                dividend[64:33] <= ~dividend[64:33] + 1;
                            end
                        end
                    end
                    else begin
                        state <= `DivFree;
                    end
                end
                `DivEnd: begin
                    result_o <= {dividend[64:33], dividend[31:0]};
                    ready_o <= `DivResReady;
                    if (start_i == `DivStop) begin
                        state <= `DivFree;
                        ready_o <= `DivResNoReady;
                        result_o <= {`ZeroWord, `ZeroWord};
                    end
                end
            endcase 
        end
    end
endmodule