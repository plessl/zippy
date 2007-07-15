onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Literal /tb_fifo/ccount
add wave -noupdate -format Literal /tb_fifo/tbstatus
add wave -noupdate -format Logic /tb_fifo/clkxc
add wave -noupdate -format Logic /tb_fifo/rstxrb
add wave -noupdate -format Logic /tb_fifo/fifowexei
add wave -noupdate -format Logic /tb_fifo/fiforexei
add wave -noupdate -format Literal -radix unsigned /tb_fifo/fifodinxdi
add wave -noupdate -format Literal -radix unsigned /tb_fifo/fifodoutxdo
add wave -noupdate -format Logic /tb_fifo/fifoemptyxso
add wave -noupdate -format Logic /tb_fifo/fifofullxso
add wave -noupdate -format Literal -radix unsigned /tb_fifo/fifofilllevelxdo
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {0 ns}
WaveRestoreZoom {0 ns} {1192 ns}
configure wave -namecolwidth 138
configure wave -valuecolwidth 50
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
