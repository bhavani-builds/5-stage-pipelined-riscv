
module branch_forwarding_unit (
    input wire [4:0] branch_rs1,
    input wire [4:0] branch_rs2,

    input wire [4:0] ex_mem_rd,
    input wire ex_mem_reg_write,

    input wire [4:0] mem_wb_rd,
    input wire mem_wb_reg_write,

    output reg [1:0] branch_forward_a,
    output reg [1:0] branch_forward_b
);

    always @(*) begin
        branch_forward_a = 2'b00;
        branch_forward_b = 2'b00;

        // Forward the most recent available EX-MEM result
        if (ex_mem_reg_write &&
            (ex_mem_rd != 5'd0) &&
            (ex_mem_rd == branch_rs1))
            branch_forward_a = 2'b10;
        else if (mem_wb_reg_write &&
                 (mem_wb_rd != 5'd0) &&
                 (mem_wb_rd == branch_rs1))
            branch_forward_a = 2'b01;

        if (ex_mem_reg_write &&
            (ex_mem_rd != 5'd0) &&
            (ex_mem_rd == branch_rs2))
            branch_forward_b = 2'b10;
        else if (mem_wb_reg_write &&
                 (mem_wb_rd != 5'd0) &&
                 (mem_wb_rd == branch_rs2))
            branch_forward_b = 2'b01;
    end

endmodule
