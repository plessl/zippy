onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Literal /tb_schedulestore/ccount
add wave -noupdate -format Literal /tb_schedulestore/tbstatus
add wave -noupdate -format Logic /tb_schedulestore/clkxc
add wave -noupdate -format Logic /tb_schedulestore/rstxrb
add wave -noupdate -format Logic /tb_schedulestore/spcclrxei
add wave -noupdate -format Logic /tb_schedulestore/spcloadxei
add wave -noupdate -format Logic /tb_schedulestore/wexei
add wave -noupdate -format Literal -radix unsigned /tb_schedulestore/iaddrxdi
add wave -noupdate -format Literal -radix unsigned /tb_schedulestore/ifillxd
add wave -noupdate -format Literal -radix unsigned /tb_schedulestore/icontextxd
add wave -noupdate -format Literal -radix unsigned /tb_schedulestore/icyclesxd
add wave -noupdate -format Literal -radix unsigned /tb_schedulestore/inextadrxd
add wave -noupdate -format Logic /tb_schedulestore/ilastxd
add wave -noupdate -format Literal /tb_schedulestore/iwordxdi
add wave -noupdate -format Literal -radix unsigned /tb_schedulestore/contextxdo
add wave -noupdate -format Literal -radix unsigned /tb_schedulestore/cyclesxdo
add wave -noupdate -format Literal -radix unsigned /tb_schedulestore/dut/spcnextaddrxd
add wave -noupdate -format Logic /tb_schedulestore/lastxso
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {400 ns}
WaveRestoreZoom {275 ns} {567 ns}
configure wave -namecolwidth 131
configure wave -valuecolwidth 52
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
