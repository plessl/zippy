# $<  name of first prerequesite
# $@  file name of the target of the rule

DATE  = $(shell date +%Y-%m-%d-%H%M)
NAME = ztools
SOURCES = $(shell find . -name '*.pm' -print)
SOURCES += zroute

all:
	@echo "done"

doc:	ztools.pdf

test:
	@echo "sources= $(SOURCES)"
	@ls -l $(SOURCES)
	@echo "pid= $(PID)"

ztools.ps: $(SOURCES)
	@echo "making documentation"
	a2ps -o ztools.ps -2 -L100 -E $(SOURCES)


backup:
	@echo "exporting unversioned copy of repository"
	svn export . /tmp/ztools
	tar -C /tmp -cvjf  ../$(NAME)-$(DATE).tbz2 ztools
	rm -rf /tmp/ztools

codesize:
	 @echo "current codesize"
	 wc -l $(SOURCES)

changelog:
	@echo "generating ChangeLog"
	svn -r HEAD:1 -v log >| ChangeLog

.PHONY : doc clean backup codesize changelog


%.pdf : %.ps
	ps2pdf -sPAPERSIZE=a4 $<

clean:
	find . -name '*~' | xargs rm -f
