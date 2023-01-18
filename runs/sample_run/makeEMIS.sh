#!/bin/bash
source namelist 
source parseNamelist

if [ -f emis.dat ]
then
	rm emis.dat
fi

# #v1.0
# #SOLO FUENTES PUNTALES (POR EL MOMENTO)
# 
# if [ -f ${inp_emis} ]; then
# for (( i=0; i<${#polluts[@]}; i++ ))
# do
# POLLUTID=${polluts[i]}
# 
# #${inp_emis}: POLLUTID; ID; TYPE; WKT;  Z;   Q;   H; T; U; D            (POINT|POINTHOR)
# #             POLLUTID; ID; TYPE; WKT;  Z;   Q;   H; *nvert; *szinit    (AREAPOLY)
# #             POLLUTID; ID; TYPE; WKT;  Z;   Q;   H; W                  (LINE)
# #             POLLUTID; ID; TYPE; WKT;  Z;   Q;   H; sy;sz              (VOLUME)
#  tail -n +2 ${inp_emis} | awk -F "[;]" -v i=${i} -v inpemis=${POLLUTID} '
# $1==inpemis {name=$2;srctype=$3;gsub("[A-Z()]","",$4);N=split($4,coordsArr,",");Z=$5;Q=$6;H=$7;
# if (srctype=="POINT" || srctype=="POINTHOR") {T=$8;V=$9;D=$10;i=i+1;
#         split(coordsArr[1],xy," ");
# 	printf("%d ! SRCNAM = %s  !\n",i,name)
# 	printf("%d ! X = %.3f, %.3f, %.1f, %.1f , %.1f , %.2f , %.1f , 0.0 , %.5f !\n",i,xy[1]/1000,xy[2]/1000,H,Z,D,V,T,Q)
# 	printf("%d ! ZPLTFM = .0  !\n",i)
# 	printf("%d ! FMFAC  = 1.0 !\n",i)
# 	#1 ! SRCNAM = ${emis_name} !
# 	#1 ! X = ${emis_x}, ${emis_y}, ${emis_h}, ${emis_z}, ${emis_d}, ${emis_u}, ${emis_t}, 0.0, ${emis_q} !
# 	#1 ! ZPLTFM  =       .0   !
#         #1 ! FMFAC  =       1.0   !
# };
# }' >> emis.dat
# done
# fi;



#v2.0: (MUY VERDE TODAVIA!)
if [ -f ${inp_emis} ]; then

