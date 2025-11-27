#!/bin/bash

# Postprocess ARD Pipeline H5 results
# Extract reflectance products & convert to images
# TODO: assumes single H5 for now

# Missing features:
# TODO: check 0-10,000 range assumption for reflectance products
# TODO: add Lambertian, NBAR/T naming to output files
# TODO: extract full size images from reflectance products?
# TODO: correct extracted path extensions?  e.g.  BAND-1.tiff to BAND-1.png
#       leaving the `tif` original prefix hints at the PNG source


# Runtime environment checks
if ! command -v gdal_translate &> /dev/null; then
    echo "ERROR: gdal_translate not detected. Is a conda env activated?"
    exit -2
fi

# TODO: update to find in a pipeline batch dir
h5_path=$(find . -iname "*.wagl.h5")
h5_ls_path=$h5_path.ls.txt

if [ ! -e $h5_ls_path ]; then
  echo "Extracting $h5_path contents list"
  wagl_ls --filename $h5_path > $h5_ls_path
fi

# Read root group as it is the graunle ID
granule=$(head -n 1 $h5_ls_path  | egrep -o L[0-9A-Z]+)

if [ -z "$granule" ]; then
  echo "granule ID not detected from $h5_ls_path"
  exit -1
fi

echo Granule ID: "$granule"

# Find H5 group paths to all reflectance products
# Extracts H5 data tree to current dir, rooted in another <granule-id> dir
egrep -o "^/L.+/REFLECTANCE/(LAMBERTIAN|NBAR|NBART)/BAND-[0-9]{1,2}" $h5_ls_path | while read -r band_group; do

  if [ ! -e ./$band_group.tif ]; then
    wagl_convert --filename $h5_path  --pathname $band_group  --outdir . && echo "Extracted $band_group"
  fi
done

echo "Converting reflectance product TIFFs to PNGs"

resize_percent=25

find ./$granule -iname "*.tif" | while read -r tiff_path; do
  # Extract a resized preview image
  # Scale grey from 15-255 to allow 0/black for NODATA & avoid dark images
  resized_path="$tiff_path.$resize_percent"_percent.png

  gdal_translate -q \
                 -ot Byte \
                 -outsize $resize_percent% $resize_percent% \
                 -scale 0 10000 15 255 \
                 -a_nodata 0 \
                 $tiff_path  $resized_path && echo "Converted $resized_path"

  # full_path="$tiff_path".png
  # gdal_translate -q -ot Byte -scale 0 10000 15 255  $tiff_path $full_path
  # echo "Converted full_path"

done
