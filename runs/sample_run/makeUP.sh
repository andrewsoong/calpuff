#!/bin/bash
source namelist
source parseNamelist
##---------------------------#
## Make UP.DAT file
##---------------------------#
#==========================================================================
#Version propia de read62:
pstop=800	#presión del nivel maximo a considerar. [mbar]

jdat=2  #formato de inp    (1:TD-6201; 2:FSL)
ifmt=2	#formato de salida (1: sep="/" ws&wd int; 2: sep="," ws&wd real )

lht=T	#si z    missing, descartar observacion.
ltemp=T #si temp missing, descartar observacion.
lwd=F   #si wd   missing, descartar observacion.
lws=F   #si ws   missing, descartar observacion.

#(!)-------------------------------------
#Intento de filtrar fechas del fsl, todavia no funciona.
#
LC_TIME=en_US.utf8
DAY_BEFORE=`date -u -d"${ini_date} - 2 day" +"254 *12 *%-d *%b *%Y"`
DAY_AFTER=`date -u -d"${end_date} + 2 days" +"254 *12 *%-d *%b *%Y"`
before=${DAY_BEFORE^^}
after=${DAY_AFTER^^}

sed -n "/$before/,/$after/{p}" ${inp_met_up} | uniq > up.fsl  #bastante desprolija esta solucion. por el momento funciona.
#---------------------------------------------------------

cat $inp_met_up > up.fsl

#reemplazo meses por numeros
sed -i 's/JAN/1/;s/FEB/2/;s/MAR/3/;s/APR/4/;s/MAY/5/;s/JUN/6/;s/JUL/7/;s/AGO/8/;s/SEP/9/;s/OCT/10/;s/NOV/11/;s/DIC/12/' up.fsl 
echo "254" >> up.fsl  #(!) importante para que escriba el ultimo sondeo.

idate="$ibyr/$ibmo/$ibdy/$ibhr"
edate="$ieyr/$iemo/$iedy/$iehr"

awk -F " " -v idate=$idate -v edate=$edate -v ibjdy=$ibjdy -v iejdy=$iejdy -v pstop=$pstop -v jdat=$jdat -v ifmt=$ifmt -v lht=$lht -v ltemp=$ltemp -v lwd=$lwd -v lws=$lws '
BEGIN{
   #FILE HEADER:
   print "UP.DAT          2.0             Header structure with coordinate parameters";
   print "   1";
   print "Producido por Ramiro A. Espada de gauss-ma.";
   print "NONE";
   split(idate,aidate,"/");split(edate,aedate,"/");
   #read(io,122)ibyru,ibjulu,ibhru,ieyru,iejulu,iehru,ptop,jdat,ifmt
   #122   format(1x,6i5,f5.0,2i5)
   printf(" %5d%5d%5d%5d%5d%5d%5.0f%5d%5d\n",aidate[1],ibjdy,aidate[4],aedate[1],iejdy,aedate[4],pstop,jdat,ifmt);
   #read(io,124)lht,ltemp,lwd,lws
   #124   format(1x,4(4x,l1))
   printf("     %1s    %1s    %1s    %1s\n",lht,ltemp,lwd,lws);
   nlev=0;
}
{
   if( $1 == 254 ){
      if(NR>1){
	#record header read and format:
	#     read(iunit,3)nosta,iyraa,imoaa,idyaa,ihraa,nlevaa
        #3    format(9x,i8,5x,4i2,35x,i5)
        printf("         %8d     %2d%2d%2d%2d                                   %5d\n",nosta,iyr-2000,imo,idy,ihr,nlev-1);
        for (i=1; i<nlev; i++)
	   # record data read and format: 
	   #     read(iunit,4)(paa(iup,ii),zlaa(iup,ii),tzaa(iup,ii),uaa(iup,ii),vaa(iup,ii),ii=1,nlevaa)
	   #4    format(4(3x,f6.1,1x,f5.0,1x,f5.1,1x,f3.0,1x,f3.0))
           if ( (i%4) ==0 || i==nlev-1 ){
             printf("   %6.0f,%5.0f,%5.1f,%3.0f,%4.1f\n",p[i],z[i],t[i],wd[i],ws[i])
           }
           else{
             printf("   %6.0f,%5.0f,%5.1f,%3.0f,%4.1f",p[i],z[i],t[i],wd[i],ws[i])
           }
        ;
      };
      iyr=$5;imo=$4;idy=$3;ihr=$2;
      nlev=0;
   };
   if( $1 == 1 ){
      nosta=$3;
   };
   if( ($1 == 4 || $1 == 9) && $2 >= pstop && $3 < 9998.){
      p[nlev]=$2;z[nlev]=$3;t[nlev]=$4/10.00+273.15;wd[nlev]=$6;ws[nlev]=$7/10;
      nlev++;
   };
}
END{
   print ""
}
' up.fsl >up.dat


