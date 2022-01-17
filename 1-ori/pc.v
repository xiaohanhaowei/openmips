`include "define.v"
module pc_reg(
	input    Clk,
	input    Rst,
	output reg [`InstAddrBus] pc,
	output reg 			     ce
);
	always @(posedge Clk) begin
		if (Rst == `RstEnable) begin
			// reset
			ce <= `ChipDisable;
		end
		else begin
			ce <= `ChipEnable;		
		end 
	end

	always @(posedge Clk) begin
		if (ce == `ChipDisable) begin
			pc <= 32'h00000000;		
		end
		else begin
			pc <= pc + 4'h4;
		end
	end
endmodule