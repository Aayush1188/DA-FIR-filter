`timescale 1ns / 1ps

module top_level (
    input wire clk_100mhz,  
    input wire reset_btn,
    input wire filter_btn_1,
    input wire filter_btn_2,
    input wire filter_btn_3,
    
    input wire adc_clk_48khz,
    input wire signed [23:0] audio_in_pin,
    output wire signed [23:0] audio_out_pin
);

    // With this hardware-accurate clock buffer:
    reg clk_div = 0;
    always @(posedge clk_100mhz) clk_div <= ~clk_div;

    wire clk_50mhz;
    BUFG bufg_inst (
        .I(clk_div),
        .O(clk_50mhz)
    );

    // CDC and Edge Detector for ADC sampling
    reg d1, d2, d3;
    always @(posedge clk_50mhz) begin 
        {d3, d2, d1} <= {d2, d1, adc_clk_48khz}; 
    end
    wire sample_trigger = (d2 && !d3);

    // Memory-Mapped DMA Interconnects
    wire spi_we;
    wire [11:0] spi_addr;
    wire signed [31:0] spi_data;
    wire spi_req, update_ack;

    // 133-Tap Profile Manager
    profile_manager_133tap dma_inst (
        .clk_50mhz(clk_50mhz), 
        .reset(reset_btn),
        .btn_1(filter_btn_1), 
        .btn_2(filter_btn_2), 
        .btn_3(filter_btn_3),
        .spi_we(spi_we), 
        .spi_addr(spi_addr),
        .spi_data_out(spi_data), 
        .spi_update_request(spi_req), 
        .update_ack(update_ack)
    );

    // 133-Tap DSP Coprocessor
    fir_da_133tap_v2 dsp_core_inst (
        .clk_50mhz(clk_50mhz), 
        .reset(reset_btn), 
        .sample_trigger(sample_trigger),
        .audio_in(audio_in_pin), 
        .audio_out(audio_out_pin), 
        .out_valid(), 
        .spi_we(spi_we), 
        .spi_addr(spi_addr),
        .spi_data_in(spi_data), 
        .spi_update_request(spi_req), 
        .update_ack(update_ack)
    );

endmodule