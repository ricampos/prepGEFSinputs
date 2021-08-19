# prepGEFSinputs
Codes to prepare the input files of GEFSv12 wave simulations with ww3 and later validation against observations

You can find the data at /work/noaa/marine/ricardo.campos/data/GEFSv12/

Wind has a grid resolution of 0.25° or 0.50°
Ice has a grid resolution of 0.234°

# Download AWS GEFSv12 winds using wget:
wgetAWSgefsv12winds_grib2.sh
# Convert grib2 wind files to netcdf format, compress, and organize files:
procAWSgefsv12winds.sh
# Unified code that download and covert wind files in the same script (outside Orion)
getAWSgefsv12_unifiedOutputFranges.sh
# Fetch, convert grib2 ice files to netcdf format, compress, and organize files:
getgefsv12ice.sh

# Download NDBC files Standard Meteorological Data, text format
get_ndbc_stdmet.py 
# Check point output list of NDBC stations used in GEFS and GFS
checkBuoys.py

# Download AODN altimeter data
get_AODN_AltData.sh


