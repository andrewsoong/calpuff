#-------------------------------------------------------------------------
#Set variable values bellow according to your environment:
BASEDIR=`dirname ${PWD}`
FC=gfortran
#-------------------------------------------------------------------------
#Compiler and library flags:
FCFLAGS=-c -O2 -static -std=legacy -mtune=native -fbacktrace -fcheck=bounds
LDFLAGS=
#-------------------------------------------------------------------------
#NetCDF flags (needed only by CALWRF)  
NC_INC="`nc-config --fflags`"
NC_LIB="`nc-config --flibs`"
#-------------------------------------------------------------------------

all:
	$(info **** CONFIGURACION    ****)
	$(MAKE) config
	$(info )
	$(info **** COMPILAR CALPUFF ****)
	$(MAKE) read_62
	$(MAKE) calmet
	$(MAKE) calpuff
	$(MAKE) calpost
	$(info )

config:
	$(info Guardando variables en config.vars:)
	echo "BASEDIR=$(BASEDIR)" >  config.vars
	echo "FC=$(FC)"           >> config.vars
	echo "FCFLAGS=$(FCFLAGS)" >> config.vars
	echo "LDFLAGS=$(LDFLAGS)" >> config.vars
	echo "NC_INC=$(NC_INC)" >> config.vars
	echo "NC_LIBS=$(NC_LIB)" >> config.vars
read_62:
	$(info -------------------- )
	$(info Compilando read62..  )
	$(info                      )
	cd read62 && make
calmet:
	$(info -------------------- )
	$(info Compilando CALMET..  )
	$(info                      )
	cd CALMET_v5.8.5_L151214 && $(MAKE)
calpuff: 
	$(info -------------------- )
	$(info Compilando CALPUFF.. )
	$(info                      )
	cd CALPUFF_v5.8.5_L151214 && $(MAKE)
calpost:
	$(info -------------------- )
	$(info Compilando CALPOST.. )
	$(info                      )
	cd CALPOST_v6.221_L080724 && $(MAKE)
calwrf:
	$(info -------------------- )
	$(info Compilando CALWRF..                 )
	$(info * Please check NetCDF is installed! )
	$(info    $> nc-config --verson            )
	$(info                                     )
	$(MAKE) config
	$(info                      )
	cd CALWRF_v2.0.3_L190426 && $(MAKE)

read62-clean:
	cd read62 && $(MAKE) clean
calmet-clean:
	cd CALMET_v5.8.5_L151214 && $(MAKE) clean
calpuff-clean: 
	cd CALPUFF_v5.8.5_L151214 && $(MAKE) clean
calpost-clean:
	cd CALPOST_v6.221_L080724 && $(MAKE) clean
calwrf-clean:
	cd CALWRF_v2.0.3_L190426 && $(MAKE) clean

clean:
	$(MAKE) read62-clean
	$(MAKE) calmet-clean
	$(MAKE) calpuff-clean
	$(MAKE) calpost-clean
	$(MAKE) calwrf-clean

