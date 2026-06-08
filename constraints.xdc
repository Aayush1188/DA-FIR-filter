# ----------------------------------------------------------------------------
# V2.0 133-Tap DA FIR Coprocessor - ZedBoard Constraints
# ----------------------------------------------------------------------------

# ----------------------------------------------------------------------------
# 100 MHz System Clock - Bank 13
# ---------------------------------------------------------------------------- 
set_property PACKAGE_PIN Y9 [get_ports {clk_100mhz}];  # "GCLK"
set_property IOSTANDARD LVCMOS33 [get_ports {clk_100mhz}];
create_clock -period 10.000 -name sys_clk_pin -waveform {0.000 5.000} -add [get_ports {clk_100mhz}];
create_generated_clock -name clk_50mhz -source [get_ports clk_100mhz] -divide_by 2 [get_pins bufg_inst/O]

# ----------------------------------------------------------------------------
# User Push Buttons - Bank 34 (Profile Selection & Reset)
# ---------------------------------------------------------------------------- 
set_property PACKAGE_PIN P16 [get_ports {reset_btn}];    # "BTNC" - Center Button
set_property PACKAGE_PIN T18 [get_ports {filter_btn_1}]; # "BTNU" - Up Button (Profile 1)
set_property PACKAGE_PIN R16 [get_ports {filter_btn_2}]; # "BTND" - Down Button (Profile 2)
set_property PACKAGE_PIN N15 [get_ports {filter_btn_3}]; # "BTNL" - Left Button (Profile 3)

set_property IOSTANDARD LVCMOS18 [get_ports {reset_btn}];
set_property IOSTANDARD LVCMOS18 [get_ports {filter_btn_1}];
set_property IOSTANDARD LVCMOS18 [get_ports {filter_btn_2}];
set_property IOSTANDARD LVCMOS18 [get_ports {filter_btn_3}];

# ----------------------------------------------------------------------------
# User DIP Switches - Bank 35 (ADC Manual Trigger)
# ---------------------------------------------------------------------------- 
set_property PACKAGE_PIN F22 [get_ports {adc_clk_48khz}];  # "SW0" - Manual 48kHz Pulse Trigger
set_property IOSTANDARD LVCMOS18 [get_ports {adc_clk_48khz}];

# ----------------------------------------------------------------------------
# 24-Bit Audio Input Bus -> Mapped to FMC Expansion Connector (Bank 34)
# ---------------------------------------------------------------------------- 
set_property PACKAGE_PIN M19 [get_ports {audio_in_pin[0]}];  # FMC_LA00_CC_P
set_property PACKAGE_PIN M20 [get_ports {audio_in_pin[1]}];  # FMC_LA00_CC_N
set_property PACKAGE_PIN N19 [get_ports {audio_in_pin[2]}];  # FMC_LA01_CC_P
set_property PACKAGE_PIN N20 [get_ports {audio_in_pin[3]}];  # FMC_LA01_CC_N
set_property PACKAGE_PIN P17 [get_ports {audio_in_pin[4]}];  # FMC_LA02_P
set_property PACKAGE_PIN P18 [get_ports {audio_in_pin[5]}];  # FMC_LA02_N
set_property PACKAGE_PIN N22 [get_ports {audio_in_pin[6]}];  # FMC_LA03_P
set_property PACKAGE_PIN P22 [get_ports {audio_in_pin[7]}];  # FMC_LA03_N
set_property PACKAGE_PIN M21 [get_ports {audio_in_pin[8]}];  # FMC_LA04_P
set_property PACKAGE_PIN M22 [get_ports {audio_in_pin[9]}];  # FMC_LA04_N
set_property PACKAGE_PIN J18 [get_ports {audio_in_pin[10]}]; # FMC_LA05_P
set_property PACKAGE_PIN K18 [get_ports {audio_in_pin[11]}]; # FMC_LA05_N
set_property PACKAGE_PIN L21 [get_ports {audio_in_pin[12]}]; # FMC_LA06_P
set_property PACKAGE_PIN L22 [get_ports {audio_in_pin[13]}]; # FMC_LA06_N
set_property PACKAGE_PIN T16 [get_ports {audio_in_pin[14]}]; # FMC_LA07_P
set_property PACKAGE_PIN T17 [get_ports {audio_in_pin[15]}]; # FMC_LA07_N
set_property PACKAGE_PIN J21 [get_ports {audio_in_pin[16]}]; # FMC_LA08_P
set_property PACKAGE_PIN J22 [get_ports {audio_in_pin[17]}]; # FMC_LA08_N
set_property PACKAGE_PIN R20 [get_ports {audio_in_pin[18]}]; # FMC_LA09_P
set_property PACKAGE_PIN R21 [get_ports {audio_in_pin[19]}]; # FMC_LA09_N
set_property PACKAGE_PIN R19 [get_ports {audio_in_pin[20]}]; # FMC_LA10_P
set_property PACKAGE_PIN T19 [get_ports {audio_in_pin[21]}]; # FMC_LA10_N
set_property PACKAGE_PIN N17 [get_ports {audio_in_pin[22]}]; # FMC_LA11_P
set_property PACKAGE_PIN N18 [get_ports {audio_in_pin[23]}]; # FMC_LA11_N

