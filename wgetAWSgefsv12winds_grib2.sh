#!/bin/bash

# Shell script to dowload GEFSv12 from AWS: simple wget without postproc
# https://noaa-gefs-retrospective.s3.amazonaws.com/index.html
# Only 10m wind components
# two arguments: year and output-path
# examples:
#      ./wgetAWSgefsv12_grib2.sh 2000 /home/name/Downloads
#      nohup ./wgetAWSgefsv12winds_grib2.sh 2000 /home/name/Downloads >> nohupout_wgetAWSgefsv12winds_grib2_2000.txt 2>&1 &

year=$1
dpath=$2

cd $dpath
SERVER="http://noaa-gefs-retrospective.s3.amazonaws.com/GEFSv12/reforecast"
# variables
vars=(u v)
# float array resolution (decimals)
dp=3

for month in `seq 1 12`; do
  for day in `seq 1 31`; do

    date=$year`printf %2.2d $month``printf %2.2d $day`

    # forecast range
    wday=$(date -d "$year-`printf %2.2d $month`-`printf %2.2d $day`" +%u)
    if [ "$wday" -eq 3 ]; then
      frg=(1-10 10-35)
    else
      frg=(1-10 10-16)
    fi
   
    for em in `seq 0 10`; do

      if [ ${em} -eq 0 ]; then
        # Control Member
        sem="c00"
      else
        # Ensemble Members
        sem="p`printf %2.2d $em`"
      fi

      # two slices of forecast ranges
      for fg in ${frg[*]}; do
        # variables U and V
        for var in ${vars[*]}; do
          fname=${var}"grd_hgt_"${date}"00_"${sem}
          wget --no-check-certificate --no-proxy -l1 -H -t1 -nd -N -np -erobots=off --tries=3 ${SERVER}/${year}/${date}"00/"${sem}"/Days:"${fg}"/"${fname}".grib2" &&
          sleep 1

          test -f ${var}"grd_hgt_"${date}"00_"${sem}".grib2" &&
          TE=$?
          if [ "$TE" -eq 0 ]; then
            mv ${fname}".grib2" ${fname}".D"${fg}".grib2"
          fi

        done

      done

    done

    echo "    Ok "${date}

  done
done

echo "Download GEFSv12 AWS wind for "$year" is complete, at "$dpath

