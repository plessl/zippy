onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Literal /tb_configmem/ccount
add wave -noupdate -format Literal /tb_configmem/tbstatus
add wave -noupdate -format Logic /tb_configmem/clkxc
add wave -noupdate -format Logic /tb_configmem/rstxrb
add wave -noupdate -format Logic /tb_configmem/wexe
add wave -noupdate -format Literal -radix unsigned /tb_configmem/cfgslicexd
add wave -noupdate -format Logic /tb_configmem/loadsliceptrxe
add wave -noupdate -format Literal -radix unsigned /tb_configmem/sliceptrxd
add wave -noupdate -format Literal /tb_configmem/configwordxd
add wave -noupdate -format Literal /tb_configmem/configword
add wave -noupdate -format Literal /tb_configmem/dut/hiptr
add wave -noupdate -format Literal /tb_configmem/dut/loptr
add wave -noupdate -color Thistle -format Logic /tb_configmem/dut/lastxs
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {7846 ns}
WaveRestoreZoom {7135 ns} {8467 ns}
configure wave -namecolwidth 129
configure wave -valuecolwidth 144
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
