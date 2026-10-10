
`timescale 1ns/1ps

module tb_control_unit;

    reg [31:0] instruction;

    wire reg_write;
    wire mem_read;
    wire mem_write;
    wire mem_to_reg;
    wire alu_src;
    wire branch;
    wire [3:0] alu_control;

    integer passed;

    control_unit uut (
        .instruction(instruction),
        .reg_write(reg_write),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .mem_to_reg(mem_to_reg),
        .alu_src(alu_src),
        .branch(branch),
        .alu_control(alu_control)
    );

    task check_result;
        input [8*35-1:0] test_name;
        input expected_reg_write;
        input expected_mem_read;
        input expected_mem_write;
        input expected_mem_to_reg;
        input expected_alu_src;
        input expected_branch;
        input [3:0] expected_alu_control;
        begin
            #1;
            if (reg_write === expected_reg_write &&
                mem_read === expected_mem_read &&
                mem_write === expected_mem_write &&
                mem_to_reg === expected_mem_to_reg &&
                alu_src === expected_alu_src &&
                branch === expected_branch &&
                alu_control === expected_alu_control) begin
                $display("PASS: %0s", test_name);
                passed = passed + 1;
            end else begin
                $display("FAIL: %0s", test_name);
                $display("reg_write=%b mem_read=%b mem_write=%b",
                         reg_write, mem_read, mem_write);
                $display("mem_to_reg=%b alu_src=%b branch=%b alu_control=%b",
                         mem_to_reg, alu_src, branch, alu_control);
            end
        end
    endtask

    initial begin
        passed = 0;

        // ADDI x1, x0, 10
        instruction = 32'h00A00093;
        check_result("ADDI", 1, 0, 0, 0, 1, 0, 4'b0000);

        // ADD x3, x1, x2
        instruction = 32'h002081B3;
        check_result("ADD", 1, 0, 0, 0, 0, 0, 4'b0000);

        // SUB x4, x2, x1
        instruction = 32'h40110233;
        check_result("SUB", 1, 0, 0, 0, 0, 0, 4'b0001);

        // LW x5, 0(x1)
        instruction = 32'h0000A283;
        check_result("LW", 1, 1, 0, 1, 1, 0, 4'b0000);

        // SW x2, 0(x1)
        instruction = 32'h0020A023;
        check_result("SW", 0, 0, 1, 0, 1, 0, 4'b0000);

        // BEQ x1, x2, offset
        instruction = 32'h00208463;
        check_result("BEQ", 0, 0, 0, 0, 0, 1, 4'b0001);

        // Unsupported opcode: safe defaults
        instruction = 32'hFFFFFFFF;
        check_result("Unsupported instruction", 0, 0, 0, 0, 0, 0, 4'b0000);

        $display("--------------------------------");
        $display("Tests passed: %0d/7", passed);

        if (passed == 7)
            $display("ALL TESTS PASSED");
        else
            $display("SOME TESTS FAILED");

        $finish;
    end

endmodule
