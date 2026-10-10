
module riscv_pipeline (
    input wire clk,
    input wire reset
);

    // Program counter signals
    wire [31:0] pc_current;
    wire [31:0] pc_next;

    // Instruction fetch signals
    wire [31:0] instruction;

    // IF-ID pipeline register outputs
    wire [31:0] if_id_pc;
    wire [31:0] if_id_instruction;

    // Initial sequential PC progression
    assign pc_next = pc_current + 32'd4;

    // Program Counter
    program_counter pc_unit (
        .clk(clk),
        .reset(reset),
        .stall(1'b0),
        .next_pc(pc_next),
        .pc(pc_current)
    );

    // Instruction Memory placeholder
    // Replace with instruction_memory.v in a later step
    assign instruction = 32'h00000013; // RISC-V NOP

    // IF-ID Pipeline Register
    if_id_register if_id_unit (
        .clk(clk),
        .reset(reset),
        .stall(1'b0),
        .flush(1'b0),
        .pc_in(pc_current),
        .instruction_in(instruction),
        .pc_out(if_id_pc),
        .instruction_out(if_id_instruction)
    );

endmodule
