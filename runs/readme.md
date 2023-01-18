# Run CALPUFF sample run:

> Intructions to execute sample run.

---

Go to the ``sample_run`` directory:
```shell 
cd sample_run
```

### Input data
In order to run calpuff you will need the following data files:
+ Source emision parameters.
+ Digital elevation model (DEM).
+ Surface meteorology.
+ Upperair sounding.
+ Main buildings near the source (optional).

Check you have all the data needed before start:

```shell
tree data
data/
├── buildings
│   └── sample_buildings.csv
├── dem
│   └── sample_dem.tif
├── emis
│   └── sample_emis.csv
├── sfc
│   └── 875930-99999-2019
└── up
    └── raob_soundings27537.tmp

```

### Namelist
Inside the ``sample_run`` directory you should see a ``namelist`` file that contains all the variables needed to set for your specific run. Open it and set them all according with your run:


### Emision data:

```shell
./makeEMIS.sh 
```

the ``emis.dat`` should be created.

### Elevation and cover data:
```shell
./makeGEO.sh  
```
the ``geo.dat`` files should be created.

### Surface Meteorology:
```shell
./makeSFC.sh 
```
``precip.dat`` and ``surf.dat`` files  should be created.

### Upperair soundings:
```shell
./makeUP.sh  
```
the ``up.dat`` should be created.

### CALMET:

First we should create the ``calmet.inp`` control file with the configuration specified in the ``namelist`` file, to do so execute:

```shell
./setupCALMET.sh 
```

the ``calmet.inp`` file should be created. Check this file and then run the calmet binary:

```shell 
./calmet.exe
```
If the run fails, check the ``calmet.lst`` file to find the error.

### CALPUFF:

To create the ``calpuff.inp`` control file execute:
```shell 
./setupCALPUFF.sh
```

the ``calpuff.inp`` file should be created. Check this file and run the calpuff binary then:

```shell 
./calpuff.exe
```
if the run fails, check the ``calpuff.lst`` file to find the error.

### CALPOST:
Same as before, execute:

```shell 
./setupCALPOST.sh 
```
the ``calpost.inp`` file should be created. Check this file and run the calpost binary:

```shell 
./calpost.exe
```

if the run fails, check the ``calpost.lst`` file to find the error.

You should see ``*.dat`` and ``*.grd`` files inside the out tree directory.
