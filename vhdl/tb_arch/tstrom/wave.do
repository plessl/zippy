onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Literal /tb_tstrom/dut/cycleupcntxd
add wave -noupdate -format Literal /tb_tstrom/dut/cycledncntxd
add wave -noupdate -format Literal /tb_tstrom/cycle
add wave -noupdate -format Literal /tb_tstrom/tbstatus
add wave -noupdate -format Logic /tb_tstrom/clkxc
add wave -noupdate -format Logic /tb_tstrom/rstxrb
add wave -noupdate -format Logic /tb_tstrom/wexe
add wave -noupdate -format Logic /tb_tstrom/rexe
add wave -noupdate -format Literal /tb_tstrom/addrxd
add wave -noupdate -format Literal -radix decimal /tb_tstrom/datainxd
add wave -noupdate -format Literal -radix decimal /tb_tstrom/dataoutxd
add wave -noupdate -format Literal /tb_tstrom/cfg
add wave -noupdate -format Literal /tb_tstrom/cfgxd
add wave -noupdate -format Literal /tb_tstrom/cfgprt
add wave -noupdate -format Literal -radix decimal /tb_tstrom/dut/compeng/dummy
add wave -noupdate -format Literal -radix decimal /tb_tstrom/dut/compeng/hbusnxz
add wave -noupdate -format Literal -radix decimal /tb_tstrom/dut/compeng/hbussxz
add wave -noupdate -format Literal /tb_tstrom/dut/compeng/vbusexz
add wave -noupdate -format Literal -radix decimal /tb_tstrom/dut/compeng/rowromrdaddrxz
add wave -noupdate -format Literal -radix decimal /tb_tstrom/dut/compeng/rowromrddataxz
add wave -noupdate -format Literal -radix decimal /tb_tstrom/dut/fifo0/doutxdo
add wave -noupdate -format Literal -radix decimal /tb_tstrom/dut/fifo0/dinxdi
add wave -noupdate -format Literal -radix decimal /tb_tstrom/dut/fifo0fillxd
add wave -noupdate -format Logic /tb_tstrom/dut/fifo0wexe
add wave -noupdate -format Logic /tb_tstrom/dut/fifo0rexe
add wave -noupdate -format Literal -radix decimal /tb_tstrom/dut/fifo0/fmem/memblock
add wave -noupdate -color Magenta -format Literal -height 15 -itemcolor Magenta -label {ROM cell input (unregistered)} -radix decimal /tb_tstrom/dut/compeng/hbusnxz(2)(0)
add wave -noupdate -format Literal -height 15 -label {row2 ROM ReadAddress bus} -radix decimal /tb_tstrom/dut/compeng/rowromrdaddrxz(2)
add wave -noupdate -format Literal -height 15 -label {row2 ROM ReadData bus} -radix decimal /tb_tstrom/dut/compeng/rowromrddataxz(2)
add wave -noupdate -color {Slate Blue} -format Literal -height 15 -itemcolor {Slate Blue} -label {ROM cell output (registered)} -radix decimal /tb_tstrom/dut/compeng/hbusnxz(3)(1)
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {8155 ns} 0}
configure wave -namecolwidth 240
configure wave -valuecolwidth 128
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
WaveRestoreZoom {7507 ns} {8785 ns}
