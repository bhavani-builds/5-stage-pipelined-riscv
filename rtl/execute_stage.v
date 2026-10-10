
module execute_stage (
    input wire [31:0] rs1_data,
    input wire [31:0] rs2_data,
    input wire [31:0] immediate,
    input wire [3:0] alu_control,
    input wire alu_src,

    input wire [1:0] forward_a,
    input wire [1:0] forward_b,
    input wire [31:0] ex_mem_result,
    input wire [31:0] mem_wb_result,

    output wire [31:0] alu_result,
    output wire zero
);

    reg [31:0] operand_a;
    reg [31:0] forwarded_b;
    wire [31:0] operand_b;

    // Select the first ALU operand
    always @(*) begin
        case (forward_a)
            2'b00: operand_a = rs1_data;
            2'b01: operand_a = mem_wb_result;
            2'b10: operand_a = ex_mem_result;
            default: operand_a = rs1_data;
        endcase
    end

    // Select the second register operand
    always @(*) begin
        case (forward_b)
            2'b00: forwarded_b = rs2_data;
            2'b01: forwarded_b = mem_wb_result;
            2'b10: forwarded_b = ex_mem_result;
            default: forwarded_b = rs2_data;
        endcase
    end

    // Select register data or immediate
    assign operand_b = alu_src ? immediate : forwarded_b;

    // Arithmetic Logic Unit
    alu alu_unit (
        .operand_a(operand_a),
        .operand_b(operand_b),
        .alu_control(alu_control),
        .result(alu_result),
        .zero(zero)
    );

endmodule
