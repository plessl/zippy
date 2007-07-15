onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /schedulertemporalpartitioning_tb/clkxc
add wave -noupdate -format Logic /schedulertemporalpartitioning_tb/rstxrb
add wave -noupdate -format Logic /schedulertemporalpartitioning_tb/schedulestartxe
add wave -noupdate -format Logic /schedulertemporalpartitioning_tb/scheduledonexs
add wave -noupdate -format Literal -radix unsigned /schedulertemporalpartitioning_tb/notpcontextsxs
add wave -noupdate -format Literal -radix unsigned /schedulertemporalpartitioning_tb/notpusercyclesxs
add wave -noupdate -format Logic /schedulertemporalpartitioning_tb/cexe
add wave -noupdate -format Literal /schedulertemporalpartitioning_tb/clrcontextxs
add wave -noupdate -format Logic /schedulertemporalpartitioning_tb/clrcontextxe
add wave -noupdate -format Literal -radix unsigned /schedulertemporalpartitioning_tb/contextxs
add wave -noupdate -format Literal -radix decimal /schedulertemporalpartitioning_tb/cycledncntxd
add wave -noupdate -format Literal -radix decimal /schedulertemporalpartitioning_tb/cycleupcntxd
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1260 ns} 0}
configure wave -namecolwidth 132
configure wave -valuecolwidth 40
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
update
WaveRestoreZoom {0 ns} {63 ns}
