`timescale 1ns/1ps

module test_decode_imm;
    reg [31:0] instruction;
    wire [31:0] immediate;
    wire [3:0] alu_operation;
    wire alu_src_immediate;
    wire register_write;
    wire memory_read;
    wire memory_write;
    wire result_from_memory;
    wire branch;
    wire jump;
    wire jump_register;
    wire valid;

    rv32i_imm_gen immediate_generator (.instruction(instruction), .immediate(immediate));
    rv32i_control control_unit (
        .opcode(instruction[6:0]), .funct3(instruction[14:12]),
        .funct7(instruction[31:25]), .alu_operation(alu_operation),
        .alu_src_immediate(alu_src_immediate), .register_write(register_write),
        .memory_read(memory_read), .memory_write(memory_write),
        .result_from_memory(result_from_memory), .branch(branch), .jump(jump),
        .jump_register(jump_register), .valid(valid)
    );

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
        instruction = 32'b0;
        #1;
        check(immediate, 32'd0, "unknown immediate");
        check(valid, 1'b0, "unknown invalid");

        instruction = 32'h00500093;
        #1;
        check(immediate, 32'd5, "I immediate");
        check(valid, 1'b1, "ADDI valid");
        check(alu_src_immediate, 1'b1, "ADDI immediate source");
        check(register_write, 1'b1, "ADDI register write");

        instruction = 32'hFE010113;
        #1;
        check(immediate, 32'hFFFFFFE0, "negative I immediate");

        instruction = 32'hFE512823;
        #1;
        check(immediate, 32'hFFFFFFF0, "S immediate");
        check(memory_write, 1'b1, "store control");

        instruction = 32'hFE208EE3;
        #1;
        check(immediate, 32'hFFFFFFFC, "negative B immediate");
        check(branch, 1'b1, "branch control");

        instruction = 32'h123452B7;
        #1;
        check(immediate, 32'h12345000, "U immediate");

        instruction = 32'h800000EF;
        #1;
        check(immediate, 32'hFFF00000, "negative J immediate");
        check(jump, 1'b1, "JAL control");

        instruction = 32'h00008067;
        #1;
        check(jump_register, 1'b1, "JALR control");

        $display("PASS: RV32I decoder and immediate-generator smoke tests");
        $finish;
    end
endmodule
