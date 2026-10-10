
module ex_mem_register (
    input wire clk,
    input wire reset,
    input wire stall,
    input wire flush,

    input wire [31:0] alu_result_in,
    input wire [31:0] rs2_data_in,
    input wire [4:0] rd_in,

    input wire reg_write_in,
    input wire mem_read_in,
    input wire mem_write_in,
    input wire mem_to_reg_in,

    output reg [31:0] alu_result_out,
    output reg [31:0] rs2_data_out,
    output reg [4:0] rd_out,

    output reg reg_write_out,
    output reg mem_read_out,
    output reg mem_write_out,
    output reg mem_to_reg_out
);

    always @(posedge clk or posedge reset) begin
        if (reset || flush) begin
            alu_result_out <= 32'b0;
            rs2_data_out <= 32'b0;
            rd_out <= 5'b0;

            reg_write_out <= 1'b0;
            mem_read_out <= 1'b0;
            mem_write_out <= 1'b0;
            mem_to_reg_out <= 1'b0;
        end
        else if (!stall) begin
            alu_result_out <= alu_result_in;
            rs2_data_out <= rs2_data_in;
            rd_out <= rd_in;

            reg_write_out <= reg_write_in;
            mem_read_out <= mem_read_in;
            mem_write_out <= mem_write_in;
            mem_to_reg_out <= mem_to_reg_in;
        end
    end

endmodule
