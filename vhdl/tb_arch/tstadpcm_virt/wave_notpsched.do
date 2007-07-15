onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic -label contextschedulertp/clkxc /tb_tstadpcm_virt/dut/contextschedulertp/clkxc
add wave -noupdate -format Logic -label contextschedulertp/rstxrb /tb_tstadpcm_virt/dut/contextschedulertp/rstxrb
add wave -noupdate -format Literal /tb_tstadpcm_virt/dut/contextschedulertp/statexs
add wave -noupdate -format Logic -label contextscheduler/schedulestartxei /tb_tstadpcm_virt/dut/contextschedulertp/schedulestartxei
add wave -noupdate -format Logic -label contextschedulertp/scheduledonexso /tb_tstadpcm_virt/dut/contextschedulertp/scheduledonexso
add wave -noupdate -format Literal -label contextschedulertp/notpcontextsxsi -radix decimal /tb_tstadpcm_virt/dut/contextschedulertp/notpcontextsxsi
add wave -noupdate -format Literal -label contextschedulertp/notpusercyclesxsi -radix decimal /tb_tstadpcm_virt/dut/contextschedulertp/notpusercyclesxsi
add wave -noupdate -format Logic -label contextschedulertp/cexeo /tb_tstadpcm_virt/dut/contextschedulertp/cexeo
add wave -noupdate -format Literal -label contextschedulertp/clrcontextxso /tb_tstadpcm_virt/dut/contextschedulertp/clrcontextxso
add wave -noupdate -format Logic -label contextschedulertp/clrcontextxeo /tb_tstadpcm_virt/dut/contextschedulertp/clrcontextxeo
add wave -noupdate -format Literal -label contextschedulertp/contextxso -radix unsigned /tb_tstadpcm_virt/dut/contextschedulertp/contextxso
add wave -noupdate -format Literal -label contextschedulertp/cycledncntxdo -radix unsigned /tb_tstadpcm_virt/dut/contextschedulertp/cycledncntxdo
add wave -noupdate -format Literal -label contextschedulertp/cycleupcntxdo -radix unsigned /tb_tstadpcm_virt/dut/contextschedulertp/cycleupcntxdo
add wave -noupdate -format Literal -label contextschedulertp/currentusercycle -radix unsigned /tb_tstadpcm_virt/dut/contextschedulertp/currentusercycle
add wave -noupdate -format Literal -label contextschedulertp/currentsubcycle -radix unsigned /tb_tstadpcm_virt/dut/contextschedulertp/currentsubcycle
add wave -noupdate -format Logic -label decdr/contextschedulerselectxeo /tb_tstadpcm_virt/dut/decdr/contextschedulerselectxeo
add wave -noupdate -format Logic -label decdr/virtcontextnoxeo /tb_tstadpcm_virt/dut/decdr/virtcontextnoxeo
add wave -noupdate -format Logic -label decdr/schedulestartxe /tb_tstadpcm_virt/dut/decdr/schedulestartxe
add wave -noupdate -divider Scheduler
add wave -noupdate -format Logic -label dut/deccontextschedulerselectxe /tb_tstadpcm_virt/dut/deccontextschedulerselectxe
add wave -noupdate -format Logic -label dut/contextscheduler/schedulerselectxsi /tb_tstadpcm_virt/dut/contextscheduler/schedulerselectxsi
add wave -noupdate -format Literal -label contextscheduler/engineschedulecontrolxeo /tb_tstadpcm_virt/dut/contextscheduler/engineschedulecontrolxeo
add wave -noupdate -format Literal -label contextscheduler/schedtemporalpartitioningxdi /tb_tstadpcm_virt/dut/contextscheduler/schedtemporalpartitioningxdi
add wave -noupdate -format Literal -label contextscheduler/schedcontextsequencerxdi /tb_tstadpcm_virt/dut/contextscheduler/schedcontextsequencerxdi
add wave -noupdate -divider Engine
add wave -noupdate -format Logic /tb_tstadpcm_virt/dut/compeng/clkxc
add wave -noupdate -format Logic /tb_tstadpcm_virt/dut/compeng/rstxrb
add wave -noupdate -format Logic /tb_tstadpcm_virt/dut/compeng/cexei
add wave -noupdate -format Literal /tb_tstadpcm_virt/dut/compeng/configxi
add wave -noupdate -format Literal /tb_tstadpcm_virt/dut/compeng/clrcontextxsi
add wave -noupdate -format Logic /tb_tstadpcm_virt/dut/compeng/clrcontextxei
add wave -noupdate -format Literal -radix unsigned /tb_tstadpcm_virt/dut/compeng/contextxsi
add wave -noupdate -format Literal -radix unsigned /tb_tstadpcm_virt/dut/compeng/cycledncntxdi
add wave -noupdate -format Literal -radix unsigned /tb_tstadpcm_virt/dut/compeng/cycleupcntxdi
add wave -noupdate -format Literal /tb_tstadpcm_virt/dut/compeng/inportxdi
add wave -noupdate -format Literal /tb_tstadpcm_virt/dut/compeng/outportxdo
add wave -noupdate -format Literal /tb_tstadpcm_virt/dut/compeng/inportxeo
add wave -noupdate -format Literal /tb_tstadpcm_virt/dut/compeng/outportxeo
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {238000 ns} 0}
configure wave -namecolwidth 312
configure wave -valuecolwidth 69
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
WaveRestoreZoom {236512 ns} {239488 ns}
