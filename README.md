# CALPUFF

> GNU-Compilation of the CALPUFF modeling system + sample run.

*DISCLAMER:* The official source code of CALPUFF and it's pre/post-processors has been developed and is manteined by scientists at [Exponent, Inc](http://www.src.com). This repository is a tool to easily compile calpuff and run it on a UNIX environment using a GNU-compiler.

## Dependencies:
To build it:
+ ``gfortran``
+ ``make``
+ ``netcdf`` library (> 4.4.0) (OPTIONAL, needed only by CALWRF)

To run it:
+ ``python``
+ ``gdal``
+ ``awk``

---

## How to build it

Just enter to the ``src/`` directory:
```shell
cd src/
```
Edit the variables inside the ``Makefile`` file according to your environment, and then execute ``make``: 
```shell
make
```
If the compilation is succesfull, you should see the executables in the ``exe/`` directory.

### Build CALWRF
First please check you have NetCDF installed on your personal computer or cluster before.
```shell
which nc-config
```

If you want to use a locally installed NetCDF library, add the paths to the environment variables:
```shell
export PATH=$PATH:/path/to/your/netcdf/bin
export LD_LIBRARY_PATH=$PATH:/path/to/your/netcdf/lib
```

In order to build CALWRF execute the following command inside the ``src/`` directory:
```shell
make calwrf
```
The calwrf executable will be placed in the ``exe/`` directory if compilation was succesfull. 


## How to run it
Sample runs have been placed in the ``runs/`` folder, please read the ``readme.md`` inside it.

