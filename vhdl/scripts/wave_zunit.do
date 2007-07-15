onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Literal /tb_zunit/ccount
add wave -noupdate -format Literal /tb_zunit/tbstatus
add wave -noupdate -format Logic /tb_zunit/clkxc
add wave -noupdate -format Logic /tb_zunit/rstxrb
add wave -noupdate -format Logic /tb_zunit/wexe
add wave -noupdate -format Logic /tb_zunit/rexe
add wave -noupdate -format Literal -radix unsigned /tb_zunit/addrxd
add wave -noupdate -format Literal -radix decimal /tb_zunit/datainxd
add wave -noupdate -format Literal -radix decimal /tb_zunit/dataoutxd
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {4500 ns}
WaveRestoreZoom {10401 ns} {11516 ns}
configure wave -namecolwidth 127
configure wave -valuecolwidth 91
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
