#!/bin/bash
#---------------------------------
source namelist
source global_vars
#---------------------------------

#Preparacion de GEO.DAT
#Extraigo de wrfout variables:
#gdal_translate -a_srs epsg:${epsg_local} NETCDF:"${calwrf_inp_file}":HGT test_dem_utm.tif
#gdal_translate NETCDF:"${calwrf_inp_file}":HGT test_dem_lcc.tif
#gdal_translate NETCDF:"${calwrf_inp_file}":CLAT test_lat_lcc.tif
#gdal_translate NETCDF:"${calwrf_inp_file}":CLON test_lon_lcc.tif
#gdalwarp -s_srs epsg:${epsg_latlon} -t_srs "${proj4}" test_dem_lcc.tif test_dem_latlon.tif
#gdal_translate -a_srs epsg:${epsg_local} NETCDF:"${calwrf_inp_file}":LU_INDEX test_lu_utm.tif
#gdal_translate -a_srs epsg:${epsg_local} NETCDF:"${calwrf_inp_file}":LAI test_lai_utm.tif
#gdal_translate -a_srs epsg:${epsg_local} NETCDF:"${calwrf_inp_file}":ALBEDO test_a0_utm.tif

datenin="${ibyr}-${ibmo}-${ibdy}" # no se que es
#====================================================
#ESCRIBIR GEO.DAT
echo -e "Escribiendo\e[32m ${geo_out_file} \e[0m..."
#·----------
#HEADER:
printf '%s\n' "GEO.DAT" > ${geo_out_file}
printf '%.0f\n%-30s\n' 1 "Produced by Ramiro A. Espada from GAUSS-ma" >> ${geo_out_file} #numero de lineas comentadas posteriores a esta.
if [ $pmap == "UTM" ]
then
	printf '%s\n' "${pmap}" >>${geo_out_file}
	printf '%.0f,%s\n' $utmzn $utmhem >>${geo_out_file}
	printf '%8s %12s\n' $datum $datenin >>${geo_out_file}
	printf '%.0f, %.0f, %.3f, %.3f, %.3f, %.3f\n' $nx $ny $xorigkm $yorigkm $dgridkm $dgridkm  >> ${geo_out_file}
	printf '%-4s\n' $xyunit >> ${geo_out_file}
fi;
if [ $pmap == "LCC" ]
then
	#xorigkm yorigkm dgridkm nx ny nz
	printf '%s\n' "$pmap" >>${geo_out_file}
	printf '%12s%s, %12s%s, %12s%s, %12s%s\n' ${rlat0} S ${rlon0} W ${xlat1} S ${xlat2} S >>${geo_out_file}
	printf '%5.2f %5.2f\n' ${feast} ${fnorth} >>${geo_out_file}
	printf '%5s %12s\n' $datum $datenin >>${geo_out_file}
	printf '%.0f, %.0f, %.3f, %.3f, %.3f, %.3f\n' $nx $ny $xorigkm $yorigkm $dgridkm $dgridkm  >> ${geo_out_file}
	printf '%-4s\n' $xyunit >> ${geo_out_file}
fi;
#·----------
#LAND USE:
echo -e "          -\e[33m Land Use\e[0m."
LU_i=10
echo "0                 -  LAND USE DATA  - IOPT1:  0=DEFAULT CATEGORIES  1=NEW CATEGORIES">> ${geo_out_file}

#ncdump -v LU_INDEX ${calwrf_inp_file} | sed -e '1,/data:/d' -e '$d' | sed 's/[,;]//g;s/  //g' >> ${geo_out_file}
#ncdump -p 3 -l 1000 -v LU_INDEX ${calwrf_inp_file} | sed -e '1,/data:/d' -e '$d' | sed 's/[\t;\,]//g;s/^ *//g' | head -n 31 | tail -n +3 >> ${geo_out_file}
#
for i in $(seq 1 $nx)
do
        for j in $(seq 1 $ny)
        do
                printf '%4.0f' ${LU_i} >>${geo_out_file}
        done;
        printf '\n' >> ${geo_out_file} #breakline
