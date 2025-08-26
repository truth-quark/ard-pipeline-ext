"""
Micro utility displays min/max lat/longs for a provided scene.
"""

import sys

from wagl import acquisition
from osgeo import osr


# TODO: does this work with Sentinel data?
# TODO: handle raw TIFF files
def get_extents(scene_path):
    container = acquisition.acquisitions(scene_path)
    acq = container.get_highest_resolution()[0][0]
    geobox = acq.gridded_geo_box()

    wgs84_crs = osr.SpatialReference()
    wgs84_crs.ImportFromEPSG(4326)
    lat_lon_extents = geobox.project_extents(wgs84_crs)
    return lat_lon_extents

if __name__ == "__main__":
    path = sys.argv[1]
    min_long, min_lat, max_long, max_lat = get_extents(path)
    print(f"max_lat={max_lat}, max_long={max_long})")
    print(f"min_lat={min_lat}, min_long={min_long})")
