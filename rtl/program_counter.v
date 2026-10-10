
module program_counter (
    input wire clk,
    input wire reset,
    input wire stall,
    input wire [31:0] next_pc,
    output reg [31:0] pc
);

    always @(posedge clk or posedge reset) begin
        if (reset)
            pc <= 32'b0;
        else if (!stall)
            pc <= next_pc;
    end

endmodule
