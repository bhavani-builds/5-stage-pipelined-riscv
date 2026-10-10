
`timescale 1ns/1ps

module tb_hazard_detection;

    reg        id_ex_mem_read;
    reg  [4:0] id_ex_rd;
    reg  [4:0] if_id_rs1;
    reg  [4:0] if_id_rs2;

    wire pc_write;
    wire if_id_write;
    wire control_stall;

    integer passed;

    hazard_detection uut (
        .id_ex_mem_read(id_ex_mem_read),
        .id_ex_rd(id_ex_rd),
        .if_id_rs1(if_id_rs1),
        .if_id_rs2(if_id_rs2),
        .pc_write(pc_write),
        .if_id_write(if_id_write),
        .control_stall(control_stall)
    );

    task check_result;
        input expected_pc_write;
        input expected_if_id_write;
        input expected_control_stall;
        input [8*50-1:0] test_name;
        begin
            #1;
            if (pc_write === expected_pc_write &&
                if_id_write === expected_if_id_write &&
                control_stall === expected_control_stall) begin
                $display("PASS: %0s", test_name);
                passed = passed + 1;
            end else begin
                $display("FAIL: %0s", test_name);
                $display("Expected: pc_write=%b if_id_write=%b stall=%b",
                         expected_pc_write,
                         expected_if_id_write,
                         expected_control_stall);
                $display("Actual:   pc_write=%b if_id_write=%b stall=%b",
                         pc_write, if_id_write, control_stall);
            end
        end
    endtask

    initial begin
        passed = 0;

        // Test 1: No load instruction in EX stage
        id_ex_mem_read = 0;
        id_ex_rd = 5;
        if_id_rs1 = 1;
        if_id_rs2 = 2;
        check_result(1, 1, 0, "No hazard");

        // Test 2: Load destination matches source register 1
        id_ex_mem_read = 1;
        id_ex_rd = 5;
        if_id_rs1 = 5;
        if_id_rs2 = 2;
        check_result(0, 0, 1, "Load-use hazard on rs1");

        // Test 3: Load destination matches source register 2
        id_ex_mem_read = 1;
        id_ex_rd = 6;
        if_id_rs1 = 2;
        if_id_rs2 = 6;
        check_result(0, 0, 1, "Load-use hazard on rs2");

        // Test 4: Destination is x0, so no hazard
        id_ex_mem_read = 1;
        id_ex_rd = 0;
        if_id_rs1 = 0;
        if_id_rs2 = 0;
        check_result(1, 1, 0, "No hazard when destination is x0");

        $display("--------------------------------");
        $display("Tests passed: %0d/4", passed);

        if (passed == 4)
            $display("ALL TESTS PASSED");
        else
            $display("SOME TESTS FAILED");

        $finish;
    end

endmodule
