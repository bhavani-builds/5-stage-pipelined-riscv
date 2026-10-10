
`timescale 1ns/1ps

module tb_if_id_register;

    reg clk;
    reg reset;
    reg flush;
    reg stall;

    reg [31:0] pc_in;
    reg [31:0] instruction_in;

    wire [31:0] pc_out;
    wire [31:0] instruction_out;

    integer passed;

    if_id_register uut (
        .clk(clk),
        .reset(reset),
        .flush(flush),
        .stall(stall),
        .pc_in(pc_in),
        .instruction_in(instruction_in),
        .pc_out(pc_out),
        .instruction_out(instruction_out)
    );

    always #5 clk = ~clk;

    task check_result;
        input [31:0] expected_pc;
        input [31:0] expected_instruction;
        input [8*40-1:0] test_name;
        begin
            #1;
            if (pc_out === expected_pc &&
                instruction_out === expected_instruction) begin
                $display("PASS: %0s", test_name);
                passed = passed + 1;
            end else begin
                $display("FAIL: %0s", test_name);
                $display("Expected PC=%h Instruction=%h",
                         expected_pc, expected_instruction);
                $display("Actual   PC=%h Instruction=%h",
                         pc_out, instruction_out);
            end
        end
    endtask

    initial begin
        clk = 0;
        reset = 1;
        flush = 0;
        stall = 0;
        pc_in = 0;
        instruction_in = 0;
        passed = 0;

        // Test 1: Reset clears both outputs
        @(posedge clk);
        check_result(32'b0, 32'b0, "Reset clears register");

        // Test 2: Capture PC and instruction
        @(negedge clk);
        reset = 0;
        pc_in = 32'h00000004;
        instruction_in = 32'h00A00093;

        @(posedge clk);
        check_result(32'h00000004, 32'h00A00093,
                     "Capture instruction");

        // Test 3: Stall preserves previous values
        @(negedge clk);
        stall = 1;
        pc_in = 32'h00000008;
        instruction_in = 32'h01400113;

        @(posedge clk);
        check_result(32'h00000004, 32'h00A00093,
                     "Stall holds previous values");

        // Test 4: Flush clears the register
        @(negedge clk);
        stall = 0;
        flush = 1;

        @(posedge clk);
        check_result(32'b0, 32'b0, "Flush clears register");

        // Test 5: Capture new values after flush
        @(negedge clk);
        flush = 0;
        pc_in = 32'h0000000C;
        instruction_in = 32'h002081B3;

        @(posedge clk);
        check_result(32'h0000000C, 32'h002081B3,
                     "Capture after flush");

        $display("--------------------------------");
        $display("Tests passed: %0d/5", passed);

        if (passed == 5)
            $display("ALL TESTS PASSED");
        else
            $display("SOME TESTS FAILED");

        $finish;
    end

endmodule
