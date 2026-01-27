#!/bin/bash

# Postprocess ARD Pipeline H5 results
# Extracts reflectance products from wagl/ARD pipeline HDF5 files &
# converts to images for previewing.

# USAGE:
# $ reflectance_post.sh <batch-directory>
# or
# $ bash reflectance_post.sh <batch-directory>


# LIMITATIONS:
# TODO: script assumes single H5 files exist for now

# Missing features:
# TODO: check 0-10,000 range assumption for reflectance products
# TODO: add Lambertian, NBAR/T naming to output files
# TODO: extract full size _PNG_ images from reflectance products?
# TODO: correct extracted path extensions?  e.g.  BAND-1.tiff to BAND-1.png
#       leaving the `tif` original prefix hints at the PNG source
# TODO: add override for pre existing files or mv/delete outputs?


# Runtime environment checks
if ! command -v gdal_translate &> /dev/null; then
    echo "ERROR: gdal_translate not detected. Is a conda env activated?"
    exit -2
fi

BATCH_DIR=$1

if [ -z $BATCH_DIR ]; then
  echo "ERROR: Specify a batch dir for the reflectance post processing script"
  exit -4
fi

if [ ! -e $BATCH_DIR ]; then
  echo "ERROR: $BATCH_DIR does not exist"
  exit -3
fi

# Search batch dir for wagl/ARD pipeline output
h5_path=$(find $BATCH_DIR -iname "*.wagl.h5")

if [ ! -e $h5_path ]; then
  # 'find' won't detect intermediate files
  echo 'ERROR: <granule-ID>.wagl.h5 found. Did the pipeline run fail?'
  exit 10
fi

# Extract H5 file index to text
h5_ls_path=$h5_path.ls.txt

if [ ! -e $h5_ls_path ]; then
  echo "Extracting $h5_path contents list to $h5_ls_path"
  wagl_ls --filename $h5_path > $h5_ls_path
fi

# Read root group to extract granule ID
granule=$(head -n 1 $h5_ls_path  | egrep -o L[0-9A-Z]+)

if [ -z "$granule" ]; then
  echo "granule ID not detected from $h5_ls_path"
  exit -1
fi


# Display header for logging
# Defer to here to prioritise fail fast for simple errors
echo 'ARD Pipeline: Reflectance Product Extraction'
echo "$(date)"
echo "Batch: $BATCH_DIR"
echo "Granule ID: $granule"
echo

resize_percent=25

# Find paths for all H5 reflectance product datasets
egrep -o "^/L.+/REFLECTANCE/(LAMBERTIAN|NBAR|NBART)/BAND-[0-9]{1,2}" $h5_ls_path | while read -r band_group; do

  # Prep TIFF output path. No dir separator as 'band_group' has a leading slash
  TIFF_PATH="$BATCH_DIR$band_group.tif"

  product=$(echo  $band_group | egrep -o "\b(LAMBERTIAN|NBAR|NBART)\b")

  if [ ! -e $TIFF_PATH ]; then
    # Extract H5 dataset to BATCH_DIR, avoid creating deep directory trees
    wagl_convert --filename $h5_path \
                 --pathname $band_group \
                 --outdir $BATCH_DIR && echo "Extracted: $TIFF_PATH (product: $product)"

    # TODO: rename output files with $product for clarity
  else
    echo "$TIFF_PATH exists, extraction skipped"
  fi

  # Display data Min/Max for each TIFF
  # TODO: add error checking (need to split the values for a 0/1 - 10,000 check
  gdalinfo -mm $TIFF_PATH | egrep -o "Min\/Max=[0-9]+[.][0-9]+,[0-9]+[.][0-9]+"

  # Resize TIFF to a preview image for easy viewing
  # Scale grey to 15-255 to allow 0/black for NODATA & avoid dark images
  resized_path="$TIFF_PATH.$resize_percent"_percent.png

  gdal_translate -q \
                 -ot Byte \
                 -outsize $resize_percent% $resize_percent% \
                 -scale 1 10000 15 255 \
                 -a_nodata 0 \
                 $TIFF_PATH  $resized_path && echo "Converted: $resized_path"
  echo

  # full_path="$tiff_path".png
  # gdal_translate -q -ot Byte -scale 0 10000 15 255  $tiff_path $full_path
  # echo "Converted full_path"

done
