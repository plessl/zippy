#!/bin/sh

ITER=250
SIMZIPPY=../../simple/sim-zippy
RESDIR=results

[ ! -d $RESDIR ] && mkdir $RESDIR

echo "===== check whether Makefile uses the correct number of samples ==="

###########################################################################
# ADPCM: Large Array, Single Context
###########################################################################

TBARCH=tstadpcm
SSAPP=tstadpcm_zippy.ss



echo "===== simulation ADPCM: large array, single context embedded CPU  ====="
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


echo "===== simulation ADPCM: large array, single context default CPU  ====="
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


