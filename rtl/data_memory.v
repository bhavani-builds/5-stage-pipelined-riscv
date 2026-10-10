
module data_memory (
    input wire clk,
    input wire reset,
    input wire mem_read,
    input wire mem_write,
    input wire [31:0] address,
    input wire [31:0] write_data,
    output reg [31:0] read_data
);

    reg [31:0] memory [0:255];
    wire [7:0] word_address;

    assign word_address = address[9:2];

    integer i;

    // Initialize data memory
    initial begin
        for (i = 0; i < 256; i = i + 1)
            memory[i] = 32'b0;

        memory[0] = 32'd100;
        memory[1] = 32'd200;
        memory[2] = 32'd300;
    end

    // Synchronous write
    always @(posedge clk) begin
        if (!reset && mem_write)
            memory[word_address] <= write_data;
    end

    // Asynchronous read
    always @(*) begin
        if (mem_read)
            read_data = memory[word_address];
        else
            read_data = 32'b0;
    end

endmodule
