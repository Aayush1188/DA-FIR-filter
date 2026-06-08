`timescale 1ns / 1ps

module profile_manager_133tap (
    input wire clk_50mhz,
    input wire reset,
    
    input wire btn_1, btn_2, btn_3,

    // Memory-Mapped DMA Interface (Connects to fir_da_133tap_v2)
    output reg spi_we,
    output reg [11:0] spi_addr, // [11:7] RAM Select, [6:0] Word Address
    output reg signed [31:0] spi_data_out, 
    
    // Handshake
    output reg spi_update_request,
    input wire update_ack
);

    // 19 ROMs instantiated for the 19 K=7 Partitions (Now explicitly signed and portable)
    reg signed [31:0] rom_1 [0:383];  initial $readmemh("E:/vivado/projects/fir3/main_rom_1.hex", rom_1);
    reg signed [31:0] rom_2 [0:383];  initial $readmemh("E:/vivado/projects/fir3/main_rom_2.hex", rom_2);
    reg signed [31:0] rom_3 [0:383];  initial $readmemh("E:/vivado/projects/fir3/main_rom_3.hex", rom_3);
    reg signed [31:0] rom_4 [0:383];  initial $readmemh("E:/vivado/projects/fir3/main_rom_4.hex", rom_4);
    reg signed [31:0] rom_5 [0:383];  initial $readmemh("E:/vivado/projects/fir3/main_rom_5.hex", rom_5);
    reg signed [31:0] rom_6 [0:383];  initial $readmemh("E:/vivado/projects/fir3/main_rom_6.hex", rom_6);
    reg signed [31:0] rom_7 [0:383];  initial $readmemh("E:/vivado/projects/fir3/main_rom_7.hex", rom_7);
    reg signed [31:0] rom_8 [0:383];  initial $readmemh("E:/vivado/projects/fir3/main_rom_8.hex", rom_8);
    reg signed [31:0] rom_9 [0:383];  initial $readmemh("E:/vivado/projects/fir3/main_rom_9.hex", rom_9);
    reg signed [31:0] rom_10 [0:383]; initial $readmemh("E:/vivado/projects/fir3/main_rom_10.hex", rom_10);
    reg signed [31:0] rom_11 [0:383]; initial $readmemh("E:/vivado/projects/fir3/main_rom_11.hex", rom_11);
    reg signed [31:0] rom_12 [0:383]; initial $readmemh("E:/vivado/projects/fir3/main_rom_12.hex", rom_12);
    reg signed [31:0] rom_13 [0:383]; initial $readmemh("E:/vivado/projects/fir3/main_rom_13.hex", rom_13);
    reg signed [31:0] rom_14 [0:383]; initial $readmemh("E:/vivado/projects/fir3/main_rom_14.hex", rom_14);
    reg signed [31:0] rom_15 [0:383]; initial $readmemh("E:/vivado/projects/fir3/main_rom_15.hex", rom_15);
    reg signed [31:0] rom_16 [0:383]; initial $readmemh("E:/vivado/projects/fir3/main_rom_16.hex", rom_16);
    reg signed [31:0] rom_17 [0:383]; initial $readmemh("E:/vivado/projects/fir3/main_rom_17.hex", rom_17);
    reg signed [31:0] rom_18 [0:383]; initial $readmemh("E:/vivado/projects/fir3/main_rom_18.hex", rom_18);
    reg signed [31:0] rom_19 [0:383]; initial $readmemh("E:/vivado/projects/fir3/main_rom_19.hex", rom_19);

    // Metastability Double-Flop Synchronizers
    reg b1_meta, b2_meta, b3_meta;
    reg b1_sync, b2_sync, b3_sync;
    
    always @(posedge clk_50mhz) begin 
        b1_meta <= btn_1; b2_meta <= btn_2; b3_meta <= btn_3; 
        b1_sync <= b1_meta; b2_sync <= b2_meta; b3_sync <= b3_meta;
    end

    localparam IDLE = 0, COPYING = 1, HANDOVER = 2, COOLDOWN = 3;
    reg [1:0] state = IDLE;
    reg [8:0] offset = 0; 
    reg [19:0] debounce_timer = 0; 
    
    // Expanded to 12 bits to count 2432 total writes (19 RAMs * 128 words)
    reg [11:0] read_counter = 0;
    wire is_copying = (state == COPYING);

    // Internal BRAM output registers
    reg signed [31:0] d_out [1:19];
    reg [4:0] ram_select_pipe = 0;

    // 1-Cycle Delay Pipeline (Aligns control signals with BRAM read latency)
    always @(posedge clk_50mhz) begin
        if (reset) begin
            spi_we <= 0;
            spi_addr <= 0;
            ram_select_pipe <= 0;
        end else begin
            // read_counter[6:0] loops from 0 to 127 to read the specific word
            d_out[1]  <= rom_1[offset + read_counter[6:0]];
            d_out[2]  <= rom_2[offset + read_counter[6:0]];
            d_out[3]  <= rom_3[offset + read_counter[6:0]];
            d_out[4]  <= rom_4[offset + read_counter[6:0]];
            d_out[5]  <= rom_5[offset + read_counter[6:0]];
            d_out[6]  <= rom_6[offset + read_counter[6:0]];
            d_out[7]  <= rom_7[offset + read_counter[6:0]];
            d_out[8]  <= rom_8[offset + read_counter[6:0]];
            d_out[9]  <= rom_9[offset + read_counter[6:0]];
            d_out[10] <= rom_10[offset + read_counter[6:0]];
            d_out[11] <= rom_11[offset + read_counter[6:0]];
            d_out[12] <= rom_12[offset + read_counter[6:0]];
            d_out[13] <= rom_13[offset + read_counter[6:0]];
            d_out[14] <= rom_14[offset + read_counter[6:0]];
            d_out[15] <= rom_15[offset + read_counter[6:0]];
            d_out[16] <= rom_16[offset + read_counter[6:0]];
            d_out[17] <= rom_17[offset + read_counter[6:0]];
            d_out[18] <= rom_18[offset + read_counter[6:0]];
            d_out[19] <= rom_19[offset + read_counter[6:0]];
            
            // Pipelined control signals
            spi_addr <= read_counter;
            spi_we   <= is_copying;
            
            // Pipeline the RAM chip-select to align with data output
            ram_select_pipe <= read_counter[11:7];
        end
    end

    // Combinational Mux for the single output bus
    always @(*) begin
        case (ram_select_pipe)
            5'd0:  spi_data_out = d_out[1];
            5'd1:  spi_data_out = d_out[2];
            5'd2:  spi_data_out = d_out[3];
            5'd3:  spi_data_out = d_out[4];
            5'd4:  spi_data_out = d_out[5];
            5'd5:  spi_data_out = d_out[6];
            5'd6:  spi_data_out = d_out[7];
            5'd7:  spi_data_out = d_out[8];
            5'd8:  spi_data_out = d_out[9];
            5'd9:  spi_data_out = d_out[10];
            5'd10: spi_data_out = d_out[11];
            5'd11: spi_data_out = d_out[12];
            5'd12: spi_data_out = d_out[13];
            5'd13: spi_data_out = d_out[14];
            5'd14: spi_data_out = d_out[15];
            5'd15: spi_data_out = d_out[16];
            5'd16: spi_data_out = d_out[17];
            5'd17: spi_data_out = d_out[18];
            5'd18: spi_data_out = d_out[19];
            default: spi_data_out = 32'sd0;
        endcase
    end

    // Master FSM
    always @(posedge clk_50mhz) begin
        if (reset) begin
            state <= IDLE; spi_update_request <= 0; read_counter <= 0; debounce_timer <= 0;
        end else begin
            case (state)
                IDLE: begin 
                    read_counter <= 0; 
                    // Strict Phase-1 Lockout (Wait for DSP to drop ACK)
                    if (b1_sync && !update_ack) begin 
                        offset <= 0;   state <= COPYING; 
                    end else if (b2_sync && !update_ack) begin 
                        offset <= 128; state <= COPYING; 
                    end else if (b3_sync && !update_ack) begin 
                        offset <= 256; state <= COPYING; 
                    end
                end

                COPYING: begin 
                    // Count exactly 2,432 cycles (19 RAMs * 128 words)
                    if (read_counter == 12'd2431) begin
                        state <= HANDOVER; 
                    end else begin
                        read_counter <= read_counter + 1; 
                    end
                end

                HANDOVER: begin 
                    spi_update_request <= 1; 
                    if (update_ack == 1) begin
                        spi_update_request <= 0; 
                        debounce_timer <= 0; 
                        state <= COOLDOWN;  
                    end
                end
                
                COOLDOWN: begin 
                    // ~21ms hardware debounce timer at 50 MHz
                    if (debounce_timer == 20'hFFFFF) begin 
                        if (!b1_sync && !b2_sync && !b3_sync) begin
                            state <= IDLE; 
                        end
                    end else begin
                        debounce_timer <= debounce_timer + 1;
                    end
                end
                
                default: state <= IDLE;
            endcase
        end
    end
endmodule