#(!)---------------------------------------
#ejemplo fsl:
#    254     12      5      JAN    2019
#      1  99999  87576  34.82S 58.53W    20   1127
#      2    200   1230    741     20  99999      3
#      3          SAEZ                99999     ms
#      9  10120     20    244    154      5     36
#      4  10000    124    232    132    360     82
#EJEMPLO archivo de salida:
#UP.DAT          2.0             Header structure with coordinate parameters
#   1
#Produced by READ62 Version: 5.54  Level: 070627
#NONE
#  2019    5   12 2019    6   13 800.    2    2
#     T    T    F    F
#           87576      19 1 512                                   8
#   999999,  20.,297.6,  5,  3.6,   999999, 124.,296.4,360,  8.2,   9250.0, 797.,291.4,360, 10.8,   8500.0,1515.,288.2, 20,  6.2,
#   7000.0,3136.,281.0,245, 10.8,   5000.0,5820.,264.1,255, 11.8,   4000.0,7500.,251.1,265, 18.5,   3000.0,9550.,236.9,255, 34.5
#           87576      19 1 612                                   8
#   999999,  20.,294.6,300,  3.1,   999999,  65.,294.6,315,  6.7,   9250.0, 746.,294.8,310, 18.0,   8500.0,1471.,288.4,310, 19.5,
#   7000.0,3107.,281.8,270,  8.7,   5000.0,5790.,263.9,315, 23.1,   4000.0,7480.,254.5,285, 20.1,   3000.0,9570.,239.3,290, 29.3
#(!)---------------------------------------

echo -e "A corregir:"
echo -e "  [ ] Hacer que el script recorte las observaciones desde un dia antes hasta un dia despues del periodo de la corrida."


#==============================================================================================
#VIEJO! (Usando READ62):
##read62 toma las fechas  en horario universal (GMT)
#
#inp_up=up.fsl
#
#pstop=800       #pstop the top pressure level (in mb units) for which data are extracted. 
#		#The pressure level must correspond to a height that equals or exceeds the top of the CALMET modeling domain,
#		# or else CALMET will stop with an error message.
#
#pvtop=1000      #pvtop if 'lxtop' is TRUE, then pvtop is the pressure (in mb units) level corresponding to where valid data must exist.
#zvsfc=50        #zvsfc if 'lxsfc' is TRUE, then zvsfc is the height (in meters) corresponding to where valid data must exist.
#
#
#
#cat ${inp_met_up} > up.fsl
##awk -F " " -v ptop=$pstop '{if( $2!=99999 && $2 < ptop || ($1 < 4 || $1 == 245 ) ){print $0}}' ${inp_met_up} > ${inp_up}
#
#
#
#cat << EOF > read62.inp  
#READ62.INP      2.1             Hour Start and End Times with Seconds
#
#0 -- Input and Output Files
#
#! INDAT  =${inp_up}      !  archivo de entrada
#* SUBDAT =	     *      archivo de entrada substituto
#! UPDAT  =${up_out_file} !  archivo de salida
#! RUNLST =read62.lst !  archivo de mensajes y errores.
#
#! LCFILES = T        ! 	nombre de salidas lowercase? (T/F)
#
#! END !
#--------------------------------------------------------------------------------
#1 -- Run control parameters
#
#Starting date/time
#! IBYR  =${gmtbyr} !
#! IBMO  =${gmtbmo} !
#! IBDY  =${gmtbdy} !
#! IBHR  =12        !
#* IBHR  =${gmtbhr} *
#* IBSEC =${gmtbsec} *
#                  
#Ending date/time  
#! IEYR  =${gmteyr} !
#! IEMO  =${gmtemo} !
#! IEDY  =${gmtedy} !
#! IEHR  =${gmtehr} !
#* IESEC =${gmtesec}*             
#                               
#File Options		       
#! JDAT = 2 !    #type of NCDC input sounding data file;
#                #	1: is the TD-6201 format 
#                #	2: is the NCDC FSL format.
#! ISUB = 0 !    #isub the format of substitute UP.DAT input sounding data file;
#                #    0: no substitute data file will be used,
#		#    1: niveles separados por "/" (ws & wd integer)
#                #    2: niveles separados por "," (ws & wd float) 
#! IFMT = 2 !    #ifmt the format of the main UP.DAT input sounding data file;
#		#    1: niveles separados por "/" (ws & wd integer)
#                #    2: niveles separados por "," (ws & wd float) 
#
#Processing Options              
#! PSTOP =${pstop} !  #pstop the top pressure level (in mb units) for which data are extracted.                                         
#                     #The pressure level must correspond to a height that equals or exceeds the top of the CALMET modeling domain,
#                     # or else CALMET will stop with an error message.
#
#! LHT   = T     !    #If height is missing from a level, that level will be rejected. [T/F]                                                 
#! LTEMP = T     !    #If temperature is missing from a level, that level will be rejected. [T/F]                                            
#! LWD   = F     !    #If wind direction is missing from a level, that level will be rejected. [T/F]                                         
#! LWS   = F     !    #If wind speed is missing from a level, that level will be rejected. [T/F]                                             
#
#! LXTOP = T     !    #extrapolate to extend missing profile data to PSTOP pressure level? [T/F].
#! PVTOP =${pvtop}!   # if 'lxtop' is TRUE, then pvtop is the pressure level corresponding to where valid data must exist.              
#! LXSFC = T      !   #extrapolate to extend missing profile data to the surface?
#! ZVSFC =${zvsfc}!   # if 'lxsfc' is TRUE, then zvsfc is the height (in meters) corresponding to where valid data must exist.          
#                                
#! END !
#EOF
#
#if [[ ! -f read62.exe ]]
#then
#	ln -sf ${read62_exe} read62.exe
#	chmod 755 read62.exe
#fi
#./read62.exe read62.inp
#
#sed -i '/->->->/d' ${up_out_file}
#sed -i 's/\*/9/g' ${up_out_file}
#echo "" >> ${up_out_file}
#
#
#
#echo -e "A corregir:"
#echo -e "  [ ] Hay un problema en las horas de los raobs, tiene que coincidir con las horas de comienzo en el calmet."
#
#
