onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Literal /tb_mux16to1/ccount
add wave -noupdate -format Literal /tb_mux16to1/tbstatus
add wave -noupdate -format Logic /tb_mux16to1/clkxc
add wave -noupdate -format Logic /tb_mux16to1/rstxrb
add wave -noupdate -format Literal -radix unsigned /tb_mux16to1/selxs
add wave -noupdate -format Literal -radix unsigned /tb_mux16to1/in0xd
add wave -noupdate -format Literal -radix unsigned /tb_mux16to1/in1xd
add wave -noupdate -format Literal -radix unsigned /tb_mux16to1/in2xd
add wave -noupdate -format Literal -radix unsigned /tb_mux16to1/in3xd
add wave -noupdate -format Literal -radix unsigned /tb_mux16to1/in4xd
add wave -noupdate -format Literal -radix unsigned /tb_mux16to1/in5xd
add wave -noupdate -format Literal -radix unsigned /tb_mux16to1/in6xd
add wave -noupdate -format Literal -radix unsigned /tb_mux16to1/in7xd
add wave -noupdate -format Literal -radix unsigned /tb_mux16to1/in8xd
add wave -noupdate -format Literal -radix unsigned /tb_mux16to1/in9xd
add wave -noupdate -format Literal -radix unsigned /tb_mux16to1/inaxd
add wave -noupdate -format Literal -radix unsigned /tb_mux16to1/inbxd
add wave -noupdate -format Literal -radix unsigned /tb_mux16to1/incxd
add wave -noupdate -format Literal -radix unsigned /tb_mux16to1/indxd
add wave -noupdate -format Literal -radix unsigned /tb_mux16to1/inexd
add wave -noupdate -format Literal -radix unsigned /tb_mux16to1/infxd
add wave -noupdate -format Literal -radix unsigned /tb_mux16to1/outxd
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {0 ns}
WaveRestoreZoom {0 ns} {1 us}
configure wave -namecolwidth 128
configure wave -valuecolwidth 122
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
