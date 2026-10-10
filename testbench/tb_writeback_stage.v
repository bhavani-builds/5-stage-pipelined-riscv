
`timescale 1ns/1ps

module tb_writeback_stage;

    reg [31:0] alu_result;
    reg [31:0] memory_data;
    reg        mem_to_reg;

    wire [31:0] writeback_data;

    integer passed;

    writeback_stage uut (
        .alu_result(alu_result),
        .memory_data(memory_data),
        .mem_to_reg(mem_to_reg),
        .writeback_data(writeback_data)
    );

    task check_result;
        input [31:0] expected;
        input [8*40-1:0] test_name;
        begin
            #1;
            if (writeback_data === expected) begin
                $display("PASS: %0s", test_name);
                passed = passed + 1;
            end else begin
                $display("FAIL: %0s", test_name);
                $display("Expected = %h", expected);
                $display("Actual   = %h", writeback_data);
            end
        end
    endtask

    initial begin
        passed = 0;

        // Test 1: Select ALU result
        alu_result = 32'd30;
        memory_data = 32'd100;
        mem_to_reg = 0;
        check_result(32'd30, "Select ALU result");

        // Test 2: Select memory data for a load
        mem_to_reg = 1;
        check_result(32'd100, "Select memory data");

        // Test 3: ALU result changes
        alu_result = 32'h12345678;
        mem_to_reg = 0;
        check_result(32'h12345678, "Updated ALU result");

        // Test 4: Memory data changes
        memory_data = 32'hABCDEF01;
        mem_to_reg = 1;
        check_result(32'hABCDEF01, "Updated memory data");

        $display("--------------------------------");
        $display("Tests passed: %0d/4", passed);

        if (passed == 4)
            $display("ALL TESTS PASSED");
        else
            $display("SOME TESTS FAILED");

        $finish;
    end

endmodule
