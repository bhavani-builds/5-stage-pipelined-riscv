
`timescale 1ns/1ps

module tb_id_ex_register;

    reg clk;
    reg reset;
    reg flush;
    reg stall;

    reg [31:0] pc_in;
    reg [31:0] rs1_data_in;
    reg [31:0] rs2_data_in;
    reg [31:0] immediate_in;
    reg [4:0] rs1_in;
    reg [4:0] rs2_in;
    reg [4:0] rd_in;
    reg [3:0] alu_control_in;

    reg reg_write_in;
    reg mem_read_in;
    reg mem_write_in;
    reg mem_to_reg_in;
    reg alu_src_in;

    wire [31:0] pc_out;
    wire [31:0] rs1_data_out;
    wire [31:0] rs2_data_out;
    wire [31:0] immediate_out;
    wire [4:0] rs1_out;
    wire [4:0] rs2_out;
    wire [4:0] rd_out;
    wire [3:0] alu_control_out;

    wire reg_write_out;
    wire mem_read_out;
    wire mem_write_out;
    wire mem_to_reg_out;
    wire alu_src_out;

    integer passed;

    id_ex_register uut (
        .clk(clk),
        .reset(reset),
        .flush(flush),
        .stall(stall),
        .pc_in(pc_in),
        .rs1_data_in(rs1_data_in),
        .rs2_data_in(rs2_data_in),
        .immediate_in(immediate_in),
        .rs1_in(rs1_in),
        .rs2_in(rs2_in),
        .rd_in(rd_in),
        .alu_control_in(alu_control_in),
        .reg_write_in(reg_write_in),
        .mem_read_in(mem_read_in),
        .mem_write_in(mem_write_in),
        .mem_to_reg_in(mem_to_reg_in),
        .alu_src_in(alu_src_in),
        .pc_out(pc_out),
        .rs1_data_out(rs1_data_out),
        .rs2_data_out(rs2_data_out),
        .immediate_out(immediate_out),
        .rs1_out(rs1_out),
        .rs2_out(rs2_out),
        .rd_out(rd_out),
        .alu_control_out(alu_control_out),
        .reg_write_out(reg_write_out),
        .mem_read_out(mem_read_out),
        .mem_write_out(mem_write_out),
        .mem_to_reg_out(mem_to_reg_out),
        .alu_src_out(alu_src_out)
    );

    always #5 clk = ~clk;

    task check_data;
        input [8*45-1:0] test_name;
        input [31:0] expected_pc;
        input [4:0] expected_rd;
        input [31:0] expected_rs1_data;
        input [31:0] expected_rs2_data;
        input expected_reg_write;
        input expected_mem_read;
        begin
            #1;
            if (pc_out === expected_pc &&
                rd_out === expected_rd &&
                rs1_data_out === expected_rs1_data &&
                rs2_data_out === expected_rs2_data &&
                reg_write_out === expected_reg_write &&
                mem_read_out === expected_mem_read) begin
                $display("PASS: %0s", test_name);
                passed = passed + 1;
            end else begin
                $display("FAIL: %0s", test_name);
                $display("PC=%h RD=%0d RS1=%h RS2=%h",
                         pc_out, rd_out, rs1_data_out, rs2_data_out);
                $display("RegWrite=%b MemRead=%b",
                         reg_write_out, mem_read_out);
            end
        end
    endtask

    initial begin
        clk = 0;
        reset = 1;
        flush = 0;
        stall = 0;

        pc_in = 0;
        rs1_data_in = 0;
        rs2_data_in = 0;
        immediate_in = 0;
        rs1_in = 0;
        rs2_in = 0;
        rd_in = 0;
        alu_control_in = 0;
        reg_write_in = 0;
        mem_read_in = 0;
        mem_write_in = 0;
        mem_to_reg_in = 0;
        alu_src_in = 0;
        passed = 0;

        // Test 1: Reset clears outputs
        @(posedge clk);
        check_data("Reset clears register", 0, 0, 0, 0, 0, 0);

        // Test 2: Capture input values
        @(negedge clk);
        reset = 0;
        pc_in = 32'h00000004;
        rs1_data_in = 32'd10;
        rs2_data_in = 32'd20;
        immediate_in = 32'd8;
        rs1_in = 5'd1;
        rs2_in = 5'd2;
        rd_in = 5'd3;
        alu_control_in = 4'b0000;
        reg_write_in = 1;
        mem_read_in = 0;
        mem_write_in = 0;
        mem_to_reg_in = 0;
        alu_src_in = 0;

        @(posedge clk);
        check_data("Capture decoded instruction",
                   32'h00000004, 5'd3, 32'd10, 32'd20, 1, 0);

        // Test 3: Stall holds previous values
        @(negedge clk);
        stall = 1;
        pc_in = 32'h00000008;
        rd_in = 5'd4;
        rs1_data_in = 32'd30;
        rs2_data_in = 32'd40;
        reg_write_in = 0;

        @(posedge clk);
        check_data("Stall holds previous values",
                   32'h00000004, 5'd3, 32'd10, 32'd20, 1, 0);

        // Test 4: Flush clears the control signals and data
        @(negedge clk);
        stall = 0;
        flush = 1;

        @(posedge clk);
        check_data("Flush clears register", 0, 0, 0, 0, 0, 0);

        $display("--------------------------------");
        $display("Tests passed: %0d/4", passed);

        if (passed == 4)
            $display("ALL TESTS PASSED");
        else
            $display("SOME TESTS FAILED");

        $finish;
    end

endmodule
