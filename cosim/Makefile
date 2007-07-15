include ../make.defs

LDFLAGS		= -lrt
CC		= cc-7.0

WORKLIB		= ../vhdl/work

VHDL = $(shell ls ../vhdl/*.vhd)

all:	server.so
	@echo "done"


## modelsim runs in 32bit mode, even on our 64bit machines, since 32bit
## version is ironically faster. If 64bit mode is used a 64bit version 
## of the server.so library is needed.
#	${CC} -xarch=v9 -c -I${MTI_HOME}/include server.c

server.so:	comm.h server.c
	${CC} -c -I${MTI_HOME}/include server.c
	ld ${LDFLAGS} -G -B dynamic -o server.so server.o

clean :
	rm -rf *~ *.o *.sl *.so work transcript server.so *.wlf
	rm -rf .simulation
	rm -rf modelsim.ini modelsim.tcl
