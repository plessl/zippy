onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Literal /tb_cclkgating/ccount
add wave -noupdate -format Literal /tb_cclkgating/tbstatus
add wave -noupdate -format Logic /tb_cclkgating/clkxc
add wave -noupdate -format Logic /tb_cclkgating/rstxrb
add wave -noupdate -format Logic /tb_cclkgating/enxe
add wave -noupdate -format Logic /tb_cclkgating/cclockxc
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {0 ns}
WaveRestoreZoom {0 ns} {579 ns}
configure wave -namecolwidth 138
configure wave -valuecolwidth 50
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
