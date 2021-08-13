import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from pylab import *
from mpl_toolkits.basemap import Basemap

# Read NDBC buoys, lat/lon and buoyID
dfgefs = pd.read_csv("wave_gefs.buoys", comment='$')
bposgefs=np.zeros((dfgefs.values.shape[0]-1,2),'float')*np.nan; bidgefs=[]
for i in range(0,dfgefs.values.shape[0]-1):
	aux=np.str(dfgefs.values[i]).split()
	bposgefs[i,0]=np.float(aux[2]) # lat
	bposgefs[i,1]=np.float(aux[1]) # lon
	bidgefs=np.append(bidgefs,aux[3][1::]) # ndbc buoy ID

dfgfs = pd.read_csv("wave_gfs.buoys.dat", comment='$')
bposgfs=np.zeros((dfgfs.values.shape[0]-1,2),'float')*np.nan; bidgfs=[]
for i in range(0,dfgfs.values.shape[0]-1):
	aux=np.str(dfgfs.values[i]).split()
	bposgfs[i,0]=np.float(aux[2]) # lat
	bposgfs[i,1]=np.float(aux[1]) # lon
	bidgfs=np.append(bidgfs,np.str(aux[3][1::]).split("'")[0])

dfabs = pd.read_csv("allbstations.dat", comment='$')
bposabs=np.zeros((dfabs.values.shape[0]-1,2),'float')*np.nan; bidabs=[]
for i in range(0,dfabs.values.shape[0]-1):
	aux=np.str(dfabs.values[i]).split()
	bposabs[i,0]=np.float(aux[2]) # lat
	bposabs[i,1]=np.float(aux[1]) # lon
	bidabs=np.append(bidabs,np.str(aux[3][1::]).split("'")[0])


# Check if all GEFS buoys are contained in GFS list
for i in range(0,size(bidgefs)):
	ind = np.where( bidgfs == bidgefs[i])
	if np.any(ind)==True or ind==0:
		print('Buoy '+bidgefs[i]+' Ok')
	else:
		print('Buoy '+bidgefs[i]+' is not contained in GFS list')


# Check if GFS buoys are contained in GEFS list
for i in range(0,size(bidgfs)):
	ind = np.where( bidgefs == bidgfs[i])
	if np.any(ind)==True or ind==0:
		print('Buoy '+bidgfs[i]+' Ok')
	else:
		print('Buoy '+bidgfs[i]+' is not contained in GEFS list')


# Plot positions
scolors=np.array(['darkblue','darkgreen','firebrick'])

# GFS
fig, ax = plt.subplots(figsize=(12,6.5))
map = Basemap(projection='mill',llcrnrlat=-75.,urcrnrlat=75.,llcrnrlon=-180.,urcrnrlon=180.,resolution='c')
map.fillcontinents(color='silver', zorder=1)
map.drawcountries(linewidth=0.3, linestyle='solid', color='grey', antialiased=1, ax=None, zorder=2)
# map.drawcoastlines(linewidth=0.5, color='k', zorder=2)
for i in range(0,size(bidgfs)):
	xs,ys = map(bposgfs[i,1],bposgfs[i,0])
	map.plot(xs,ys,marker='.',color=scolors[0],ms="6")
	# plt.text(xs,ys,bidgfs[i], fontsize=6)

map.drawmeridians(np.linspace(0,360,13),labels=[0,0,0,1],linewidth=0.3,fontsize=12) 
map.drawparallels(np.linspace(-60,60,9),labels=[1,0,0,0],linewidth=0.3,fontsize=12) 
fig.tight_layout()
savefig('GFSbuoys.eps', format='eps', dpi=1000)
savefig('GFSbuoys.png', dpi=300, facecolor='w', edgecolor='w',orientation='portrait', papertype=None, format='png',transparent=False, bbox_inches='tight', pad_inches=0.1)
plt.close()


# GEFS
fig, ax = plt.subplots(figsize=(12,6.5))
map = Basemap(projection='mill',llcrnrlat=-75.,urcrnrlat=75.,llcrnrlon=-180.,urcrnrlon=180.,resolution='c')
map.fillcontinents(color='silver', zorder=1)
map.drawcountries(linewidth=0.5, linestyle='solid', color='grey', antialiased=1, ax=None, zorder=2)
# map.drawcoastlines(linewidth=1., color='k', zorder=2)
for i in range(0,size(bidgefs)):
	xs,ys = map(bposgefs[i,1],bposgefs[i,0])
	map.plot(xs,ys,marker='.',color=scolors[1],ms="6")
	# plt.text(xs,ys,bidgefs[i], fontsize=6)

map.drawmeridians(np.linspace(0,360,13),labels=[0,0,0,1],linewidth=0.3,fontsize=12) 
map.drawparallels(np.linspace(-60,60,9),labels=[1,0,0,0],linewidth=0.3,fontsize=12) 
fig.tight_layout()
savefig('GEFSbuoys.eps', format='eps', dpi=1000)
savefig('GEFSbuoys.png', dpi=300, facecolor='w', edgecolor='w',orientation='portrait', papertype=None, format='png',transparent=False, bbox_inches='tight', pad_inches=0.1)
plt.close()


# All buoys & stations
fig, ax = plt.subplots(figsize=(12,6.5))
map = Basemap(projection='mill',llcrnrlat=-75.,urcrnrlat=75.,llcrnrlon=-180.,urcrnrlon=180.,resolution='c')
map.fillcontinents(color='silver', zorder=1)
map.drawcountries(linewidth=0.5, linestyle='solid', color='grey', antialiased=1, ax=None, zorder=2)
# map.drawcoastlines(linewidth=1., color='k', zorder=2)
for i in range(0,size(bidabs)):
	xs,ys = map(bposabs[i,1],bposabs[i,0])
	map.plot(xs,ys,marker='.',color=scolors[2],ms="6")
	# plt.text(xs,ys,bidabs[i], fontsize=6)

map.drawmeridians(np.linspace(0,360,13),labels=[0,0,0,1],linewidth=0.3,fontsize=12) 
map.drawparallels(np.linspace(-60,60,9),labels=[1,0,0,0],linewidth=0.3,fontsize=12) 
fig.tight_layout()
savefig('Allbuoys.eps', format='eps', dpi=1000)
savefig('Allbuoys.png', dpi=300, facecolor='w', edgecolor='w',orientation='portrait', papertype=None, format='png',transparent=False, bbox_inches='tight', pad_inches=0.1)
plt.close()
