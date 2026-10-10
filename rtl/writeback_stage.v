
module writeback_stage (
    input wire [31:0] alu_result,
    input wire [31:0] memory_data,
    input wire mem_to_reg,

    output wire [31:0] writeback_data
);

    // Select the value to write into the register file
    assign writeback_data =
        mem_to_reg ? memory_data : alu_result;

endmodule
