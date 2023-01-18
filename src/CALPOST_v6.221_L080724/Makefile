FC=gfortran
FCFLAGS=-O3
LDFLAGS=

-include ../config.vars

OBJECTS=calpost.o
EXE=$(BASEDIR)/exe/CALPOSTv6.221.EXE

all: $(OBJECTS)
	$(FC) $(LDFLAGS) $(OBJECTS) -o $(EXE)

%.o: %.for
	$(FC) $(FCFLAGS) $< -o $@

clean:
	rm -rf *.o *.mod *.exe *.EXE
