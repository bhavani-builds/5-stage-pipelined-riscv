
`timescale 1ns / 1ps

module tb_forwarding_unit;

    reg [4:0] id_ex_rs1;
    reg [4:0] id_ex_rs2;

    reg [4:0] ex_mem_rd;
    reg ex_mem_reg_write;

    reg [4:0] mem_wb_rd;
    reg mem_wb_reg_write;

    wire [1:0] forward_a;
    wire [1:0] forward_b;

    integer errors;

    forwarding_unit dut (
        .id_ex_rs1(id_ex_rs1),
        .id_ex_rs2(id_ex_rs2),
        .ex_mem_rd(ex_mem_rd),
        .ex_mem_reg_write(ex_mem_reg_write),
        .mem_wb_rd(mem_wb_rd),
        .mem_wb_reg_write(mem_wb_reg_write),
        .forward_a(forward_a),
        .forward_b(forward_b)
    );

    task check_forwarding;
        input [1:0] expected_a;
        input [1:0] expected_b;
        begin
            #1;
            if (forward_a !== expected_a ||
                forward_b !== expected_b) begin
                $display(
                    "FAIL: A=%b B=%b expected A=%b B=%b",
                    forward_a, forward_b,
                    expected_a, expected_b
                );
                errors = errors + 1;
            end
            else begin
                $display(
                    "PASS: forward_a=%b forward_b=%b",
                    forward_a, forward_b
                );
            end
        end
    endtask

    initial begin
        errors = 0;

        id_ex_rs1 = 5'd5;
        id_ex_rs2 = 5'd6;
        ex_mem_rd = 0;
        ex_mem_reg_write = 0;
        mem_wb_rd = 0;
        mem_wb_reg_write = 0;

        // Case 1: No forwarding
        check_forwarding(2'b00, 2'b00);

        // Case 2: Forward operand A from EX-MEM
        ex_mem_rd = 5'd5;
        ex_mem_reg_write = 1;
        check_forwarding(2'b10, 2'b00);

        // Case 3: Forward operand B from MEM-WB
        ex_mem_rd = 0;
        ex_mem_reg_write = 0;
        mem_wb_rd = 5'd6;
        mem_wb_reg_write = 1;
        check_forwarding(2'b00, 2'b01);

        // Case 4: EX-MEM has priority over MEM-WB
        ex_mem_rd = 5'd5;
        ex_mem_reg_write = 1;
        mem_wb_rd = 5'd5;
        mem_wb_reg_write = 1;
        check_forwarding(2'b10, 2'b00);

        // Case 5: Never forward register x0
        id_ex_rs1 = 5'd0;
        id_ex_rs2 = 5'd0;
        ex_mem_rd = 5'd0;
        mem_wb_rd = 5'd0;
        check_forwarding(2'b00, 2'b00);

        if (errors == 0)
            $display("ALL FORWARDING TESTS PASSED");
        else
            $display("FORWARDING TESTS FAILED: %0d errors", errors);

        $finish;
    end

endmodule
