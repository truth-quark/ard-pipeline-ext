# Postprocess ARD Pipeline H5 results
# Extract reflectance products & convert to images
# TODO: assumes single H5 for now


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

# Find paths to all reflectance products
# Extracts H5 tree to current dir, another <granule-id> dir
egrep -o "^/L.+/REFLECTANCE/(LAMBERTIAN|NBAR|NBART)/BAND-[0-9]{1,2}" $h5_ls_path | while read -r line; do

  if [ ! -e ./$line.tif ]; then
    wagl_convert --filename $h5_path  --pathname $line  --outdir .
    echo "Extracted $line"
  fi
done

echo "Converting reflectance product TIFFs to PNGs"

resize=25

find ./$granule -iname "*.tif" | while read -r line; do
  # gdal_translate -q -ot Byte -scale 0 10000 0 255  $line $line.png

  # TODO: correct the extensions?

  # Scale output to 15 255 to allow NODATA as 0/black & avoid dark images

  # resize preview image
  # convert to 15 255 to allow NODATA as 0/black & avoid dark images
  resized="$line.$resize"_percent.png
  # echo $resized
  gdal_translate -q -ot Byte -outsize $resize% $resize% -scale 0 10000 15 255  $line  $resized  2>/dev/null
  echo "Converted $resized"

  # TODO: extract full size image?
  # gdal_translate -q -ot Byte -scale 0 10000 15 255  $line $line.full.png 2>/dev/null
  # echo "Converted $line.png"

done
