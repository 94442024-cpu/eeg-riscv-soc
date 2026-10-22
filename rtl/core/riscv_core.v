`timescale 1ns/1ps

module riscv_core (
    input wire clock,
    input wire reset
);
    localparam OPCODE_BRANCH = 7'b1100011;
    localparam OPCODE_JAL    = 7'b1101111;
    localparam OPCODE_JALR   = 7'b1100111;
    localparam OPCODE_LUI    = 7'b0110111;
    localparam OPCODE_AUIPC  = 7'b0010111;

    reg [31:0] program_counter;
    wire [31:0] instruction;
    wire [6:0] opcode = instruction[6:0];
    wire [4:0] read_address_1 = instruction[19:15];
    wire [4:0] read_address_2 = instruction[24:20];
    wire [4:0] write_address = instruction[11:7];
    wire [2:0] funct3 = instruction[14:12];
    wire [31:0] immediate;
    wire [31:0] read_data_1;
    wire [31:0] read_data_2;
    wire [31:0] alu_left_operand;
    wire [31:0] alu_right_operand;
    wire [31:0] alu_result;
    wire [31:0] memory_read_data;
    wire [31:0] writeback_data;
    reg [31:0] next_program_counter;
    wire [31:0] sequential_program_counter = program_counter + 32'd4;

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

    reg branch_condition;
    wire is_lui = (opcode == OPCODE_LUI);
    wire is_auipc = (opcode == OPCODE_AUIPC);
    wire is_jump = (opcode == OPCODE_JAL) || (opcode == OPCODE_JALR);

    rv32i_instr_mem instruction_memory (
        .address(program_counter),
        .instruction(instruction)
    );

    rv32i_imm_gen immediate_generator (
        .instruction(instruction),
        .immediate(immediate)
    );

    rv32i_control control_unit (
        .opcode(opcode),
        .funct3(funct3),
        .funct7(instruction[31:25]),
        .alu_operation(alu_operation),
        .alu_src_immediate(alu_src_immediate),
        .register_write(register_write),
        .memory_read(memory_read),
        .memory_write(memory_write),
        .result_from_memory(result_from_memory),
        .branch(branch),
        .jump(jump),
        .jump_register(jump_register),
        .valid(valid)
    );

    rv32i_regfile register_file (
        .clock(clock),
        .reset(reset),
        .read_address_1(read_address_1),
        .read_address_2(read_address_2),
        .write_address(write_address),
        .write_data(writeback_data),
        .write_enable(register_write && valid),
        .read_data_1(read_data_1),
        .read_data_2(read_data_2)
    );

    assign alu_left_operand = is_lui ? 32'd0 : (is_auipc ? program_counter : read_data_1);
    assign alu_right_operand = alu_src_immediate ? immediate : read_data_2;

    rv32i_alu arithmetic_logic_unit (
        .operation(alu_operation),
        .left_operand(alu_left_operand),
        .right_operand(alu_right_operand),
        .result(alu_result)
    );

    rv32i_data_mem data_memory (
        .clock(clock),
        .reset(reset),
        .address(alu_result),
        .write_data(read_data_2),
        .read_enable(memory_read && valid),
        .write_enable(memory_write && valid),
        .funct3(funct3),
        .read_data(memory_read_data)
    );

    always @* begin
        case (funct3)
            3'b000: branch_condition = (read_data_1 == read_data_2);
            3'b001: branch_condition = (read_data_1 != read_data_2);
            3'b100: branch_condition = ($signed(read_data_1) < $signed(read_data_2));
            3'b101: branch_condition = ($signed(read_data_1) >= $signed(read_data_2));
            3'b110: branch_condition = (read_data_1 < read_data_2);
            3'b111: branch_condition = (read_data_1 >= read_data_2);
            default: branch_condition = 1'b0;
        endcase
    end

    assign writeback_data = is_lui ? immediate :
                            is_auipc ? (program_counter + immediate) :
                            is_jump ? sequential_program_counter :
                            result_from_memory ? memory_read_data : alu_result;

    always @* begin
        next_program_counter = sequential_program_counter;
        if (branch && branch_condition)
            next_program_counter = program_counter + immediate;
        if (jump) begin
            if (jump_register)
                next_program_counter = (read_data_1 + immediate) & 32'hFFFFFFFE;
            else
                next_program_counter = program_counter + immediate;
        end
        if (!valid)
            next_program_counter = sequential_program_counter;
    end

    always @(posedge clock) begin
        if (reset)
            program_counter <= 32'd0;
        else
            program_counter <= next_program_counter;
    end
endmodule
