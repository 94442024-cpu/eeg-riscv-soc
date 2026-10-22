`timescale 1ns/1ps

module rv32i_alu (
    input  wire [3:0]  operation,
    input  wire [31:0] left_operand,
    input  wire [31:0] right_operand,
    output reg  [31:0] result
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

    always @* begin
        case (operation)
            OP_ADD:  result = left_operand + right_operand;
            OP_SUB:  result = left_operand - right_operand;
            OP_AND:  result = left_operand & right_operand;
            OP_OR:   result = left_operand | right_operand;
            OP_XOR:  result = left_operand ^ right_operand;
            OP_SLL:  result = left_operand << right_operand[4:0];
            OP_SRL:  result = left_operand >> right_operand[4:0];
            OP_SRA:  result = $signed(left_operand) >>> right_operand[4:0];
            OP_SLT:  result = ($signed(left_operand) < $signed(right_operand)) ? 32'd1 : 32'd0;
            OP_SLTU: result = (left_operand < right_operand) ? 32'd1 : 32'd0;
            default: result = 32'd0;
        endcase
    end
endmodule
