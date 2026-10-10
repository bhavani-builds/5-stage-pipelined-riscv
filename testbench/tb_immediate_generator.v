
`timescale 1ns / 1ps

module tb_immediate_generator;

    reg [31:0] instruction;
    wire [31:0] immediate;
    integer errors;

    immediate_generator dut (
        .instruction(instruction),
        .immediate(immediate)
    );

    task check_immediate;
        input [31:0] expected;
        begin
            #1;
            if (immediate !== expected) begin
                $display(
                    "FAIL: instruction=%h expected=%h actual=%h",
                    instruction, expected, immediate
                );
                errors = errors + 1;
            end
            else begin
                $display(
                    "PASS: instruction=%h immediate=%h",
                    instruction, immediate
                );
            end
        end
    endtask

    initial begin
        errors = 0;

        // ADDI x1, x0, 10: I-type immediate
        instruction = 32'h00A00093;
        check_immediate(32'd10);

        // ADDI x1, x0, -1: sign extension
        instruction = 32'hFFF00093;
        check_immediate(32'hFFFFFFFF);

        // SW x2, 4(x1): S-type immediate
        instruction = 32'h0020A223;
        check_immediate(32'd4);

        // BEQ x1, x2, +8: B-type immediate
        instruction = 32'h00208463;
        check_immediate(32'd8);

        // Unsupported instruction
        instruction = 32'hFFFFFFFF;
        check_immediate(32'd0);

        if (errors == 0)
            $display("ALL IMMEDIATE GENERATOR TESTS PASSED");
        else
            $display("TESTS FAILED: %0d errors", errors);

        $finish;
    end

endmodule
