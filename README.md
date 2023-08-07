# rc2_subset

A small subset of the RC2 dataset for running data release production (DRP) data reduction pipelines.

## Subset and Purpose

The intent of this subset is to provide a small gen3 compliant repository.
It could be used for measuring metrics in a CI environment.
It can also be used as a starting point for tutorials and examples for using the data butler and the stack.
Because it was intended to be small, it should not be treated as a dataset intended for passing milestones.

The dataset consists of 6 central detectors for 8 randomly chosen visits in all 5 HSC broad band filters.
These were specifically chosen from the COSMOS field, so that translational dither would be minimal and we could expect the central chips to overlap each other.

As of 11 June 2022, these data have been shown to be sufficient to run through `step3` of the DRP pipeline.
Some custom configuration is necessary however, especially for FGCM.
The pipeline definition YAML file containing this custom configuration can be found in `$DRP_PIPE_DIR/pipelines/HSC/DRP-RC2_subset.yaml`.

For more details about how the repository was constructed and how the processing was tested, see the file called `notes.txt`.

## Git LFS

To clone and use this repository, you'll need Git Large File Storage (LFS).

Our [Developer Guide](https://developer.lsst.io/git/git-lfs.html) explains how to set up Git LFS for LSST development.

## Using rc2_subset

To process RC2 subset data locally, first set up `lsst_distrib` and a locally cloned version of the `rc2_subset` package.
Then, on the command line, run:

```shell=
$RC2_SUBSET_DIR/bin/run_rc2_subset.sh
```

This command will not process any data until `--run` is appended to the command.
Instead, it prints the environment variables that _would_ be used to process RC2 subset data and performs some initial checks that the environment is set up correctly.
If the environment is not set up correctly, the script will print an error message with more information and exit.

A number of environment variables can be customized for a given RC2 subset data processing run.
These variable names are listed by the `run_rc2_subset.sh` script inside square brackets (e.g., `[RC2_SUBSET_PROC]`) alongside a brief description for each and their current value.
For example, to reduce the maximum number of processors to use from the default value of 8 down to 4, run:

```shell=
RC2_SUBSET_PROC=4 \
$RC2_SUBSET_DIR/bin/run_rc2_subset.sh
```

Finally, when you are ready to process data, append `--run` to your command:

```shell=
RC2_SUBSET_PROC=4 \
$RC2_SUBSET_DIR/bin/run_rc2_subset.sh --run
```
