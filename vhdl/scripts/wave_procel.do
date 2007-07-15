onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Literal /tb_procel/ccount
add wave -noupdate -format Literal /tb_procel/tbstatus
add wave -noupdate -format Logic /tb_procel/clkxc
add wave -noupdate -format Logic /tb_procel/rstxrb
add wave -noupdate -format Literal -expand /tb_procel/cfg
add wave -noupdate -format Literal -radix decimal /tb_procel/in0xd
add wave -noupdate -format Literal -radix decimal /tb_procel/in1xd
add wave -noupdate -format Literal -radix decimal /tb_procel/outxd
add wave -noupdate -format Literal -radix unsigned /tb_procel/multuxd
add wave -noupdate -format Literal -radix decimal /tb_procel/multsxd
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {2858 ns}
WaveRestoreZoom {6520 ns} {7558 ns}
configure wave -namecolwidth 125
configure wave -valuecolwidth 82
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
