`include "openmips.v"
`include "inst_rom.v"

module openmips_min_sopc (
    input clk,
    input rst
);
    wire [`InstAddrBus] inst_addr;
    wire [`InstBus]     inst;
    wire                rom_ce;

    openmips openmips0(
        .clk(clk),
        .rst(rst),
        .rom_data_i(inst),
        .rom_addr_o(inst_addr),
        .rom_ce_o(rom_ce)
    );
    inst_rom inst_rom0(
        .ce(rom_ce),
        .addr(inst_addr),
        .inst(inst)  
    );

endmodule