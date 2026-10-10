
`timescale 1ns / 1ps

module tb_instruction_decoder;

    reg [31:0] instruction;

    wire reg_write;
    wire mem_read;
    wire mem_write;
    wire mem_to_reg;
    wire alu_src;
    wire branch;
    wire [3:0] alu_control;

    integer errors;

    instruction_decoder dut (
        .instruction(instruction),
        .reg_write(reg_write),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .mem_to_reg(mem_to_reg),
        .alu_src(alu_src),
        .branch(branch),
        .alu_control(alu_control)
    );

    task check_controls;
        input expected_reg_write;
        input expected_mem_read;
        input expected_mem_write;
        input expected_mem_to_reg;
        input expected_alu_src;
        input expected_branch;
        input [3:0] expected_alu_control;

        begin
            #1;
            if ({reg_write, mem_read, mem_write,
                 mem_to_reg, alu_src, branch, alu_control}
                !==
                {expected_reg_write, expected_mem_read,
                 expected_mem_write, expected_mem_to_reg,
                 expected_alu_src, expected_branch,
                 expected_alu_control}) begin

                $display("FAIL: instruction=%h", instruction);
                errors = errors + 1;
            end
            else begin
                $display("PASS: instruction=%h", instruction);
            end
        end
    endtask

    initial begin
        errors = 0;

        // ADDI x1, x0, 10
        instruction = 32'h00A00093;
        check_controls(1, 0, 0, 0, 1, 0, 4'b0000);

        // ADD x3, x1, x2
        instruction = 32'h002081B3;
        check_controls(1, 0, 0, 0, 0, 0, 4'b0000);

        // SUB x4, x2, x1
        instruction = 32'h40110233;
        check_controls(1, 0, 0, 0, 0, 0, 4'b0001);

        // LW x5, 0(x1)
        instruction = 32'h0000A283;
        check_controls(1, 1, 0, 1, 1, 0, 4'b0000);

        // SW x2, 0(x1)
        instruction = 32'h0020A023;
        check_controls(0, 0, 1, 0, 1, 0, 4'b0000);

        // BEQ x1, x2, offset
        instruction = 32'h00208063;
        check_controls(0, 0, 0, 0, 0, 1, 4'b0001);

        // Unsupported instruction
        instruction = 32'hFFFFFFFF;
        check_controls(0, 0, 0, 0, 0, 0, 4'b0000);

        if (errors == 0)
            $display("ALL DECODER TESTS PASSED");
        else
            $display("DECODER TESTS FAILED: %0d errors", errors);

        $finish;
    end

endmodule
