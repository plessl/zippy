onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Literal /tb_contextmux/ccount
add wave -noupdate -format Literal /tb_contextmux/tbstatus
add wave -noupdate -format Logic /tb_contextmux/clkxc
add wave -noupdate -format Logic /tb_contextmux/rstxrb
add wave -noupdate -format Literal -radix unsigned /tb_contextmux/selxs
add wave -noupdate -format Literal /tb_contextmux/inp
add wave -noupdate -format Literal /tb_contextmux/outxd
add wave -noupdate -format Literal -radix unsigned /tb_contextmux/outtailxd
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {0 ns}
WaveRestoreZoom {1275 ns} {1775 ns}
configure wave -namecolwidth 112
configure wave -valuecolwidth 138
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
