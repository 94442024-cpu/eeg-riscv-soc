`timescale 1ns/1ps

module test_riscv_core;
    reg clock = 1'b0;
    reg reset = 1'b1;
    integer cycle;

    riscv_core dut (.clock(clock), .reset(reset));

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
        dut.instruction_memory.instruction_memory[0] = 32'h00500093;
        dut.instruction_memory.instruction_memory[1] = 32'h00700113;
        dut.instruction_memory.instruction_memory[2] = 32'h002081B3;
        dut.instruction_memory.instruction_memory[3] = 32'h04302023;
        dut.instruction_memory.instruction_memory[4] = 32'h04002203;
        dut.instruction_memory.instruction_memory[5] = 32'h00418463;
        dut.instruction_memory.instruction_memory[6] = 32'h00100293;
        dut.instruction_memory.instruction_memory[7] = 32'h0080036F;
        dut.instruction_memory.instruction_memory[8] = 32'h00200393;
        dut.instruction_memory.instruction_memory[9] = 32'h00300413;

        repeat (2) @(posedge clock);
        #1;
        reset = 1'b0;

        for (cycle = 0; cycle < 14; cycle = cycle + 1)
            @(posedge clock);
        #1;

        check(dut.register_file.registers[1], 32'd5, "ADDI x1");
        check(dut.register_file.registers[2], 32'd7, "ADDI x2");
        check(dut.register_file.registers[3], 32'd12, "ADD x3");
        check(dut.register_file.registers[4], 32'd12, "LW x4");
        check(dut.register_file.registers[5], 32'd0, "BEQ skips x5 write");
        check(dut.register_file.registers[6], 32'd32, "JAL link address");
        check(dut.register_file.registers[7], 32'd0, "JAL skips x7 write");
        check(dut.register_file.registers[8], 32'd3, "ADDI x8 after JAL");
        check(dut.data_memory.data_memory[64], 8'd12, "SW low byte");
        check(dut.program_counter, 32'd64, "PC after test program");

        $display("PASS: RV32I single-cycle core integration test");
        $finish;
    end
endmodule
