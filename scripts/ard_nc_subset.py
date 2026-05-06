"""
Quick & dirty tool to subset ARD ancillary files required for ARD processing.
"""

# TODO any v10 ancils?

# TODO: cut down the data to the minimum viable time slice to enable small data
#       subsets for testing.


ERA5_SINGLE_LEVEL_VARIABLES = ("2t", "z", "sp", "2d")
ERA5_PRESSURE_LEVELS_VARIABLES = ("r", "t", "z")


import os
import sys
import wagl
from wagl import era5
from wagl import merra2
from wagl.acquisition import acquisitions


def main(acq_path, outdir="./converted"):
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

    # generate ncks commands for ERA5 data
    # TODO: de-duplicate the ncks command string
    timestep_index = hour_index(acq.acquisition_datetime)

    for var, path in zip(ERA5_SINGLE_LEVEL_VARIABLES, single_paths):
        output_path = era5.build_era5_path(outdir, var, acq.acquisition_datetime, True)

        # subset time steps either side of the acquisition time
        cmd = f"ncks -d time,{timestep_index},{timestep_index+1} {path} {output_path}"
        print(cmd)

    for var, path in zip(ERA5_PRESSURE_LEVELS_VARIABLES, pressure_paths):
        output_path = era5.build_era5_path(outdir, var, acq.acquisition_datetime, False)
        cmd = f"ncks -d time,{timestep_index},{timestep_index+1} {path} {output_path}"
        print(cmd)


    raise NotImplementedError("Remove when ERA5 done")


def hour_index(_datetime):
    day = _datetime.day
    hour = _datetime.hour
    index = ((day - 1) * 24) + hour
    return index


if __name__ == "__main__":
    assert os.environ["ERA5_DATA_DIR"], "Set ERA5_DATA_DIR env var"
    assert os.environ["MERRA2_DATA_DIR"], "Set MERRA2_DATA_DIR env var"

    acq_path = sys.argv[1]
    assert os.path.exists(acq_path)
    main(acq_path)
