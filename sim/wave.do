onerror {resume}
quietly virtual signal -install /top_tb { /top_tb/w_idata[11:6]} I_h
quietly virtual signal -install /top_tb { /top_tb/w_idata[5:0]} I_l
quietly virtual signal -install /top_tb { /top_tb/w_qdata[11:6]} Q_h
quietly virtual signal -install /top_tb { /top_tb/w_qdata[5:0]} Q_l
quietly virtual signal -install /top_tb { /top_tb/w_tx_data[11:6]} h
quietly virtual signal -install /top_tb { /top_tb/w_tx_data[5:0]} low
quietly virtual signal -install /top_tb { /top_tb/w_rx_rom_iqdata[23:18]} original_Q_high
quietly virtual signal -install /top_tb { /top_tb/w_rx_rom_iqdata[17:12]} original_Q_low
quietly virtual signal -install /top_tb { /top_tb/w_rx_rom_iqdata[11:6]} original_I_high
quietly virtual signal -install /top_tb { /top_tb/w_rx_rom_iqdata[5:0]} original_I_low
quietly WaveActivateNextPane {} 0
add wave -noupdate /top_tb/clk
add wave -noupdate /top_tb/i_rx_clk
add wave -noupdate /top_tb/i_tx_clk
add wave -noupdate /top_tb/original_I_high
add wave -noupdate /top_tb/original_Q_high
add wave -noupdate /top_tb/original_I_low
add wave -noupdate /top_tb/original_Q_low
add wave -noupdate /top_tb/w_rx_rom_iqdata
add wave -noupdate -expand -group lvcmos_tx /top_tb/w_tx_clk
add wave -noupdate -expand -group lvcmos_tx -color {Orange Red} /top_tb/w_tx_data
add wave -noupdate -expand -group lvcmos_tx /top_tb/h
add wave -noupdate -expand -group lvcmos_tx /top_tb/low
add wave -noupdate -expand -group lvcmos_rx_iqout /top_tb/w_iqdata_fp
add wave -noupdate -expand -group lvcmos_rx_iqout /top_tb/w_idata
add wave -noupdate -expand -group lvcmos_rx_iqout /top_tb/w_qdata
add wave -noupdate -expand -group lvcmos_rx_iqout -color Yellow -label I_dat_high /top_tb/I_h
add wave -noupdate -expand -group lvcmos_rx_iqout -color Yellow -label Q_dat_high /top_tb/Q_h
add wave -noupdate -expand -group lvcmos_rx_iqout -color Yellow -label I_dat_low /top_tb/I_l
add wave -noupdate -expand -group lvcmos_rx_iqout -color Yellow -label Q_dat_low /top_tb/Q_l
add wave -noupdate -expand -group lvds_tx /top_tb/o_tx_frame
add wave -noupdate -expand -group lvds_tx /top_tb/o_tx_clk
add wave -noupdate -expand -group lvds_tx /top_tb/o_tx_data
add wave -noupdate -group Inter /top_tb/u_ad80305_tx_if_ddr_lvcmos_31p25/udac_conver_fifo/data
add wave -noupdate -group Inter /top_tb/u_ad80305_tx_if_ddr_lvcmos_31p25/udac_conver_fifo/q
add wave -noupdate -group Inter /top_tb/u_ad80305_tx_if_ddr_lvcmos_31p25/w_dac_data
add wave -noupdate -group Inter /top_tb/u_ad80305_tx_if_ddr_lvcmos_31p25/cos_data
add wave -noupdate -group Inter /top_tb/u_ad80305_tx_if_ddr_lvcmos_31p25/sin_data
add wave -noupdate -group Inter /top_tb/u_ad80305_rx_if_ddr_lvcmos_31p25/o_qdata
add wave -noupdate -group Inter /top_tb/u_ad80305_rx_if_ddr_lvcmos_31p25/o_idata
add wave -noupdate /top_tb/u_ad80305_rx_if_ddr_lvcmos_31p25/w_adc_data
add wave -noupdate /top_tb/u_ad80305_rx_if_ddr_lvcmos_31p25/ad80305_iddr_inst/aclr
add wave -noupdate -expand -group DDIO_IN /top_tb/u_ad80305_rx_if_ddr_lvcmos_31p25/ad80305_iddr_inst/inclock
add wave -noupdate -expand -group DDIO_IN /top_tb/w_tx_frame
add wave -noupdate -expand -group DDIO_IN /top_tb/u_ad80305_rx_if_ddr_lvcmos_31p25/ad80305_iddr_inst/datain
add wave -noupdate -expand -group DDIO_IN /top_tb/u_ad80305_rx_if_ddr_lvcmos_31p25/ad80305_iddr_inst/dataout_l
add wave -noupdate -expand -group DDIO_IN -color {Dark Orchid} /top_tb/u_ad80305_rx_if_ddr_lvcmos_31p25/ad80305_iddr_inst/dataout_h
add wave -noupdate /top_tb/u_ad80305_rx_if_ddr_lvcmos_31p25/dataout_i
add wave -noupdate /top_tb/u_ad80305_rx_if_ddr_lvcmos_31p25/dataout_q
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {95 ns} 0} {{Cursor 2} {25271 ns} 0}
quietly wave cursor active 2
configure wave -namecolwidth 441
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {25095 ns} {25534 ns}
