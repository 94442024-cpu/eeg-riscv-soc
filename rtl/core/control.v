`timescale 1ns/1ps

module rv32i_control (
    input  wire [6:0] opcode,
    input  wire [2:0] funct3,
    input  wire [6:0] funct7,
    output reg  [3:0] alu_operation,
    output reg        alu_src_immediate,
    output reg        register_write,
    output reg        memory_read,
    output reg        memory_write,
    output reg        result_from_memory,
    output reg        branch,
    output reg        jump,
    output reg        jump_register,
    output reg        valid
);
    localparam OP_ADD  = 4'd0;
    localparam OP_SUB  = 4'd1;
    localparam OP_AND  = 4'd2;
    localparam OP_OR   = 4'd3;
    localparam OP_XOR  = 4'd4;
    localparam OP_SLL  = 4'd5;
    localparam OP_SRL  = 4'd6;
    localparam OP_SRA  = 4'd7;
    localparam OP_SLT  = 4'd8;
    localparam OP_SLTU = 4'd9;

    localparam OPCODE_R      = 7'b0110011;
    localparam OPCODE_I      = 7'b0010011;
    localparam OPCODE_LOAD   = 7'b0000011;
    localparam OPCODE_STORE  = 7'b0100011;
    localparam OPCODE_BRANCH = 7'b1100011;
    localparam OPCODE_JAL    = 7'b1101111;
    localparam OPCODE_JALR   = 7'b1100111;
    localparam OPCODE_LUI    = 7'b0110111;
    localparam OPCODE_AUIPC  = 7'b0010111;

    always @* begin
        alu_operation = OP_ADD;
        alu_src_immediate = 1'b0;
        register_write = 1'b0;
        memory_read = 1'b0;
        memory_write = 1'b0;
        result_from_memory = 1'b0;
        branch = 1'b0;
        jump = 1'b0;
        jump_register = 1'b0;
        valid = 1'b0;

        case (opcode)
            OPCODE_R: begin
                valid = 1'b1;
                register_write = 1'b1;
                case (funct3)
                    3'b000: alu_operation = (funct7[5] ? OP_SUB : OP_ADD);
                    3'b001: alu_operation = OP_SLL;
                    3'b010: alu_operation = OP_SLT;
                    3'b011: alu_operation = OP_SLTU;
                    3'b100: alu_operation = OP_XOR;
                    3'b101: alu_operation = (funct7[5] ? OP_SRA : OP_SRL);
                    3'b110: alu_operation = OP_OR;
                    3'b111: alu_operation = OP_AND;
                    default: valid = 1'b0;
                endcase
            end
            OPCODE_I: begin
                valid = 1'b1;
                alu_src_immediate = 1'b1;
                register_write = 1'b1;
                case (funct3)
                    3'b000: alu_operation = OP_ADD;
                    3'b010: alu_operation = OP_SLT;
                    3'b011: alu_operation = OP_SLTU;
                    3'b100: alu_operation = OP_XOR;
                    3'b110: alu_operation = OP_OR;
                    3'b111: alu_operation = OP_AND;
                    3'b001: alu_operation = OP_SLL;
                    3'b101: alu_operation = (funct7[5] ? OP_SRA : OP_SRL);
                    default: valid = 1'b0;
                endcase
            end
            OPCODE_LOAD: begin
                valid = 1'b1;
                alu_operation = OP_ADD;
                alu_src_immediate = 1'b1;
                register_write = 1'b1;
                memory_read = 1'b1;
                result_from_memory = 1'b1;
            end
            OPCODE_STORE: begin
                valid = 1'b1;
                alu_operation = OP_ADD;
                alu_src_immediate = 1'b1;
                memory_write = 1'b1;
            end
            OPCODE_BRANCH: begin
                valid = 1'b1;
                alu_operation = OP_SUB;
                branch = 1'b1;
            end
            OPCODE_JAL: begin
                valid = 1'b1;
                register_write = 1'b1;
                jump = 1'b1;
            end
            OPCODE_JALR: begin
                valid = 1'b1;
                alu_operation = OP_ADD;
                alu_src_immediate = 1'b1;
                register_write = 1'b1;
                jump = 1'b1;
                jump_register = 1'b1;
            end
            OPCODE_LUI: begin
                valid = 1'b1;
                alu_src_immediate = 1'b1;
                register_write = 1'b1;
            end
            OPCODE_AUIPC: begin
                valid = 1'b1;
                alu_src_immediate = 1'b1;
                register_write = 1'b1;
            end
            default: begin
                valid = 1'b0;
            end
        endcase
    end
endmodule
