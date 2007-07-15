onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Literal /tb_tstor/tbstatus
add wave -noupdate -format Literal /tb_tstor/cycle
add wave -noupdate -format Literal -radix hexadecimal /tb_tstor/stimulitb/response
add wave -noupdate -format Literal /tb_tstor/stimulitb/expectedresponse
TreeUpdate [SetDefaultTree]
quietly WaveActivateNextPane
add wave -noupdate -divider {Testbench Signals}
add wave -noupdate -format Literal -expand /tb_tstor/cfg
add wave -noupdate -format Literal -radix symbolic /tb_tstor/cfgprt
add wave -noupdate -divider {Interface Signals}
add wave -noupdate -format Logic /tb_tstor/dut/clkxc
add wave -noupdate -format Logic /tb_tstor/dut/rstxrb
add wave -noupdate -format Logic /tb_tstor/dut/wexei
add wave -noupdate -format Logic /tb_tstor/dut/rexei
add wave -noupdate -format Literal /tb_tstor/dut/addrxdi
add wave -noupdate -format Literal /tb_tstor/dut/dataxdi
add wave -noupdate -format Literal /tb_tstor/dut/dataxdo
add wave -noupdate -divider {Decoder Signals}
add wave -noupdate -format Logic /tb_tstor/dut/decrstxrb
add wave -noupdate -format Logic /tb_tstor/dut/decloadccxe
add wave -noupdate -format Logic /tb_tstor/dut/decfifo0wexe
add wave -noupdate -format Logic /tb_tstor/dut/decfifo0rexe
add wave -noupdate -format Logic /tb_tstor/dut/decfifo1wexe
add wave -noupdate -format Logic /tb_tstor/dut/decfifo1rexe
add wave -noupdate -format Literal /tb_tstor/dut/deccmwexe
add wave -noupdate -format Literal /tb_tstor/dut/deccmloadptrxe
add wave -noupdate -format Logic /tb_tstor/dut/deccsrxe
add wave -noupdate -format Logic /tb_tstor/dut/decengclrcntxtxe
add wave -noupdate -format Literal /tb_tstor/dut/decdoutmuxs
add wave -noupdate -format Logic /tb_tstor/dut/decsswexe
add wave -noupdate -format Literal /tb_tstor/dut/decssiaddrxd
add wave -noupdate -format Logic /tb_tstor/dut/decschedulestartxe
add wave -noupdate -format Logic /tb_tstor/dut/runningxs
add wave -noupdate -format Logic /tb_tstor/dut/ccloadxe
add wave -noupdate -format Logic /tb_tstor/dut/ccmuxs
add wave -noupdate -format Literal /tb_tstor/dut/ifccinxd
add wave -noupdate -format Literal /tb_tstor/dut/ccinxd
add wave -noupdate -format Literal -radix decimal /tb_tstor/dut/cycledncntxd
add wave -noupdate -format Literal -radix decimal /tb_tstor/dut/cycleupcntxd
add wave -noupdate -format Literal /tb_tstor/dut/contextxs
add wave -noupdate -format Literal /tb_tstor/dut/contexts
add wave -noupdate -format Literal /tb_tstor/dut/datainxd
add wave -noupdate -format Literal /tb_tstor/dut/ifcsrinxd
add wave -noupdate -format Literal /tb_tstor/dut/csrinxd
add wave -noupdate -format Logic /tb_tstor/dut/csrenxe
add wave -noupdate -format Logic /tb_tstor/dut/csrmuxs
add wave -noupdate -divider FIFOs
add wave -noupdate -divider FIFO0
add wave -noupdate -format Literal -radix hexadecimal /tb_tstor/dut/fifo0inxd
add wave -noupdate -format Logic /tb_tstor/dut/fifo0muxs
add wave -noupdate -format Logic /tb_tstor/dut/fifo0modexs
add wave -noupdate -format Logic /tb_tstor/dut/fifo0wexe
add wave -noupdate -format Logic /tb_tstor/dut/fifo0rexe
add wave -noupdate -format Literal -radix hexadecimal /tb_tstor/dut/fifo0outxd
add wave -noupdate -format Literal -radix decimal /tb_tstor/dut/fifo0fillxd
add wave -noupdate -divider FIFO1
add wave -noupdate -format Literal -radix hexadecimal /tb_tstor/dut/fifo1inxd
add wave -noupdate -format Logic /tb_tstor/dut/fifo1muxs
add wave -noupdate -format Logic /tb_tstor/dut/fifo1modexs
add wave -noupdate -format Logic /tb_tstor/dut/fifo1wexe
add wave -noupdate -format Logic /tb_tstor/dut/fifo1rexe
add wave -noupdate -format Literal -radix hexadecimal /tb_tstor/dut/fifo1outxd
add wave -noupdate -format Literal -radix decimal /tb_tstor/dut/fifo1fillxd
add wave -noupdate -divider {Engine Signals}
add wave -noupdate -format Literal -radix hexadecimal /tb_tstor/dut/compeng/inportxdi
add wave -noupdate -format Literal /tb_tstor/dut/compeng/inportxeo
add wave -noupdate -format Literal -radix hexadecimal /tb_tstor/dut/compeng/outportxdo
add wave -noupdate -format Literal /tb_tstor/dut/compeng/outportxeo
add wave -noupdate -format Literal -radix hexadecimal /tb_tstor/dut/compeng/hbussxz
add wave -noupdate -format Literal -radix hexadecimal /tb_tstor/dut/compeng/hbusnxz
add wave -noupdate -format Literal -radix hexadecimal /tb_tstor/dut/compeng/gridout
add wave -noupdate -format Literal -radix hexadecimal /tb_tstor/dut/compeng/gridinp
add wave -noupdate -format Logic /tb_tstor/dut/engclrcntxtxe
add wave -noupdate -format Logic /tb_tstor/dut/schedswitchxe
add wave -noupdate -format Logic /tb_tstor/dut/schedbusyxs
add wave -noupdate -format Logic /tb_tstor/dut/notschedbusyxs
add wave -noupdate -format Logic /tb_tstor/dut/schedstatusxs
add wave -noupdate -format Logic /tb_tstor/dut/schedlastxs
add wave -noupdate -format Logic /tb_tstor/dut/sslastxs
add wave -noupdate -format Literal /tb_tstor/dut/ssiwordxd
add wave -noupdate -format Literal /tb_tstor/dut/sscontextxd
add wave -noupdate -format Literal /tb_tstor/dut/sscyclesxd
add wave -noupdate -format Literal /tb_tstor/dut/sscsrinxd
add wave -noupdate -format Literal /tb_tstor/dut/ssccinxd
add wave -noupdate -format Literal /tb_tstor/dut/fifo0outresxd
add wave -noupdate -format Literal /tb_tstor/dut/fifo1outresxd
add wave -noupdate -format Literal /tb_tstor/dut/fifo0fillresxd
add wave -noupdate -format Literal /tb_tstor/dut/fifo1fillresxd
add wave -noupdate -format Literal /tb_tstor/dut/cycledncntresxd
add wave -noupdate -format Literal /tb_tstor/dut/schedstatusresxd
add wave -noupdate -divider Engine
add wave -noupdate -format Logic /tb_tstor/dut/compeng/clkxc
add wave -noupdate -format Logic /tb_tstor/dut/compeng/rstxrb
add wave -noupdate -format Logic /tb_tstor/dut/compeng/cexei
add wave -noupdate -format Literal /tb_tstor/dut/compeng/configxi
add wave -noupdate -format Literal /tb_tstor/dut/compeng/clrcontextxsi
add wave -noupdate -format Logic /tb_tstor/dut/compeng/clrcontextxei
add wave -noupdate -format Literal /tb_tstor/dut/compeng/contextxsi
add wave -noupdate -format Literal /tb_tstor/dut/compeng/cycledncntxdi
add wave -noupdate -format Literal /tb_tstor/dut/compeng/cycleupcntxdi
add wave -noupdate -format Literal -radix hexadecimal /tb_tstor/dut/compeng/gridinp
add wave -noupdate -format Literal -radix hexadecimal /tb_tstor/dut/compeng/gridout
add wave -noupdate -divider {Cell 2/3 IO}
add wave -noupdate -format Logic -label r2c3/cell_i/CExEI -radix symbolic /tb_tstor/dut/compeng/gen_rows__2/row_i/gen_cells__3/cell_i/cexei
add wave -noupdate -format Literal -label r2c3/cell_i/ConfigxI -radix symbolic /tb_tstor/dut/compeng/gen_rows__2/row_i/gen_cells__3/cell_i/configxi
add wave -noupdate -format Literal -label r2ce/cell_i/ClrContextxSI -radix symbolic /tb_tstor/dut/compeng/gen_rows__2/row_i/gen_cells__3/cell_i/clrcontextxsi
add wave -noupdate -format Logic -label r2c3/cell_i/ClrContextxEI -radix symbolic /tb_tstor/dut/compeng/gen_rows__2/row_i/gen_cells__3/cell_i/clrcontextxei
add wave -noupdate -format Literal -label r2c3/cell_i/ContextxSI -radix symbolic /tb_tstor/dut/compeng/gen_rows__2/row_i/gen_cells__3/cell_i/contextxsi
add wave -noupdate -format Literal -label r2c3/cell_i/InputxDI -radix symbolic -expand /tb_tstor/dut/compeng/gen_rows__2/row_i/gen_cells__3/cell_i/inputxdi
add wave -noupdate -format Literal -label r2c3/cell_i/OutputxZO -radix symbolic /tb_tstor/dut/compeng/gen_rows__2/row_i/gen_cells__3/cell_i/outputxzo
add wave -noupdate -format Literal -label r2c3/cell_i/ProcelInxD -radix symbolic /tb_tstor/dut/compeng/gen_rows__2/row_i/gen_cells__3/cell_i/procelinxd
add wave -noupdate -format Literal -label r2c3/cell_i/ProcelOutxD -radix symbolic /tb_tstor/dut/compeng/gen_rows__2/row_i/gen_cells__3/cell_i/proceloutxd
add wave -noupdate -format Literal -label r2c3/cell_i/procel/InxDI -radix symbolic /tb_tstor/dut/compeng/gen_rows__2/row_i/gen_cells__3/cell_i/procelement/inxdi
add wave -noupdate -format Literal -label r2c3/cell_i/procel/OutxDO -radix symbolic /tb_tstor/dut/compeng/gen_rows__2/row_i/gen_cells__3/cell_i/procelement/outxdo
add wave -noupdate -divider {HBusN driver}
add wave -noupdate -divider {r2 p1 hbusn1}
add wave -noupdate -format Literal -label tbuf_p1_r2_hbusn1/InxDI /tb_tstor/dut/compeng/tbufport_gen__1/tbufrow_gen__2/tbufhbusn_gen__1/inptbuf/inxdi
add wave -noupdate -format Logic -label tbuf_p1_r2_hbusn1/OexEI /tb_tstor/dut/compeng/tbufport_gen__1/tbufrow_gen__2/tbufhbusn_gen__1/inptbuf/oexei
add wave -noupdate -format Literal -label tbuf_p1_r2_hbusn1/OutxZO /tb_tstor/dut/compeng/tbufport_gen__1/tbufrow_gen__2/tbufhbusn_gen__1/inptbuf/outxzo
add wave -noupdate -divider {r2 p0 hbusn1}
add wave -noupdate -format Literal -label tbuf_p0_r2_hbusn1/InxDI /tb_tstor/dut/compeng/tbufport_gen__0/tbufrow_gen__2/tbufhbusn_gen__1/inptbuf/inxdi
add wave -noupdate -format Logic -label tbuf_p0_r2_hbusn1/OexEI /tb_tstor/dut/compeng/tbufport_gen__0/tbufrow_gen__2/tbufhbusn_gen__1/inptbuf/oexei
add wave -noupdate -format Literal -label tbuf_p0_r2_hbusn1/OutxZO /tb_tstor/dut/compeng/tbufport_gen__0/tbufrow_gen__2/tbufhbusn_gen__1/inptbuf/outxzo
add wave -noupdate -divider {r2 p1 hbusn0}
add wave -noupdate -format Literal -label tbuf_p1_r2_hbusn0/InxDI /tb_tstor/dut/compeng/tbufport_gen__1/tbufrow_gen__2/tbufhbusn_gen__0/inptbuf/inxdi
add wave -noupdate -format Logic -label tbuf_p1_r2_hbusn0/OexEI /tb_tstor/dut/compeng/tbufport_gen__1/tbufrow_gen__2/tbufhbusn_gen__0/inptbuf/oexei
add wave -noupdate -format Literal -label tbuf_p1_r2_hbusn0/OutxZO /tb_tstor/dut/compeng/tbufport_gen__1/tbufrow_gen__2/tbufhbusn_gen__0/inptbuf/outxzo
add wave -noupdate -divider {r2 p0 hbusn0}
add wave -noupdate -format Literal -label tbuf_p0_r2_hbusn0/InxDI /tb_tstor/dut/compeng/tbufport_gen__0/tbufrow_gen__2/tbufhbusn_gen__0/inptbuf/inxdi
add wave -noupdate -format Logic -label tbuf_p0_r2_hbusn0/OeXEI /tb_tstor/dut/compeng/tbufport_gen__0/tbufrow_gen__2/tbufhbusn_gen__0/inptbuf/oexei
add wave -noupdate -format Literal -label tbuf_p0_r2_hbusn0/OutxZO /tb_tstor/dut/compeng/tbufport_gen__0/tbufrow_gen__2/tbufhbusn_gen__0/inptbuf/outxzo
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {33620 ns} 0}
configure wave -namecolwidth 255
configure wave -valuecolwidth 146
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
WaveRestoreZoom {32965 ns} {34240 ns}
