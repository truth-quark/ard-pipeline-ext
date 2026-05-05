"""
Quick & dirty tool to list input files required for ARD processing an acquisition.
"""

# TODO v10 ancils
# TODO does CopDEM have an S3 reader? YES


import os
import sys
import wagl
from wagl import era5
from wagl import merra2
from wagl.acquisition import acquisitions


def main(acq_path):
    assert os.path.exists(acq_path)
    container = acquisitions(acq_path)
    acq = container.get_highest_resolution()[0][0]
    assert acq.acquisition_datetime

    era5_base_dir = os.environ["ERA5_DATA_DIR"]

    pressure_paths, single_paths = era5.build_all_era5_paths(
        era5_base_dir,
        era5.ERA5_PRESSURE_LEVELS_VARIABLES,
        era5.ERA5_SINGLE_LEVEL_VARIABLES,
        acq.acquisition_datetime
    )

    era5_ozone_path = era5.build_era5_path(
        era5_base_dir,
        era5.ERA5_TOTAL_COLUMN_OZONE,
        acq.acquisition_datetime,
        single=True
    )

    merra2_base_dir = os.environ["MERRA2_BASE_DIR"]
    merra2_path = merra2.build_merra2_path(
        merra2_base_dir, acq.acquisition_datetime
    )

    # reporting
    print("Ancillary Data")
    print()

    # ERA5 deals with atmospheric column & surface level data
    print("ERA5 data\n")
    print("Pressure levels paths")
    for v, p in zip(era5.ERA5_PRESSURE_LEVELS_VARIABLES, pressure_paths):
        print(f"{v}: {p}")

    print()
    print("Single levels paths")
    for v, p in zip(era5.ERA5_SINGLE_LEVEL_VARIABLES, single_paths):
        print(f"{v}: {p}")

    print("\nOzone path")
    print(era5_ozone_path

    # MERRA2 paths (deals with aerosols)
    print("\n\nMERRA2 data")
    print(merra2_path)


if __name__ == "__main__":
    main(sys.argv[1])
