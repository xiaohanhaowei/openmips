`include "define.v"
module ram(
    input wire           clk,
    input wire           ce,
    input wire           we,
    input wire [`RegBus] addr,
    input wire [`RegBus] data,
    input wire [3:0]     sel,
    
    output reg [`RegBus] data_o

);
    reg [`ByteWidth] datamem0[0: `DataMemNum-1];
    reg [`ByteWidth] datamem1[0: `DataMemNum-1];
    reg [`ByteWidth] datamem2[0: `DataMemNum-1];
    reg [`ByteWidth] datamem3[0: `DataMemNum-1];
    
    //write 
    always @(clk) begin
        if(ce == `ChipDisable) begin
            data_o <= `ZeroWord;
        end
        else if (we == `WriteEnable) begin
            if (sel[3] == 1'b1)begin
                datamem3[addr[`DataMemNumLog2+1 : 2]] <= data[31:24];
            end
            if (sel[2] == 1'b1)begin
                datamem2[addr[`DataMemNumLog2+1 : 2]] <= data[23:16];
            end
            if (sel[1] == 1'b1)begin
                datamem1[addr[`DataMemNumLog2+1 : 2]] <= data[15:8];
            end
            if (sel[0] == 1'b1)begin
                datamem0[addr[`DataMemNumLog2+1 : 2]] <= data[7:0];  //为啥要这么写?
            end
        end
        
    end

    //read
    always @(*) begin
        if (ce==`ChipDisable) begin
            data_o <= `ZeroWord;
        end
        else if (we == `WriteDisable) begin
            data_o <= {datamem3[addr[`DataMemNumLog2+1:2]], 
                       datamem2[addr[`DataMemNumLog2+1:2]],
                       datamem1[addr[`DataMemNumLog2+1:2]],
                       datamem0[addr[`DataMemNumLog2+1:2]]};
        end else begin
            data_o <= `ZeroWord;
        end
    end

endmodule