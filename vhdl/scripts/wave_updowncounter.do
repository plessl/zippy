onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Literal /tb_updowncounter/ccount
add wave -noupdate -format Literal /tb_updowncounter/tbstatus
add wave -noupdate -format Logic /tb_updowncounter/clkxc
add wave -noupdate -format Logic /tb_updowncounter/rstxrb
add wave -noupdate -format Logic /tb_updowncounter/loadxei
add wave -noupdate -format Logic /tb_updowncounter/cexei
add wave -noupdate -format Logic /tb_updowncounter/modexsi
add wave -noupdate -format Literal -radix unsigned /tb_updowncounter/cinxdi
add wave -noupdate -format Literal -radix unsigned /tb_updowncounter/coutxdo
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {3651 ns}
WaveRestoreZoom {0 ns} {1211 ns}
configure wave -namecolwidth 116
configure wave -valuecolwidth 48
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