done;

#·----------
#ELEVATION:
echo -e "          -\e[33m Elevation\e[0m."
echo "1.0 	 	-  TERRAIN HEIGHTS - HTFAC (factor de conversion a metros)">>${geo_out_file}
i=0

#ncdump -v HGT ${calwrf_inp_file} | sed -e '1,/data:/d' -e '$d' | sed 's/[,;]//g;s/  //g' >> ${geo_out_file}
#ncdump -l 1000 -v HGT ${calwrf_inp_file} | sed -e '1,/data:/d' -e '$d' | sed 's/[\t;\,]//g;s/^ *//g' >> ${geo_out_file}
#ncdump -p 4 -l 1000 -v HGT ${calwrf_inp_file} | sed -e '1,/data:/d' -e '$d' | sed 's/[\t;\,]//g;s/^ *//g' | head -n 31 | tail -n +3 >> ${geo_out_file}
#
for i in $(seq 1 $nx)
do
        for j in $(seq 1 $ny)
        do
                printf '%4.0f' 0.0 >>${geo_out_file}
        done;
        printf '\n' >> ${geo_out_file} #breakline
done;

#·----------
#SURFACE DESCRIPTORS:
echo -e "          -\e[33m Surface descriptors\e[0m."
cat << EOF >> ${geo_out_file}
0 - IOPT2 (z0)	-- (0=default z0-lu table,    1=new z0-lu table,    2=gridded)
0 - IOPT3 (alb) -- (0=default albedo-lu table,1=new albedo-lu table,2=gridded)
0 - IOPT4 (Bo) 	-- (0=default Bowen-lu table, 1=new Bowen-lu table, 2=gridded)
0 - IOPT5 (HCG) -- (0=default HCG-lu table,   1=new HCG-lu table,   2=gridded)
0 - IOPT6 (QF) 	-- (0=default QF-lu table,    1=new QF-lu table,    2=gridded)
0 - IOPT7 (LAI) -- (0=default XLAI-lu table,  1=new XLAI-lu table,  2=gridded)
EOF
	## CALMET LAND USE CATEOGORIES TABLE:
	#	typ	Description			z0	albedo	Bo   	HCG   	QF	LAI
	#	10    Urban or Built-up Land 		1.0 	0.18 	1.5 	.25 	0.0 	0.2
	#	20    Agricultural Land - Unirrigated 	0.25 	0.15 	1.0 	.15 	0.0 	3.0
	#	-20   Agricultural Land - Irrigated 	0.25 	0.15 	0.5 	.15 	0.0	3.0
	#	30    Rangeland 			0.05 	0.25 	1.0 	.15 	0.0	0.5
	#	40    Forest Land 			1.0 	0.10 	1.0 	.15 	0.0	7.0
	#	51    Small Water Body 			0.001 	0.10 	0.0 	1.0 	0.0	0.0
	#	54    Bays and Estuaries 		0.001 	0.10 	0.0 	1.0 	0.0	0.0
	#	55    Large Water Body 			0.001 	0.10 	0.0 	1.0 	0.0	0.0
	#	60    Wetland 				1.0 	0.10 	0.5 	.25 	0.0	2.0
	#	61    Forested Wetland 			1.0 	0.1 	0.5 	0.25 	0.0	2.0
	#	62    Nonforested Wetland 		0.2 	0.1 	0.1 	0.25 	0.0	1.0
	#	70    Barren Land 			0.05 	0.30 	1.0 	.15 	0.0	0.05
	#	80    Tundra 				0.20 	0.30 	0.5 	.15 	0.0	0.0
	#	90    Perennial Snow or Ice 		0.20 	0.70 	0.5 	.15 	0.0	0.0
	#
	#	*  (-) negative values means irrigated
	#	** z0=roughness length;Bo=bowens ratio; HCG:soil heat flux; QF: anthropo heat flux;
#·----------
#FIN.
#====================================================
echo -e "A Mejorar:"
echo -e "  [ ] Extraer dimensiones de variables desde el wrfout."

