`include "define.v"
module pc_reg(
	input    					Clk,
	input    					Rst,
	input wire [5:0] 			stall,
	input wire    				branch_flag_i,
	input wire [`RegBus]  		branch_target_address_i,
	output reg [`InstAddrBus] 	pc,
	output reg 			     	ce
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
		else if(stall[0] == `NOSTOP) begin
			if (branch_flag_i == `Branch) begin
				pc <= branch_target_address_i;
			end
			else begin
				pc <= pc + 4'h4;
			end
		end
		// else begin //其他时候保持不变,但是时序电路有记忆功能,因此不用写也是保持.
		// 	pc <= pc;
		// end
	end
endmodule