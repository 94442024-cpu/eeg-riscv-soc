`timescale 1ns/1ps

module test_rv32i_widths_and_alu;
    reg clock = 1'b0;
    reg reset = 1'b1;
    integer cycle;
    integer pc_index;
    riscv_core dut (.clock(clock), .reset(reset));
    always #5 clock = ~clock;

    function [31:0] i;
        input integer imm; input [4:0] rs1; input [2:0] f3; input [4:0] rd; input [6:0] op;
        begin i = {imm[11:0], rs1, f3, rd, op}; end
    endfunction
    function [31:0] r;
        input [6:0] f7; input [4:0] rs2; input [4:0] rs1; input [2:0] f3; input [4:0] rd;
        begin r = {f7, rs2, rs1, f3, rd, 7'b0110011}; end
    endfunction
    function [31:0] s;
        input integer imm; input [4:0] rs2; input [4:0] rs1; input [2:0] f3;
        begin s = {imm[11:5], rs2, rs1, f3, imm[4:0], 7'b0100011}; end
    endfunction
    task check;
        input [31:0] actual; input [31:0] expected; input [127:0] label;
        begin if (actual !== expected) begin $display("FAIL %s: %h != %h", label, actual, expected); $finish(1); end end
    endtask

    initial begin
        pc_index = 0;
        dut.instruction_memory.instruction_memory[pc_index++] = i(16, 0, 3'b000, 1, 7'b0010011);
        dut.instruction_memory.instruction_memory[pc_index++] = i(-3, 0, 3'b000, 2, 7'b0010011);
        dut.instruction_memory.instruction_memory[pc_index++] = r(7'b0100000, 2, 1, 3'b000, 3);
        dut.instruction_memory.instruction_memory[pc_index++] = r(0, 1, 2, 3'b111, 4);
        dut.instruction_memory.instruction_memory[pc_index++] = r(0, 1, 2, 3'b110, 5);
        dut.instruction_memory.instruction_memory[pc_index++] = r(0, 1, 2, 3'b100, 6);
        dut.instruction_memory.instruction_memory[pc_index++] = r(0, 1, 2, 3'b001, 7);
        dut.instruction_memory.instruction_memory[pc_index++] = r(0, 1, 2, 3'b101, 8);
        dut.instruction_memory.instruction_memory[pc_index++] = r(7'b0100000, 1, 2, 3'b101, 9);
        dut.instruction_memory.instruction_memory[pc_index++] = i(-1, 0, 3'b000, 10, 7'b0010011);
        dut.instruction_memory.instruction_memory[pc_index++] = s(100, 10, 0, 3'b001);
        dut.instruction_memory.instruction_memory[pc_index++] = i(100, 0, 3'b001, 11, 7'b0000011);
        dut.instruction_memory.instruction_memory[pc_index++] = i(100, 0, 3'b101, 12, 7'b0000011);
        dut.instruction_memory.instruction_memory[pc_index++] = i(127, 0, 3'b000, 13, 7'b0010011);
        dut.instruction_memory.instruction_memory[pc_index++] = s(102, 13, 0, 3'b000);
        dut.instruction_memory.instruction_memory[pc_index++] = i(102, 0, 3'b000, 14, 7'b0000011);
        dut.instruction_memory.instruction_memory[pc_index++] = i(102, 0, 3'b100, 15, 7'b0000011);

        repeat (2) @(posedge clock);
        #1 reset = 1'b0;
        for (cycle = 0; cycle < pc_index + 3; cycle = cycle + 1) @(posedge clock);
        #1;
        check(dut.register_file.registers[3], 32'd19, "SUB");
        check(dut.register_file.registers[4], 32'd16, "AND");
        check(dut.register_file.registers[5], 32'hFFFFFFFD, "OR");
        check(dut.register_file.registers[6], 32'hFFFFFFED, "XOR");
        check(dut.register_file.registers[7], 32'hFFFD0000, "SLL");
        check(dut.register_file.registers[8], 32'h0000FFFF, "SRL");
        check(dut.register_file.registers[9], 32'hFFFFFFFF, "SRA");
        check(dut.register_file.registers[11], 32'hFFFFFFFF, "LH");
        check(dut.register_file.registers[12], 32'h0000FFFF, "LHU");
        check(dut.register_file.registers[14], 32'h0000007F, "LB");
        check(dut.register_file.registers[15], 32'h0000007F, "LBU");
        $display("PASS: RV32I remaining ALU and memory-width regression");
        $finish;
    end
endmodule
