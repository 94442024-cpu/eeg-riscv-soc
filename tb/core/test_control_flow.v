`timescale 1ns/1ps

module test_control_flow;
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
    function [31:0] b;
        input integer offset; input [4:0] rs2; input [4:0] rs1; input [2:0] f3;
        reg [12:0] immediate;
        begin
            immediate = offset;
            b = {immediate[12], immediate[10:5], rs2, rs1, f3,
                 immediate[4:1], immediate[11], 1'b0, 7'b1100011};
        end
    endfunction
    function [31:0] auipc;
        input [4:0] rd;
        begin auipc = {20'd0, rd, 7'b0010111}; end
    endfunction
    task check;
        input [31:0] actual; input [31:0] expected; input [127:0] label;
        begin if (actual !== expected) begin $display("FAIL %s: %h != %h", label, actual, expected); $finish(1); end end
    endtask

    initial begin
        pc_index = 0;
        dut.instruction_memory.instruction_memory[pc_index++] = i(1, 0, 3'b000, 1, 7'b0010011);
        dut.instruction_memory.instruction_memory[pc_index++] = i(2, 0, 3'b000, 2, 7'b0010011);
        dut.instruction_memory.instruction_memory[pc_index++] = i(-1, 0, 3'b000, 3, 7'b0010011);

        dut.instruction_memory.instruction_memory[pc_index++] = 32'h00108463;
        dut.instruction_memory.instruction_memory[pc_index++] = i(99, 0, 3'b000, 10, 7'b0010011);
        dut.instruction_memory.instruction_memory[pc_index++] = 32'h00209463;
        dut.instruction_memory.instruction_memory[pc_index++] = i(99, 0, 3'b000, 11, 7'b0010011);
        dut.instruction_memory.instruction_memory[pc_index++] = 32'h0011C463;
        dut.instruction_memory.instruction_memory[pc_index++] = i(99, 0, 3'b000, 12, 7'b0010011);
        dut.instruction_memory.instruction_memory[pc_index++] = 32'h0030D463;
        dut.instruction_memory.instruction_memory[pc_index++] = i(99, 0, 3'b000, 13, 7'b0010011);
        dut.instruction_memory.instruction_memory[pc_index++] = 32'h0020E463;
        dut.instruction_memory.instruction_memory[pc_index++] = i(99, 0, 3'b000, 14, 7'b0010011);
        dut.instruction_memory.instruction_memory[pc_index++] = 32'h00117463;
        dut.instruction_memory.instruction_memory[pc_index++] = i(99, 0, 3'b000, 15, 7'b0010011);

        dut.instruction_memory.instruction_memory[pc_index++] = 32'h00208463;
        dut.instruction_memory.instruction_memory[pc_index++] = i(7, 0, 3'b000, 16, 7'b0010011);
        dut.instruction_memory.instruction_memory[pc_index++] = 32'h00109463;
        dut.instruction_memory.instruction_memory[pc_index++] = i(7, 0, 3'b000, 17, 7'b0010011);
        dut.instruction_memory.instruction_memory[pc_index++] = 32'h00114463;
        dut.instruction_memory.instruction_memory[pc_index++] = i(7, 0, 3'b000, 18, 7'b0010011);
        dut.instruction_memory.instruction_memory[pc_index++] = 32'h0020D463;
        dut.instruction_memory.instruction_memory[pc_index++] = i(7, 0, 3'b000, 19, 7'b0010011);
        dut.instruction_memory.instruction_memory[pc_index++] = 32'h00116463;
        dut.instruction_memory.instruction_memory[pc_index++] = i(7, 0, 3'b000, 20, 7'b0010011);
        dut.instruction_memory.instruction_memory[pc_index++] = 32'h0020F463;
        dut.instruction_memory.instruction_memory[pc_index++] = i(7, 0, 3'b000, 21, 7'b0010011);

        dut.instruction_memory.instruction_memory[pc_index++] = auipc(22);
        dut.instruction_memory.instruction_memory[pc_index++] = i(20, 22, 3'b000, 22, 7'b0010011);
        dut.instruction_memory.instruction_memory[pc_index++] = 32'h000B0BE7;
        dut.instruction_memory.instruction_memory[pc_index++] = i(99, 0, 3'b000, 23, 7'b0010011);
        dut.instruction_memory.instruction_memory[pc_index++] = 32'h00000013;
        dut.instruction_memory.instruction_memory[pc_index++] = i(1, 0, 3'b000, 24, 7'b0010011);

        repeat (2) @(posedge clock);
        #1 reset = 1'b0;
        for (cycle = 0; cycle < pc_index + 4; cycle = cycle + 1) @(posedge clock);
        #1;
        check(dut.register_file.registers[10], 0, "BEQ taken");
        check(dut.register_file.registers[11], 0, "BNE taken");
        check(dut.register_file.registers[12], 0, "BLT taken");
        check(dut.register_file.registers[13], 0, "BGE taken");
        check(dut.register_file.registers[14], 0, "BLTU taken");
        check(dut.register_file.registers[15], 0, "BGEU taken");
        check(dut.register_file.registers[16], 7, "BEQ not taken");
        check(dut.register_file.registers[17], 7, "BNE not taken");
        check(dut.register_file.registers[18], 7, "BLT not taken");
        check(dut.register_file.registers[19], 7, "BGE not taken");
        check(dut.register_file.registers[20], 7, "BLTU not taken");
        check(dut.register_file.registers[21], 7, "BGEU not taken");
        check(dut.register_file.registers[23], 120, "JALR link");
        check(dut.register_file.registers[24], 1, "JALR target");
        $display("PASS: RV32I branch and JALR regression");
        $finish;
    end
endmodule
