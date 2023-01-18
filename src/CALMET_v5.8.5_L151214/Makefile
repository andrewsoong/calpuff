FC=gfortran
FCFLAGS=-c -O3
LDFLAGS=

-include ../config.vars
OBJECTS=calmet.o
EXE=$(BASEDIR)/exe/CALMETv5.8.5.EXE

all: $(OBJECTS)
	$(FC) $(LDFLAGS) $(OBJECTS) -o $(EXE)

%.o: %.for
	$(FC) $(FCFLAGS) $< -o $@

clean:
	rm -rf *.o *.mod *.exe *.EXE
