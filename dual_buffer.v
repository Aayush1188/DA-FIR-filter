`timescale 1ns / 1ps

module ping_pong_ram (
    // Port A: The DSP Read Port (Fast 50 MHz Math)
    input wire clk_dsp,
    input wire [6:0] bitslc,   
    input wire active_bank,    
    output reg signed [31:0] data_out_dsp,

    // Port B: The DMA Write Port (Background Loading)
    input wire clk_spi,
    input wire [6:0] addr_spi, 
    input wire we_spi,         
    input wire signed [31:0] data_in_spi
);

    reg signed [31:0] ram [0:255];

    wire [7:0] physical_read_addr = {active_bank, bitslc};
    wire [7:0] physical_write_addr = {~active_bank, addr_spi};

    always @(posedge clk_dsp) begin
        data_out_dsp <= ram[physical_read_addr];
    end

    always @(posedge clk_spi) begin
        if (we_spi) begin
            ram[physical_write_addr] <= data_in_spi;
        end
    end
endmodule