onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Literal /tb_engine/ccount
add wave -noupdate -format Literal /tb_engine/tbstatus
add wave -noupdate -format Logic /tb_engine/clkxc
add wave -noupdate -format Logic /tb_engine/rstxrb
add wave -noupdate -format Literal /tb_engine/cfg
add wave -noupdate -format Literal -radix decimal /tb_engine/inport0xd
add wave -noupdate -format Literal -radix decimal /tb_engine/inport1xd
add wave -noupdate -format Literal -radix decimal /tb_engine/outport0xd
add wave -noupdate -format Literal -radix decimal /tb_engine/outport1xd
add wave -noupdate -format Logic /tb_engine/inport0xe
add wave -noupdate -format Logic /tb_engine/inport1xe
add wave -noupdate -format Logic /tb_engine/outport0xe
add wave -noupdate -format Logic /tb_engine/outport1xe
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {0 ns}
WaveRestoreZoom {0 ns} {413 ns}
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
