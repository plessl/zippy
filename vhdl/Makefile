include ../make.defs

TBARCHDIRS = tb_arch/tstor tb_arch/tstbitat0

#VHDL = $(shell ls *.vhd)

all:	tb_arch

#vhdl:
#	test -d work || vlib work
#	$(MAKE) "VCOM=$(VCOM) -lint -quiet" -f Makefile.vhdl
#	$(MAKE) "VCOM=$(VCOM) -pedanticerrors -quiet" -f Makefile.vhdl

tb_arch:
	$(MAKE) -C tb_arch	

vmake:
	$(VMAKE) > Makefile.vhdl
	perl -pi -e 's/(-quiet\s*)+/-quiet /' Makefile.vhdl

clean:
	rm -rf work
	rm -f *~ *.bak transcript *.wlf
	rm -f vsim_stacktrace.vstf
	$(MAKE) -C tb_arch clean

.PHONY:	tb_arch vmake
