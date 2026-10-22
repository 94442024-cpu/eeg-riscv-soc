`timescale 1ns/1ps

module rv32i_data_mem #(
    parameter BYTES = 4096
) (
    input  wire        clock,
    input  wire        reset,
    input  wire [31:0] address,
    input  wire [31:0] write_data,
    input  wire        read_enable,
    input  wire        write_enable,
    input  wire [2:0]  funct3,
    output reg  [31:0] read_data
);
    reg [7:0] data_memory [0:BYTES-1];
    integer index;
    wire address_in_range = (address < BYTES);
    wire byte_aligned = address_in_range;
    wire halfword_aligned = address_in_range && (address[0] == 1'b0) && ((address + 1) < BYTES);
    wire word_aligned = address_in_range && (address[1:0] == 2'b00) && ((address + 3) < BYTES);

    always @* begin
        read_data = 32'd0;
        if (read_enable) begin
            case (funct3)
                3'b000: begin
                    if (byte_aligned)
                        read_data = {{24{data_memory[address][7]}}, data_memory[address]};
                end
                3'b001: begin
                    if (halfword_aligned)
                        read_data = {{16{data_memory[address + 1][7]}}, data_memory[address + 1], data_memory[address]};
                end
                3'b010: begin
                    if (word_aligned)
                        read_data = {data_memory[address + 3], data_memory[address + 2],
                                     data_memory[address + 1], data_memory[address]};
                end
                3'b100: begin
                    if (byte_aligned)
                        read_data = {24'd0, data_memory[address]};
                end
                3'b101: begin
                    if (halfword_aligned)
                        read_data = {16'd0, data_memory[address + 1], data_memory[address]};
                end
                default: read_data = 32'd0;
            endcase
        end
    end

    always @(posedge clock) begin
        if (reset) begin
            for (index = 0; index < BYTES; index = index + 1)
                data_memory[index] <= 8'd0;
        end else if (write_enable) begin
            case (funct3)
                3'b000: begin
                    if (byte_aligned)
                        data_memory[address] <= write_data[7:0];
                end
                3'b001: begin
                    if (halfword_aligned) begin
                        data_memory[address] <= write_data[7:0];
                        data_memory[address + 1] <= write_data[15:8];
                    end
                end
                3'b010: begin
                    if (word_aligned) begin
                        data_memory[address] <= write_data[7:0];
                        data_memory[address + 1] <= write_data[15:8];
                        data_memory[address + 2] <= write_data[23:16];
                        data_memory[address + 3] <= write_data[31:24];
                    end
                end
                default: begin
                end
            endcase
        end
    end
endmodule
