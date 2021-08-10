#!/bin/bash

# Shell script to process GEFSv12 ice
# examples:
#      ./getgefsv12ice.sh 2000 /home/name/Downloads
#      nohup ./getgefsv12ice.sh 2000 /home/name/Downloads >> nohupout_getgefsv12ice_2000.txt 2>&1 &

year=$1
dpath=$2

module load intel/2021.2 cdo/1.9.8 nco

cd $dpath
ODIR="/work/noaa/ng-godas/marineda/DATM_INPUT/GEFS"

# float array resolution (decimals)
dp=4

for month in `seq 1 12`; do
  for day in `seq 1 31`; do

    date=$year`printf %2.2d $month``printf %2.2d $day`

    test -f ${ODIR}"/"${year}`printf %2.2d ${month}`"/gefs."${date}"00.nc" &&
    TE=$?
    if [ "$TE" -eq 0 ]; then
      cdo -selvar,icecsfc,u10m,v10m ${ODIR}"/"${year}`printf %2.2d ${month}`"/gefs."${date}"00.nc" "gefs."${date}"00.v1.nc"
      cdo -setreftime,'1970-01-01','00:00:00' -setmissval,nan -invertlat  "gefs."${date}"00.v1.nc" "gefs."${date}"00.v2.nc"   
      rm "gefs."${date}"00.v1.nc" &&
      ncks -4 -L 1 "gefs."${date}"00.v2.nc" "gefs."${date}"00.v3.nc" &&
      rm "gefs."${date}"00.v2.nc" &&
      ncks --ppc default=.$dp "gefs."${date}"00.v3.nc" "ice."${date}"00.nc" &&
      sleep 1
      rm "gefs."${date}"00.v3.nc" &&
      chmod +775 "ice."${date}"00.nc"
    fi
  done
done

