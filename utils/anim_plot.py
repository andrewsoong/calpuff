#!/usr/bin/env python3
import os
import numpy as np
import cartopy.crs as ccrs
import matplotlib.pyplot as plt
import cartopy.io.img_tiles as cimgt
from osgeo import gdal
import geopandas as gpd
from matplotlib.animation import FuncAnimation

def getData(filepath):
    ds = gdal.Open(filepath, gdal.GA_ReadOnly)
    for x in range(1, ds.RasterCount + 1):
        #band = ds.GetRasterBand(x)
        C = ds.ReadAsArray()
    nx=ds.RasterXSize
    ny=ds.RasterYSize
    ulx, xres, xskew, uly, yskew, yres  = ds.GetGeoTransform()
    lrx = ulx + (nx * xres)
    lry = uly + (ny * yres)
    C[C<0]=np.NaN
    X,Y=np.meshgrid(np.linspace(ulx,lrx,nx),np.linspace(uly,lry,ny))
    return X,Y,C

basedir='/home/rama/github/gauss-ma/calpuff/runs/sample_run/out/plt/'
files=os.listdir(basedir)
files.sort()
request = cimgt.OSM()
request=cimgt.GoogleTiles(style='satellite')

#projection= ccrs.GOOGLE_MERCATOR
utmzone=20
projection = ccrs.UTM(zone=utmzone,southern_hemisphere=True)

fig = plt.figure()
ax = fig.add_subplot(1, 1, 1, projection=projection)

def plotFile(filepath,i):

    X,Y,C=getData(filepath)
    X=X*1000.0;Y=Y*1000.0
    border=200/2.0
    xmin=X.min()-border;xmax=X.max()+border;
    ymin=Y.min()-border;ymax=Y.max()+border;
    extent=[xmin,xmax,ymin,ymax]
    ax.cla()
    #ax = fig.add_subplot(1, 1, 1, projection=projection)
    ax.set_extent(extent, crs=projection)
    ax.set_xticks(np.linspace(xmin,xmax,3).round(0), crs=projection)
    ax.set_yticks(np.linspace(ymin,ymax,4).round(0), crs=projection)
    ax.tick_params(labelsize=8)
    #ax.add_image(request, 14)
    p=ax.contourf(X,Y,C[:,:],alpha=0.6,cmap='RdBu_r')    
    ax.set_title(filepath, fontsize=9)
    if (i==0):
        fig.colorbar(p, shrink=0.6)

def init():
    print("Init")
    #plotFile(str(basedir+files[0]),0)
    
    #ax.clear()
    #drawMap(m)
    #ax.pcolormesh(x, y, var[0,:,:], alpha=0.8)
        
#filepath=basedir+'prueba/2019_m01_d05_0500(utc+0300)_l00_co_1hr_conc.grd'

def animate(i):
    plotFile(str(basedir+files[i]),i)
    
    
#for i in range(len(files)):
#for i in range(len(files)):
#    #print(i);
#    #print(str(files[i]))
#    plotFile(str(basedir+files[i]),i)

im_ani=FuncAnimation(fig, animate, init_func=init,
              frames=len(files),
              interval=2e+2,
              blit=False,repeat=True)
im_ani.save('animation.gif', writer='imagemagick', fps=2)