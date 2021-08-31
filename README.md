# rc2_subset
A small subset of the RC2 dataset for running DRP

## Subset and Purpose
The intent of this subset is to provide a small gen3 compliant repository.
It could be used for measuring metrics in a CI environment.
It can also be used as a starting point for tutorials and examples for using the data butler and the stack.
Because it was intended to be small, it should not be treated as a dataset intended for passing milestones.

The dataset consists of the central 6 detectors for 8 randomly chosen visits in the 5 broad band filters.
These were specifically chosen from the COSMOS field, so that translational dither would be minimal and we could expsect the central chips to overlap each other.

As of 11 June, these data have been show to be sufficient to run through `step3` of the DRP pipeline.
However, some custom configuration is necessary, especially for FGCM.
This repository provides the configuration file used to do these processing testss.
It can be found in the `pipelines/DRP.yaml` file.

For more details about how the repository was constructed and how the processing was tested, see the file called `notes.txt`.

## Git LFS

To clone and use this repository, you'll need Git Large File Storage (LFS).

Our [Developer Guide](https://developer.lsst.io/tools/git_lfs.html) explains how to set up Git LFS for LSST development.
