
module alu (
    input wire [31:0] operand_a,
    input wire [31:0] operand_b,
    input wire [3:0] alu_control,

    output reg [31:0] result,
    output wire zero
);

    always @(*) begin
        case (alu_control)
            4'b0000: result = operand_a + operand_b;
            4'b0001: result = operand_a - operand_b;
            4'b0010: result = operand_a & operand_b;
            4'b0011: result = operand_a | operand_b;
            4'b0100: result = operand_a ^ operand_b;
            4'b0101: result = operand_a << operand_b[4:0];
            4'b0110: result = operand_a >> operand_b[4:0];
            4'b0111: result =
                ($signed(operand_a) < $signed(operand_b)) ? 32'd1 : 32'd0;
            4'b1000: result =
                (operand_a < operand_b) ? 32'd1 : 32'd0;
            default: result = 32'b0;
        endcase
    end

    assign zero = (result == 32'b0);

endmodule
