
`timescale 1ns/1ps

module tb_instruction_memory;

    reg [31:0] address;
    wire [31:0] instruction;

    integer passed;

    instruction_memory uut (
        .address(address),
        .instruction(instruction)
    );

    task check_instruction;
        input [31:0] test_address;
        input [31:0] expected_instruction;
        input [8*40-1:0] test_name;
        begin
            address = test_address;
            #1;

            if (instruction === expected_instruction) begin
                $display("PASS: %0s", test_name);
                passed = passed + 1;
            end else begin
                $display("FAIL: %0s", test_name);
                $display("Address=%h Expected=%h Actual=%h",
                         test_address,
                         expected_instruction,
                         instruction);
            end
        end
    endtask

    initial begin
        passed = 0;

        check_instruction(
            32'h00000000, 32'h00A00093, "Instruction at address 0"
        );

        check_instruction(
            32'h00000004, 32'h01400113, "Instruction at address 4"
        );

        check_instruction(
            32'h00000008, 32'h002081B3, "Instruction at address 8"
        );

        check_instruction(
            32'h0000000C, 32'h40110233, "Instruction at address 12"
        );

        check_instruction(
            32'h00000010, 32'h0020F2B3, "Instruction at address 16"
        );

        check_instruction(
            32'h00000014, 32'h0020E333, "Instruction at address 20"
        );

        $display("--------------------------------");
        $display("Tests passed: %0d/6", passed);

        if (passed == 6)
            $display("ALL TESTS PASSED");
        else
            $display("SOME TESTS FAILED");

        $finish;
    end

endmodule
