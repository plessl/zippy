onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Literal /tb_configpkg/ccount
add wave -noupdate -format Literal /tb_configpkg/tbstatus
add wave -noupdate -format Logic /tb_configpkg/clkxc
add wave -noupdate -format Literal /tb_configpkg/proccfg
add wave -noupdate -format Literal /tb_configpkg/proccfgxd
add wave -noupdate -format Literal /tb_configpkg/proccfgbck
add wave -noupdate -format Literal /tb_configpkg/routcfg
add wave -noupdate -format Literal /tb_configpkg/routcfgxd
add wave -noupdate -format Literal /tb_configpkg/routcfgbck
add wave -noupdate -format Literal /tb_configpkg/cellcfg
add wave -noupdate -format Literal /tb_configpkg/cellcfgxd
add wave -noupdate -format Literal /tb_configpkg/cellcfgbck
add wave -noupdate -format Literal /tb_configpkg/rowcfg
add wave -noupdate -format Literal /tb_configpkg/rowcfgxd
add wave -noupdate -format Literal /tb_configpkg/rowcfgbck
add wave -noupdate -format Literal /tb_configpkg/gridcfg
add wave -noupdate -format Literal /tb_configpkg/gridcfgxd
add wave -noupdate -format Literal /tb_configpkg/gridcfgbck
add wave -noupdate -format Literal /tb_configpkg/ioportcfg
add wave -noupdate -format Literal /tb_configpkg/ioportcfgxd
add wave -noupdate -format Literal /tb_configpkg/ioportcfgbck
add wave -noupdate -format Literal /tb_configpkg/engncfg
add wave -noupdate -format Literal /tb_configpkg/engncfgxd
add wave -noupdate -format Literal /tb_configpkg/engncfgbck
add wave -noupdate -format Literal /tb_configpkg/engncfgarr
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {91 ns}
WaveRestoreZoom {0 ns} {464 ns}
configure wave -namecolwidth 133
configure wave -valuecolwidth 117
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
