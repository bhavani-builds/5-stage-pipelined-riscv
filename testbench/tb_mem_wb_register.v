
`timescale 1ns/1ps

module tb_mem_wb_register;

    reg clk;
    reg reset;
    reg flush;
    reg stall;

    reg [31:0] alu_result_in;
    reg [31:0] memory_data_in;
    reg [4:0] rd_in;
    reg reg_write_in;
    reg mem_to_reg_in;

    wire [31:0] alu_result_out;
    wire [31:0] memory_data_out;
    wire [4:0] rd_out;
    wire reg_write_out;
    wire mem_to_reg_out;

    integer passed;

    mem_wb_register uut (
        .clk(clk),
        .reset(reset),
        .flush(flush),
        .stall(stall),
        .alu_result_in(alu_result_in),
        .memory_data_in(memory_data_in),
        .rd_in(rd_in),
        .reg_write_in(reg_write_in),
        .mem_to_reg_in(mem_to_reg_in),
        .alu_result_out(alu_result_out),
        .memory_data_out(memory_data_out),
        .rd_out(rd_out),
        .reg_write_out(reg_write_out),
        .mem_to_reg_out(mem_to_reg_out)
    );

    always #5 clk = ~clk;

    task check_result;
        input [8*40-1:0] test_name;
        input [31:0] expected_alu;
        input [31:0] expected_memory;
        input [4:0] expected_rd;
        input expected_reg_write;
        input expected_mem_to_reg;
        begin
            #1;
            if (alu_result_out === expected_alu &&
                memory_data_out === expected_memory &&
                rd_out === expected_rd &&
                reg_write_out === expected_reg_write &&
                mem_to_reg_out === expected_mem_to_reg) begin
                $display("PASS: %0s", test_name);
                passed = passed + 1;
            end else begin
                $display("FAIL: %0s", test_name);
                $display("ALU=%h Memory=%h RD=%0d",
                         alu_result_out, memory_data_out, rd_out);
                $display("RegWrite=%b MemToReg=%b",
                         reg_write_out, mem_to_reg_out);
            end
        end
    endtask

    initial begin
        clk = 0;
        reset = 1;
        flush = 0;
        stall = 0;

        alu_result_in = 0;
        memory_data_in = 0;
        rd_in = 0;
        reg_write_in = 0;
        mem_to_reg_in = 0;
        passed = 0;

        // Test 1: Reset clears outputs
        @(posedge clk);
        check_result("Reset clears outputs", 0, 0, 0, 0, 0);

        // Test 2: Capture an arithmetic result
        @(negedge clk);
        reset = 0;
        alu_result_in = 32'd25;
        memory_data_in = 32'd0;
        rd_in = 5'd3;
        reg_write_in = 1;
        mem_to_reg_in = 0;

        @(posedge clk);
        check_result("Capture ALU result", 32'd25, 0, 5'd3, 1, 0);

        // Test 3: Capture a load result
        @(negedge clk);
        alu_result_in = 32'd100;
        memory_data_in = 32'd500;
        rd_in = 5'd5;
        reg_write_in = 1;
        mem_to_reg_in = 1;

        @(posedge clk);
        check_result("Capture memory data", 32'd100, 32'd500, 5'd5, 1, 1);

        // Test 4: Stall holds previous outputs
        @(negedge clk);
        stall = 1;
        alu_result_in = 32'd200;
        memory_data_in = 32'd600;
        rd_in = 5'd7;
        reg_write_in = 0;

        @(posedge clk);
        check_result("Stall holds outputs", 32'd100, 32'd500, 5'd5, 1, 1);

        // Test 5: Flush clears outputs
        @(negedge clk);
        stall = 0;
        flush = 1;

        @(posedge clk);
        check_result("Flush clears outputs", 0, 0, 0, 0, 0);

        $display("--------------------------------");
        $display("Tests passed: %0d/5", passed);

        if (passed == 5)
            $display("ALL TESTS PASSED");
        else
            $display("SOME TESTS FAILED");

        $finish;
    end

endmodule
