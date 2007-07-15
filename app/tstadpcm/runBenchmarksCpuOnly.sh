#!/bin/sh

ITER=250
SIMZIPPY=../../simple/sim-zippy
RESDIR=results

[ ! -d $RESDIR ] && mkdir $RESDIR

echo "===== check whether Makefile uses the correct number of samples ==="

###########################################################################
# ADPCM: No Array, CPU only (No Optimization -O0)
###########################################################################

SSAPP="tstadpcm_zippy_noarray.ss"

echo "===== simulation ADPCM: embedded CPU only (no optimization) ====="

SSCFG=../../simple/embedded.cfg
SSARCH=emb

$SIMZIPPY -config $SSCFG \
    -redir:sim  $RESDIR/adpcm_cpuonly_noopt.$SSARCH.$ITER.sim \
    -redir:prog $RESDIR/adpcm_cpuonly_noopt.$SSARCH.$ITER.prog \
    ./$SSAPP $ITER



echo "===== simulation ADPCM: default CPU only (no optimization)  ====="

SSCFG=../../simple/config/default.cfg
SSARCH=default

$SIMZIPPY -config $SSCFG \
    -redir:sim  $RESDIR/adpcm_cpuonly_noopt.$SSARCH.$ITER.sim \
    -redir:prog $RESDIR/adpcm_cpuonly_noopt.$SSARCH.$ITER.prog \
    ./$SSAPP $ITER


###########################################################################
# ADPCM: No Array, CPU only (Optimized -O)
###########################################################################

SSAPP="tstadpcm_zippy_noarray.opt.ss"

echo "===== simulation ADPCM: embedded CPU only (with optimization) ====="

SSCFG=../../simple/embedded.cfg
SSARCH=emb

$SIMZIPPY -config $SSCFG \
    -redir:sim  $RESDIR/adpcm_cpuonly_opt.$SSARCH.$ITER.sim \
    -redir:prog $RESDIR/adpcm_cpuonly_opt.$SSARCH.$ITER.prog \
    ./$SSAPP $ITER



echo "===== simulation ADPCM: default CPU only (with optimization) ====="

SSCFG=../../simple/config/default.cfg
SSARCH=default

$SIMZIPPY -config $SSCFG \
    -redir:sim  $RESDIR/adpcm_cpuonly_opt.$SSARCH.$ITER.sim \
    -redir:prog $RESDIR/adpcm_cpuonly_opt.$SSARCH.$ITER.prog \
    ./$SSAPP $ITER

