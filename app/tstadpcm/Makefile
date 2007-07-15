# Makefile for adpcm and test programs
#
# $Id: Makefile 483 2006-03-22 08:04:36Z plessl $
# $URL$

include ../../make.defs

DEBUG = 0

### configurations for host compiler
CFLAGS = -O

SSCC = ssbig-na-sstrix-gcc
SSCFLAGS = -O0
SSCFLAGS_OPT = -O

SSFIX = ../../cosim/fix_instructions.pl

TARGET=tstadpcm

# This is really strange. 512 samples doesn't work while 513 samples
# work perfectly.

# Workaround: although it is not nice, we use 500 bytes, i.e. 1000
# samples
SAMPLES=500

ifeq ($(DEBUG),1)
  CFLAGS += -g
endif

CFLAGS += -Wall -pedantic

ALLTARGETS = adpcm2pcm hello.adpcm hello.wav 
ALLTARGETS += testfiles 
ALLTARGETS += $(TARGET)_zippy.ss $(TARGET)_zippy_noarray.ss 
ALLTARGETS += $(TARGET)_noarray
ALLTARGETS += $(TARGET)_zippy_noarray.opt.ss

TSTFILES = test.adpcm.h test.pcm.h

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


testfiles: adpcm2pcm
	$(HEAD) -c $(SAMPLES) hello.adpcm > test.adpcm
	./adpcm2pcm test.adpcm test.pcm
	./adpcm2txt test.adpcm > test.adpcm.txt
	./pcm2txt   test.pcm   > test.pcm.txt
	./adpcm2h   test.adpcm > test.adpcm.h
	./pcm2h     test.pcm   > test.pcm.h

adpcm.ss.o: adpcm.c adpcm.h
	$(SSCC) -c -o adpcm.ss.o adpcm.c

adpcm.opt.ss.o: adpcm.c adpcm.h
	$(SSCC) $(SSCFLAGS_OPT) -c -o $@ $<

$(TARGET)_zippy_noarray.ss: $(TARGET)_zippy_noarray.c $(TSTFILES) adpcm.ss.o
	$(SSCC) $(SSCFLAGS) -c -o $(TARGET)_zippy_noarray.ss.o $(TARGET)_zippy_noarray.c
	$(SSCC) -o $(TARGET)_zippy_noarray.ss adpcm.ss.o $(TARGET)_zippy_noarray.ss.o

$(TARGET)_zippy_noarray.opt.ss: $(TARGET)_zippy_noarray.c $(TSTFILES) adpcm.opt.ss.o
	$(SSCC) $(SSCFLAGS_OPT) -c -o $(TARGET)_zippy_noarray.opt.ss.o $(TARGET)_zippy_noarray.c
	$(SSCC) -o $(TARGET)_zippy_noarray.opt.ss adpcm.opt.ss.o $(TARGET)_zippy_noarray.opt.ss.o


#host
$(TARGET)_noarray: $(TARGET)_zippy_noarray.c $(TSTFILES) adpcm.o
	$(CC) $(CFLAGS) -c -o $(TARGET)_noarray.o $(TARGET)_zippy_noarray.c
	$(CC) $(CFLAGS) -o $(TARGET)_noarray adpcm.o $(TARGET)_noarray.o

$(TARGET)_zippy.ss: $(TARGET)_cfg.h $(TARGET)_zippy.c $(TSTFILES) $(SSFIX)
	$(SSCC) $(SSCFLAGS) -S $(TARGET)_zippy.c
	$(SSFIX) $(TARGET)_zippy.s $(TARGET)_zippyf.s
	$(SSCC) $(SSCFLAGS) -o $(TARGET)_zippy.ss $(TARGET)_zippyf.s

$(TARGET)_cfg.h: ../../vhdl/tb_arch/$(TARGET)/$(TARGET)_cfg.h
	#make -C ../../vhdl/tb_arch/$(TARGET) configuration
	cp ../../vhdl/tb_arch/$(TARGET)/$(TARGET)_cfg.h .

clean:
	rm -f *.o *~
	rm -f $(ALLTARGETS)
#	rm -f $(TARGET)_cfg.h
#	rm -f $(TARGET)_zippy.ss $(TARGET)_zippyf.s $(TARGET)_zippy.s
#	rm -f $(TARGET)_noarray $(TARGET)_noarray.o
#	rm -f $(TARGET)_noarray.ss
#	rm -f $(TARGET)_minimal

	rm -f adpcm.ss.o
	rm -f adpcm.o
	rm -f adpcm2pcm
	rm -f hello.wav hello.pcm
	rm -f test.pcm test.pcm.txt test.adpcm test.adpcm.txt
	rm -f test.pcm.h test.adpcm.h




