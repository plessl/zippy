onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Literal -radix unsigned /tb_decoder/ccount
add wave -noupdate -format Literal -radix unsigned /tb_decoder/tbstatus
add wave -noupdate -format Logic -radix unsigned /tb_decoder/clkxc
add wave -noupdate -format Logic -radix unsigned /tb_decoder/rstxrb
add wave -noupdate -format Logic -radix unsigned /tb_decoder/wrreqxe
add wave -noupdate -format Logic -radix unsigned /tb_decoder/rdreqxe
add wave -noupdate -format Literal -radix unsigned /tb_decoder/regnrxd
add wave -noupdate -format Logic -radix unsigned /tb_decoder/systrstxrb
add wave -noupdate -format Logic -radix unsigned /tb_decoder/ccloadxe
add wave -noupdate -format Logic -radix unsigned /tb_decoder/finwexe
add wave -noupdate -format Logic -radix unsigned /tb_decoder/foutrexe
add wave -noupdate -format Literal -radix unsigned /tb_decoder/cmwexe
add wave -noupdate -format Literal -radix unsigned /tb_decoder/cmloadptrxe
add wave -noupdate -format Logic /tb_decoder/csrxe
add wave -noupdate -format Literal -radix unsigned /tb_decoder/doutmuxs
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {4981 ns}
WaveRestoreZoom {4648 ns} {5334 ns}
configure wave -namecolwidth 125
configure wave -valuecolwidth 57
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
