#!/bin/sh

if [ ! -n "$1" ] ;
then
    echo "argument expected: $0 name_of_testbench";
    exit;
fi

TBARCH=$1
VSIM=vsim-6.0a-ma
WORKLIB=../vhdl/tb_arch/$TBARCH/work

if [ ! -d "$WORKLIB" ] ;
then
    echo "$0: not a vallid modelsim work library at $WORKLIB";
    exit;
fi


echo "starting cosimulation for architecture $TBARCH"

nice $VSIM -c -lib ../vhdl/tb_arch/$TBARCH/work verification -do 'run -all; quit;' &

