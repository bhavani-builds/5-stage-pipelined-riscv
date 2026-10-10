
module execute_stage_full (
    input wire [31:0] rs1_data,
    input wire [31:0] rs2_data,
    input wire [31:0] immediate,

    input wire [3:0] alu_control,
    input wire alu_src,

    input wire [1:0] forward_a,
    input wire [1:0] forward_b,

    input wire [31:0] ex_mem_alu_result,
    input wire [31:0] mem_wb_write_data,

    output wire [31:0] alu_result,
    output wire zero,
    output wire [31:0] forwarded_rs2_data
);

    reg [31:0] operand_a;
    reg [31:0] operand_b_register;

    wire [31:0] operand_b;

    // Select the latest value for source register 1.
    always @(*) begin
        case (forward_a)
            2'b10: operand_a = ex_mem_alu_result;
            2'b01: operand_a = mem_wb_write_data;
            default: operand_a = rs1_data;
        endcase
    end

    // Select the latest value for source register 2.
    always @(*) begin
        case (forward_b)
            2'b10: operand_b_register = ex_mem_alu_result;
            2'b01: operand_b_register = mem_wb_write_data;
            default: operand_b_register = rs2_data;
        endcase
    end

    // Preserve forwarded source-2 data for store instructions.
    assign forwarded_rs2_data = operand_b_register;

    // Select register data or immediate for ALU operand B.
    assign operand_b = alu_src ? immediate : operand_b_register;

    // Arithmetic and logic operations.
    alu alu_unit (
        .a(operand_a),
        .b(operand_b),
        .alu_control(alu_control),
        .result(alu_result),
        .zero(zero)
    );

endmodule
