
module branch_control (
    input wire [31:0] pc_current,
    input wire [31:0] branch_immediate,
    input wire branch_taken,

    output wire [31:0] pc_sequential,
    output wire [31:0] pc_branch,
    output wire [31:0] pc_next
);

    // Address of the next sequential instruction
    assign pc_sequential = pc_current + 32'd4;

    // Branch destination address
    assign pc_branch = pc_current + branch_immediate;

    // Select the next PC
    assign pc_next = branch_taken
                   ? pc_branch
                   : pc_sequential;

endmodule
