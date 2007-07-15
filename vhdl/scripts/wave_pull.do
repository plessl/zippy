onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Literal /tb_pull/ccount
add wave -noupdate -format Literal /tb_pull/tbstatus
add wave -noupdate -format Logic /tb_pull/clkxc
add wave -noupdate -format Logic /tb_pull/rstxrb
add wave -noupdate -format Logic /tb_pull/modexs
add wave -noupdate -format Literal /tb_pull/busxz
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {0 ns}
WaveRestoreZoom {0 ns} {529 ns}
configure wave -namecolwidth 113
configure wave -valuecolwidth 84
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
