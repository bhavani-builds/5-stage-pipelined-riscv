
`timescale 1ns/1ps

module tb_execute_stage;

    reg [31:0] rs1_data;
    reg [31:0] rs2_data;
    reg [31:0] immediate;
    reg [3:0]  alu_control;
    reg        alu_src;

    reg [1:0]  forward_a;
    reg [1:0]  forward_b;
    reg [31:0] ex_mem_alu_result;
    reg [31:0] mem_wb_write_data;

    wire [31:0] alu_result;
    wire        zero;

    integer passed;

    execute_stage uut (
        .rs1_data(rs1_data),
        .rs2_data(rs2_data),
        .immediate(immediate),
        .alu_control(alu_control),
        .alu_src(alu_src),
        .forward_a(forward_a),
        .forward_b(forward_b),
        .ex_mem_alu_result(ex_mem_alu_result),
        .mem_wb_write_data(mem_wb_write_data),
        .alu_result(alu_result),
        .zero(zero)
    );

    task check_result;
        input [31:0] expected_result;
        input expected_zero;
        input [8*40-1:0] test_name;
        begin
            #1;
            if (alu_result === expected_result &&
                zero === expected_zero) begin
                $display("PASS: %0s", test_name);
                passed = passed + 1;
            end else begin
                $display("FAIL: %0s", test_name);
                $display("Expected result=%h zero=%b",
                         expected_result, expected_zero);
                $display("Actual   result=%h zero=%b",
                         alu_result, zero);
            end
        end
    endtask

    initial begin
        passed = 0;

        rs1_data = 32'd10;
        rs2_data = 32'd5;
        immediate = 32'd3;
        alu_control = 4'b0000; // ADD
        alu_src = 0;
        forward_a = 2'b00;
        forward_b = 2'b00;
        ex_mem_alu_result = 32'd0;
        mem_wb_write_data = 32'd0;

        check_result(32'd15, 0, "ADD register operands");

        alu_control = 4'b0001; // SUB
        check_result(32'd5, 0, "SUB register operands");

        alu_control = 4'b0000; // ADD immediate
        alu_src = 1;
        check_result(32'd13, 0, "ADD immediate");

        // Forward operand A from EX/MEM
        alu_src = 0;
        forward_a = 2'b10;
        ex_mem_alu_result = 32'd20;
        alu_control = 4'b0000;
        check_result(32'd25, 0, "Forward A from EX/MEM");

        // Forward operand B from MEM/WB
        forward_a = 2'b00;
        forward_b = 2'b01;
        mem_wb_write_data = 32'd7;
        check_result(32'd17, 0, "Forward B from MEM/WB");

        // Forwarded operands produce zero
        forward_a = 2'b00;
        forward_b = 2'b00;
        rs1_data = 32'd5;
        rs2_data = 32'd5;
        alu_control = 4'b0001;
        check_result(32'd0, 1, "SUB result is zero");

        $display("--------------------------------");
        $display("Tests passed: %0d/6", passed);

        if (passed == 6)
            $display("ALL TESTS PASSED");
        else
            $display("SOME TESTS FAILED");

        $finish;
    end

endmodule
