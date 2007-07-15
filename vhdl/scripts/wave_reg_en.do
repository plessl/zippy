onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Literal /tb_reg_en/ccount
add wave -noupdate -format Literal /tb_reg_en/tbstatus
add wave -noupdate -format Logic /tb_reg_en/clkxc
add wave -noupdate -format Logic /tb_reg_en/rstxrb
add wave -noupdate -format Literal -radix unsigned /tb_reg_en/dinxd
add wave -noupdate -format Literal -radix unsigned /tb_reg_en/doutxd
add wave -noupdate -format Logic /tb_reg_en/enxe
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {0 ns}
WaveRestoreZoom {0 ns} {519 ns}
configure wave -namecolwidth 127
configure wave -valuecolwidth 108
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
