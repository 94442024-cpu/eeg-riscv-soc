`timescale 1ns/1ps

module test_riscv_core_regression;
    reg clock = 1'b0;
    reg reset = 1'b1;
    integer cycle;
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
    function [31:0] b;
        input integer off; input [4:0] rs2; input [4:0] rs1; input [2:0] f3;
        begin b = {off[12], off[10:5], rs2, rs1, f3, off[4:1], off[11], 1'b0, 7'b1100011}; end
    endfunction
    function [31:0] u;
        input [19:0] imm; input [4:0] rd; input [6:0] op;
        begin u = {imm, rd, op}; end
    endfunction
    function [31:0] j;
        input integer off; input [4:0] rd;
        begin j = {off[20], off[10:1], off[11], off[19:12], rd, 7'b1101111}; end
    endfunction
    task check;
        input [31:0] actual; input [31:0] expected; input [127:0] label;
        begin if (actual !== expected) begin $display("FAIL %s: %h != %h", label, actual, expected); $finish(1); end end
    endtask

    initial begin
        dut.instruction_memory.instruction_memory[0] = i(16, 0, 3'b000, 1, 7'b0010011);
        dut.instruction_memory.instruction_memory[1] = i(-1, 0, 3'b000, 2, 7'b0010011);
        dut.instruction_memory.instruction_memory[2] = i(2, 1, 3'b001, 3, 7'b0010011);
        dut.instruction_memory.instruction_memory[3] = i(1, 2, 3'b101, 4, 7'b0010011);
        dut.instruction_memory.instruction_memory[4] = i(1, 2, 3'b101, 5, 7'b0010011) | 32'h40000000;
        dut.instruction_memory.instruction_memory[5] = r(0, 1, 2, 3'b010, 6);
        dut.instruction_memory.instruction_memory[6] = r(0, 1, 2, 3'b011, 7);
        dut.instruction_memory.instruction_memory[7] = u(20'h12345, 8, 7'b0110111);
        dut.instruction_memory.instruction_memory[8] = i(16, 0, 3'b000, 9, 7'b0010011);
        dut.instruction_memory.instruction_memory[9] = s(100, 9, 0, 3'b000);
        dut.instruction_memory.instruction_memory[10] = i(100, 0, 3'b000, 10, 7'b0000011);
        dut.instruction_memory.instruction_memory[11] = i(100, 0, 3'b100, 11, 7'b0000011);
        dut.instruction_memory.instruction_memory[12] = 32'h00108463;
        dut.instruction_memory.instruction_memory[13] = i(99, 0, 3'b000, 12, 7'b0010011);
        dut.instruction_memory.instruction_memory[14] = 32'h008006EF;
        dut.instruction_memory.instruction_memory[15] = i(99, 0, 3'b000, 14, 7'b0010011);
        dut.instruction_memory.instruction_memory[16] = i(1, 0, 3'b000, 15, 7'b0010011);

        repeat (2) @(posedge clock);
        #1 reset = 1'b0;
        for (cycle = 0; cycle < 22; cycle = cycle + 1) @(posedge clock);
        #1;
        check(dut.register_file.registers[1], 32'd16, "ADDI");
        check(dut.register_file.registers[2], 32'hFFFFFFFF, "negative ADDI");
        check(dut.register_file.registers[3], 32'd64, "SLLI");
        check(dut.register_file.registers[4], 32'h7FFFFFFF, "SRLI");
        check(dut.register_file.registers[5], 32'hFFFFFFFF, "SRAI");
        check(dut.register_file.registers[6], 32'd1, "SLT");
        check(dut.register_file.registers[7], 32'd0, "SLTU");
        check(dut.register_file.registers[8], 32'h12345000, "LUI");
        check(dut.register_file.registers[10], 32'd16, "LB");
        check(dut.register_file.registers[11], 32'd16, "LBU");
        check(dut.register_file.registers[12], 32'd0, "BEQ skipped write");
        check(dut.register_file.registers[13], 32'd60, "JAL link");
        check(dut.register_file.registers[14], 32'd0, "JAL skipped write");
        check(dut.register_file.registers[15], 32'd1, "JAL target");
        $display("PASS: RV32I instruction regression");
        $finish;
    end
endmodule
