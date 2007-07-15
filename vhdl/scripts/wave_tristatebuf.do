onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Literal /tb_tristatebuf/ccount
add wave -noupdate -format Literal /tb_tristatebuf/tbstatus
add wave -noupdate -format Logic /tb_tristatebuf/clkxc
add wave -noupdate -format Logic /tb_tristatebuf/rstxrb
add wave -noupdate -format Literal -radix decimal /tb_tristatebuf/inxd
add wave -noupdate -format Logic /tb_tristatebuf/oexe
add wave -noupdate -format Literal -radix decimal /tb_tristatebuf/outxz
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {385 ns}
WaveRestoreZoom {0 ns} {1184 ns}
configure wave -namecolwidth 130
configure wave -valuecolwidth 49
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
