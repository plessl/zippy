onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider RegisterInterface
add wave -noupdate -format Logic /verification/todut_rexei
add wave -noupdate -format Logic /verification/todut_wexei
add wave -noupdate -format Literal -radix hexadecimal /verification/fromdut_dataxdo
add wave -noupdate -format Literal -radix decimal /verification/todut_addrxdi
add wave -noupdate -format Literal -radix hexadecimal /verification/todut_dataxdi
add wave -noupdate -divider ContextScheduler
add wave -noupdate -format Logic -label contextschedulertp/clkxc /verification/i_dut/contextschedulertp/clkxc
add wave -noupdate -format Logic -label contextschedulertp/rstxrb /verification/i_dut/contextschedulertp/rstxrb
add wave -noupdate -format Literal -label contextSchedulerTp/StatexS /verification/i_dut/contextschedulertp/statexs
add wave -noupdate -format Logic -label contextscheduler/schedulestartxei /verification/i_dut/contextschedulertp/schedulestartxei
add wave -noupdate -format Logic -label contextschedulertp/scheduledonexso /verification/i_dut/contextschedulertp/scheduledonexso
add wave -noupdate -format Literal -label contextschedulertp/notpcontextsxsi -radix decimal /verification/i_dut/contextschedulertp/notpcontextsxsi
add wave -noupdate -format Literal -label contextschedulertp/notpusercyclesxsi -radix decimal /verification/i_dut/contextschedulertp/notpusercyclesxsi
add wave -noupdate -format Logic -label contextschedulertp/cexeo /verification/i_dut/contextschedulertp/cexeo
add wave -noupdate -format Literal -label contextschedulertp/clrcontextxso /verification/i_dut/contextschedulertp/clrcontextxso
add wave -noupdate -format Logic -label contextschedulertp/clrcontextxeo /verification/i_dut/contextschedulertp/clrcontextxeo
add wave -noupdate -format Literal -label contextschedulertp/contextxso -radix unsigned /verification/i_dut/contextschedulertp/contextxso
add wave -noupdate -format Literal -label contextschedulertp/cycledncntxdo -radix unsigned /verification/i_dut/contextschedulertp/cycledncntxdo
add wave -noupdate -format Literal -label contextschedulertp/cycleupcntxdo -radix unsigned /verification/i_dut/contextschedulertp/cycleupcntxdo
add wave -noupdate -format Literal -label contextschedulertp/currentusercycle -radix unsigned /verification/i_dut/contextschedulertp/currentusercycle
add wave -noupdate -format Literal -label contextschedulertp/currentsubcycle -radix unsigned /verification/i_dut/contextschedulertp/currentsubcycle
add wave -noupdate -format Logic -label decdr/contextschedulerselectxeo /verification/i_dut/decdr/contextschedulerselectxeo
add wave -noupdate -format Logic -label decdr/virtcontextnoxeo /verification/i_dut/decdr/virtcontextnoxeo
add wave -noupdate -format Logic -label decdr/schedulestartxe /verification/i_dut/decdr/schedulestartxe
add wave -noupdate -divider Scheduler
add wave -noupdate -format Logic -label dut/deccontextschedulerselectxe /verification/i_dut/deccontextschedulerselectxe
add wave -noupdate -format Logic -label dut/contextscheduler/schedulerselectxsi /verification/i_dut/contextscheduler/schedulerselectxsi
add wave -noupdate -format Literal -label contextscheduler/engineschedulecontrolxeo -expand /verification/i_dut/contextscheduler/engineschedulecontrolxeo
add wave -noupdate -format Literal -label contextscheduler/schedtemporalpartitioningxdi /verification/i_dut/contextscheduler/schedtemporalpartitioningxdi
add wave -noupdate -format Literal -label contextscheduler/schedcontextsequencerxdi -expand /verification/i_dut/contextscheduler/schedcontextsequencerxdi
add wave -noupdate -divider Engine
add wave -noupdate -format Logic -label compeng/clkxc /verification/i_dut/compeng/clkxc
add wave -noupdate -format Logic -label compeng/rstxrb /verification/i_dut/compeng/rstxrb
add wave -noupdate -format Logic -label compeng/cexei /verification/i_dut/compeng/cexei
add wave -noupdate -format Literal -label compeng/configxi /verification/i_dut/compeng/configxi
add wave -noupdate -format Literal -label compeng/clrcontextxsi -radix unsigned /verification/i_dut/compeng/clrcontextxsi
add wave -noupdate -format Logic -label compeng/clrcontextxei /verification/i_dut/compeng/clrcontextxei
add wave -noupdate -format Literal -label compeng/contextxsi -radix unsigned /verification/i_dut/compeng/contextxsi
add wave -noupdate -format Literal -label compeng/cycledncntxdi -radix unsigned /verification/i_dut/compeng/cycledncntxdi
add wave -noupdate -format Literal -label compeng/cycleupcntxdi -radix unsigned /verification/i_dut/compeng/cycleupcntxdi
add wave -noupdate -format Literal -label compeng/inportxdi -radix hexadecimal -expand /verification/i_dut/compeng/inportxdi
add wave -noupdate -format Literal -label compeng/outportxdo -radix hexadecimal /verification/i_dut/compeng/outportxdo
add wave -noupdate -format Literal -label compeng/inportxeo /verification/i_dut/compeng/inportxeo
add wave -noupdate -format Literal -label compeng/outportxeo /verification/i_dut/compeng/outportxeo
add wave -noupdate -format Logic -label dut/fifo1/emptyxso /verification/i_dut/fifo1/emptyxso
add wave -noupdate -format Logic -label dut/fifo1/fullxso /verification/i_dut/fifo1/fullxso
add wave -noupdate -format Logic -label dut/fifo1/emptyxs /verification/i_dut/fifo1/emptyxs
add wave -noupdate -format Literal -label dut/fifo1/filllevelxdo -radix unsigned /verification/i_dut/fifo1/filllevelxdo
add wave -noupdate -format Logic -label dut/fifo0/emptyxs /verification/i_dut/fifo0/emptyxs
add wave -noupdate -format Logic -label dut/fifo0/fullxso /verification/i_dut/fifo0/fullxso
add wave -noupdate -format Logic -label dut/fifo0/emptyxso /verification/i_dut/fifo0/emptyxso
add wave -noupdate -format Literal -label dut/fifo0/filllevelxdo -radix unsigned /verification/i_dut/fifo0/filllevelxdo
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {629913100 ns} 0}
configure wave -namecolwidth 233
configure wave -valuecolwidth 124
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
WaveRestoreZoom {629911558 ns} {629920399 ns}
