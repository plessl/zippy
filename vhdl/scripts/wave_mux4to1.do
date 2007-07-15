onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Literal /tb_mux4to1/ccount
add wave -noupdate -format Literal /tb_mux4to1/tbstatus
add wave -noupdate -format Logic /tb_mux4to1/clkxc
add wave -noupdate -format Logic /tb_mux4to1/rstxrb
add wave -noupdate -format Literal -radix unsigned /tb_mux4to1/selxs
add wave -noupdate -format Literal -radix unsigned /tb_mux4to1/in0xd
add wave -noupdate -format Literal -radix unsigned /tb_mux4to1/in1xd
add wave -noupdate -format Literal -radix unsigned /tb_mux4to1/in2xd
add wave -noupdate -format Literal -radix unsigned /tb_mux4to1/in3xd
add wave -noupdate -format Literal -radix unsigned /tb_mux4to1/outxd
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
