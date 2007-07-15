onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Literal /tb_ioportctrl/ccount
add wave -noupdate -format Literal /tb_ioportctrl/tbstatus
add wave -noupdate -format Logic /tb_ioportctrl/clkxc
add wave -noupdate -format Logic /tb_ioportctrl/rstxrb
add wave -noupdate -format Literal /tb_ioportctrl/configxi
add wave -noupdate -format Literal -radix unsigned /tb_ioportctrl/cycledncntxdi
add wave -noupdate -format Literal -radix unsigned /tb_ioportctrl/cycleupcntxdi
add wave -noupdate -format Logic /tb_ioportctrl/portxeo
TreeUpdate [SetDefaultTree]
WaveRestoreZoom {0 ns} {1210 ns}
configure wave -namecolwidth 164
configure wave -valuecolwidth 54
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
