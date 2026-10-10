
module decode_stage (
    input wire clk,
    input wire reset,

    input wire [31:0] instruction,

    input wire [4:0] wb_rd,
    input wire [31:0] wb_data,
    input wire wb_reg_write,

    output wire [31:0] rs1_data,
    output wire [31:0] rs2_data,
    output wire [31:0] immediate,

    output wire [4:0] rs1,
    output wire [4:0] rs2,
    output wire [4:0] rd,

    output wire reg_write,
    output wire mem_read,
    output wire mem_write,
    output wire mem_to_reg,
    output wire alu_src,
    output wire branch,
    output wire [3:0] alu_control
);

    assign rs1 = instruction[19:15];
    assign rs2 = instruction[24:20];
    assign rd  = instruction[11:7];

    // Register File
    register_file rf (
        .clk(clk),
        .reset(reset),
        .rs1(rs1),
        .rs2(rs2),
        .rd(wb_rd),
        .write_data(wb_data),
        .reg_write(wb_reg_write),
        .read_data1(rs1_data),
        .read_data2(rs2_data)
    );

    // Immediate Generator
    immediate_generator imm_gen (
        .instruction(instruction),
        .immediate(immediate)
    );

    // Control Unit
    control_unit control (
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
