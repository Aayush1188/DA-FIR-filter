% =========================================================================
% 133-Tap Partitioned DA FIR Coefficient & LUT Generator
% Generates 19 hex files, each containing 384 words (3 profiles x 128)
% =========================================================================
clear; clc;

% --- System Specifications ---
N = 133;            % Total number of taps
K = 7;              % Partition width (taps per sector)
P = 19;             % Number of partitions (133 / 7)
fs = 48000;         % Sampling frequency (48 kHz)

% --- 1. Generate 3 FIR Profiles (Hamming Window) ---
% Profile 1: Low-Pass Filter (Cutoff = 5 kHz)
fc1 = 5000 / (fs/2);
h1 = fir1(N-1, fc1, 'low');

% Profile 2: High-Pass Filter (Cutoff = 2 kHz)
fc2 = 2000 / (fs/2);
h2 = fir1(N-1, fc2, 'high');

% Profile 3: Band-Pass Filter (Passband = 1 kHz to 4 kHz)
fc3 = [1000 4000] / (fs/2);
h3 = fir1(N-1, fc3, 'bandpass');

% --- 2. L2 Norm Coefficient Scaling (Q1.23 Format) ---
% Maximize SNR by scaling so the L2 norm sits near the 24-bit headroom limit
max_val = 2^23 - 1; 

scale_factor1 = max_val / norm(h1, 2);
scale_factor2 = max_val / norm(h2, 2);
scale_factor3 = max_val / norm(h3, 2);

h1_int = round(h1 * scale_factor1);
h2_int = round(h2 * scale_factor2);
h3_int = round(h3 * scale_factor3);

% Combine into a single matrix for processing (3 rows x 133 cols)
h_all = [h1_int; h2_int; h3_int];

% --- 3. Generate DA Combinations and Write to HEX Files ---
disp('Generating LUT memory files...');

for p = 1:P
    % Create file for Partition 'p'
    filename = sprintf('main_rom_%d.hex', p);
    fileID = fopen(filename, 'w');
    
    % Iterate sequentially through the 3 profiles to fill the 384 words
    for profile = 1:3
        % Extract the 7 taps for this specific partition and profile
        start_idx = (p-1)*K + 1;
        end_idx = p*K;
        chunk = h_all(profile, start_idx:end_idx);
        
        % Generate the 128 combinations (2^7) for this chunk
        for addr = 0:127
            lut_val = 0;
            
            % Bitwise dot-product
            for bit_pos = 0:(K-1)
                % bitget is 1-indexed (LSB is index 1)
                % Maps perfectly to Verilog: addr LSB = chunk(1) = shift_reg[0]
                bit_val = bitget(addr, bit_pos + 1); 
                if bit_val == 1
                    lut_val = lut_val + chunk(bit_pos + 1);
                end
            end
            
            % Convert to 32-bit Two's Complement for negative numbers
            if lut_val < 0
                lut_val = lut_val + 2^32;
            end
            
            % Write to file as 8-character (32-bit) uppercase Hexadecimal
            fprintf(fileID, '%08X\n', lut_val);
        end
    end
    
    fclose(fileID);
end

disp('Success! 19 HEX files generated.');