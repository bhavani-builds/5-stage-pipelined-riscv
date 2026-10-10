
`timescale 1ns/1ps

module tb_ex_mem_register;

    reg clk;
    reg reset;
    reg flush;
    reg stall;

    reg [31:0] alu_result_in;
    reg [31:0] rs2_data_in;
    reg [4:0]  rd_in;
    reg reg_write_in;
    reg mem_read_in;
    reg mem_write_in;
    reg mem_to_reg_in;

    wire [31:0] alu_result_out;
    wire [31:0] rs2_data_out;
    wire [4:0]  rd_out;
    wire reg_write_out;
    wire mem_read_out;
    wire mem_write_out;
    wire mem_to_reg_out;

    integer passed;

    ex_mem_register uut (
        .clk(clk),
        .reset(reset),
        .flush(flush),
        .stall(stall),
        .alu_result_in(alu_result_in),
        .rs2_data_in(rs2_data_in),
        .rd_in(rd_in),
        .reg_write_in(reg_write_in),
        .mem_read_in(mem_read_in),
        .mem_write_in(mem_write_in),
        .mem_to_reg_in(mem_to_reg_in),
        .alu_result_out(alu_result_out),
        .rs2_data_out(rs2_data_out),
        .rd_out(rd_out),
        .reg_write_out(reg_write_out),
        .mem_read_out(mem_read_out),
        .mem_write_out(mem_write_out),
        .mem_to_reg_out(mem_to_reg_out)
    );

    always #5 clk = ~clk;

    task check_result;
        input [8*40-1:0] test_name;
        input [31:0] expected_alu;
        input [31:0] expected_rs2;
        input [4:0] expected_rd;
        input expected_reg_write;
        input expected_mem_read;
        input expected_mem_write;
        input expected_mem_to_reg;
        begin
            #1;
            if (alu_result_out === expected_alu &&
                rs2_data_out === expected_rs2 &&
                rd_out === expected_rd &&
                reg_write_out === expected_reg_write &&
                mem_read_out === expected_mem_read &&
                mem_write_out === expected_mem_write &&
                mem_to_reg_out === expected_mem_to_reg) begin
                $display("PASS: %0s", test_name);
                passed = passed + 1;
            end else begin
                $display("FAIL: %0s", test_name);
                $display("ALU=%h RS2=%h RD=%0d",
                         alu_result_out, rs2_data_out, rd_out);
                $display("Controls: reg_write=%b mem_read=%b mem_write=%b mem_to_reg=%b",
                         reg_write_out, mem_read_out,
                         mem_write_out, mem_to_reg_out);
            end
        end
    endtask

    initial begin
        clk = 0;
        reset = 1;
        flush = 0;
        stall = 0;

        alu_result_in = 0;
        rs2_data_in = 0;
        rd_in = 0;
        reg_write_in = 0;
        mem_read_in = 0;
        mem_write_in = 0;
        mem_to_reg_in = 0;
        passed = 0;

        // Test 1: Reset
        @(posedge clk);
        check_result("Reset clears outputs", 0, 0, 0, 0, 0, 0, 0);

        // Test 2: Capture an arithmetic result
        @(negedge clk);
        reset = 0;
        alu_result_in = 32'd30;
        rs2_data_in = 32'd20;
        rd_in = 5'd3;
        reg_write_in = 1;
        mem_read_in = 0;
        mem_write_in = 0;
        mem_to_reg_in = 0;

        @(posedge clk);
        check_result("Capture arithmetic result",
                     32'd30, 32'd20, 5'd3, 1, 0, 0, 0);

        // Test 3: Capture a load instruction's controls
        @(negedge clk);
        alu_result_in = 32'd100;
        rd_in = 5'd5;
        reg_write_in = 1;
        mem_read_in = 1;
        mem_write_in = 0;
        mem_to_reg_in = 1;

        @(posedge clk);
        check_result("Capture load controls",
                     32'd100, 32'd20, 5'd5, 1, 1, 0, 1);

        // Test 4: Stall holds the previous values
        @(negedge clk);
        stall = 1;
        alu_result_in = 32'd200;
        rd_in = 5'd7;
        mem_read_in = 0;

        @(posedge clk);
        check_result("Stall holds outputs",
                     32'd100, 32'd20, 5'd5, 1, 1, 0, 1);

        // Test 5: Flush clears outputs
        @(negedge clk);
        stall = 0;
        flush = 1;

        @(posedge clk);
        check_result("Flush clears outputs", 0, 0, 0, 0, 0, 0, 0);

        $display("--------------------------------");
        $display("Tests passed: %0d/5", passed);

        if (passed == 5)
            $display("ALL TESTS PASSED");
        else
            $display("SOME TESTS FAILED");

        $finish;
    end

endmodule
