onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic -label contextschedulertp/clkxc /tb_tstadpcm_virt_tpsched/dut/contextschedulertp/clkxc
add wave -noupdate -format Logic -label contextschedulertp/rstxrb /tb_tstadpcm_virt_tpsched/dut/contextschedulertp/rstxrb
add wave -noupdate -format Literal /tb_tstadpcm_virt_tpsched/dut/contextschedulertp/statexs
add wave -noupdate -format Logic -label contextscheduler/schedulestartxei /tb_tstadpcm_virt_tpsched/dut/contextschedulertp/schedulestartxei
add wave -noupdate -format Logic -label contextschedulertp/scheduledonexso /tb_tstadpcm_virt_tpsched/dut/contextschedulertp/scheduledonexso
add wave -noupdate -format Literal -label contextschedulertp/notpcontextsxsi -radix decimal /tb_tstadpcm_virt_tpsched/dut/contextschedulertp/notpcontextsxsi
add wave -noupdate -format Literal -label contextschedulertp/notpusercyclesxsi -radix decimal /tb_tstadpcm_virt_tpsched/dut/contextschedulertp/notpusercyclesxsi
add wave -noupdate -format Logic -label contextschedulertp/cexeo /tb_tstadpcm_virt_tpsched/dut/contextschedulertp/cexeo
add wave -noupdate -format Literal -label contextschedulertp/clrcontextxso /tb_tstadpcm_virt_tpsched/dut/contextschedulertp/clrcontextxso
add wave -noupdate -format Logic -label contextschedulertp/clrcontextxeo /tb_tstadpcm_virt_tpsched/dut/contextschedulertp/clrcontextxeo
add wave -noupdate -format Literal -label contextschedulertp/contextxso -radix unsigned /tb_tstadpcm_virt_tpsched/dut/contextschedulertp/contextxso
add wave -noupdate -format Literal -label contextschedulertp/cycledncntxdo -radix unsigned /tb_tstadpcm_virt_tpsched/dut/contextschedulertp/cycledncntxdo
add wave -noupdate -format Literal -label contextschedulertp/cycleupcntxdo -radix unsigned /tb_tstadpcm_virt_tpsched/dut/contextschedulertp/cycleupcntxdo
add wave -noupdate -format Literal -label contextschedulertp/currentusercycle -radix unsigned /tb_tstadpcm_virt_tpsched/dut/contextschedulertp/currentusercycle
add wave -noupdate -format Literal -label contextschedulertp/currentsubcycle -radix unsigned /tb_tstadpcm_virt_tpsched/dut/contextschedulertp/currentsubcycle
add wave -noupdate -format Logic -label decdr/contextschedulerselectxeo /tb_tstadpcm_virt_tpsched/dut/decdr/contextschedulerselectxeo
add wave -noupdate -format Logic -label decdr/virtcontextnoxeo /tb_tstadpcm_virt_tpsched/dut/decdr/virtcontextnoxeo
add wave -noupdate -format Logic -label decdr/schedulestartxe /tb_tstadpcm_virt_tpsched/dut/decdr/schedulestartxe
add wave -noupdate -divider Scheduler
add wave -noupdate -format Logic -label dut/deccontextschedulerselectxe /tb_tstadpcm_virt_tpsched/dut/deccontextschedulerselectxe
add wave -noupdate -format Logic -label dut/contextscheduler/schedulerselectxsi /tb_tstadpcm_virt_tpsched/dut/contextscheduler/schedulerselectxsi
add wave -noupdate -format Literal -label contextscheduler/engineschedulecontrolxeo -expand /tb_tstadpcm_virt_tpsched/dut/contextscheduler/engineschedulecontrolxeo
add wave -noupdate -format Literal -label contextscheduler/schedtemporalpartitioningxdi /tb_tstadpcm_virt_tpsched/dut/contextscheduler/schedtemporalpartitioningxdi
add wave -noupdate -format Literal -label contextscheduler/schedcontextsequencerxdi -expand /tb_tstadpcm_virt_tpsched/dut/contextscheduler/schedcontextsequencerxdi
add wave -noupdate -divider Engine
add wave -noupdate -format Literal -label tbstatus /tb_tstadpcm_virt_tpsched/tbstatus
add wave -noupdate -format Logic -label compeng/clkxc /tb_tstadpcm_virt_tpsched/dut/compeng/clkxc
add wave -noupdate -format Logic -label compeng/rstxrb /tb_tstadpcm_virt_tpsched/dut/compeng/rstxrb
add wave -noupdate -format Logic -label compeng/cexei /tb_tstadpcm_virt_tpsched/dut/compeng/cexei
add wave -noupdate -format Literal -label compeng/configxi /tb_tstadpcm_virt_tpsched/dut/compeng/configxi
add wave -noupdate -format Literal -label compeng/clrcontextxsi -radix unsigned /tb_tstadpcm_virt_tpsched/dut/compeng/clrcontextxsi
add wave -noupdate -format Logic -label compeng/clrcontextxei /tb_tstadpcm_virt_tpsched/dut/compeng/clrcontextxei
add wave -noupdate -format Literal -label compeng/contextxsi -radix unsigned /tb_tstadpcm_virt_tpsched/dut/compeng/contextxsi
add wave -noupdate -format Literal -label compeng/cycledncntxdi -radix unsigned /tb_tstadpcm_virt_tpsched/dut/compeng/cycledncntxdi
add wave -noupdate -format Literal -label compeng/cycleupcntxdi -radix unsigned /tb_tstadpcm_virt_tpsched/dut/compeng/cycleupcntxdi
add wave -noupdate -format Literal -label compeng/inportxdi /tb_tstadpcm_virt_tpsched/dut/compeng/inportxdi
add wave -noupdate -format Literal -label compeng/outportxdo /tb_tstadpcm_virt_tpsched/dut/compeng/outportxdo
add wave -noupdate -format Literal -label compeng/inportxeo /tb_tstadpcm_virt_tpsched/dut/compeng/inportxeo
add wave -noupdate -format Literal -label compeng/outportxeo /tb_tstadpcm_virt_tpsched/dut/compeng/outportxeo
add wave -noupdate -format Logic -label dut/fifo1/emptyxso /tb_tstadpcm_virt_tpsched/dut/fifo1/emptyxso
add wave -noupdate -format Logic -label dut/fifo1/fullxso /tb_tstadpcm_virt_tpsched/dut/fifo1/fullxso
add wave -noupdate -format Logic -label dut/fifo1/emptyxs /tb_tstadpcm_virt_tpsched/dut/fifo1/emptyxs
add wave -noupdate -format Literal -label dut/fifo1/filllevelxdo -radix unsigned /tb_tstadpcm_virt_tpsched/dut/fifo1/filllevelxdo
add wave -noupdate -format Logic -label dut/fifo0/emptyxs /tb_tstadpcm_virt_tpsched/dut/fifo0/emptyxs
add wave -noupdate -format Logic -label dut/fifo0/fullxso /tb_tstadpcm_virt_tpsched/dut/fifo0/fullxso
add wave -noupdate -format Logic -label dut/fifo0/emptyxso /tb_tstadpcm_virt_tpsched/dut/fifo0/emptyxso
add wave -noupdate -format Literal -label dut/fifo0/filllevelxdo -radix unsigned /tb_tstadpcm_virt_tpsched/dut/fifo0/filllevelxdo
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {238000 ns} 0}
configure wave -namecolwidth 314
configure wave -valuecolwidth 83
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
WaveRestoreZoom {237343 ns} {238657 ns}
