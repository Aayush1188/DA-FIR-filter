`timescale 1ns / 1ps

module fir_da_133tap_v2 (
    input wire clk_50mhz,
    input wire reset,
    input wire sample_trigger, 
    input wire signed [23:0] audio_in,
    
    // Memory-Mapped DMA Interface
    input wire spi_we,
    input wire [11:0] spi_addr,  // [11:7] RAM Select, [6:0] Word Address
    input wire signed [31:0] spi_data_in,
    input wire spi_update_request,
    output reg update_ack,
    
    // Audio Output
    output reg signed [23:0] audio_out,
    output reg out_valid
);

    reg active_bank = 0;
    
    // Expanded to 19 Partitions
    wire signed [31:0] lut_out [1:19];
    wire [6:0] bitslc [1:19]; 

    // Address Decoder for Write Enables
    wire we_ram1  = (spi_we && (spi_addr[11:7] == 5'd0));
    wire we_ram2  = (spi_we && (spi_addr[11:7] == 5'd1));
    wire we_ram3  = (spi_we && (spi_addr[11:7] == 5'd2));
    wire we_ram4  = (spi_we && (spi_addr[11:7] == 5'd3));
    wire we_ram5  = (spi_we && (spi_addr[11:7] == 5'd4));
    wire we_ram6  = (spi_we && (spi_addr[11:7] == 5'd5));
    wire we_ram7  = (spi_we && (spi_addr[11:7] == 5'd6));
    wire we_ram8  = (spi_we && (spi_addr[11:7] == 5'd7));
    wire we_ram9  = (spi_we && (spi_addr[11:7] == 5'd8));
    wire we_ram10 = (spi_we && (spi_addr[11:7] == 5'd9));
    wire we_ram11 = (spi_we && (spi_addr[11:7] == 5'd10));
    wire we_ram12 = (spi_we && (spi_addr[11:7] == 5'd11));
    wire we_ram13 = (spi_we && (spi_addr[11:7] == 5'd12));
    wire we_ram14 = (spi_we && (spi_addr[11:7] == 5'd13));
    wire we_ram15 = (spi_we && (spi_addr[11:7] == 5'd14));
    wire we_ram16 = (spi_we && (spi_addr[11:7] == 5'd15));
    wire we_ram17 = (spi_we && (spi_addr[11:7] == 5'd16));
    wire we_ram18 = (spi_we && (spi_addr[11:7] == 5'd17));
    wire we_ram19 = (spi_we && (spi_addr[11:7] == 5'd18));

    // Shadow RAM Instantiations
    ping_pong_ram ram1  (.clk_dsp(clk_50mhz), .bitslc(bitslc[1]),  .active_bank(active_bank), .data_out_dsp(lut_out[1]),  .clk_spi(clk_50mhz), .addr_spi(spi_addr[6:0]), .we_spi(we_ram1),  .data_in_spi(spi_data_in));
    ping_pong_ram ram2  (.clk_dsp(clk_50mhz), .bitslc(bitslc[2]),  .active_bank(active_bank), .data_out_dsp(lut_out[2]),  .clk_spi(clk_50mhz), .addr_spi(spi_addr[6:0]), .we_spi(we_ram2),  .data_in_spi(spi_data_in));
    ping_pong_ram ram3  (.clk_dsp(clk_50mhz), .bitslc(bitslc[3]),  .active_bank(active_bank), .data_out_dsp(lut_out[3]),  .clk_spi(clk_50mhz), .addr_spi(spi_addr[6:0]), .we_spi(we_ram3),  .data_in_spi(spi_data_in));
    ping_pong_ram ram4  (.clk_dsp(clk_50mhz), .bitslc(bitslc[4]),  .active_bank(active_bank), .data_out_dsp(lut_out[4]),  .clk_spi(clk_50mhz), .addr_spi(spi_addr[6:0]), .we_spi(we_ram4),  .data_in_spi(spi_data_in));
    ping_pong_ram ram5  (.clk_dsp(clk_50mhz), .bitslc(bitslc[5]),  .active_bank(active_bank), .data_out_dsp(lut_out[5]),  .clk_spi(clk_50mhz), .addr_spi(spi_addr[6:0]), .we_spi(we_ram5),  .data_in_spi(spi_data_in));
    ping_pong_ram ram6  (.clk_dsp(clk_50mhz), .bitslc(bitslc[6]),  .active_bank(active_bank), .data_out_dsp(lut_out[6]),  .clk_spi(clk_50mhz), .addr_spi(spi_addr[6:0]), .we_spi(we_ram6),  .data_in_spi(spi_data_in));
    ping_pong_ram ram7  (.clk_dsp(clk_50mhz), .bitslc(bitslc[7]),  .active_bank(active_bank), .data_out_dsp(lut_out[7]),  .clk_spi(clk_50mhz), .addr_spi(spi_addr[6:0]), .we_spi(we_ram7),  .data_in_spi(spi_data_in));
    ping_pong_ram ram8  (.clk_dsp(clk_50mhz), .bitslc(bitslc[8]),  .active_bank(active_bank), .data_out_dsp(lut_out[8]),  .clk_spi(clk_50mhz), .addr_spi(spi_addr[6:0]), .we_spi(we_ram8),  .data_in_spi(spi_data_in));
    ping_pong_ram ram9  (.clk_dsp(clk_50mhz), .bitslc(bitslc[9]),  .active_bank(active_bank), .data_out_dsp(lut_out[9]),  .clk_spi(clk_50mhz), .addr_spi(spi_addr[6:0]), .we_spi(we_ram9),  .data_in_spi(spi_data_in));
    ping_pong_ram ram10 (.clk_dsp(clk_50mhz), .bitslc(bitslc[10]), .active_bank(active_bank), .data_out_dsp(lut_out[10]), .clk_spi(clk_50mhz), .addr_spi(spi_addr[6:0]), .we_spi(we_ram10), .data_in_spi(spi_data_in));
    ping_pong_ram ram11 (.clk_dsp(clk_50mhz), .bitslc(bitslc[11]), .active_bank(active_bank), .data_out_dsp(lut_out[11]), .clk_spi(clk_50mhz), .addr_spi(spi_addr[6:0]), .we_spi(we_ram11), .data_in_spi(spi_data_in));
    ping_pong_ram ram12 (.clk_dsp(clk_50mhz), .bitslc(bitslc[12]), .active_bank(active_bank), .data_out_dsp(lut_out[12]), .clk_spi(clk_50mhz), .addr_spi(spi_addr[6:0]), .we_spi(we_ram12), .data_in_spi(spi_data_in));
    ping_pong_ram ram13 (.clk_dsp(clk_50mhz), .bitslc(bitslc[13]), .active_bank(active_bank), .data_out_dsp(lut_out[13]), .clk_spi(clk_50mhz), .addr_spi(spi_addr[6:0]), .we_spi(we_ram13), .data_in_spi(spi_data_in));
    ping_pong_ram ram14 (.clk_dsp(clk_50mhz), .bitslc(bitslc[14]), .active_bank(active_bank), .data_out_dsp(lut_out[14]), .clk_spi(clk_50mhz), .addr_spi(spi_addr[6:0]), .we_spi(we_ram14), .data_in_spi(spi_data_in));
    ping_pong_ram ram15 (.clk_dsp(clk_50mhz), .bitslc(bitslc[15]), .active_bank(active_bank), .data_out_dsp(lut_out[15]), .clk_spi(clk_50mhz), .addr_spi(spi_addr[6:0]), .we_spi(we_ram15), .data_in_spi(spi_data_in));
    ping_pong_ram ram16 (.clk_dsp(clk_50mhz), .bitslc(bitslc[16]), .active_bank(active_bank), .data_out_dsp(lut_out[16]), .clk_spi(clk_50mhz), .addr_spi(spi_addr[6:0]), .we_spi(we_ram16), .data_in_spi(spi_data_in));
    ping_pong_ram ram17 (.clk_dsp(clk_50mhz), .bitslc(bitslc[17]), .active_bank(active_bank), .data_out_dsp(lut_out[17]), .clk_spi(clk_50mhz), .addr_spi(spi_addr[6:0]), .we_spi(we_ram17), .data_in_spi(spi_data_in));
    ping_pong_ram ram18 (.clk_dsp(clk_50mhz), .bitslc(bitslc[18]), .active_bank(active_bank), .data_out_dsp(lut_out[18]), .clk_spi(clk_50mhz), .addr_spi(spi_addr[6:0]), .we_spi(we_ram18), .data_in_spi(spi_data_in));
    ping_pong_ram ram19 (.clk_dsp(clk_50mhz), .bitslc(bitslc[19]), .active_bank(active_bank), .data_out_dsp(lut_out[19]), .clk_spi(clk_50mhz), .addr_spi(spi_addr[6:0]), .we_spi(we_ram19), .data_in_spi(spi_data_in));

    // Shift Register extended to 133 Taps
    reg signed [23:0] shift_reg [0:132];
    integer i;
    
    reg [4:0] bit_count = 0;
    wire [4:0] slice_idx = (bit_count < 24) ? bit_count : 5'd23; // Pipeline Lock
    
    // 19 Parallel Bit-Slice Extractions
    assign bitslc[1]  = {shift_reg[6][slice_idx],   shift_reg[5][slice_idx],   shift_reg[4][slice_idx],   shift_reg[3][slice_idx],   shift_reg[2][slice_idx],   shift_reg[1][slice_idx],   shift_reg[0][slice_idx]};
    assign bitslc[2]  = {shift_reg[13][slice_idx],  shift_reg[12][slice_idx],  shift_reg[11][slice_idx],  shift_reg[10][slice_idx],  shift_reg[9][slice_idx],   shift_reg[8][slice_idx],   shift_reg[7][slice_idx]};
    assign bitslc[3]  = {shift_reg[20][slice_idx],  shift_reg[19][slice_idx],  shift_reg[18][slice_idx],  shift_reg[17][slice_idx],  shift_reg[16][slice_idx],  shift_reg[15][slice_idx],  shift_reg[14][slice_idx]};
    assign bitslc[4]  = {shift_reg[27][slice_idx],  shift_reg[26][slice_idx],  shift_reg[25][slice_idx],  shift_reg[24][slice_idx],  shift_reg[23][slice_idx],  shift_reg[22][slice_idx],  shift_reg[21][slice_idx]};
    assign bitslc[5]  = {shift_reg[34][slice_idx],  shift_reg[33][slice_idx],  shift_reg[32][slice_idx],  shift_reg[31][slice_idx],  shift_reg[30][slice_idx],  shift_reg[29][slice_idx],  shift_reg[28][slice_idx]};
    assign bitslc[6]  = {shift_reg[41][slice_idx],  shift_reg[40][slice_idx],  shift_reg[39][slice_idx],  shift_reg[38][slice_idx],  shift_reg[37][slice_idx],  shift_reg[36][slice_idx],  shift_reg[35][slice_idx]};
    assign bitslc[7]  = {shift_reg[48][slice_idx],  shift_reg[47][slice_idx],  shift_reg[46][slice_idx],  shift_reg[45][slice_idx],  shift_reg[44][slice_idx],  shift_reg[43][slice_idx],  shift_reg[42][slice_idx]};
    assign bitslc[8]  = {shift_reg[55][slice_idx],  shift_reg[54][slice_idx],  shift_reg[53][slice_idx],  shift_reg[52][slice_idx],  shift_reg[51][slice_idx],  shift_reg[50][slice_idx],  shift_reg[49][slice_idx]};
    assign bitslc[9]  = {shift_reg[62][slice_idx],  shift_reg[61][slice_idx],  shift_reg[60][slice_idx],  shift_reg[59][slice_idx],  shift_reg[58][slice_idx],  shift_reg[57][slice_idx],  shift_reg[56][slice_idx]};
    assign bitslc[10] = {shift_reg[69][slice_idx],  shift_reg[68][slice_idx],  shift_reg[67][slice_idx],  shift_reg[66][slice_idx],  shift_reg[65][slice_idx],  shift_reg[64][slice_idx],  shift_reg[63][slice_idx]};
    assign bitslc[11] = {shift_reg[76][slice_idx],  shift_reg[75][slice_idx],  shift_reg[74][slice_idx],  shift_reg[73][slice_idx],  shift_reg[72][slice_idx],  shift_reg[71][slice_idx],  shift_reg[70][slice_idx]};
    assign bitslc[12] = {shift_reg[83][slice_idx],  shift_reg[82][slice_idx],  shift_reg[81][slice_idx],  shift_reg[80][slice_idx],  shift_reg[79][slice_idx],  shift_reg[78][slice_idx],  shift_reg[77][slice_idx]};
    assign bitslc[13] = {shift_reg[90][slice_idx],  shift_reg[89][slice_idx],  shift_reg[88][slice_idx],  shift_reg[87][slice_idx],  shift_reg[86][slice_idx],  shift_reg[85][slice_idx],  shift_reg[84][slice_idx]};
    assign bitslc[14] = {shift_reg[97][slice_idx],  shift_reg[96][slice_idx],  shift_reg[95][slice_idx],  shift_reg[94][slice_idx],  shift_reg[93][slice_idx],  shift_reg[92][slice_idx],  shift_reg[91][slice_idx]};
    assign bitslc[15] = {shift_reg[104][slice_idx], shift_reg[103][slice_idx], shift_reg[102][slice_idx], shift_reg[101][slice_idx], shift_reg[100][slice_idx], shift_reg[99][slice_idx],  shift_reg[98][slice_idx]};
    assign bitslc[16] = {shift_reg[111][slice_idx], shift_reg[110][slice_idx], shift_reg[109][slice_idx], shift_reg[108][slice_idx], shift_reg[107][slice_idx], shift_reg[106][slice_idx], shift_reg[105][slice_idx]};
    assign bitslc[17] = {shift_reg[118][slice_idx], shift_reg[117][slice_idx], shift_reg[116][slice_idx], shift_reg[115][slice_idx], shift_reg[114][slice_idx], shift_reg[113][slice_idx], shift_reg[112][slice_idx]};
    assign bitslc[18] = {shift_reg[125][slice_idx], shift_reg[124][slice_idx], shift_reg[123][slice_idx], shift_reg[122][slice_idx], shift_reg[121][slice_idx], shift_reg[120][slice_idx], shift_reg[119][slice_idx]};
    assign bitslc[19] = {shift_reg[132][slice_idx], shift_reg[131][slice_idx], shift_reg[130][slice_idx], shift_reg[129][slice_idx], shift_reg[128][slice_idx], shift_reg[127][slice_idx], shift_reg[126][slice_idx]};

    // 19-Input Combinational Adder Tree
    wire signed [36:0] total_tree_sum = lut_out[1]  + lut_out[2]  + lut_out[3]  + 
                                        lut_out[4]  + lut_out[5]  + lut_out[6]  + 
                                        lut_out[7]  + lut_out[8]  + lut_out[9]  +
                                        lut_out[10] + lut_out[11] + lut_out[12] +
                                        lut_out[13] + lut_out[14] + lut_out[15] +
                                        lut_out[16] + lut_out[17] + lut_out[18] +
                                        lut_out[19];

    // Explicit 60-bit expansion prevents Vivado from truncating the shift
    wire signed [59:0] tree_sum_ext = total_tree_sum;

    reg state = 0;
    reg signed [59:0] accumulator = 0;
    
    wire signed [59:0] next_accum_add = (accumulator >>> 1) + (tree_sum_ext <<< 23);
    wire signed [59:0] next_accum_sub = (accumulator >>> 1) - (tree_sum_ext <<< 23);

    always @(posedge clk_50mhz) begin
        if (reset) begin
            state <= 0; bit_count <= 0; accumulator <= 0; audio_out <= 0; out_valid <= 0; update_ack <= 0;
            // Clear all 133 registers
            for (i=0; i<133; i=i+1) shift_reg[i] <= 0;
        end else begin
            out_valid <= 0; 
            
            // Decoupled Phase 4 Handshake Cleanup
            if (!spi_update_request && update_ack) begin
                update_ack <= 0;
            end
            
            if (state == 0) begin // IDLE
                if (sample_trigger) begin
                    // Shift the 133-deep delay line
                    for (i = 132; i > 0; i = i - 1) shift_reg[i] <= shift_reg[i-1];
                    shift_reg[0] <= audio_in; 
                    
                    bit_count <= 0; accumulator <= 0; state <= 1; 
                end else if (spi_update_request && !update_ack) begin
                    active_bank <= ~active_bank; update_ack <= 1;
                end
            end 
            
            else if (state == 1) begin // CALCULATING
                if (bit_count == 0) begin
                    // Absorb Ping-Pong RAM latency
                    bit_count <= 1;
                end 
                else if (bit_count < 24) begin
                    accumulator <= next_accum_add;
                    bit_count <= bit_count + 1;
                end 
                else if (bit_count == 24) begin
                    accumulator <= next_accum_sub;
                    
                    // Symmetric Hard Clipping
                    if ($signed(next_accum_sub[59:23]) > $signed(24'sd8388607)) begin
                        audio_out <= 24'sd8388607; 
                    end 
                    else if ($signed(next_accum_sub[59:23]) < $signed(-24'sd8388608)) begin
                        audio_out <= -24'sd8388608; 
                    end 
                    else begin
                        audio_out <= next_accum_sub[46:23]; 
                    end
                    
                    out_valid <= 1; 
                    state <= 0; 
                    
                    if (spi_update_request && !update_ack) begin
                        active_bank <= ~active_bank; update_ack <= 1;
                    end
                end
            end
        end
    end
endmodule