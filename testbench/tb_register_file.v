
`timescale 1ns / 1ps

module tb_register_file;

    reg clk;
    reg reset;
    reg reg_write;
    reg [4:0] read_addr1;
    reg [4:0] read_addr2;
    reg [4:0] write_addr;
    reg [31:0] write_data;

    wire [31:0] read_data1;
    wire [31:0] read_data2;

    integer errors;

    register_file dut (
        .clk(clk),
        .reset(reset),
        .reg_write(reg_write),
        .read_addr1(read_addr1),
        .read_addr2(read_addr2),
        .write_addr(write_addr),
        .write_data(write_data),
        .read_data1(read_data1),
        .read_data2(read_data2)
    );

    always #5 clk = ~clk;

    task check_value;
        input [31:0] actual;
        input [31:0] expected;
        input [255:0] test_name;
        begin
            if (actual !== expected) begin
                $display("FAIL: %0s expected=%h actual=%h",
                         test_name, expected, actual);
                errors = errors + 1;
            end
            else begin
                $display("PASS: %0s", test_name);
            end
        end
    endtask

    initial begin
        clk = 0;
        reset = 1;
        reg_write = 0;
        read_addr1 = 0;
        read_addr2 = 0;
        write_addr = 0;
        write_data = 0;
        errors = 0;

        // Reset the register file
        repeat (2) @(negedge clk);
        reset = 0;

        // Write 25 into x5
        @(negedge clk);
        reg_write = 1;
        write_addr = 5;
        write_data = 25;

        @(negedge clk);
        reg_write = 0;
        read_addr1 = 5;
        #1;
        check_value(read_data1, 32'd25, "Read x5");

        // Write 40 into x6
        @(negedge clk);
        reg_write = 1;
        write_addr = 6;
        write_data = 40;

        @(negedge clk);
        reg_write = 0;
        read_addr1 = 5;
        read_addr2 = 6;
        #1;
        check_value(read_data1, 32'd25, "Read port 1");
        check_value(read_data2, 32'd40, "Read port 2");

        // Attempt to write into x0
        @(negedge clk);
        reg_write = 1;
        write_addr = 0;
        write_data = 99;

        @(negedge clk);
        reg_write = 0;
        read_addr1 = 0;
        #1;
        check_value(read_data1, 32'd0, "x0 remains zero");

        if (errors == 0)
            $display("ALL REGISTER FILE TESTS PASSED");
        else
            $display("REGISTER FILE TESTS FAILED: %0d errors", errors);

        $finish;
    end

endmodule
