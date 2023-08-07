#!/usr/bin/env bash

set -e  # Exit immediately on failures.

welcome="RC2_subset nightly processing"
underline=$(printf "%-${#welcome}s" | tr ' ' '-')
echo -e "$welcome\n$underline"

LSST_DISTRIB=$(eups list | grep lsst_distrib | grep setup)
if [ -n "$LSST_DISTRIB" ]; then
    echo -e "$LSST_DISTRIB\n"
else
    echo "The lsst_distrib package is not set up. Exiting."
    exit 1
fi
LSST_DISTRIB_EUPS=$(awk '{for (i=3; i<=NF; i++) printf "%s ", $i; print ""}' <<< "$LSST_DISTRIB")

RC2_SUBSET_EUPS=${RC2_SUBSET_EUPS:-setup}
echo "[RC2_SUBSET_EUPS] EUPS lsst_distrib: $RC2_SUBSET_EUPS"

RC2_SUBSET_LEVL=${RC2_SUBSET_LEVL:-INFO}
echo "[RC2_SUBSET_LEVL] Run logging level: $RC2_SUBSET_LEVL"

RC2_SUBSET_PROC=${RC2_SUBSET_PROC:-8}
echo "[RC2_SUBSET_PROC] Maximum processes: $RC2_SUBSET_PROC"

RC2_SUBSET_ARGS=${RC2_SUBSET_ARGS:-""}
echo "[RC2_SUBSET_ARGS] Extra config args: $RC2_SUBSET_ARGS"

RC2_SUBSET_REPO=${RC2_SUBSET_REPO:-$RC2_SUBSET_DIR/SMALL_HSC}
echo "[RC2_SUBSET_REPO] Butler repository: $RC2_SUBSET_REPO"

RC2_SUBSET_DEFS=${RC2_SUBSET_DEFS:-HSC/RC2_subset/defaults}
echo "[RC2_SUBSET_DEFS] Input collections: $RC2_SUBSET_DEFS"

RC2_SUBSET_COLL=${RC2_SUBSET_COLL:-u/$USER/RC2_subset/nightly}
echo "[RC2_SUBSET_COLL] Output collection: $RC2_SUBSET_COLL"

RC2_SUBSET_PIPE=${RC2_SUBSET_PIPE:-$DRP_PIPE_DIR/pipelines/HSC/DRP-RC2_subset.yaml}
echo "[RC2_SUBSET_PIPE] Pipeline def YAML: $RC2_SUBSET_PIPE"

# Check that required file paths exist.
paths=($RC2_SUBSET_PIPE)
for path in "${paths[@]}"; do
    if [ ! -e "$path" ]; then
        echo -e "\nERROR: Path does not exist: $path"
        exit 1
    fi
done

# Check that the currently set up lsst_distrib matches the expected EUPS tag.
if [[ ! $LSST_DISTRIB =~ $RC2_SUBSET_EUPS ]]; then
    cat >&2 << EOF

ERROR: This script expects lsst_distrib to be set up with the EUPS version tag:

    $RC2_SUBSET_EUPS

However, lsst_distrib is currently set up with the following EUPS version tags:

    $LSST_DISTRIB_EUPS

To resolve this, please either set up lsst_distrib with the expected EUPS tag:

    setup lsst_distrib -t $RC2_SUBSET_EUPS

or change the RC2_SUBSET_EUPS environment variable to match one of the
currently set up lsst_distrib EUPS version tags:

    RC2_SUBSET_EUPS=<TAG> ./run_rc2_subset.sh

EOF
    exit 1
fi

# Exit early unless '--run' is provided, to allow for check of defaults.
if [ ! "$1" = "--run" ]; then
    echo -e "\nRC2_subset nightly processing ready to run. Please use the '--run' argument to process data."
    exit 0
fi

# Capture the start time.
start_time=$(date +%s)

# Boilerplate pipetask run command.
# NOTE: The -p pipeline argument *must* be the last argument here, as subsets
#       are passed to the pipeline as a string immediately following this.
PIPETASK_RUN="pipetask --log-level $RC2_SUBSET_LEVL --long-log run --register-dataset-types $RC2_SUBSET_ARGS -b $RC2_SUBSET_REPO -i $RC2_SUBSET_DEFS -o $RC2_SUBSET_COLL -p $RC2_SUBSET_PIPE"

# Run the nightly pipeline steps.
cmd_1="$PIPETASK_RUN#nightlyStep1 -j $RC2_SUBSET_PROC"
echo -e "\nRunning nightlyStep1 on all RC2_subset visits\n$cmd_1"
eval $cmd_1

cmd_2a="$PIPETASK_RUN#nightlyStep2a -j $RC2_SUBSET_PROC"
echo -e "\nRunning nightlyStep2a on all RC2_subset visits\n$cmd_2a"
eval $cmd_2a

cmd_2b="$PIPETASK_RUN#nightlyStep2b -j $RC2_SUBSET_PROC -d \"skymap = 'hsc_rings_v1' AND tract = 9813\""
echo -e "\nRunning nightlyStep2b on tract 9813\n$cmd_2b"
eval $cmd_2b

cmd_2c="$PIPETASK_RUN#nightlyStep2c -c fgcmFitCycle:doPlots=False"
echo -e "\nRunning nightlyStep2c without multiprocessing\n$cmd_2c"
eval $cmd_2c

cmd_2d="$PIPETASK_RUN#nightlyStep2d -j $RC2_SUBSET_PROC"
echo -e "\nRunning nightlyStep2d on all RC2_subset visits\n$cmd_2d"
eval $cmd_2d

cmd_3="$PIPETASK_RUN#nightlyStep3 -j $RC2_SUBSET_PROC -d \"skymap = 'hsc_rings_v1' AND tract = 9813 AND patch in (40)\""
echo -e "\nRunning nightlyStep3 on tract 9813, patch 40\n$cmd_3"
eval $cmd_3

cmd_4="$PIPETASK_RUN#nightlyStep4 -j $RC2_SUBSET_PROC -d \"skymap = 'hsc_rings_v1' AND tract = 9813 AND patch in (40)\""
echo -e "\nRunning nightlyStep4 on tract 9813, patch 40\n$cmd_4"
eval $cmd_4

cmd_5="$PIPETASK_RUN#nightlyStep5 -j $RC2_SUBSET_PROC -d \"skymap = 'hsc_rings_v1' AND tract = 9813 AND patch in (40)\""
echo -e "\nRunning nightlyStep5 on tract 9813, patch 40\n$cmd_5"
eval $cmd_5

cmd_8="$PIPETASK_RUN#nightlyStep8 -j $RC2_SUBSET_PROC"
echo -e "\nRunning nightlyStep8 on tract 9813, patch 40\n$cmd_8"
eval $cmd_8

# Capture the end time and calculate the total runtime.
end_time=$(date +%s)
runtime=$((end_time - start_time))
hours=$((runtime / 3600))
minutes=$(( (runtime % 3600) / 60 ))
seconds=$((runtime % 60))
printf "\nTotal runtime: %02d:%02d:%02d\n" $hours $minutes $seconds
