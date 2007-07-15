# $URL$
# $Id: Makefile 240 2005-04-07 08:37:45Z plessl $

SUBDIRS = tstadpcm tstadpcm_virt tstadpcm_virt_tpsched
SUBDIRS += tstbitat0 tstfir4 tstfir8_virt tstmux 
SUBDIRS += tstor tstpass_virt tstrom

all:
	for dir in $(SUBDIRS); do \
		$(MAKE) -C $$dir; \
	done


vhdl:
	for dir in $(SUBDIRS); do \
		$(MAKE) -C $$dir vhdl; \
	done


configuration:
	for dir in $(SUBDIRS); do \
		$(MAKE) -C $$dir configuration; \
	done

tests:
	for dir in $(SUBDIRS); do \
		cd $$dir; sh runTestbench.sh; cd ..; \
	done


clean:
	for dir in $(SUBDIRS); do \
		$(MAKE) -C $$dir clean; \
	done
	rm -f *~

.PHONY: all configuration
