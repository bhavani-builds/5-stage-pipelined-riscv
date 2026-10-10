
`timescale 1ns / 1ps

module tb_riscv_pipeline;

    reg clk;
    reg reset;

    riscv_pipeline dut (
        .clk(clk),
        .reset(reset)
    );

    // 10 ns clock period
    always #5 clk = ~clk;

    initial begin
        clk = 1'b0;
        reset = 1'b1;

        // Apply reset
        #20;
        reset = 1'b0;

        // Observe six instructions
        repeat (10) begin
            @(posedge clk);
            #1;
            $display(
                "Time=%0t | PC=%08h | Instruction=%08h",
                $time,
                dut.pc_current,
                dut.instruction
            );
        end

        $display("Instruction fetch test completed.");
        $finish;
    end

endmodule
