onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Literal /tb_reg_clr_en/ccount
add wave -noupdate -format Literal /tb_reg_clr_en/tbstatus
add wave -noupdate -format Logic /tb_reg_clr_en/clkxc
add wave -noupdate -format Logic /tb_reg_clr_en/rstxrb
add wave -noupdate -format Logic /tb_reg_clr_en/clrxe
add wave -noupdate -format Logic /tb_reg_clr_en/enxe
add wave -noupdate -format Literal -radix unsigned /tb_reg_clr_en/dinxd
add wave -noupdate -format Literal -radix unsigned /tb_reg_clr_en/doutxd
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {0 ns}
WaveRestoreZoom {0 ns} {1 us}
configure wave -namecolwidth 108
configure wave -valuecolwidth 142
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
