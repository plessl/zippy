onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Literal /tb_routel/ccount
add wave -noupdate -format Literal /tb_routel/tbstatus
add wave -noupdate -format Logic /tb_routel/clkxc
add wave -noupdate -format Logic /tb_routel/rstxrb
add wave -noupdate -format Literal /tb_routel/cfg
add wave -noupdate -format Literal -radix unsigned /tb_routel/in0xd
add wave -noupdate -format Literal -radix unsigned /tb_routel/in1xd
add wave -noupdate -format Literal -radix unsigned /tb_routel/in2xd
add wave -noupdate -format Literal -radix unsigned /tb_routel/in3xd
add wave -noupdate -format Literal -radix unsigned /tb_routel/in4xd
add wave -noupdate -format Literal -radix unsigned /tb_routel/in5xd
add wave -noupdate -format Literal -radix unsigned /tb_routel/in6xd
add wave -noupdate -format Literal -radix unsigned /tb_routel/in7xd
add wave -noupdate -format Literal -radix unsigned /tb_routel/procelin0xd
add wave -noupdate -format Literal -radix unsigned /tb_routel/procelin1xd
add wave -noupdate -format Literal -radix unsigned /tb_routel/proceloutxd
add wave -noupdate -format Literal -radix unsigned /tb_routel/outxd
add wave -noupdate -format Literal -radix unsigned /tb_routel/out0xz
add wave -noupdate -format Literal -radix unsigned /tb_routel/out1xz
add wave -noupdate -format Literal -radix unsigned /tb_routel/out2xz
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {1191 ns}
WaveRestoreZoom {0 ns} {1757 ns}
configure wave -namecolwidth 129
configure wave -valuecolwidth 40
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