for (( i=0; i<${#polluts[@]}; i++ ))
do
POLLUTID=${polluts[i]}

#sec 13: points

#  subgroup 13a
npt1=$(grep "POINT" ${inp_emis} | grep "$POLLUTID" | wc -l)


if (( $npt1 > 0 ))
then
cat << EOF > emis.dat

 13 -- Point source parameters
---------------
Subgroup (13a)
---------------
 ! NPT1 = ${npt1}  !  Number of point sources
 ! IPTU = 1  !  Units emis (1:g/s)
 ! NSPT1 = 0 !  Numbre of points with variable emisions
 ! NPT2 = 0  !  Numbre of points with variable emisions in external file
 ! END !
EOF

#  subgroup 13b
grep "POINT" ${inp_emis} | awk -F "[;]" -v i=${i} -v inpemis=${POLLUTID} '
BEGIN{print "---------------\nSubgroup (13b)\n---------------"}
$1==inpemis {name=$2;srctype=$3;gsub("[A-Z()]","",$4);N=split($4,coordsArr,",");Z=$5;Q=$6;H=$7;
	T=$8;V=$9;D=$10;i=i+1;
        split(coordsArr[1],xy," ");
        printf("%d ! SRCNAM = %s  !\n",i,name)
        printf("%d ! X = %.3f, %.3f, %.1f, %.1f , %.1f , %.2f , %.1f , 0.0 , %.5f !\n",i,xy[1]/1000,xy[2]/1000,H,Z,D,V,T,Q)
        printf("%d ! ZPLTFM = .0  !\n",i)
        printf("%d ! FMFAC  = 1.0 !\n",i)
}END{print "! END !"}
' >> emis.dat

#---------------
#Subgroup (13c)
#---------------
#BUILDING DIMENSION DATA FOR SOURCES SUBJECT TO DOWNWASH
#-------------------------------------------------------
#src  height & width every 10 degrees.
#1 ! SRCNAM
#1 ! HEIGHT=
#1 ! WIDTH=
#!END!

#---------------
#Subgroup (13d)
#---------------
#POINT SOURCE: VARIABLE EMISSIONS DATA
#---------------------------------------
#IVARY determines the type of variation, and is source-specific:
#	0 =Constant (default)
#	1 =Diurnal cycle (24 scaling factors: hours 1-24)
#	2 =Monthly cycle (12 scaling factors: months 1-12)
#	3 =Hour & Season (4 groups of 24 hourly scaling factors, where first group is DEC-JAN-FEB)
#	4 =Speed & Stab. (6 groups of 6 scaling factors by stability and speed)
#	5 =Temperature (12 scaling factors, by temperature (C) of: 0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 50+)
#1! SRCNAM = BLR1 !
#1! IVARY = 2 ! (12 Months)
#1! SO2 = 0.1,0.1,0.5,0.9,2,2.2, 2.5,1.5,1.1,0.9,0.5,0.1 !
#!END!
# 

else
	echo " " > emis.dat
	echo " 13 -- Point source parameters" >> emis.dat
	echo " ! END !" >> emis.dat
fi;


#
# #sec 14: area
# 

nar1=$(grep "POLYGON" ${inp_emis} | grep "$POLLUTID" | wc -l)


if (( $nar1 > 0 ))
then

cat << EOF >> emis.dat

 14 -- Area source parameters
---------------
Subgroup (14a)
---------------
! NAR1 =${nar1}! Number of polygon area sources with parameters specified below
! IARU =1      ! Units emission 1=g/m2.s
! NSAR1=0      !  Number of source-species combinations with variable emissions scaling factors
! NAR2 =0      !  Number of buoyant polygon area sources with variable location and emission parameters
! END !

EOF

grep "POLYGON" ${inp_emis} | awk -F "[;]" -v i=${i} -v inpemis=${POLLUTID} '
BEGIN{print "---------------\nSubgroup (14b)\n---------------\n   Area Source: Constant Data"}
$1==inpemis {name=$2;srctype=$3;gsub("[A-Z()]","",$4);N=split($4,coordsArr,",");Z=$5;Q=$6;H=$7;
	T=$8;V=$9;D=$10;i=i+1;
        split(coordsArr[1],xy," ");
        printf("%d ! SRCNAM = %s  !\n",i,name)
        printf("%d ! X = %.1f, %.1f , 2.5, %.5f !\n",i,H,Z,Q)
}END{print "! END !"}
' >> emis.dat


grep "POLYGON" ${inp_emis} | awk -F "[;]" -v i=${i} -v inpemis=${POLLUTID} '
BEGIN{print "---------------\nSubgroup (14c)\n---------------\n   Coordinates  Constant Data"}
$1==inpemis {name=$2;gsub("[A-Z()]","",$4);N=split($4,coordsArr,",");Z=$5;Q=$6;H=$7;
	i=i+1;
        split(coordsArr[1],xy," ");
        printf("%d ! SRCNAM = %s  !\n",i,name);
        printf("%d ! XVERT = ",i);
	for(j=1;j<=4;j++){ split(coordsArr[j],X," ");printf("%.2f, ", X[1]/1000.0) };
        printf("!\n");
        printf("%d ! YVERT = ",i);
	for(j=1;j<=4;j++){ split(coordsArr[j],X," ");printf("%.2f, ", X[2]/1000.0) };
        printf("!\n");
	printf("\n");
}
END{print("! END !")}' >> emis.dat

else
	echo " " >> emis.dat
	echo " 14 -- Area source parameters" >> emis.dat
	echo "! END !" >> emis.dat

fi;

#
# #sec 15: line
#
	echo " " >> emis.dat
 	echo " 15 -- Line source parameters" >> emis.dat
	echo "! END !" >> emis.dat
#
# #sec 16: volume
# 
	echo " " >> emis.dat
	echo " 16 -- Volume source parameters" >> emis.dat
	echo "! END !" >> emis.dat

done
fi;


