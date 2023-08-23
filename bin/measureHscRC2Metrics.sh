#!/usr/bin/env bash

set -e

REPO=${RC2_SUBSET_DIR}/SMALL_HSC
OUTPUT_COLLECTION_STUB="jenkins"
RC2_SUBSET_PIPELINE=${DRP_PIPE_DIR}/pipelines/HSC/DRP-RC2_subset.yaml

echo "Running nightlyStep1 on all visits"
pipetask --long-log run --register-dataset-types -j $NUMPROC -b $REPO -i HSC/RC2/defaults -o $OUTPUT_COLLECTION_STUB/step1 -p $RC2_SUBSET_PIPELINE#nightlyStep1

echo "Running nightlyStep2a on all visits"
pipetask --long-log run --register-dataset-types -j $NUMPROC -b $REPO -i $OUTPUT_COLLECTION_STUB/step1 -o $OUTPUT_COLLECTION_STUB/step2 -p $RC2_SUBSET_PIPELINE#nightlyStep2a

echo "Running nightlyStep2b on tract 9813"
pipetask --long-log run --register-dataset-types -j $NUMPROC -b $REPO -o $OUTPUT_COLLECTION_STUB/step2 -p $RC2_SUBSET_PIPELINE#nightlyStep2b -d "skymap = 'hsc_rings_v1' AND tract = 9813"

echo "Running nightlyStep2c without multiprocessing"
pipetask --long-log run --register-dataset-types -b $REPO -o $OUTPUT_COLLECTION_STUB/step2 -p $RC2_SUBSET_PIPELINE#nightlyStep2c

echo "Running nightlyStep2d on all visits"
pipetask --long-log run --register-dataset-types -j $NUMPROC -b $REPO -o $OUTPUT_COLLECTION_STUB/step2 -p $RC2_SUBSET_PIPELINE#nightlyStep2d

echo "Running nightlyStep3 on tract 9813, patch 40"
pipetask --long-log run --register-dataset-types -j $NUMPROC -b $REPO -i $OUTPUT_COLLECTION_STUB/step2 -o $OUTPUT_COLLECTION_STUB/step3 -p $RC2_SUBSET_PIPELINE#nightlyStep3 -d "skymap = 'hsc_rings_v1' AND tract = 9813 AND patch in (40)"

echo "Running nightlyStep4 on tract 9813, patch 40"
pipetask --long-log run --register-dataset-types -j $NUMPROC -b $REPO -i $OUTPUT_COLLECTION_STUB/step3 -o $OUTPUT_COLLECTION_STUB/step4 -p $RC2_SUBSET_PIPELINE#nightlyStep4 -d "skymap = 'hsc_rings_v1' AND tract = 9813 AND patch in (40)"

echo "Running nightlyStep5 on tract 9813, patch 40"
pipetask --long-log run --register-dataset-types -j $NUMPROC -b $REPO -i $OUTPUT_COLLECTION_STUB/step4 -o $OUTPUT_COLLECTION_STUB/step5 -p $RC2_SUBSET_PIPELINE#nightlyStep5 -d "skymap = 'hsc_rings_v1' AND tract = 9813 AND patch in (40) AND band in ('g', 'r', 'i', 'z', 'y')"

echo "Running make_job_document.py faro script"
${FARO_DIR}/bin/make_job_document.py $REPO $OUTPUT_COLLECTION_STUB/step3
${FARO_DIR}/bin/make_job_document.py $REPO $OUTPUT_COLLECTION_STUB/step5
${FARO_DIR}/bin/make_job_document.py $REPO $OUTPUT_COLLECTION_STUB/step5 --metrics_package "pipe_analysis"
