#!/bin/sh

WORKLIB="work"

TBDIR=`pwd`
TBNAME=`basename $TBDIR`
TESTBENCH=tb_$TBNAME

echo "simulating testench $TESTBENCH"

#vsim "-lib $WORKLIB $TESTBENCH"
vsim -lib $WORKLIB $TESTBENCH
