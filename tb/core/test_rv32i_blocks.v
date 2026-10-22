`timescale 1ns/1ps

module test_rv32i_blocks;
    reg clock = 1'b0;
    reg reset = 1'b1;
    reg [4:0] read_address_1 = 0;
    reg [4:0] read_address_2 = 0;
    reg [4:0] write_address = 0;
    reg [31:0] write_data = 0;
    reg write_enable = 0;
    wire [31:0] read_data_1;
    wire [31:0] read_data_2;

    reg [3:0] operation;
    reg [31:0] left_operand;
    reg [31:0] right_operand;
    wire [31:0] result;

    rv32i_regfile registers (
        .clock(clock), .reset(reset),
        .read_address_1(read_address_1), .read_address_2(read_address_2),
        .write_address(write_address), .write_data(write_data),
        .write_enable(write_enable), .read_data_1(read_data_1), .read_data_2(read_data_2)
    );

    rv32i_alu alu (
        .operation(operation), .left_operand(left_operand),
        .right_operand(right_operand), .result(result)
    );

    always #5 clock = ~clock;

    task check;
        input [31:0] actual;
        input [31:0] expected;
        input [255:0] label;
        begin
            if (actual !== expected) begin
                $display("FAIL: %s actual=%h expected=%h", label, actual, expected);
                $finish(1);
            end
        end
    endtask

    initial begin
        #1;
        @(posedge clock);
        #1;
        reset = 1'b0;

        read_address_1 = 5'd0;
        read_address_2 = 5'd5;
        #1;
        check(read_data_1, 32'd0, "x0 after reset");
        check(read_data_2, 32'd0, "x5 after reset");

        write_address = 5'd5;
        write_data = 32'h12345678;
        write_enable = 1'b1;
        @(posedge clock);
        #1;
        write_enable = 1'b0;
        #1;
        check(read_data_2, 32'h12345678, "register write/read");

        write_address = 5'd0;
        write_data = 32'hFFFFFFFF;
        write_enable = 1'b1;
        @(posedge clock);
        #1;
        write_enable = 1'b0;
        #1;
        check(read_data_1, 32'd0, "x0 ignores writes");

        left_operand = 32'hFFFFFFFF;
        right_operand = 32'd1;
        operation = 4'd0;
        #1;
        check(result, 32'd0, "ADD wraps");

        left_operand = 32'h80000000;
        right_operand = 32'd4;
        operation = 4'd7;
        #1;
        check(result, 32'hF8000000, "SRA sign extends");

        left_operand = 32'hFFFFFFFF;
        right_operand = 32'd1;
        operation = 4'd8;
        #1;
        check(result, 32'd1, "SLT signed");

        left_operand = 32'hFFFFFFFF;
        right_operand = 32'd1;
        operation = 4'd9;
        #1;
        check(result, 32'd0, "SLTU unsigned");

        $display("PASS: RV32I ALU and register file smoke tests");
        $finish;
    end
endmodule
