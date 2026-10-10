
`timescale 1ns/1ps

module tb_program_counter;

    reg clk;
    reg reset;
    reg stall;
    reg [31:0] next_pc;

    wire [31:0] pc;

    integer passed;

    program_counter uut (
        .clk(clk),
        .reset(reset),
        .stall(stall),
        .next_pc(next_pc),
        .pc(pc)
    );

    always #5 clk = ~clk;

    task check_pc;
        input [31:0] expected_pc;
        input [8*40-1:0] test_name;
        begin
            #1;
            if (pc === expected_pc) begin
                $display("PASS: %0s", test_name);
                passed = passed + 1;
            end else begin
                $display("FAIL: %0s", test_name);
                $display("Expected PC = %h", expected_pc);
                $display("Actual PC   = %h", pc);
            end
        end
    endtask

    initial begin
        clk = 0;
        reset = 1;
        stall = 0;
        next_pc = 0;
        passed = 0;

        // Test 1: Asynchronous reset
        #2;
        check_pc(32'h00000000, "Reset clears PC");

        // Release reset away from the active clock edge
        #1 reset = 0;

        // Test 2: Load the next PC
        @(negedge clk);
        next_pc = 32'h00000004;
        @(posedge clk);
        check_pc(32'h00000004, "PC advances to address 4");

        // Test 3: Advance to another address
        @(negedge clk);
        next_pc = 32'h00000008;
        @(posedge clk);
        check_pc(32'h00000008, "PC advances to address 8");

        // Test 4: Stall holds the current PC
        @(negedge clk);
        stall = 1;
        next_pc = 32'h0000000C;
        @(posedge clk);
        check_pc(32'h00000008, "Stall holds PC");

        // Test 5: Resume updating
        @(negedge clk);
        stall = 0;
        @(posedge clk);
        check_pc(32'h0000000C, "PC resumes after stall");

        $display("--------------------------------");
        $display("Tests passed: %0d/5", passed);

        if (passed == 5)
            $display("ALL TESTS PASSED");
        else
            $display("SOME TESTS FAILED");

        $finish;
    end

endmodule
