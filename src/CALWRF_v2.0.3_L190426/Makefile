FC=gfortran
FCFLAGS=-c -O2 -static -fcheck=all -Wall -Wextra -Wconversion # -pedantic #-std=legacy -mtune=native -fbacktrace -fcheck=bounds #-mtune=native#-fcheck=bounds

#original:
#gfortran -I$DIR/lib/netcdf/include calwrf.f -L$DIR/lib/netcdf/lib -lnetcdf -lnetcdff -o $DIR/exe/CALWRFv2.0.3.EXE

include ../config.vars

OBJECTS=calwrf.o
EXE=$(BASEDIR)/exe/CALWRFv2.0.3.EXE

all: $(OBJECTS)
	$(FC) $(NC_INC) $(OBJECTS) $(NC_LIBS) -o $(EXE)

%.o: %.f
	$(FC) $(FCFLAGS) $(NC_INC) $< -o $@

clean:
	rm -rf *.o *.mod *.exe *.EXE
