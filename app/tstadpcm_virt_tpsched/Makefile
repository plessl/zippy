# Makefile for adpcm and test programs
#
# $Id: Makefile 483 2006-03-22 08:04:36Z plessl $
# $URL$

include ../../make.defs

DEBUG = 0

### configurations for host compiler
CFLAGS = -O

SSCC = ssbig-na-sstrix-gcc
#SSCFLAGS = -O
SSCFLAGS = -O0

SSFIX = ../../cosim/fix_instructions.pl

TARGET=tstadpcm_virt_tpsched

# in bytes. the number of samples is actually twice this size
SAMPLES=500

ifeq ($(DEBUG),1)
  CFLAGS += -g
endif

CFLAGS += -Wall -pedantic

ALLTARGETS = adpcm2pcm hello.adpcm hello.wav 
ALLTARGETS += testfiles 
ALLTARGETS += $(TARGET)_zippy.ss

.PHONY:	testfiles

all: $(ALLTARGETS)


adpcm.o: adpcm.c adpcm.h
	$(CC) $(CFLAGS) -c -o $@ $<

adpcm2pcm: adpcm.o adpcm2pcm.o
	$(CC) $(CFLAGS) adpcm.o adpcm2pcm.o -o adpcm2pcm

hello.adpcm: helloadp.uu
	uudecode helloadp.uu

#pcm2adpcm: adpcm.o pcm2adpcm.o
#	$(CC) $(CFLAGS) adpcm.o pcm2adpcm.o -o pcm2adpcm

# -t raw (no headers, raw data)
# -s       signed data (2's complement)
# -w       word-sized (16bit) data
# -c 1     mono (1 channel)
# -r 8000 sampling rate 8kHz

###%.adpcm: %.pcm
#	./pcm2adpcm $< $@

%.pcm: %.adpcm
	./adpcm2pcm $< $@

%.wav: %.pcm
	$(SOX) -t raw -s -w -c 1 -r 8000 $< $@

testfiles: adpcm2pcm hello.adpcm
	$(HEAD) -c $(SAMPLES) hello.adpcm > test.adpcm
	./adpcm2pcm test.adpcm test.pcm
	./adpcm2txt test.adpcm > test.adpcm.txt
	./pcm2txt   test.pcm   > test.pcm.txt
	./adpcm2h   test.adpcm > test.adpcm.h
	./pcm2h     test.pcm   > test.pcm.h

$(TARGET)_zippy.ss: $(TARGET)_cfg.h $(TARGET).c test.adpcm.h test.pcm.h $(SSFIX)
	$(SSCC) $(SSCFLAGS) -S $(TARGET).c
	$(SSFIX) $(TARGET).s $(TARGET)_f.s
	$(SSCC) $(SSCFLAGS) -o $(TARGET).ss $(TARGET)_f.s

$(TARGET)_cfg.h: ../../vhdl/tb_arch/$(TARGET)/$(TARGET)_cfg.h
	$(MAKE) -C ../../vhdl/tb_arch/$(TARGET) configuration
	cp ../../vhdl/tb_arch/$(TARGET)/$(TARGET)_cfg.h .

clean:
	rm -f *.o *~
	rm -f $(ALLTARGETS)
	rm -f $(TARGET)_f.s $(TARGET).s $(TARGET).ss
#	rm -f $(TARGET)_cfg.h
	rm -f adpcm.ss.o
	rm -f adpcm.o
	rm -f adpcm2pcm
	rm -f hello.wav hello.pcm
	rm -f test.pcm test.pcm.txt test.adpcm test.adpcm.txt
	rm -f test.pcm.h test.adpcm.h




