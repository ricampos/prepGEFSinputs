#!/bin/bash

# Shell script to process GEFSv12 grib2 files from AWS, previously downloaded using wgetAWSgefsv12winds_grib2.sh
# It converts to netcdf format, compress and organize the output files
# Only 10m wind components (uwnd and vwnd)
# three arguments: year grib-file-path and output-path
# examples:
#      ./procAWSgefsv12.sh 2000 /home/name/Downloads/grib2 /home/name/Downloads/netcdf
#      nohup ./procAWSgefsv12winds.sh 2000 /home/name/Downloads/grib2 /home/name/Downloads/netcdf >> nohupout_procAWSgefsv12winds_2000.txt 2>&1 &

year=$1
gpath=$2
dpath=$3

module load intel/2021.2 nco wgrib

cd $dpath
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
          fname=${var}"grd_hgt_"${date}"00_"${sem}".D"${fg}
          test -f ${gpath}"/"${fname}".grib2" &&
          TE=$?
          if [ "$TE" -eq 0 ]; then
            # convert from grib2 to netcdf
            # cdo -f nc copy ${fname}".grib2" ${fname}".aux1.nc" &&
            wgrib2 ${gpath}"/"${fname}".grib2" -netcdf ${dpath}"/"${fname}".aux1.nc" &&
            # correct time array
	    # cdo setreftime,1970-01-01,00:00:00,seconds ${fname}".aux1.nc" ${fname}".aux2.nc" &&
            # remove wind at 100m
            ncks -x -v ${var^}"GRD_100maboveground" ${dpath}"/"${fname}".aux1.nc" ${dpath}"/"${fname}".aux2.nc" &&
            # modify variable name
            ncrename -v ${var^}"GRD_10maboveground",${var}"wnd" ${dpath}"/"${fname}".aux2.nc" ${dpath}"/"${fname}".nc" &&
            # correct latitudes, starting with -90.
            # ncpdq -O -a -lat ${fname}".aux2.nc" ${fname}".D"${fg}".nc" &&
            sleep 1
            rm ${dpath}"/"${fname}".aux*.nc"
            # rm ${gpath}"/"${fname}".grib2"
          fi
        done

        # join u v into a singe netcdf file
        test -f ${dpath}"/"${vars[0]}"grd_hgt_"${date}"00_"${sem}".D"${fg}".nc"
        TE=$?
        if [ "$TE" -eq 0 ]; then
          test -f ${dpath}"/"${vars[1]}"grd_hgt_"${date}"00_"${sem}".D"${fg}".nc"
          TE=$?
          if [ "$TE" -eq 0 ]; then
            rname="wnd10m_"${date}"00_"${sem}".D"${fg}
            cp ${dpath}"/"${vars[0]}"grd_hgt_"${date}"00_"${sem}".D"${fg}".nc" ${dpath}"/"${rname}".nc"
            ncks -A ${dpath}"/"${vars[1]}"grd_hgt_"${date}"00_"${sem}".D"${fg}".nc" ${dpath}"/"${rname}".nc" &&
            sleep 1
            rm ${dpath}"/"${vars[0]}"grd_hgt_"${date}"00_"${sem}".D"${fg}".nc"
            rm ${dpath}"/"${vars[1]}"grd_hgt_"${date}"00_"${sem}".D"${fg}".nc"
          fi
        fi

        # reduce size
        test -f ${dpath}"/"${rname}".nc"
        TE=$?
        if [ "$TE" -eq 0 ]; then
          ncks -4 -L 1 ${dpath}"/"${rname}".nc" ${dpath}"/"${rname}".aux1.nc" &&
          rm ${dpath}"/"${rname}".nc"
          ncks --ppc default=.$dp ${dpath}"/"${rname}".aux1.nc" ${dpath}"/"${rname}".nc" &&
          sleep 1
          rm ${dpath}"/"${rname}".aux1.nc"
          chmod +775 ${dpath}"/"${rname}".nc"
        fi

      done

    done

    echo "    Ok "${date}

  done
done

# remove empty files (errors)
# find -empty -type f -delete

echo "Proc GEFSv12 AWS wind (uwnd,vwnd) for "$year" is complete, at "$dpath

