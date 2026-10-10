
`timescale 1ns/1ps

module tb_branch_unit;

    reg [31:0] pc;
    reg [31:0] immediate;
    reg [31:0] rs1_data;
    reg [31:0] rs2_data;
    reg        branch;
    reg [2:0]  funct3;

    wire [31:0] branch_target;
    wire        branch_taken;

    integer passed;

    branch_unit uut (
        .pc(pc),
        .immediate(immediate),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data),
        .branch(branch),
        .funct3(funct3),
        .branch_target(branch_target),
        .branch_taken(branch_taken)
    );

    task check_result;
        input expected_taken;
        input [31:0] expected_target;
        input [8*40-1:0] test_name;
        begin
            #1;
            if (branch_taken === expected_taken &&
                branch_target === expected_target) begin
                $display("PASS: %0s", test_name);
                passed = passed + 1;
            end else begin
                $display("FAIL: %0s", test_name);
                $display("Expected taken=%b target=%h",
                         expected_taken, expected_target);
                $display("Actual   taken=%b target=%h",
                         branch_taken, branch_target);
            end
        end
    endtask

    initial begin
        passed = 0;

        pc = 32'h00000010;
        immediate = 32'h00000008;
        rs1_data = 32'd10;
        rs2_data = 32'd10;
        branch = 1;
        funct3 = 3'b000; // BEQ
        check_result(1, 32'h00000018, "BEQ equal operands");

        rs2_data = 32'd20;
        check_result(0, 32'h00000018, "BEQ unequal operands");

        funct3 = 3'b001; // BNE
        check_result(1, 32'h00000018, "BNE unequal operands");

        rs1_data = 32'hFFFFFFFF; // -1
        rs2_data = 32'd1;
        funct3 = 3'b100; // BLT
        check_result(1, 32'h00000018, "BLT signed comparison");

        funct3 = 3'b110; // BLTU
        check_result(0, 32'h00000018, "BLTU unsigned comparison");

        rs1_data = 32'd20;
        rs2_data = 32'd10;
        funct3 = 3'b101; // BGE
        check_result(1, 32'h00000018, "BGE signed comparison");

        funct3 = 3'b111; // BGEU
        check_result(1, 32'h00000018, "BGEU unsigned comparison");

        branch = 0;
        funct3 = 3'b000;
        check_result(0, 32'h00000018, "Branch disabled");

        $display("--------------------------------");
        $display("Tests passed: %0d/8", passed);

        if (passed == 8)
            $display("ALL TESTS PASSED");
        else
            $display("SOME TESTS FAILED");

        $finish;
    end

endmodule
