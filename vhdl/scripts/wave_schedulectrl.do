onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Literal /tb_schedulectrl/ccount
add wave -noupdate -format Literal /tb_schedulectrl/tbstatus
add wave -noupdate -format Logic /tb_schedulectrl/clkxc
add wave -noupdate -format Logic /tb_schedulectrl/rstxrb
add wave -noupdate -format Logic /tb_schedulectrl/startxei
add wave -noupdate -format Logic /tb_schedulectrl/runningxsi
add wave -noupdate -format Logic /tb_schedulectrl/lastxsi
add wave -noupdate -format Logic /tb_schedulectrl/switchxeo
add wave -noupdate -format Logic /tb_schedulectrl/busyxso
add wave -noupdate -format Literal /tb_schedulectrl/dut/currstate
add wave -noupdate -format Literal /tb_schedulectrl/dut/nextstate
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {0 ns}
WaveRestoreZoom {0 ns} {1156 ns}
configure wave -namecolwidth 122
configure wave -valuecolwidth 65
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