set_property IOSTANDARD LVCMOS18 [get_ports {audio_in_pin[*]}];

# ----------------------------------------------------------------------------
# 24-Bit Audio Output Bus -> Mapped to FMC Expansion Connector (Banks 34 & 35)
# ---------------------------------------------------------------------------- 
set_property PACKAGE_PIN P20 [get_ports {audio_out_pin[0]}];  # FMC_LA12_P (Bank 34)
set_property PACKAGE_PIN P21 [get_ports {audio_out_pin[1]}];  # FMC_LA12_N
set_property PACKAGE_PIN L17 [get_ports {audio_out_pin[2]}];  # FMC_LA13_P
set_property PACKAGE_PIN M17 [get_ports {audio_out_pin[3]}];  # FMC_LA13_N
set_property PACKAGE_PIN K19 [get_ports {audio_out_pin[4]}];  # FMC_LA14_P
set_property PACKAGE_PIN K20 [get_ports {audio_out_pin[5]}];  # FMC_LA14_N
set_property PACKAGE_PIN J16 [get_ports {audio_out_pin[6]}];  # FMC_LA15_P
set_property PACKAGE_PIN J17 [get_ports {audio_out_pin[7]}];  # FMC_LA15_N
set_property PACKAGE_PIN J20 [get_ports {audio_out_pin[8]}];  # FMC_LA16_P
set_property PACKAGE_PIN K21 [get_ports {audio_out_pin[9]}];  # FMC_LA16_N

set_property PACKAGE_PIN B19 [get_ports {audio_out_pin[10]}]; # FMC_LA17_CC_P (Bank 35)
set_property PACKAGE_PIN B20 [get_ports {audio_out_pin[11]}]; # FMC_LA17_CC_N
set_property PACKAGE_PIN D20 [get_ports {audio_out_pin[12]}]; # FMC_LA18_CC_P
set_property PACKAGE_PIN C20 [get_ports {audio_out_pin[13]}]; # FMC_LA18_CC_N
set_property PACKAGE_PIN G15 [get_ports {audio_out_pin[14]}]; # FMC_LA19_P
set_property PACKAGE_PIN G16 [get_ports {audio_out_pin[15]}]; # FMC_LA19_N
set_property PACKAGE_PIN G20 [get_ports {audio_out_pin[16]}]; # FMC_LA20_P
set_property PACKAGE_PIN G21 [get_ports {audio_out_pin[17]}]; # FMC_LA20_N
set_property PACKAGE_PIN E19 [get_ports {audio_out_pin[18]}]; # FMC_LA21_P
set_property PACKAGE_PIN E20 [get_ports {audio_out_pin[19]}]; # FMC_LA21_N
set_property PACKAGE_PIN G19 [get_ports {audio_out_pin[20]}]; # FMC_LA22_P
set_property PACKAGE_PIN F19 [get_ports {audio_out_pin[21]}]; # FMC_LA22_N
set_property PACKAGE_PIN E15 [get_ports {audio_out_pin[22]}]; # FMC_LA23_P
set_property PACKAGE_PIN D15 [get_ports {audio_out_pin[23]}]; # FMC_LA23_N

set_property IOSTANDARD LVCMOS18 [get_ports {audio_out_pin[*]}];