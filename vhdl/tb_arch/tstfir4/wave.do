onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Literal /tb_tstfir4/tbstatus
add wave -noupdate -format Literal /tb_tstfir4/cycle
add wave -noupdate -format Literal -radix decimal /tb_tstfir4/stimulitb/response
add wave -noupdate -format Literal -radix decimal /tb_tstfir4/stimulitb/expectedresponse
add wave -noupdate -format Literal -radix decimal /tb_tstfir4/dut/cycleupcntxd
add wave -noupdate -format Literal -radix decimal /tb_tstfir4/dut/cycledncntxd
TreeUpdate [SetDefaultTree]
quietly WaveActivateNextPane
add wave -noupdate -divider {Testbench Signals}
add wave -noupdate -format Literal /tb_tstfir4/cfg
add wave -noupdate -format Literal /tb_tstfir4/cfgprt
add wave -noupdate -divider {Interface Signals}
add wave -noupdate -format Logic /tb_tstfir4/dut/clkxc
add wave -noupdate -format Logic /tb_tstfir4/dut/rstxrb
add wave -noupdate -format Logic /tb_tstfir4/dut/wexei
add wave -noupdate -format Logic /tb_tstfir4/dut/rexei
add wave -noupdate -format Literal /tb_tstfir4/dut/addrxdi
add wave -noupdate -format Literal /tb_tstfir4/dut/dataxdi
add wave -noupdate -format Literal -radix hexadecimal /tb_tstfir4/dut/dataxdo
add wave -noupdate -divider {Decoder Signals}
add wave -noupdate -format Logic /tb_tstfir4/dut/decrstxrb
add wave -noupdate -format Logic /tb_tstfir4/dut/decloadccxe
add wave -noupdate -format Logic /tb_tstfir4/dut/decfifo0wexe
add wave -noupdate -format Logic /tb_tstfir4/dut/decfifo0rexe
add wave -noupdate -format Logic /tb_tstfir4/dut/decfifo1wexe
add wave -noupdate -format Logic /tb_tstfir4/dut/decfifo1rexe
add wave -noupdate -format Literal /tb_tstfir4/dut/deccmwexe
add wave -noupdate -format Literal /tb_tstfir4/dut/deccmloadptrxe
add wave -noupdate -format Logic /tb_tstfir4/dut/deccsrxe
add wave -noupdate -format Logic /tb_tstfir4/dut/decengclrcntxtxe
add wave -noupdate -format Literal /tb_tstfir4/dut/decdoutmuxs
add wave -noupdate -format Logic /tb_tstfir4/dut/decsswexe
add wave -noupdate -format Literal /tb_tstfir4/dut/decssiaddrxd
add wave -noupdate -format Logic /tb_tstfir4/dut/decschedulestartxe
add wave -noupdate -format Logic /tb_tstfir4/dut/runningxs
add wave -noupdate -format Logic /tb_tstfir4/dut/ccloadxe
add wave -noupdate -format Logic /tb_tstfir4/dut/ccmuxs
add wave -noupdate -format Literal /tb_tstfir4/dut/ifccinxd
add wave -noupdate -format Literal /tb_tstfir4/dut/ccinxd
add wave -noupdate -format Literal /tb_tstfir4/dut/contextxs
add wave -noupdate -format Literal /tb_tstfir4/dut/contexts
add wave -noupdate -format Literal /tb_tstfir4/dut/datainxd
add wave -noupdate -format Literal /tb_tstfir4/dut/ifcsrinxd
add wave -noupdate -format Literal /tb_tstfir4/dut/csrinxd
add wave -noupdate -format Logic /tb_tstfir4/dut/csrenxe
add wave -noupdate -format Logic /tb_tstfir4/dut/csrmuxs
add wave -noupdate -divider FIFOs
add wave -noupdate -divider FIFO0
add wave -noupdate -format Literal -radix decimal /tb_tstfir4/dut/fifo0inxd
add wave -noupdate -format Logic /tb_tstfir4/dut/fifo0muxs
add wave -noupdate -format Logic /tb_tstfir4/dut/fifo0modexs
add wave -noupdate -format Logic /tb_tstfir4/dut/fifo0wexe
add wave -noupdate -format Logic /tb_tstfir4/dut/fifo0rexe
add wave -noupdate -format Literal -radix decimal /tb_tstfir4/dut/fifo0outxd
add wave -noupdate -format Literal -radix decimal /tb_tstfir4/dut/fifo0fillxd
add wave -noupdate -divider FIFO1
add wave -noupdate -format Literal -radix decimal /tb_tstfir4/dut/fifo1inxd
add wave -noupdate -format Logic /tb_tstfir4/dut/fifo1muxs
add wave -noupdate -format Logic /tb_tstfir4/dut/fifo1modexs
add wave -noupdate -format Logic /tb_tstfir4/dut/fifo1wexe
add wave -noupdate -format Logic /tb_tstfir4/dut/fifo1rexe
add wave -noupdate -format Literal -radix decimal /tb_tstfir4/dut/fifo1outxd
add wave -noupdate -format Literal -radix decimal /tb_tstfir4/dut/fifo1fillxd
add wave -noupdate -divider {Engine Signals}
add wave -noupdate -format Logic /tb_tstfir4/dut/enginport0xe
add wave -noupdate -format Logic /tb_tstfir4/dut/enginport1xe
add wave -noupdate -format Logic /tb_tstfir4/dut/engoutport0xe
add wave -noupdate -format Logic /tb_tstfir4/dut/engoutport1xe
add wave -noupdate -format Literal -radix decimal /tb_tstfir4/dut/engout0xd
add wave -noupdate -format Literal -radix decimal /tb_tstfir4/dut/engout1xd
add wave -noupdate -format Logic /tb_tstfir4/dut/engclrcntxtxe
add wave -noupdate -format Logic /tb_tstfir4/dut/schedswitchxe
add wave -noupdate -format Logic /tb_tstfir4/dut/schedbusyxs
add wave -noupdate -format Logic /tb_tstfir4/dut/notschedbusyxs
add wave -noupdate -format Logic /tb_tstfir4/dut/schedstatusxs
add wave -noupdate -format Logic /tb_tstfir4/dut/schedlastxs
add wave -noupdate -format Logic /tb_tstfir4/dut/sslastxs
add wave -noupdate -format Literal /tb_tstfir4/dut/ssiwordxd
add wave -noupdate -format Literal /tb_tstfir4/dut/sscontextxd
add wave -noupdate -format Literal /tb_tstfir4/dut/sscyclesxd
add wave -noupdate -format Literal /tb_tstfir4/dut/sscsrinxd
add wave -noupdate -format Literal /tb_tstfir4/dut/ssccinxd
add wave -noupdate -format Literal /tb_tstfir4/dut/fifo0outresxd
add wave -noupdate -format Literal /tb_tstfir4/dut/fifo1outresxd
add wave -noupdate -format Literal /tb_tstfir4/dut/fifo0fillresxd
add wave -noupdate -format Literal /tb_tstfir4/dut/fifo1fillresxd
add wave -noupdate -format Literal /tb_tstfir4/dut/cycledncntresxd
add wave -noupdate -format Literal /tb_tstfir4/dut/schedstatusresxd
add wave -noupdate -divider Engine
add wave -noupdate -format Logic /tb_tstfir4/dut/compeng/clkxc
add wave -noupdate -format Logic /tb_tstfir4/dut/compeng/rstxrb
add wave -noupdate -format Logic /tb_tstfir4/dut/compeng/cexei
add wave -noupdate -format Literal /tb_tstfir4/dut/compeng/configxi
add wave -noupdate -format Literal /tb_tstfir4/dut/compeng/clrcontextxsi
add wave -noupdate -format Logic /tb_tstfir4/dut/compeng/clrcontextxei
add wave -noupdate -format Literal /tb_tstfir4/dut/compeng/contextxsi
add wave -noupdate -format Literal /tb_tstfir4/dut/compeng/cycledncntxdi
add wave -noupdate -format Literal /tb_tstfir4/dut/compeng/cycleupcntxdi
add wave -noupdate -format Literal /tb_tstfir4/dut/compeng/inport0xdi
add wave -noupdate -format Literal /tb_tstfir4/dut/compeng/inport1xdi
add wave -noupdate -format Literal -radix decimal /tb_tstfir4/dut/compeng/outport0xdo
add wave -noupdate -format Literal -radix decimal /tb_tstfir4/dut/compeng/outport1xdo
add wave -noupdate -format Logic /tb_tstfir4/dut/compeng/inport0xeo
add wave -noupdate -format Logic /tb_tstfir4/dut/compeng/inport1xeo
add wave -noupdate -format Logic /tb_tstfir4/dut/compeng/outport0xeo
add wave -noupdate -format Logic /tb_tstfir4/dut/compeng/outport1xeo
add wave -noupdate -format Literal /tb_tstfir4/dut/compeng/gridinp
add wave -noupdate -format Literal /tb_tstfir4/dut/compeng/gridout
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {6498 ns} 0}
configure wave -namecolwidth 316
configure wave -valuecolwidth 52
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
WaveRestoreZoom {5000 ns} {7000 ns}
