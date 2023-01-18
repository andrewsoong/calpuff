FC=gfortran
FCFLAGS=-c -O3
LDFLAGS=

-include ../config.vars
OBJECTS=read62.o
EXE=$(BASEDIR)/exe/READ62.EXE

all: $(OBJECTS)
	$(FC) $(LDFLAGS) $(OBJECTS) -o $(EXE)

%.o: %.for
	$(FC) $(FCFLAGS) $< -o $@

clean:
	rm -rf *.o *.mod *.exe *.EXE
