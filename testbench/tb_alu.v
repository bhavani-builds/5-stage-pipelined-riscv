
`timescale 1ns / 1ps

module tb_alu;

    reg [31:0] operand_a;
    reg [31:0] operand_b;
    reg [3:0] alu_control;

    wire [31:0] result;
    wire zero;

    integer errors;

    alu dut (
        .operand_a(operand_a),
        .operand_b(operand_b),
        .alu_control(alu_control),
        .result(result),
        .zero(zero)
    );

    task check_result;
        input [31:0] expected;
        begin
            #1;
            if (result !== expected) begin
                $display(
                    "FAIL: control=%b A=%h B=%h expected=%h got=%h",
                    alu_control, operand_a, operand_b,
                    expected, result
                );
                errors = errors + 1;
            end
            else begin
                $display("PASS: result=%h", result);
            end
        end
    endtask

    initial begin
        errors = 0;
        operand_a = 32'd10;
        operand_b = 32'd5;

        // Addition: 10 + 5 = 15
        alu_control = 4'b0000;
        check_result(32'd15);

        // Subtraction: 10 - 5 = 5
        alu_control = 4'b0001;
        check_result(32'd5);

        // AND: 10 & 5 = 0
        alu_control = 4'b0010;
        check_result(32'd0);

        // OR: 10 | 5 = 15
        alu_control = 4'b0011;
        check_result(32'd15);

        // XOR: 10 ^ 5 = 15
        alu_control = 4'b0100;
        check_result(32'd15);

        // Left shift: 10 << 1 = 20
        operand_b = 32'd1;
        alu_control = 4'b0101;
        check_result(32'd20);

        // Right shift: 10 >> 1 = 5
        alu_control = 4'b0110;
        check_result(32'd5);

        // Signed less-than: 10 < 5 is false
        operand_a = 32'd10;
        operand_b = 32'd5;
        alu_control = 4'b0111;
        check_result(32'd0);

        // Unsigned less-than: 5 < 10 is true
        operand_a = 32'd5;
        operand_b = 32'd10;
        alu_control = 4'b1000;
        check_result(32'd1);

        if (errors == 0)
            $display("ALL ALU TESTS PASSED");
        else
            $display("ALU TESTS FAILED: %0d errors", errors);

        $finish;
    end

endmodule
