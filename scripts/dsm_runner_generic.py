"""
Run DSM creation for the provided Landsat scene.
"""

import os
import sys
import datetime

import h5py

from wagl.acquisition import acquisitions
from wagl.dsm import get_dsm

assert len(sys.argv) == 4, " Args: CopDEM dir, level1_path, job descriptor (no whitespace)"
_, cop_path, level1, job_desc = sys.argv

assert os.path.exists(cop_path)
assert os.path.exists(level1)

now = datetime.datetime.now()
timestamp = now.strftime("%Y%m%d-%H%M%S")
out_path = f"{timestamp}_{job_desc}_dsm.wagl.h5"

# TODO: is there ever a need to specify both SRTM & CopDEM?
srtm_path = ""  # None causes sloppy DSM logic to break

# compression=H5CompressionFilter.BITSHUFFLE

container = acquisitions(level1)

if len(container.granules) > 1:
    raise NotImplementedError("Only handles single granules")

granule = container.granules[0]

with h5py.File(out_path, "a") as fid:
    fid.attrs["level1_uri"] = level1

    try:
        root = fid[granule]
    except Exception:
        root = fid.create_group(granule)

    acq = container.get_highest_resolution()[0][0]
    get_dsm(acq, srtm_path, cop_path, out_group=root)
