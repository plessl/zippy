onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Literal /tb_fifo2/ccount
add wave -noupdate -format Literal /tb_fifo2/tbstatus
add wave -noupdate -format Logic /tb_fifo2/clkxc
add wave -noupdate -format Logic /tb_fifo2/rstxrb
add wave -noupdate -format Logic /tb_fifo2/fifomodexsi
add wave -noupdate -format Logic /tb_fifo2/fifowexei
add wave -noupdate -format Logic /tb_fifo2/fiforexei
add wave -noupdate -format Literal -radix decimal /tb_fifo2/fifodinxdi
add wave -noupdate -format Literal -radix decimal /tb_fifo2/fifodoutxdo
add wave -noupdate -format Logic /tb_fifo2/fifoemptyxso
add wave -noupdate -format Logic /tb_fifo2/fifofullxso
add wave -noupdate -format Literal -radix unsigned /tb_fifo2/fifofilllevelxdo
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {0 ns}
WaveRestoreZoom {0 ns} {1 us}
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
