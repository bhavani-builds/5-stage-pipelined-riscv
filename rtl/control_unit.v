
module control_unit (
    input wire [31:0] instruction,

    output wire reg_write,
    output wire mem_read,
    output wire mem_write,
    output wire mem_to_reg,
    output wire alu_src,
    output wire branch,
    output wire [3:0] alu_control
);

    instruction_decoder decoder_unit (
        .instruction(instruction),
        .reg_write(reg_write),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .mem_to_reg(mem_to_reg),
        .alu_src(alu_src),
        .branch(branch),
        .alu_control(alu_control)
    );

endmodule
