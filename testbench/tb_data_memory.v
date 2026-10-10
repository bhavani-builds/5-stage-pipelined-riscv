
`timescale 1ns/1ps

module tb_data_memory;

    reg clk;
    reg reset;
    reg mem_read;
    reg mem_write;
    reg [31:0] address;
    reg [31:0] write_data;

    wire [31:0] read_data;

    integer passed;

    data_memory uut (
        .clk(clk),
        .reset(reset),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .address(address),
        .write_data(write_data),
        .read_data(read_data)
    );

    always #5 clk = ~clk;

    task check_read;
        input [31:0] expected;
        input [8*40-1:0] test_name;
        begin
            #1;
            if (read_data === expected) begin
                $display("PASS: %0s", test_name);
                passed = passed + 1;
            end else begin
                $display("FAIL: %0s", test_name);
                $display("Expected=%h Actual=%h",
                         expected, read_data);
            end
        end
    endtask

    initial begin
        clk = 0;
        reset = 1;
        mem_read = 0;
        mem_write = 0;
        address = 0;
        write_data = 0;
        passed = 0;

        repeat (2) @(posedge clk);
        #1 reset = 0;

        // Check the initialized memory locations.
        mem_read = 1;
        address = 32'h00000000;
        check_read(32'd100, "Read initialized word at address 0");

        address = 32'h00000004;
        check_read(32'd200, "Read initialized word at address 4");

        // Write a new value to address 8.
        @(negedge clk);
        mem_read = 0;
        mem_write = 1;
        address = 32'h00000008;
        write_data = 32'd1234;

        @(posedge clk);
        #1 mem_write = 0;
        mem_read = 1;

        check_read(32'd1234, "Write then read address 8");

        // Write another value to address 12.
        @(negedge clk);
        mem_read = 0;
        mem_write = 1;
        address = 32'h0000000C;
        write_data = 32'd5678;

        @(posedge clk);
        #1 mem_write = 0;
        mem_read = 1;

        check_read(32'd5678, "Write then read address 12");

        $display("--------------------------------");
        $display("Tests passed: %0d/4", passed);

        if (passed == 4)
            $display("ALL TESTS PASSED");
        else
            $display("SOME TESTS FAILED");

        $finish;
    end

endmodule
