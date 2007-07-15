HOSTCC = gcc

SSCC = ssbig-na-sstrix-gcc
SSCFLAGS = -O0
SSCFLAGS_OPT = -O3
SSFIX = ../../cosim/fix_instructions.pl

TBNAME = tstfir8_virt
TBCFGNAME = $(TBNAME)_cfg.h


all: fir_noarray fir_noarray.ss fir_zippy.ss fir_zippy_imit.ss

fir_noarray: coefficients.h input.h fir_noarray.c
	$(HOSTCC) -o fir_noarray fir_noarray.c -lm

fir_noarray.ss: coefficients.h input.h fir_noarray.c
	$(SSCC) $(SSCFLAGS_OPT) -o fir_noarray.ss fir_noarray.c

fir_zippy.ss: $(TBCFGNAME) input.h fir_zippy.c $(SSFIX)
	$(SSCC) $(SSCFLAGS) -S fir_zippy.c
	$(SSFIX) fir_zippy.s fir_zippyf.s
	$(SSCC) $(SSCFLAGS) -o fir_zippy.ss fir_zippyf.s

fir_zippy_imit.ss: $(TBCFGNAME) input.h fir_zippy_imit.c $(SSFIX)
	$(SSCC) $(SSCFLAGS) -S fir_zippy_imit.c
	$(SSFIX) fir_zippy_imit.s fir_zippy_imitf.s
	$(SSCC) $(SSCFLAGS) -o fir_zippy_imit.ss fir_zippy_imitf.s

$(TBCFGNAME): ../../vhdl/tb_arch/$(TBNAME)/$(TBCFGNAME)
	cp ../../vhdl/tb_arch/$(TBNAME)/$(TBCFGNAME) .

clean:
	rm -f *.o *~
	rm -f fir_zippy.ss fir_zippyf.s fir_zippy.s
	rm -f fir_zippy_imit.ss fir_zippy_imitf.s fir_zippy_imit.s
	rm -f fir_noarray fir_noarray.ss
