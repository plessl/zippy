HOSTCC = gcc

SSCC = ssbig-na-sstrix-gcc
SSCFLAGS = -O0
SSCFLAGS_OPT = -O3
SSFIX = ../../cosim/fix_instructions.pl

TARGET=tstor

all: $(TARGET)_zippy.ss

# host version running on workstation
#$(TARGET)_noarray: $(TARGET)_noarray.c input.h
#	$(HOSTCC) -o $(TARGET)_noarray $(TARGET)_noarray.c -lm

$(TARGET)_zippy.ss: $(TARGET)_cfg.h $(TARGET)_zippy.c $(SSFIX)
	$(SSCC) $(SSCFLAGS) -S $(TARGET)_zippy.c
	$(SSFIX) $(TARGET)_zippy.s $(TARGET)_zippyf.s
	$(SSCC) $(SSCFLAGS) -o $(TARGET)_zippy.ss $(TARGET)_zippyf.s

$(TARGET)_cfg.h: ../../vhdl/tb_arch/$(TARGET)/$(TARGET)_cfg.h
	cp ../../vhdl/tb_arch/$(TARGET)/$(TARGET)_cfg.h .

clean:
	rm -f *.o *~
	rm -f $(TARGET)_cfg.h
	rm -f $(TARGET)_zippy.ss $(TARGET)_zippyf.s $(TARGET)_zippy.s
#	rm -f $(TARGET)_noarray
