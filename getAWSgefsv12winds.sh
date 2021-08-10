#!/bin/bash

# Shell script to dowload GEFSv12 from AWS
# https://noaa-gefs-retrospective.s3.amazonaws.com/index.html
# Only 10m wind components (10u and 10v)
# two arguments: year and output-path
# examples:
#      ./getAWSgefsv12.sh 2000 /home/name/Downloads
#      nohup ./getAWSgefsv12.sh 2000 /home/name/Downloads >> nohupout_getAWSgefsv12_2000.txt 2>&1 &

year=$1
dpath=$2

module load intel/2021.2 cdo/1.9.8 nco

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
            # convert from grib2 to netcdf
            cdo -f nc copy ${fname}".grib2" ${fname}".aux1.nc" &&
            # remove wind at 100m
            ncks -x -v 100${var} ${fname}".aux1.nc" ${fname}".aux2.nc" &&
            ncpdq -O -a -lat ${fname}".aux2.nc" ${fname}".D"${fg}".nc" &&
            sleep 1
            rm *.aux*.nc
            rm ${fname}".grib2"
          fi

        done
        
        # join u v into a singe netcdf file
        test -f ${vars[0]}"grd_hgt_"${date}"00_"${sem}".D"${fg}".nc"
        TE=$?
        if [ "$TE" -eq 0 ]; then
          test -f ${vars[1]}"grd_hgt_"${date}"00_"${sem}".D"${fg}".nc"
          TE=$?
          if [ "$TE" -eq 0 ]; then
            rname="wnd10m_"${date}"00_"${sem}".D"${fg}
            cp ${vars[0]}"grd_hgt_"${date}"00_"${sem}".D"${fg}".nc" ${rname}".nc"
            ncks -A ${vars[1]}"grd_hgt_"${date}"00_"${sem}".D"${fg}".nc" ${rname}".nc" &&
            sleep 1
            rm ${vars[0]}"grd_hgt_"${date}"00_"${sem}".D"${fg}".nc"
            rm ${vars[1]}"grd_hgt_"${date}"00_"${sem}".D"${fg}".nc"
          fi
        fi

        # reduce size
        test -f ${rname}".nc"
        TE=$?
        if [ "$TE" -eq 0 ]; then
          ncks -4 -L 1 ${rname}".nc" ${rname}".aux1.nc" &&
          rm ${rname}".nc"
          ncks --ppc default=.$dp ${rname}".aux1.nc" ${rname}".nc" &&
          sleep 1
          rm ${rname}".aux1.nc"
          chmod +775 ${rname}".nc"
        fi

      done

    done

    echo "    Ok "${date}

  done
done

# remove empty files (errors)
find -empty -type f -delete

echo "Download GEFSv12 AWS wind (U10,V10) for "$year" is complete, at "$dpath

