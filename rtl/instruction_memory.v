
module instruction_memory (
    input wire [31:0] address,
    output wire [31:0] instruction
);

    reg [31:0] memory [0:255];
    wire [7:0] word_address;

    assign word_address = address[9:2];

    // Asynchronous instruction read
    assign instruction = memory[word_address];

    integer i;

    initial begin
        // Initialize unused locations to RISC-V NOP
        for (i = 0; i < 256; i = i + 1)
            memory[i] = 32'h00000013;

        // Example program
        // addi x1, x0, 10
        memory[0] = 32'h00A00093;

        // addi x2, x0, 20
        memory[1] = 32'h01400113;

        // add x3, x1, x2
        memory[2] = 32'h002081B3;

        // sub x4, x2, x1
        memory[3] = 32'h40110233;

        // and x5, x1, x2
        memory[4] = 32'h0020F2B3;

        // or x6, x1, x2
        memory[5] = 32'h0020E333;
    end

endmodule
