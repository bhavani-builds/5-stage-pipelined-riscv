
module branch_unit (
    input wire [31:0] pc,
    input wire [31:0] immediate,
    input wire [31:0] rs1_data,
    input wire [31:0] rs2_data,
    input wire branch,
    input wire [2:0] funct3,

    output wire branch_taken,
    output wire [31:0] branch_target
);

    wire equal;
    wire signed_less;
    wire unsigned_less;

    assign equal = (rs1_data == rs2_data);
    assign signed_less = ($signed(rs1_data) < $signed(rs2_data));
    assign unsigned_less = (rs1_data < rs2_data);

    assign branch_target = pc + immediate;

    reg condition;

    always @(*) begin
        case (funct3)
            3'b000: condition = equal;          // BEQ
            3'b001: condition = !equal;         // BNE
            3'b100: condition = signed_less;    // BLT
            3'b101: condition = !signed_less;   // BGE
            3'b110: condition = unsigned_less;  // BLTU
            3'b111: condition = !unsigned_less; // BGEU
            default: condition = 1'b0;
        endcase
    end

    assign branch_taken = branch && condition;

endmodule
