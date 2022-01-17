`include "define.v"
module cp0(
    input wire                  clk,
    input wire                  rst,
    input wire [4:0]            raddr_i,
    input wire [5:0]            int_i,//外部中断声明
    input wire                  we_i,
    input wire [4:0]            waddr_i,
    input wire [31:0]           wdata_i,
    input wire [`RegBus]        except_type_i,
    input wire [`InstAddrBus]   current_inst_addr_i,
    input wire                  is_in_delayslot_i,
    
    output reg [31:0]           data_o,
    output reg [31:0]           count_o,
    output reg [31:0]           compare_o,
    output reg [31:0]           status_o,
    output reg [31:0]           cause_o,
    output reg [31:0]           epc_o,
    output reg [31:0]           config_o,
    output reg [31:0]           prid_o,
    output reg                  timer_int_o  //定时器中断
);
    always @(posedge clk) begin
        if(rst == `RstEnable) begin
            count_o <= `ZeroWord;
            compare_o <= `ZeroWord;
            status_o <= 32'h10000000;
            cause_o <= `ZeroWord;
            epc_o <= `ZeroWord;
            config_o <= 32'h00008000;
            prid_o <= 32'h00870102;
            timer_int_o <= `InterruptNotAssert;
        end else begin
            count_o <= count_o + 1'b1;
            cause_o[15:10] <= int_i; 
            if (compare_o != `ZeroWord && count_o == compare_o) begin
                timer_int_o <= `InterruptAssert;
            end
            if (we_i == `WriteEnable) begin
                case (waddr_i)
                    `CP0_REG_COUNT_ADDR: begin
                        count_o <= wdata_i;
                    end
                    `CP0_REG_COMPARE_ADDR: begin
                        compare_o <= wdata_i;
                        timer_int_o <= `InterruptNotAssert;
                    end
                    `CP0_REG_STATUS_ADDR: begin
                        status_o <= wdata_i;
                    end
                    `CP0_REG_EPC_ADDR: begin
                        epc_o <= wdata_i;
                    end
                    `CP0_REG_CAUSE_ADDR: begin
                        cause_o[23:22] <= wdata_i[23:22];
                        cause_o[9:8] <= wdata_i[9:8];
                    end
                endcase
            end
            case (except_type_i)
                32'h00000001: begin //external interrupt
                    if(is_in_delayslot_i == `InDelaySlot) begin
                        epc_o <= current_inst_addr_i - 4;
                        cause_o[31] <= 1'b1;    //BD
                    end
                    else begin
                        epc_o <= current_inst_addr_i;
                        cause_o[31] <= 1'b0;
                    end
                    status_o[1] <= 1'b1;
                    cause_o[6:2] <= 5'b00000;
                end
                32'h00000008: begin //syscall
                    if(status_o[1] == 1'b0) begin
                        if(is_in_delayslot_i == `InDelaySlot) begin
                            epc_o <= current_inst_addr_i - 4;
                            cause_o[31] <= 1'b1;
                        end
                        else begin
                            epc_o <= current_inst_addr_i;
                            cause_o[31] <= 1'b0;
                        end
                    end
                    status_o[1] <= 1'b1;
                    cause_o[6:2] <= 5'b01000;
                end
                32'h0000000a: begin
                    if(status_o[1] == 1'b0) begin
                        if(is_in_delayslot_i == `InDelaySlot)begin
                            epc_o <= current_inst_addr_i -4;
                            cause_o[31] <= 1'b1;
                        end
                        else begin
                            epc_o <= current_inst_addr_i;
                            cause_o[31] <= 1'b0;
                        end
                    end
                    status_o[1] <= 1'b1;
                    cause_o[6:2] <= 5'b01010;
                end
                32'h0000000d: begin
                    if(status_o[1]==1'b0) begin
                        if(is_in_delayslot_i == `InDelaySlot) begin
                            epc_o <= current_inst_addr_i -4;
                            cause_o[31] <= 1'b1;
                        end
                        else begin
                            epc_o <= current_inst_addr_i;
                            cause_o[31] <= 1'b0;
                        end
                    end
                    status_o[1] <= 1'b1;
                    cause_o[6:2] <= 5'b01101;
                end
                32'h0000000c: begin
                    if(status_o == 1'b0) begin
                       epc_o <= current_inst_addr_i - 4;
                       cause_o[31] <= 1'b1; 
                    end
                    else begin
                        epc_o <= current_inst_addr_i;
                        cause_o[31] <= 1'b0;
                    end
                    status_o[1] <= 1'b1;
                    cause_o[6:2] <= 5'b01100;
                end
                32'h0000000e: begin
                    status_o[1] <= 1'b0;
                end
                default : begin
                    
                end
            endcase
        end
    end

    always @(*) begin
        if (rst == `RstEnable) begin
            data_o <= `ZeroWord;
        end else begin
            case(raddr_i)
                `CP0_REG_COUNT_ADDR: begin
                    data_o <= count_o;
                end
                `CP0_REG_COMPARE_ADDR: begin
                    data_o <= compare_o;
                end
                `CP0_REG_STATUS_ADDR: begin
                    data_o <= status_o;
                end
                `CP0_REG_CAUSE_ADDR: begin
                    data_o <= cause_o;
                end
                `CP0_REG_EPC_ADDR: begin
                    data_o <= epc_o;
                end
                `CP0_REG_PRID_ADDR: begin
                    data_o <= prid_o;
                end
                `CP0_REG_CONFIG_ADDR: begin
                    data_o <= config_o;
                end
                default: begin
                    data_o <= `ZeroWord;
                end
            endcase
        end
    end

endmodule