"""
Read a BOXLINE.csv file & convert start, bisection & end points to GeoJSON.

BOXLINE.csv likely needs to be extracted from a `wagl.h5` intermediate file.

Prints a GeoJSON FeatureCollection formatted string to the console.
"""

import csv
import sys
import pathlib

import geojson


def features(rows):
    """
    For each row, yields start, bisection & end points as geojson.Feature objs.
    """

    reader = csv.reader(rows)
    header = reader.__next__()

    for row in reader:
        r_id = row[0]

        (bisection_longitude,
        bisection_latitude,
        start_longitude,
        start_latitude,
        end_longitude,
        end_latitude) = [float(n) for n in row[-6:]]

        # emit points, likely left to right
        start_pt = geojson.Point((start_longitude, start_latitude))
        start_feat = geojson.Feature(id=f"{r_id}_start", geometry=start_pt)
        yield start_feat

        bisect_pt = geojson.Point((bisection_longitude, bisection_latitude))
        bisect_feat = geojson.Feature(id=f"{r_id}_bisect", geometry=bisect_pt)
        yield bisect_feat

        end_pt = geojson.Point((end_longitude, end_latitude))
        end_feat = geojson.Feature(id=f"{r_id}_end", geometry=end_pt)
        yield end_feat


if __name__ == "__main__":
    csv_path = pathlib.Path(sys.argv[1])
    assert csv_path.exists()

    with open(csv_path) as f:
        collection = geojson.FeatureCollection(list(features(f.readlines())))

    print(geojson.dumps(collection))
