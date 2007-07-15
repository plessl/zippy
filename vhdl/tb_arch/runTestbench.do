set NumericStdNoWarnings 1
run 0ns
set NumericStdNoWarnings 0
when { /tbStatus == done } {
   echo "OK=OK=OK=OK=OK=OK=OK=OK=OK=OK=OK=OK=OK=OK=OK=OK"
   echo "Testbench successfully terminated at time $now"
   echo "OK=OK=OK=OK=OK=OK=OK=OK=OK=OK=OK=OK=OK=OK=OK=OK"
   quit -f
}
run -all
quit
