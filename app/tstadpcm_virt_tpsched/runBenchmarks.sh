#!/bin/sh

echo "===== check whether Makefile uses the correct number of samples ==="

ITER=250
SIMZIPPY=../../simple/sim-zippy
RESDIR=results
TBARCH=tstadpcm_virt_tpsched
SSAPP="$TBARCH.ss"

[ ! -d $RESDIR ] && mkdir $RESDIR

echo "===== simulation ADPCM: temporal partitioning, 3 contexts, embedded CPU  ====="
cd ../../cosim
./runsim.sh $TBARCH &
sleep 30
cd ../app/$TBARCH

SSCFG=../../simple/embedded.cfg
SSARCH=emb

$SIMZIPPY -enable_zippy -config $SSCFG \
    -redir:sim  $RESDIR/$TBARCH.$SSARCH.$ITER.sim \
    -redir:prog $RESDIR/$TBARCH.$SSARCH.$ITER.prog \
    ./$SSAPP $ITER


echo "===== simulation ADPCM: temporal partitioning, 3 contexts, highend CPU  ====="
cd ../../cosim
./runsim.sh $TBARCH &
sleep 30
cd ../app/$TBARCH

SSCFG=../../simple/config/default.cfg
SSARCH=default

$SIMZIPPY -enable_zippy -config $SSCFG \
    -redir:sim  $RESDIR/$TBARCH.$SSARCH.$ITER.sim \
    -redir:prog $RESDIR/$TBARCH.$SSARCH.$ITER.prog \
    ./$SSAPP $ITER
