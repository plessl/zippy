#!/bin/sh

RDIR=Results

./zroute -v -netlist Benchmarks/ZNF/fir2.znf \
         -architecture Benchmarks/Architectures/4x4_small.arch \
         -out "$RDIR/fir2.out" \
         -vhdlout "$RDIR/fir2.vhdl" | tee "$RDIR/fir2.log"


