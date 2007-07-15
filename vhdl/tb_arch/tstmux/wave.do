onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Literal /tb_tstmux/tbstatus
add wave -noupdate -format Literal /tb_tstmux/cycle
add wave -noupdate -format Literal -radix hexadecimal /tb_tstmux/stimulitb/response
add wave -noupdate -format Literal -radix hexadecimal /tb_tstmux/stimulitb/expectedresponse
TreeUpdate [SetDefaultTree]
quietly WaveActivateNextPane
add wave -noupdate -divider {Testbench Signals}
add wave -noupdate -format Literal /tb_tstmux/cfg
add wave -noupdate -format Literal /tb_tstmux/cfgprt
add wave -noupdate -divider {Interface Signals}
add wave -noupdate -format Logic /tb_tstmux/dut/clkxc
add wave -noupdate -format Logic /tb_tstmux/dut/rstxrb
add wave -noupdate -format Logic /tb_tstmux/dut/wexei
add wave -noupdate -format Logic /tb_tstmux/dut/rexei
add wave -noupdate -format Literal /tb_tstmux/dut/addrxdi
add wave -noupdate -format Literal /tb_tstmux/dut/dataxdi
add wave -noupdate -format Literal -radix hexadecimal /tb_tstmux/dut/dataxdo
add wave -noupdate -divider {Decoder Signals}
add wave -noupdate -format Logic /tb_tstmux/dut/decrstxrb
add wave -noupdate -format Logic /tb_tstmux/dut/decloadccxe
add wave -noupdate -format Logic /tb_tstmux/dut/decfifo0wexe
add wave -noupdate -format Logic /tb_tstmux/dut/decfifo0rexe
add wave -noupdate -format Logic /tb_tstmux/dut/decfifo1wexe
add wave -noupdate -format Logic /tb_tstmux/dut/decfifo1rexe
add wave -noupdate -format Literal /tb_tstmux/dut/deccmwexe
add wave -noupdate -format Literal /tb_tstmux/dut/deccmloadptrxe
add wave -noupdate -format Logic /tb_tstmux/dut/deccsrxe
add wave -noupdate -format Logic /tb_tstmux/dut/decengclrcntxtxe
add wave -noupdate -format Literal /tb_tstmux/dut/decdoutmuxs
add wave -noupdate -format Logic /tb_tstmux/dut/decsswexe
add wave -noupdate -format Literal /tb_tstmux/dut/decssiaddrxd
add wave -noupdate -format Logic /tb_tstmux/dut/decschedulestartxe
add wave -noupdate -format Logic /tb_tstmux/dut/runningxs
add wave -noupdate -format Logic /tb_tstmux/dut/ccloadxe
add wave -noupdate -format Logic /tb_tstmux/dut/ccmuxs
add wave -noupdate -format Literal /tb_tstmux/dut/ifccinxd
add wave -noupdate -format Literal /tb_tstmux/dut/ccinxd
add wave -noupdate -format Literal -radix decimal /tb_tstmux/dut/cycledncntxd
add wave -noupdate -format Literal -radix decimal /tb_tstmux/dut/cycleupcntxd
add wave -noupdate -format Literal /tb_tstmux/dut/contextxs
add wave -noupdate -format Literal /tb_tstmux/dut/contexts
add wave -noupdate -format Literal /tb_tstmux/dut/datainxd
add wave -noupdate -format Literal /tb_tstmux/dut/ifcsrinxd
add wave -noupdate -format Literal /tb_tstmux/dut/csrinxd
add wave -noupdate -format Logic /tb_tstmux/dut/csrenxe
add wave -noupdate -format Logic /tb_tstmux/dut/csrmuxs
add wave -noupdate -divider FIFOs
add wave -noupdate -divider FIFO0
add wave -noupdate -format Literal -radix hexadecimal /tb_tstmux/dut/fifo0inxd
add wave -noupdate -format Logic /tb_tstmux/dut/fifo0muxs
add wave -noupdate -format Logic /tb_tstmux/dut/fifo0modexs
add wave -noupdate -format Logic /tb_tstmux/dut/fifo0wexe
add wave -noupdate -format Logic /tb_tstmux/dut/fifo0rexe
add wave -noupdate -format Literal -radix hexadecimal /tb_tstmux/dut/fifo0outxd
add wave -noupdate -format Literal -radix decimal /tb_tstmux/dut/fifo0fillxd
add wave -noupdate -divider FIFO1
add wave -noupdate -format Literal -radix hexadecimal /tb_tstmux/dut/fifo1inxd
add wave -noupdate -format Logic /tb_tstmux/dut/fifo1muxs
add wave -noupdate -format Logic /tb_tstmux/dut/fifo1modexs
add wave -noupdate -format Logic /tb_tstmux/dut/fifo1wexe
add wave -noupdate -format Logic /tb_tstmux/dut/fifo1rexe
add wave -noupdate -format Literal -radix hexadecimal /tb_tstmux/dut/fifo1outxd
add wave -noupdate -format Literal -radix decimal /tb_tstmux/dut/fifo1fillxd
add wave -noupdate -divider {Engine Signals}
add wave -noupdate -format Logic /tb_tstmux/dut/enginport0xe
add wave -noupdate -format Logic /tb_tstmux/dut/enginport1xe
add wave -noupdate -format Logic /tb_tstmux/dut/engoutport0xe
add wave -noupdate -format Logic /tb_tstmux/dut/engoutport1xe
add wave -noupdate -format Literal /tb_tstmux/dut/engout0xd
add wave -noupdate -format Literal /tb_tstmux/dut/engout1xd
add wave -noupdate -format Logic /tb_tstmux/dut/engclrcntxtxe
add wave -noupdate -format Logic /tb_tstmux/dut/schedswitchxe
add wave -noupdate -format Logic /tb_tstmux/dut/schedbusyxs
add wave -noupdate -format Logic /tb_tstmux/dut/notschedbusyxs
add wave -noupdate -format Logic /tb_tstmux/dut/schedstatusxs
add wave -noupdate -format Logic /tb_tstmux/dut/schedlastxs
add wave -noupdate -format Logic /tb_tstmux/dut/sslastxs
add wave -noupdate -format Literal /tb_tstmux/dut/ssiwordxd
add wave -noupdate -format Literal /tb_tstmux/dut/sscontextxd
add wave -noupdate -format Literal /tb_tstmux/dut/sscyclesxd
add wave -noupdate -format Literal /tb_tstmux/dut/sscsrinxd
add wave -noupdate -format Literal /tb_tstmux/dut/ssccinxd
add wave -noupdate -format Literal /tb_tstmux/dut/fifo0outresxd
add wave -noupdate -format Literal /tb_tstmux/dut/fifo1outresxd
add wave -noupdate -format Literal /tb_tstmux/dut/fifo0fillresxd
add wave -noupdate -format Literal /tb_tstmux/dut/fifo1fillresxd
add wave -noupdate -format Literal /tb_tstmux/dut/cycledncntresxd
add wave -noupdate -format Literal /tb_tstmux/dut/schedstatusresxd
add wave -noupdate -divider Engine
add wave -noupdate -format Logic /tb_tstmux/dut/compeng/clkxc
add wave -noupdate -format Logic /tb_tstmux/dut/compeng/rstxrb
add wave -noupdate -format Logic /tb_tstmux/dut/compeng/cexei
add wave -noupdate -format Literal /tb_tstmux/dut/compeng/configxi
add wave -noupdate -format Literal /tb_tstmux/dut/compeng/clrcontextxsi
add wave -noupdate -format Logic /tb_tstmux/dut/compeng/clrcontextxei
add wave -noupdate -format Literal /tb_tstmux/dut/compeng/contextxsi
add wave -noupdate -format Literal /tb_tstmux/dut/compeng/cycledncntxdi
add wave -noupdate -format Literal /tb_tstmux/dut/compeng/cycleupcntxdi
add wave -noupdate -format Literal /tb_tstmux/dut/compeng/gridinp
add wave -noupdate -format Literal /tb_tstmux/dut/compeng/gridout
add wave -noupdate -divider {Cell 2/3 IO}
add wave -noupdate -format Literal -label cell2_3/procelin0xD -radix hexadecimal /tb_tstmux/dut/compeng/gen_rows__2/row_i/gen_cells__3/cell_i/procelin0xd
add wave -noupdate -format Literal -label cell2_3/procelin1xD -radix hexadecimal /tb_tstmux/dut/compeng/gen_rows__2/row_i/gen_cells__3/cell_i/procelin1xd
add wave -noupdate -format Literal -label cell2_3/procelin2xD -radix hexadecimal /tb_tstmux/dut/compeng/gen_rows__2/row_i/gen_cells__3/cell_i/procelin2xd
add wave -noupdate -format Logic /tb_tstmux/dut/compeng/gen_rows__2/row_i/gen_cells__3/cell_i/clkxc
add wave -noupdate -format Logic /tb_tstmux/dut/compeng/gen_rows__2/row_i/gen_cells__3/cell_i/rstxrb
add wave -noupdate -format Logic /tb_tstmux/dut/compeng/gen_rows__2/row_i/gen_cells__3/cell_i/cexei
add wave -noupdate -format Literal -expand /tb_tstmux/dut/compeng/gen_rows__2/row_i/gen_cells__3/cell_i/configxi
add wave -noupdate -format Literal /tb_tstmux/dut/compeng/gen_rows__2/row_i/gen_cells__3/cell_i/clrcontextxsi
add wave -noupdate -format Logic /tb_tstmux/dut/compeng/gen_rows__2/row_i/gen_cells__3/cell_i/clrcontextxei
add wave -noupdate -format Literal /tb_tstmux/dut/compeng/gen_rows__2/row_i/gen_cells__3/cell_i/contextxsi
add wave -noupdate -format Literal -radix hexadecimal /tb_tstmux/dut/compeng/gen_rows__2/row_i/gen_cells__3/cell_i/in2xdi
add wave -noupdate -format Literal -radix hexadecimal /tb_tstmux/dut/compeng/gen_rows__2/row_i/gen_cells__3/cell_i/in3xdi
add wave -noupdate -format Literal -radix hexadecimal /tb_tstmux/dut/compeng/gen_rows__2/row_i/gen_cells__3/cell_i/in4xdi
add wave -noupdate -format Literal -radix hexadecimal /tb_tstmux/dut/compeng/gen_rows__2/row_i/gen_cells__3/cell_i/in5xdi
add wave -noupdate -format Literal -radix hexadecimal /tb_tstmux/dut/compeng/gen_rows__2/row_i/gen_cells__3/cell_i/in6xdi
add wave -noupdate -format Literal -radix hexadecimal /tb_tstmux/dut/compeng/gen_rows__2/row_i/gen_cells__3/cell_i/in7xdi
add wave -noupdate -format Literal -radix hexadecimal /tb_tstmux/dut/compeng/gen_rows__2/row_i/gen_cells__3/cell_i/outxdo
add wave -noupdate -format Literal -radix hexadecimal /tb_tstmux/dut/compeng/gen_rows__2/row_i/gen_cells__3/cell_i/out0xzo
add wave -noupdate -format Literal -radix hexadecimal /tb_tstmux/dut/compeng/gen_rows__2/row_i/gen_cells__3/cell_i/out1xzo
add wave -noupdate -format Literal -radix hexadecimal /tb_tstmux/dut/compeng/gen_rows__2/row_i/gen_cells__3/cell_i/out2xzo
add wave -noupdate -format Literal -radix hexadecimal /tb_tstmux/dut/compeng/gen_rows__2/row_i/gen_cells__3/cell_i/proceloutxd
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {7442 ns} 0}
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
WaveRestoreZoom {12228 ns} {15186 ns}
