
`timescale 1ns / 1ps

module tb_riscv_pipeline;

    reg clk;
    reg reset;

    // Instantiate the processor top module
    riscv_pipeline dut (
        .clk(clk),
        .reset(reset)
    );

    // Generate a 10 ns clock
    always #5 clk = ~clk;

    initial begin
        clk = 1'b0;
        reset = 1'b1;

        // Hold reset for two clock edges
        #20;
        reset = 1'b0;

        // Allow the pipeline to run
        #100;

        $display("Simulation completed.");
        $finish;
    end

    // Monitor the internal program counter
    initial begin
        $monitor(
            "Time=%0t reset=%b PC=%h",
            $time, reset, dut.pc_current
        );
    end

endmodule
