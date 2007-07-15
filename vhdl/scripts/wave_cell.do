onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Literal /tb_cell/ccount
add wave -noupdate -format Literal /tb_cell/tbstatus
add wave -noupdate -format Logic /tb_cell/clkxc
add wave -noupdate -format Logic /tb_cell/rstxrb
add wave -noupdate -format Literal -expand /tb_cell/cfg
add wave -noupdate -format Literal -radix unsigned /tb_cell/in0xd
add wave -noupdate -format Literal -radix unsigned /tb_cell/in1xd
add wave -noupdate -format Literal -radix unsigned /tb_cell/in2xd
add wave -noupdate -format Literal -radix unsigned /tb_cell/in3xd
add wave -noupdate -format Literal -radix unsigned /tb_cell/in4xd
add wave -noupdate -format Literal -radix unsigned /tb_cell/in5xd
add wave -noupdate -format Literal -radix unsigned /tb_cell/in6xd
add wave -noupdate -format Literal -radix unsigned /tb_cell/in7xd
add wave -noupdate -format Literal -radix unsigned /tb_cell/outxd
add wave -noupdate -format Literal -radix unsigned /tb_cell/out0xz
add wave -noupdate -format Literal -radix unsigned /tb_cell/out1xz
add wave -noupdate -format Literal -radix unsigned /tb_cell/out2xz
TreeUpdate [SetDefaultTree]
WaveRestoreZoom {0 ns} {752 ns}
configure wave -namecolwidth 125
configure wave -valuecolwidth 71
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
