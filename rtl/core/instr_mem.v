`timescale 1ns/1ps

module rv32i_instr_mem #(
    parameter WORDS = 1024
) (
    input  wire [31:0] address,
    output wire [31:0] instruction
);
    reg [31:0] instruction_memory [0:WORDS-1];
    wire [31:0] word_address = address >> 2;

    reg [1023:0] initialization_file;

    initial begin
        if ($value$plusargs("PROGRAM=%s", initialization_file))
            $readmemh(initialization_file, instruction_memory);
    end

    assign instruction = (word_address < WORDS) ? instruction_memory[word_address] : 32'h00000013;
endmodule
