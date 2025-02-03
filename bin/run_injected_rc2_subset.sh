#!/usr/bin/env bash

welcome="RC2_subset nightly processing with source injection"
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

set -e  # Exit immediately on failures from this point on.

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

RC2_SUBSET_COLL=${RC2_SUBSET_COLL:-u/$USER/RC2_subset/nightly}
echo "[RC2_SUBSET_COLL] Existing output collection (non-injected): $RC2_SUBSET_COLL"

RC2_SUBSET_INJECT_CATS=${RC2_SUBSET_INJECT_CATS:-injection/catalogs/DM-47887}
echo "[RC2_SUBSET_INJECT_CATS] Injection catalog input collection: $RC2_SUBSET_INJECT_CATS"

RC2_SUBSET_INJECT_COLL=${RC2_SUBSET_INJECT_COLL:-u/$USER/RC2_subset/injected_nightly}
echo "[RC2_SUBSET_INJECT_COLL] New injected output collection    : $RC2_SUBSET_INJECT_COLL"

RC2_SUBSET_INJECT_PIPE=${RC2_SUBSET_INJECT_PIPE:-$DRP_PIPE_DIR/pipelines/HSC/DRP-RC2_subset+injected_deepCoadd_stars.yaml}
echo "[RC2_SUBSET_INJECT_PIPE] Source injection pipeline def YAML: $RC2_SUBSET_INJECT_PIPE"

# Check that required file paths exist.
paths=($RC2_SUBSET_REPO $RC2_SUBSET_INJECT_PIPE)
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

    RC2_SUBSET_EUPS=<TAG> ./run_injected_rc2_subset.sh

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
INJECTED_PIPETASK_RUN="pipetask --log-level $RC2_SUBSET_LEVL --long-log run --register-dataset-types $RC2_SUBSET_ARGS -b $RC2_SUBSET_REPO -i $RC2_SUBSET_COLL,$RC2_SUBSET_INJECT_CATS -o $RC2_SUBSET_INJECT_COLL -p $RC2_SUBSET_INJECT_PIPE"

injected_cmd_3="$INJECTED_PIPETASK_RUN#injected_nightlyStep3 -j $RC2_SUBSET_PROC -d \"skymap = 'hsc_rings_v1' AND tract = 9813 AND patch in (40)\""
echo -e "\nRunning injected_nightlyStep3 on tract 9813, patch 40\n$injected_cmd_3"
eval $injected_cmd_3

injected_cmd_coadd_analysis="$INJECTED_PIPETASK_RUN#injected_stars_coadd_analysis -j $RC2_SUBSET_PROC -d \"skymap = 'hsc_rings_v1' AND tract = 9813 AND patch in (40)\""
echo -e "\nRunning injected_coadd_analysis on tract 9813, patch 40\n$injected_cmd_coadd_analysis"
eval $injected_cmd_coadd_analysis

# Capture the end time and calculate the total runtime.
end_time=$(date +%s)
runtime=$((end_time - start_time))
hours=$((runtime / 3600))
minutes=$(( (runtime % 3600) / 60 ))
seconds=$((runtime % 60))
printf "\nTotal runtime: %02d:%02d:%02d\n" $hours $minutes $seconds
