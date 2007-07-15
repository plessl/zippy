SUBDIRS = vhdl cosim simple app

include make.defs

all: $(SUBDIRS) ChangeLog

$(SUBDIRS):
	@echo "Making $@"
	$(MAKE) -C $@

ChangeLog:
	svn log -v -r HEAD:1 > ChangeLog

clean:
	rm -rf ~* transcript
	for dir in $(SUBDIRS); do \
		$(MAKE) -C $$dir clean; \
	done


.PHONY: all $(SUBDIRS) app cosim simple vhdl ChangeLog

cosim: simple vhdl
app: cosim
