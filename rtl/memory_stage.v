
module memory_stage (
    input wire clk,
    input wire reset,

    input wire [31:0] alu_result_in,
    input wire [31:0] rs2_data_in,
    input wire [4:0] rd_in,

    input wire reg_write_in,
    input wire mem_read_in,
    input wire mem_write_in,
    input wire mem_to_reg_in,

    output wire [31:0] alu_result_out,
    output wire [31:0] memory_data_out,
    output wire [4:0] rd_out,

    output wire reg_write_out,
    output wire mem_to_reg_out
);

    wire [31:0] ex_mem_alu_result;
    wire [31:0] ex_mem_rs2_data;
    wire [4:0] ex_mem_rd;

    wire ex_mem_reg_write;
    wire ex_mem_mem_read;
    wire ex_mem_mem_write;
    wire ex_mem_mem_to_reg;

    wire [31:0] data_read;

    // EX-MEM pipeline register
    ex_mem_register ex_mem_unit (
        .clk(clk),
        .reset(reset),
        .stall(1'b0),
        .flush(1'b0),

        .alu_result_in(alu_result_in),
        .rs2_data_in(rs2_data_in),
        .rd_in(rd_in),

        .reg_write_in(reg_write_in),
        .mem_read_in(mem_read_in),
        .mem_write_in(mem_write_in),
        .mem_to_reg_in(mem_to_reg_in),

        .alu_result_out(ex_mem_alu_result),
        .rs2_data_out(ex_mem_rs2_data),
        .rd_out(ex_mem_rd),

        .reg_write_out(ex_mem_reg_write),
        .mem_read_out(ex_mem_mem_read),
        .mem_write_out(ex_mem_mem_write),
        .mem_to_reg_out(ex_mem_mem_to_reg)
    );

    // Data memory
    data_memory data_mem_unit (
        .clk(clk),
        .reset(reset),
        .mem_read(ex_mem_mem_read),
        .mem_write(ex_mem_mem_write),
        .address(ex_mem_alu_result),
        .write_data(ex_mem_rs2_data),
        .read_data(data_read)
    );

    // Pass results toward write-back
    assign alu_result_out = ex_mem_alu_result;
    assign memory_data_out = data_read;
    assign rd_out = ex_mem_rd;
    assign reg_write_out = ex_mem_reg_write;
    assign mem_to_reg_out = ex_mem_mem_to_reg;

endmodule
