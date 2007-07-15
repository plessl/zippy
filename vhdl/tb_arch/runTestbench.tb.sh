#!/bin/sh

# $Id: runTestbench.sh 136 2004-10-26 12:50:34Z plessl $
# $URL$

WORKLIB="work"
TBDIR=`pwd`
TBNAME=`basename $TBDIR`
TESTBENCH=tb_$TBNAME

echo "simulating testench $TESTBENCH"

vsim -quiet -lib $WORKLIB $TESTBENCH -c -do ../runTestbench.do
