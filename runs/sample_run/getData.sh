#!/bin/bash

source namelist

read byr bmo bdy ibhr ibmin ibsec <<< ${ini_date//[-:\/_ ]/ }
read eyr emo edy iehr iemin iesec <<< ${end_date//[-:\/_ ]/ }

## SFC:
echo "Descargando ISHs ..."
for year in $(seq $byr $eyr);
do
       wget ftp://ftp.ncdc.noaa.gov/pub/data/noaa/${year}/${id_sfc}0-99999-${year}.gz -P data/sfc/.
done
gzip -d data/sfc/${id_sfc}*.gz

## UP:
echo "Descargando FSL ..."

curl -L "https://ruc.noaa.gov/raobs/GetRaobs.cgi?shour=0z%2C+12z+ONLY&ltype=Mandatory&wunits=Tenths+of+Meters%2FSecond&bdate=${byr}${bmo}${bdy}00&edate=${eyr}${emo}${edy}23&access=WMO+Station+Identifier&view=NO&StationIDs=${id_up}&osort=Station+Series+Sort&oformat=FSL+format+%28ASCII+text%29" -o data/up/raob_${id_up}_${byr}${bmo}${bdy}_${eyr}${emo}${edy}.tmp

