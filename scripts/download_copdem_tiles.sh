#!/bin/bash

# Example script to download NCI's CopDEM mirror

alias RS='rsync -avzh --progress'

# Grab a row of tiles for S78 degrees
for N in {108..120}; do
  mkdir Copernicus_DSM_COG_10_S78_00_W"$N"_00_DEM
  RS gadi:/g/data/v10/eoancillarydata-2/elevation/copernicus_30m_world/Copernicus_DSM_COG_10_S78_00_W"$N"_00_DEM/Copernicus_DSM_COG_10_S78_00_W"$N"_00_DEM.tif  Copernicus_DSM_COG_10_S78_00_W"$N"_00_DEM/
done


# Example for S75 degrees
for N in {108..120}; do
  mkdir Copernicus_DSM_COG_10_S75_00_W"$N"_00_DEM
  RS gadi:/g/data/v10/eoancillarydata-2/elevation/copernicus_30m_world/Copernicus_DSM_COG_10_S75_00_W"$N"_00_DEM/Copernicus_DSM_COG_10_S75_00_W"$N"_00_DEM.tif  Copernicus_DSM_COG_10_S75_00_W"$N"_00_DEM/
done





# Tiles for the Wagga region
# download an area with a nested loop
for LAT in {34..36}; do
  for LONG in {145..148}; do
    DEST=Copernicus_DSM_COG_10_S"$LAT"_00_W"$LONG"_00_DEM
    mkdir $DEST
    RS gadi:/g/data/v10/eoancillarydata-2/elevation/copernicus_30m_world/"$DEST"/"$DEST".tif  $DEST/
  done
done



function download_wagga () {
  # Tiles for the Wagga region
  # download an area with a nested loop
  for LAT in {34..36}; do
    for LONG in {145..148}; do
      DEST=Copernicus_DSM_COG_10_S"$LAT"_00_E"$LONG"_00_DEM
      mkdir $DEST
      RS gadi:/g/data/v10/eoancillarydata-2/elevation/copernicus_30m_world/"$DEST"/"$DEST".tif  "$DEST"/
    done
  done
}
