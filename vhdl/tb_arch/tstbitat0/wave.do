onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Literal /tb_tstbitat0/tbstatus
add wave -noupdate -format Literal /tb_tstbitat0/cycle
add wave -noupdate -format Literal -radix hexadecimal /tb_tstbitat0/response
add wave -noupdate -format Literal -radix hexadecimal /tb_tstbitat0/expectedresponse
TreeUpdate [SetDefaultTree]
quietly WaveActivateNextPane
add wave -noupdate -divider {Testbench Signals}
add wave -noupdate -format Literal /tb_tstbitat0/cfg
add wave -noupdate -format Literal /tb_tstbitat0/cfgprt
add wave -noupdate -divider {Interface Signals}
add wave -noupdate -format Logic /tb_tstbitat0/dut/clkxc
add wave -noupdate -format Logic /tb_tstbitat0/dut/rstxrb
add wave -noupdate -format Logic /tb_tstbitat0/dut/wexei
add wave -noupdate -format Logic /tb_tstbitat0/dut/rexei
add wave -noupdate -format Literal /tb_tstbitat0/dut/addrxdi
add wave -noupdate -format Literal /tb_tstbitat0/dut/dataxdi
add wave -noupdate -format Literal -radix hexadecimal /tb_tstbitat0/dut/dataxdo
add wave -noupdate -divider {Decoder Signals}
add wave -noupdate -format Logic /tb_tstbitat0/dut/decrstxrb
add wave -noupdate -format Logic /tb_tstbitat0/dut/decloadccxe
add wave -noupdate -format Logic /tb_tstbitat0/dut/decfifo0wexe
add wave -noupdate -format Logic /tb_tstbitat0/dut/decfifo0rexe
add wave -noupdate -format Logic /tb_tstbitat0/dut/decfifo1wexe
add wave -noupdate -format Logic /tb_tstbitat0/dut/decfifo1rexe
add wave -noupdate -format Literal /tb_tstbitat0/dut/deccmwexe
add wave -noupdate -format Literal /tb_tstbitat0/dut/deccmloadptrxe
add wave -noupdate -format Logic /tb_tstbitat0/dut/deccsrxe
add wave -noupdate -format Logic /tb_tstbitat0/dut/decengclrcntxtxe
add wave -noupdate -format Literal /tb_tstbitat0/dut/decdoutmuxs
add wave -noupdate -format Logic /tb_tstbitat0/dut/decsswexe
add wave -noupdate -format Literal /tb_tstbitat0/dut/decssiaddrxd
add wave -noupdate -format Logic /tb_tstbitat0/dut/decschedulestartxe
add wave -noupdate -format Logic /tb_tstbitat0/dut/runningxs
add wave -noupdate -format Logic /tb_tstbitat0/dut/ccloadxe
add wave -noupdate -format Logic /tb_tstbitat0/dut/ccmuxs
add wave -noupdate -format Literal /tb_tstbitat0/dut/ifccinxd
add wave -noupdate -format Literal /tb_tstbitat0/dut/ccinxd
add wave -noupdate -format Literal -radix decimal /tb_tstbitat0/dut/cycledncntxd
add wave -noupdate -format Literal -radix decimal /tb_tstbitat0/dut/cycleupcntxd
add wave -noupdate -format Literal /tb_tstbitat0/dut/contextxs
add wave -noupdate -format Literal /tb_tstbitat0/dut/contexts
add wave -noupdate -format Literal /tb_tstbitat0/dut/datainxd
add wave -noupdate -format Literal /tb_tstbitat0/dut/ifcsrinxd
add wave -noupdate -format Literal /tb_tstbitat0/dut/csrinxd
add wave -noupdate -format Logic /tb_tstbitat0/dut/csrenxe
add wave -noupdate -format Logic /tb_tstbitat0/dut/csrmuxs
add wave -noupdate -divider FIFOs
add wave -noupdate -divider FIFO0
add wave -noupdate -format Literal -radix hexadecimal /tb_tstbitat0/dut/fifo0inxd
add wave -noupdate -format Logic /tb_tstbitat0/dut/fifo0muxs
add wave -noupdate -format Logic /tb_tstbitat0/dut/fifo0modexs
add wave -noupdate -format Logic /tb_tstbitat0/dut/fifo0wexe
add wave -noupdate -format Logic /tb_tstbitat0/dut/fifo0rexe
add wave -noupdate -format Literal -radix hexadecimal /tb_tstbitat0/dut/fifo0outxd
add wave -noupdate -format Literal -radix decimal /tb_tstbitat0/dut/fifo0fillxd
add wave -noupdate -divider FIFO1
add wave -noupdate -format Literal -radix hexadecimal /tb_tstbitat0/dut/fifo1inxd
add wave -noupdate -format Logic /tb_tstbitat0/dut/fifo1muxs
add wave -noupdate -format Logic /tb_tstbitat0/dut/fifo1modexs
add wave -noupdate -format Logic /tb_tstbitat0/dut/fifo1wexe
add wave -noupdate -format Logic /tb_tstbitat0/dut/fifo1rexe
add wave -noupdate -format Literal -radix hexadecimal /tb_tstbitat0/dut/fifo1outxd
add wave -noupdate -format Literal -radix decimal /tb_tstbitat0/dut/fifo1fillxd
add wave -noupdate -divider {Engine Signals}
add wave -noupdate -format Logic /tb_tstbitat0/dut/enginport0xe
add wave -noupdate -format Logic /tb_tstbitat0/dut/enginport1xe
add wave -noupdate -format Logic /tb_tstbitat0/dut/engoutport0xe
add wave -noupdate -format Logic /tb_tstbitat0/dut/engoutport1xe
add wave -noupdate -format Literal /tb_tstbitat0/dut/engout0xd
add wave -noupdate -format Literal /tb_tstbitat0/dut/engout1xd
add wave -noupdate -format Logic /tb_tstbitat0/dut/engclrcntxtxe
add wave -noupdate -format Logic /tb_tstbitat0/dut/schedswitchxe
add wave -noupdate -format Logic /tb_tstbitat0/dut/schedbusyxs
add wave -noupdate -format Logic /tb_tstbitat0/dut/notschedbusyxs
add wave -noupdate -format Logic /tb_tstbitat0/dut/schedstatusxs
add wave -noupdate -format Logic /tb_tstbitat0/dut/schedlastxs
add wave -noupdate -format Logic /tb_tstbitat0/dut/sslastxs
add wave -noupdate -format Literal /tb_tstbitat0/dut/ssiwordxd
add wave -noupdate -format Literal /tb_tstbitat0/dut/sscontextxd
add wave -noupdate -format Literal /tb_tstbitat0/dut/sscyclesxd
add wave -noupdate -format Literal /tb_tstbitat0/dut/sscsrinxd
add wave -noupdate -format Literal /tb_tstbitat0/dut/ssccinxd
add wave -noupdate -format Literal /tb_tstbitat0/dut/fifo0outresxd
add wave -noupdate -format Literal /tb_tstbitat0/dut/fifo1outresxd
add wave -noupdate -format Literal /tb_tstbitat0/dut/fifo0fillresxd
add wave -noupdate -format Literal /tb_tstbitat0/dut/fifo1fillresxd
add wave -noupdate -format Literal /tb_tstbitat0/dut/cycledncntresxd
add wave -noupdate -format Literal /tb_tstbitat0/dut/schedstatusresxd
add wave -noupdate -divider Engine
add wave -noupdate -format Logic /tb_tstbitat0/dut/compeng/clkxc
add wave -noupdate -format Logic /tb_tstbitat0/dut/compeng/rstxrb
add wave -noupdate -format Logic /tb_tstbitat0/dut/compeng/cexei
add wave -noupdate -format Literal /tb_tstbitat0/dut/compeng/configxi
add wave -noupdate -format Literal /tb_tstbitat0/dut/compeng/clrcontextxsi
add wave -noupdate -format Logic /tb_tstbitat0/dut/compeng/clrcontextxei
add wave -noupdate -format Literal /tb_tstbitat0/dut/compeng/contextxsi
add wave -noupdate -format Literal /tb_tstbitat0/dut/compeng/cycledncntxdi
add wave -noupdate -format Literal /tb_tstbitat0/dut/compeng/cycleupcntxdi
add wave -noupdate -format Literal /tb_tstbitat0/dut/compeng/inport0xdi
add wave -noupdate -format Literal /tb_tstbitat0/dut/compeng/inport1xdi
add wave -noupdate -format Literal -radix hexadecimal /tb_tstbitat0/dut/compeng/outport0xdo
add wave -noupdate -format Literal /tb_tstbitat0/dut/compeng/outport1xdo
add wave -noupdate -format Logic /tb_tstbitat0/dut/compeng/inport0xeo
add wave -noupdate -format Logic /tb_tstbitat0/dut/compeng/inport1xeo
add wave -noupdate -format Logic /tb_tstbitat0/dut/compeng/outport0xeo
add wave -noupdate -format Logic /tb_tstbitat0/dut/compeng/outport1xeo
add wave -noupdate -format Literal /tb_tstbitat0/dut/compeng/gridinp
add wave -noupdate -format Literal /tb_tstbitat0/dut/compeng/gridout
add wave -noupdate -format Literal /tb_tstbitat0/dut/compeng/outa3xd
add wave -noupdate -format Literal /tb_tstbitat0/dut/compeng/outa2xd
add wave -noupdate -format Literal /tb_tstbitat0/dut/compeng/outa1xd
add wave -noupdate -format Literal /tb_tstbitat0/dut/compeng/outa0xd
add wave -noupdate -format Literal /tb_tstbitat0/dut/compeng/outb3xd
add wave -noupdate -format Literal /tb_tstbitat0/dut/compeng/outb2xd
add wave -noupdate -format Literal /tb_tstbitat0/dut/compeng/outb1xd
add wave -noupdate -format Literal /tb_tstbitat0/dut/compeng/outb0xd
add wave -noupdate -format Literal /tb_tstbitat0/dut/compeng/outc3xd
add wave -noupdate -format Literal /tb_tstbitat0/dut/compeng/outc2xd
add wave -noupdate -format Literal /tb_tstbitat0/dut/compeng/outc1xd
add wave -noupdate -format Literal /tb_tstbitat0/dut/compeng/outc0xd
add wave -noupdate -format Literal /tb_tstbitat0/dut/compeng/outd3xd
add wave -noupdate -format Literal /tb_tstbitat0/dut/compeng/outd2xd
add wave -noupdate -format Literal /tb_tstbitat0/dut/compeng/outd1xd
add wave -noupdate -format Literal /tb_tstbitat0/dut/compeng/outd0xd
add wave -noupdate -format Literal /tb_tstbitat0/dut/compeng/hbusab0xz
add wave -noupdate -format Literal /tb_tstbitat0/dut/compeng/hbusab1xz
add wave -noupdate -format Literal /tb_tstbitat0/dut/compeng/hbusaaxz
add wave -noupdate -format Literal /tb_tstbitat0/dut/compeng/hbusbbxz
add wave -noupdate -format Literal /tb_tstbitat0/dut/compeng/hbuscd0xz
add wave -noupdate -format Literal /tb_tstbitat0/dut/compeng/hbusccxz
add wave -noupdate -format Literal /tb_tstbitat0/dut/compeng/hbusda0xz
add wave -noupdate -format Literal /tb_tstbitat0/dut/compeng/hbusda1xz
add wave -noupdate -format Literal /tb_tstbitat0/dut/compeng/hbusddxz
add wave -noupdate -divider {Cell 2/3 IO}
add wave -noupdate -format Literal -radix hexadecimal /tb_tstbitat0/dut/compeng/hbusbc0xz
add wave -noupdate -format Literal -radix hexadecimal /tb_tstbitat0/dut/compeng/hbusbc1xz
add wave -noupdate -format Literal -radix hexadecimal /tb_tstbitat0/dut/compeng/hbuscd1xz
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {7442 ns} 0}
configure wave -namecolwidth 162
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
WaveRestoreZoom {5758 ns} {7592 ns}
