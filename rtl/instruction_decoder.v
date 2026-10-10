
module instruction_decoder (
    input wire [31:0] instruction,

    output reg reg_write,
    output reg mem_read,
    output reg mem_write,
    output reg mem_to_reg,
    output reg alu_src,
    output reg branch,
    output reg [3:0] alu_control
);

    wire [6:0] opcode;
    wire [2:0] funct3;
    wire [6:0] funct7;

    assign opcode = instruction[6:0];
    assign funct3 = instruction[14:12];
    assign funct7 = instruction[31:25];

    always @(*) begin
        // Safe defaults for unsupported instructions
        reg_write = 1'b0;
        mem_read = 1'b0;
        mem_write = 1'b0;
        mem_to_reg = 1'b0;
        alu_src = 1'b0;
        branch = 1'b0;
        alu_control = 4'b0000;

        case (opcode)

            // R-type: ADD, SUB, AND, OR, XOR, SLT
            7'b0110011: begin
                reg_write = 1'b1;

                case (funct3)
                    3'b000: begin
                        if (funct7 == 7'b0100000)
                            alu_control = 4'b0001; // SUB
                        else
                            alu_control = 4'b0000; // ADD
                    end

                    3'b111: alu_control = 4'b0010; // AND
                    3'b110: alu_control = 4'b0011; // OR
                    3'b100: alu_control = 4'b0100; // XOR
                    3'b010: alu_control = 4'b0111; // SLT
                    default: reg_write = 1'b0;
                endcase
            end

            // ADDI
            7'b0010011: begin
                reg_write = 1'b1;
                alu_src = 1'b1;

                if (funct3 == 3'b000)
                    alu_control = 4'b0000;
                else
                    reg_write = 1'b0;
            end

            // LW
            7'b0000011: begin
                if (funct3 == 3'b010) begin
                    reg_write = 1'b1;
                    mem_read = 1'b1;
                    mem_to_reg = 1'b1;
                    alu_src = 1'b1;
                    alu_control = 4'b0000;
                end
            end

            // SW
            7'b0100011: begin
                if (funct3 == 3'b010) begin
                    mem_write = 1'b1;
                    alu_src = 1'b1;
                    alu_control = 4'b0000;
                end
            end

            // BEQ
            7'b1100011: begin
                if (funct3 == 3'b000) begin
                    branch = 1'b1;
                    alu_control = 4'b0001;
                end
            end

            default: begin
                // Unsupported instruction: retain safe defaults
            end

        endcase
    end

endmodule
