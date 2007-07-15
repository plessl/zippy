onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Literal /tb_contextregfile/ccount
add wave -noupdate -format Literal /tb_contextregfile/tbstatus
add wave -noupdate -format Logic /tb_contextregfile/clkxc
add wave -noupdate -format Logic /tb_contextregfile/rstxrb
add wave -noupdate -format Literal -radix unsigned /tb_contextregfile/clrcontextxsi
add wave -noupdate -format Logic /tb_contextregfile/clrcontextxei
add wave -noupdate -format Literal -radix unsigned /tb_contextregfile/contextxsi
add wave -noupdate -format Logic /tb_contextregfile/enxei
add wave -noupdate -format Literal -radix decimal /tb_contextregfile/dinxdi
add wave -noupdate -format Literal -radix decimal /tb_contextregfile/doutxdo
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {0 ns}
WaveRestoreZoom {0 ns} {1060 ns}
configure wave -namecolwidth 131
configure wave -valuecolwidth 119
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
