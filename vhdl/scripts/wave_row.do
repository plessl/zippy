onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Literal /tb_row/ccount
add wave -noupdate -format Literal /tb_row/tbstatus
add wave -noupdate -format Logic /tb_row/clkxc
add wave -noupdate -format Logic /tb_row/rstxrb
add wave -noupdate -format Literal /tb_row/cfg
add wave -noupdate -format Literal -radix unsigned /tb_row/input
add wave -noupdate -format Literal -radix unsigned -expand /tb_row/output
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {879 ns}
WaveRestoreZoom {0 ns} {629 ns}
configure wave -namecolwidth 129
configure wave -valuecolwidth 84
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
