onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Literal /tb_cycledncntr/ccount
add wave -noupdate -format Literal /tb_cycledncntr/tbstatus
add wave -noupdate -format Logic /tb_cycledncntr/clkxc
add wave -noupdate -format Logic /tb_cycledncntr/rstxrb
add wave -noupdate -format Logic /tb_cycledncntr/loadxe
add wave -noupdate -format Literal -radix unsigned /tb_cycledncntr/cinxd
add wave -noupdate -format Logic /tb_cycledncntr/onxs
add wave -noupdate -format Literal -radix unsigned /tb_cycledncntr/coutxd
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
