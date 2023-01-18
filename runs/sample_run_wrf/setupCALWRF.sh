#!/bin/bash

source namelist

read ibyr ibmo ibdy ibhr ibmin ibsec <<< ${ini_date//[-:\/_ ]/ }
read ieyr iemo iedy iehr iemin iesec <<< ${end_date//[-:\/_ ]/ }

wrfoutFile=$1
calwrf_out=test.m3d

read ny nx <<<$( ncdump -h $wrfoutFile | sed -n 's/\;//;/west_east =/p;/south_north =/p;' | sort | awk '{gsub(/.*=/,"");printf $0}')

if [[ ! -f calwrf.exe ]];then
        ln -sf ${calwrf_exe} calwrf.exe
fi;

cat << EOF > calwrf.inp
Create 3D.DAT file from WRF output
calwrf.lst              		! Log file name
${calwrf_out}           		! Output file name
1,${nx},1,${ny},1,${nz} 		!-1,-1,-1,-1,-1,-1   ! Beg/End I/J/K ("-" for all)
${ibyr}${ibmo}${ibdy}${ibhr}            ! Start datetime (UTC yyyymmddhh, "-" for all)
${ieyr}${iemo}${iedy}${iehr}            ! End   datetime (UTC yyyymmddhh, "-" for all)
1                   			! Number of WRF output files
${wrfoutFile}       			! File name of wrf output (Loop over files
EOF

