`timescale 1ns/1ps

module rv32i_regfile (
    input  wire        clock,
    input  wire        reset,
    input  wire [4:0]  read_address_1,
    input  wire [4:0]  read_address_2,
    input  wire [4:0]  write_address,
    input  wire [31:0] write_data,
    input  wire        write_enable,
    output wire [31:0] read_data_1,
    output wire [31:0] read_data_2
);
    reg [31:0] registers [0:31];
    integer index;

    assign read_data_1 = (read_address_1 == 5'd0) ? 32'd0 : registers[read_address_1];
    assign read_data_2 = (read_address_2 == 5'd0) ? 32'd0 : registers[read_address_2];

    always @(posedge clock) begin
        if (reset) begin
            for (index = 0; index < 32; index = index + 1)
                registers[index] <= 32'd0;
        end else if (write_enable && (write_address != 5'd0)) begin
            registers[write_address] <= write_data;
        end
    end
endmodule
