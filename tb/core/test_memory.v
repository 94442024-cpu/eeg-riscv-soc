`timescale 1ns/1ps

module test_memory;
    reg clock = 1'b0;
    reg reset = 1'b1;
    reg [31:0] instruction_address = 0;
    wire [31:0] instruction;
    reg [31:0] data_address = 0;
    reg [31:0] write_data = 0;
    reg read_enable = 0;
    reg write_enable = 0;
    reg [2:0] funct3 = 0;
    wire [31:0] read_data;

    rv32i_instr_mem instruction_memory (
        .address(instruction_address), .instruction(instruction)
    );
    rv32i_data_mem data_memory (
        .clock(clock), .reset(reset), .address(data_address),
        .write_data(write_data), .read_enable(read_enable),
        .write_enable(write_enable), .funct3(funct3), .read_data(read_data)
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

    task write_memory;
        input [31:0] address_value;
        input [31:0] data_value;
        input [2:0] width;
        begin
            data_address = address_value;
            write_data = data_value;
            funct3 = width;
            write_enable = 1'b1;
            @(posedge clock);
            #1;
            write_enable = 1'b0;
        end
    endtask

    task read_memory;
        input [31:0] address_value;
        input [2:0] width;
        begin
            data_address = address_value;
            funct3 = width;
            read_enable = 1'b1;
            #1;
        end
    endtask

    initial begin
        instruction_memory.instruction_memory[0] = 32'h00500093;
        instruction_memory.instruction_memory[1] = 32'h00000013;
        instruction_address = 32'd0;
        #1;
        check(instruction, 32'h00500093, "instruction fetch");
        instruction_address = 32'd4;
        #1;
        check(instruction, 32'h00000013, "word-aligned instruction fetch");

        @(posedge clock);
        #1;
        reset = 1'b0;
        write_memory(32'd16, 32'h80FF7F01, 3'b010);

        read_memory(32'd16, 3'b010);
        check(read_data, 32'h80FF7F01, "LW little endian");
        read_enable = 1'b0;

        read_memory(32'd16, 3'b000);
        check(read_data, 32'h00000001, "LB positive");
        read_enable = 1'b0;
        read_memory(32'd17, 3'b000);
        check(read_data, 32'h0000007F, "LB positive second byte");
        read_enable = 1'b0;
        read_memory(32'd18, 3'b000);
        check(read_data, 32'hFFFFFFFF, "LB sign extension");
        read_enable = 1'b0;
        read_memory(32'd18, 3'b100);
        check(read_data, 32'h000000FF, "LBU zero extension");
        read_enable = 1'b0;

        read_memory(32'd16, 3'b001);
        check(read_data, 32'h00007F01, "LH sign extension positive");
        read_enable = 1'b0;
        read_memory(32'd18, 3'b001);
        check(read_data, 32'hFFFF80FF, "LH sign extension negative");
        read_enable = 1'b0;
        read_memory(32'd18, 3'b101);
        check(read_data, 32'h000080FF, "LHU zero extension");
        read_enable = 1'b0;

        $display("PASS: RV32I instruction and data memory smoke tests");
        $finish;
    end
endmodule
