onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Literal /tb_reg_aclr_en/ccount
add wave -noupdate -format Literal /tb_reg_aclr_en/tbstatus
add wave -noupdate -format Logic /tb_reg_aclr_en/clkxc
add wave -noupdate -format Logic /tb_reg_aclr_en/rstxrb
add wave -noupdate -format Logic /tb_reg_aclr_en/clrxa
add wave -noupdate -format Logic /tb_reg_aclr_en/enxe
add wave -noupdate -format Literal -radix decimal /tb_reg_aclr_en/dinxd
add wave -noupdate -format Literal -radix decimal /tb_reg_aclr_en/doutxd
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {0 ns}
WaveRestoreZoom {193 ns} {693 ns}
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
