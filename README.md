# rc2_subset
A small subset of the RC2 dataset for running DRP

## Subset and Purpose
The intent of this subset is to provide a small gen3 compliant repository.
It could be used for measuring metrics in a CI environment.
It can also be used as a starting point for tutorials and examples for using the data butler and the stack.
Because it was intended to be small, it should not be treated as a dataset intended for passing milestones.

The dataset consists of the central 6 detectors for 8 randomly chosen visits in the 5 broad band filters.
These were specifically chosen from the COSMOS field, so that translational dither would be minimal and we could expect the central chips to overlap each other.

As of 11 June 2022, these data have been shown to be sufficient to run through `step3` of the DRP pipeline.
However, some custom configuration is necessary, especially for FGCM.
The pipeline definition YAML file containing this custom configuration can be found in `$DRP_PIPE_DIR/pipelines/HSC/DRP-rc2_subset.yaml`.

For more details about how the repository was constructed and how the processing was tested, see the file called `notes.txt`.

## Git LFS

To clone and use this repository, you'll need Git Large File Storage (LFS).

Our [Developer Guide](https://developer.lsst.io/git/git-lfs.html) explains how to set up Git LFS for LSST development.

## Using rc2_subset

To run rc2_subset, first set up a locally cloned version of this package.
Then run on the command line:

```shell=
NUMPROC=X $RC2_SUBSET_DIR/bin/measureHscRC2Metrics.sh
```

where `NUMPROC=X` sets the desired number of processors to run each `pipetask run` job on.
