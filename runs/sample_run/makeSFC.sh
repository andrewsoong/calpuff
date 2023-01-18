#!/bin/bash
source namelist
source parseNamelist
#---------------------------------o#
#Make SURF.DAT & PRECIP.DAT
#----------------------------------#
echo -e "Escribiendo\e[32m ${sfc_out_file} \e[0m..."

inp_sfc=sfc.ish

#grep "FM-12+" ${inp_met_sfc} | awk '{if($0 ~ /GF1/)print $0;else gsub(/ADD/,"ADDGF100000"); print}' >> ${inp_sfc}   #Solo dejo reportes de superficie (FM-12+) & si informa GF1, lo considero despejado.
cat $inp_met_sfc | awk '{if($0 ~ /GF1/)print $0;else gsub(/ADD/,"ADDGF100000"); print}' > ${inp_sfc}
#cat $inp_met_sfc > $inp_sfc

awk -v ibyr=${ibyr} -v ibmo=${ibmo} -v ibdy=${ibdy} -v ibhr=${ibhr} -v ieyr=${ieyr} -v iemo=${iemo} -v iedy=${iedy} -v iehr=${iehr} -v ibjdy=${ibjdy} -v iejdy=${iejdy} -v time_offset=${time_offset} -v nstats=${nstats} -v stat_id=${id_sfc} '
BEGIN{
	printf("%s\n1\nProduced by Ramiro A. Espada from GAUSS-ma\nNONE\n","SURF.DAT");
	printf("%4.0f %4.0f %3.0f %4.0f %4.0f %3.0f %.0f %.0f\n", ibyr,ibjdy,ibhr,ieyr,iejdy,iehr,time_offset,nstats);
	printf("%.0f\n",stat_id);
	bdate=ibyr ibmo ibdy ibhr;
	edate=ieyr iemo iedy iehr;
}
{
	date=substr($0,16,10); 
	if ( !seen[date]++ && date >= bdate && date <= edate) {
		yr=substr($0,16,4);mo=substr($0,20,2);dy=substr($0,22,2);hr=substr($0,24,2);
		cmd="date -d "yr"-"mo"-"dy" +%j";  #otra forma: jdy=system("date -d "yr"-"mo"-"dy" +%j"); #+\047%j\047");
		cmd | getline jdy;
        	wd=substr($0,61,3)/1;        		#wdir
        	ws=substr($0,66,4)/10;       		#wspd   m/s*10 -> m/s       
        	ceil=substr($0,71,5)*3.28084/100.0-1;   #clht   m      -> km   
        	#sky=substr($0,79,6)/1000;   		#hzvs   m      -> km    
        	t=substr($0,88,5)/10+273.2;  		#tmpd   C*10   -> C
        	d=substr($0,94,5)/10;        		#dptp   C*10   -> C
		rh=100*(exp((17.625*d)/(243.04+d))/exp((17.625*(t-273.2))/(243.04+(t-273.2))));
        	pres=substr($0,100,5)/10;    		#slvp   hPa*10 -> hPa
        	#AA1 (precip)
        	match($0,/AA1/);
		if(RSTART !=0){ pp_t=substr($0,RSTART+3,2);pp=substr($0,RSTART+5,4)/10; #prcp_period [hr]  #prcp [mm*10] -> [mm]
		ppr=pp/pp_t;}
		else{ppr=0;};
		pp_code=0;
		if (t > 0 && ppr < 2.5             ){pp_code=1 };
		if (t > 0 && ppr > 2.5 && ppr < 7.6){pp_code=2 };
		if (t > 0 && ppr > 7.6             ){pp_code=3 };
		if (t < 0 && ppr < 2.5             ){pp_code=19};
		if (t < 0 && ppr > 2.5 && ppr < 7.6){pp_code=20};
		if (t < 0 && ppr > 7.6             ){pp_code=21};
        	#GF1 (sky-condition)
        	match($0,/GF1/); if(RSTART !=0){ sky=substr($0,RSTART+3,2)}else{sky=99};   #sky cover [octas]    #sky opaque cover
		#
		if (pres == 9999.9){
			match($0,/MA1/); 
			if(RSTART !=0){pres=substr($0,RSTART+3,5)/10} else(pres=1013.25);
		};
		#PRINT TO FILE:
		printf("%4d %4d %3d\n",yr,jdy,hr);
		printf("%6.2f %6.1f %6.0f %6.0f %6.2f %6.0f %6.1f %6.0f\n",ws,wd,ceil,sky,t,rh,pres,pp_code)
	}
}' ${inp_sfc}  > ${sfc_out_file}

##PRECIP.DAT
echo -e "Escribiendo\e[32m ${ppt_out_file} \e[0m..."

awk -v ibyr=${ibyr} -v ibmo=${ibmo} -v ibdy=${ibdy} -v ibhr=${ibhr} -v ieyr=${ieyr} -v iemo=${iemo} -v iedy=${iedy} -v iehr=${iehr} -v ibjdy=${ibjdy} -v iejdy=${iejdy} -v time_offset=${time_offset} -v nstats=${nstats} -v stat_id=${id_sfc} '
BEGIN{
	printf("%s\n1\nProduced by Ramiro A. Espada from GAUSS-ma\nNONE\n","PRECIP.DAT");
	printf("%6.0f %6.0f %6.0f %6.0f %6.0f %6.0f %6.0f %6.0f\n",ibyr,ibjdy,ibhr,ieyr,iejdy,iehr,time_offset,nstats);
	printf("%.0f\n",stat_id);
	bdate=ibyr ibmo ibdy ibhr;
	edate=ieyr iemo iedy iehr;
}
{
	date=substr($0,16,10); 
	if ( !seen[date]++ && date >= bdate && date <= edate) {
		yr=substr($0,16,4);
		mo=substr($0,20,2);
		dy=substr($0,22,2);
		hr=substr($0,24,2);
		cmd="date -d "yr"-"mo"-"dy" +%j";  #otra forma: jdy=system("date -d "yr"-"mo"-"dy" +%j"); #+\047%j\047");
		cmd | getline jdy;
        	#AA1 (precip)
        	match($0,/AA1/);if(RSTART !=0){ pp_t=substr($0,RSTART+3,2);pp=substr($0,RSTART+5,4)/10; #prcp_period [hr]  #prcp [mm*10] -> [mm]
		ppr=pp/pp_t;
		}else{ppr=0;};
		printf("%6.0f %6.0f %6.0f %6.2f\n",yr,jdy,hr,ppr);
	}
}' ${inp_sfc}  > ${ppt_out_file}

echo -e "A corregir:"
echo -e "  [ ] Asegurarse que la serie comience con valores \e[31mNO NULOS \e[0m!"
echo -e "  [x] Asegurarse que no tenga dias/horas repetidas!"
echo -e "  [ ] Asegurarse que wd no esté fuera de rango (0-360]!"
