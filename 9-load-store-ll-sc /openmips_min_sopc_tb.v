`include "define.v"
`include "openmips_min_sopc.v"
`timescale 1ns/1ps
module openmips_min_sopc_tb();
    reg clk;
    reg rst;
    initial begin
        clk = 1'b0;
        forever #10 clk = ~clk;
    end
    
    initial begin
        $dumpfile("openmips_min_sopc_tb.vcd");
        $dumpvars(0, openmips_min_sopc_tb);
    end

    initial begin
        rst = `RstEnable;
        #195 rst = `RstDisable;
        #3000 $stop;
        $display("test complete");
    end
    openmips_min_sopc openmips_min_sopc0(
        .clk(clk),
        .rst(rst)
    );
endmodule