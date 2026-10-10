
`timescale 1ns/1ps

module tb_branch_forwarding_unit;

    reg [4:0] rs1;
    reg [4:0] rs2;

    reg [4:0] ex_mem_rd;
    reg       ex_mem_reg_write;

    reg [4:0] mem_wb_rd;
    reg       mem_wb_reg_write;

    wire [1:0] forward_a;
    wire [1:0] forward_b;

    integer passed;

    branch_forwarding_unit uut (
        .rs1(rs1),
        .rs2(rs2),
        .ex_mem_rd(ex_mem_rd),
        .ex_mem_reg_write(ex_mem_reg_write),
        .mem_wb_rd(mem_wb_rd),
        .mem_wb_reg_write(mem_wb_reg_write),
        .forward_a(forward_a),
        .forward_b(forward_b)
    );

    task check_result;
        input [1:0] expected_a;
        input [1:0] expected_b;
        input [8*45-1:0] test_name;
        begin
            #1;
            if (forward_a === expected_a &&
                forward_b === expected_b) begin
                $display("PASS: %0s", test_name);
                passed = passed + 1;
            end else begin
                $display("FAIL: %0s", test_name);
                $display("Expected A=%b B=%b", expected_a, expected_b);
                $display("Actual   A=%b B=%b", forward_a, forward_b);
            end
        end
    endtask

    initial begin
        passed = 0;

        // Test 1: No forwarding required
        rs1 = 5'd1;
        rs2 = 5'd2;
        ex_mem_rd = 5'd0;
        ex_mem_reg_write = 0;
        mem_wb_rd = 5'd0;
        mem_wb_reg_write = 0;
        check_result(2'b00, 2'b00, "No forwarding");

        // Test 2: Forward operand A from EX/MEM
        rs1 = 5'd5;
        rs2 = 5'd2;
        ex_mem_rd = 5'd5;
        ex_mem_reg_write = 1;
        check_result(2'b10, 2'b00, "Forward A from EX/MEM");

        // Test 3: Forward operand B from MEM/WB
        rs1 = 5'd1;
        rs2 = 5'd6;
        ex_mem_rd = 5'd0;
        ex_mem_reg_write = 0;
        mem_wb_rd = 5'd6;
        mem_wb_reg_write = 1;
        check_result(2'b00, 2'b01, "Forward B from MEM/WB");

        // Test 4: EX/MEM has priority over MEM/WB
        rs1 = 5'd7;
        rs2 = 5'd8;
        ex_mem_rd = 5'd7;
        ex_mem_reg_write = 1;
        mem_wb_rd = 5'd7;
        mem_wb_reg_write = 1;
        check_result(2'b10, 2'b00, "EX/MEM forwarding priority");

        // Test 5: Never forward register x0
        rs1 = 5'd0;
        rs2 = 5'd0;
        ex_mem_rd = 5'd0;
        ex_mem_reg_write = 1;
        mem_wb_rd = 5'd0;
        mem_wb_reg_write = 1;
        check_result(2'b00, 2'b00, "Ignore register x0");

        $display("--------------------------------");
        $display("Tests passed: %0d/5", passed);

        if (passed == 5)
            $display("ALL TESTS PASSED");
        else
            $display("SOME TESTS FAILED");

        $finish;
    end

endmodule
