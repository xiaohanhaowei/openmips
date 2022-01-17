`include "openmips.v"
`include "inst_rom.v"
`include "ram.v"
module openmips_min_sopc (
    input clk,
    input rst
);
    wire [`InstAddrBus] inst_addr;
    wire [`InstBus]     inst;
    wire                rom_ce;
    wire [`RegBus]      ram_data_i_wire;          
    wire [`RegBus]      ram_addr_wire;      
    wire                ram_we_wire;     
    wire [3:0]          ram_sel_wire;     
    wire[`RegBus]       ram_data_o_wire;     
    wire                ram_ce_wire;     
    openmips openmips0(
        .clk(clk),
        .rst(rst),
        .rom_data_i(inst),
        .ram_data_i(ram_data_i_wire),
        .ram_addr_o(ram_addr_wire),
        .ram_we_o(ram_we_wire),
        .ram_sel_o(ram_sel_wire),
        .ram_data_o(ram_data_o_wire),
        .ram_ce_o(ram_ce_wire), 
        .rom_addr_o(inst_addr),
        .rom_ce_o(rom_ce)
    );
    inst_rom inst_rom0(
        .ce(rom_ce),
        .addr(inst_addr),
        .inst(inst)  
    );
    ram ram0(
    .clk(clk),
    .ce(ram_ce_wire),
    .we(ram_we_wire),
    .addr(ram_addr_wire),
    .data(ram_data_o_wire),
    .sel(ram_sel_wire),
    .data_o(ram_data_i_wire)

);

endmodule