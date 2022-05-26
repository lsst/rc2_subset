#!/usr/bin/env bash

set -e

pipetask --long-log run -j $NUMPROC -b ${RC2_SUBSET_DIR}/SMALL_HSC/butler.yaml -p ${RC2_SUBSET_DIR}'/pipelines/DRP.yaml#nightlyStep1' -i HSC/RC2/defaults --register-dataset-types -o jenkins/step1

echo "Running step2a on all visits"
pipetask --long-log run -j $NUMPROC -b ${RC2_SUBSET_DIR}/SMALL_HSC/butler.yaml -p ${RC2_SUBSET_DIR}'/pipelines/DRP.yaml#nightlyStep2a' -i jenkins/step1 --register-dataset-types -o jenkins/step2

echo "Running step2b on tract 9813"
pipetask --long-log run -j $NUMPROC -b ${RC2_SUBSET_DIR}/SMALL_HSC/butler.yaml -p ${RC2_SUBSET_DIR}'/pipelines/DRP.yaml#nightlyStep2b'  -d "tract = 9813 and skymap = 'hsc_rings_v1'" --register-dataset-types -o jenkins/step2

echo "Running step2c without multiprocessing"
pipetask --long-log run -b ${RC2_SUBSET_DIR}/SMALL_HSC/butler.yaml -p ${RC2_SUBSET_DIR}'/pipelines/DRP.yaml#nightlyStep2c' --register-dataset-types -o jenkins/step2

echo "Running step2d on all visits"
pipetask --long-log run -j $NUMPROC -b ${RC2_SUBSET_DIR}/SMALL_HSC/butler.yaml -p ${RC2_SUBSET_DIR}'/pipelines/DRP.yaml#nightlyStep2d' --register-dataset-types -o jenkins/step2

pipetask --long-log run -j $NUMPROC -b ${RC2_SUBSET_DIR}/SMALL_HSC/butler.yaml -p ${RC2_SUBSET_DIR}'/pipelines/DRP.yaml#nightlyStep3' -d "tract = 9813 and skymap = 'hsc_rings_v1' AND patch in (40)" -i jenkins/step2 --register-dataset-types -o jenkins/step3

pipetask --long-log run -j $NUMPROC -b ${RC2_SUBSET_DIR}/SMALL_HSC/butler.yaml -p ${RC2_SUBSET_DIR}'/pipelines/DRP.yaml#nightlyStep4' -d "tract = 9813 and skymap = 'hsc_rings_v1' AND patch in (40)" -i jenkins/step3 --register-dataset-types -o jenkins/step4

pipetask --long-log run -j $NUMPROC -b ${RC2_SUBSET_DIR}/SMALL_HSC/butler.yaml -p ${RC2_SUBSET_DIR}'/pipelines/DRP.yaml#nightlyStep5' -d "tract = 9813 and skymap = 'hsc_rings_v1' AND patch in (40)" -i jenkins/step4 --register-dataset-types -o jenkins/step5

${FARO_DIR}/bin/make_job_document.py ${RC2_SUBSET_DIR}/SMALL_HSC jenkins/step3
${FARO_DIR}/bin/make_job_document.py ${RC2_SUBSET_DIR}/SMALL_HSC jenkins/step5
${FARO_DIR}/bin/make_job_document.py ${RC2_SUBSET_DIR}/SMALL_HSC jenkins/step5 --metrics_package "pipe_analysis"
