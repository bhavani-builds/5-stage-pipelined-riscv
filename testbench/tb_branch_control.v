
`timescale 1ns/1ps

module tb_branch_control;

    reg [31:0] pc;
    reg [31:0] branch_target;
    reg        branch_taken;

    wire [31:0] next_pc;

    integer passed;

    branch_control uut (
        .pc(pc),
        .branch_target(branch_target),
        .branch_taken(branch_taken),
        .next_pc(next_pc)
    );

    task check_result;
        input [31:0] expected_pc;
        input [8*40-1:0] test_name;
        begin
            #1;
            if (next_pc === expected_pc) begin
                $display("PASS: %0s", test_name);
                passed = passed + 1;
            end else begin
                $display("FAIL: %0s", test_name);
                $display("Expected PC = %h", expected_pc);
                $display("Actual PC   = %h", next_pc);
            end
        end
    endtask

    initial begin
        passed = 0;

        // Test 1: Normal sequential execution
        pc = 32'h00000010;
        branch_target = 32'h00000040;
        branch_taken = 0;
        check_result(32'h00000014, "Select PC + 4");

        // Test 2: Branch taken
        branch_taken = 1;
        check_result(32'h00000040, "Select branch target");

        // Test 3: Different PC address
        pc = 32'h00000100;
        branch_target = 32'h00000080;
        branch_taken = 0;
        check_result(32'h00000104, "Sequential PC at new address");

        // Test 4: Branch to another target
        branch_taken = 1;
        check_result(32'h00000080, "Branch to new target");

        $display("--------------------------------");
        $display("Tests passed: %0d/4", passed);

        if (passed == 4)
            $display("ALL TESTS PASSED");
        else
            $display("SOME TESTS FAILED");

        $finish;
    end

endmodule
