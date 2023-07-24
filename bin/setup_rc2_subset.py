#!/usr/bin/env python

"""Make a subset of the RC2 dataset.

This script makes a subset of the RC2 dataset using a predefined list of
visits. An output TAGGED collection for the subset is created in the repo,
alongside the necessary CHAINED defaults input collection.
"""

import logging
import sys
from argparse import ArgumentDefaultsHelpFormatter, ArgumentParser

from lsst.daf.butler import Butler, CollectionType
from lsst.daf.butler.cli.butler import cli
from lsst.daf.butler.cli.utils import LogCliRunner
from lsst.daf.butler.registry import MissingCollectionError

parser = ArgumentParser(
    description="""Set up the RC2 dataset data processing inputs.

    This function registers a new TAGGED collection containing a subset of the
    RC2 dataset, and a CHAINED collection containing the required defaults for
    RC2 processing.
    The subset is defined by a predefined list of visits and detectors.

    It should only be necessary to run this function once per repo.
    """,
    formatter_class=ArgumentDefaultsHelpFormatter,
)
parser.add_argument("REPO", help="URI or path to an existing data repository root or configuration file")
parser.add_argument("-a", "--all", default="HSC/raw/all", help="Input collection containing raws to subset")
parser.add_argument("-r", "--raw", default="HSC/raw/RC2_subset", help="Output collection with TAGGED raws")
parser.add_argument("-d", "--defaults", default="HSC/RC2_subset/defaults", help="Output CHAINED defaults")
args = parser.parse_args()

# Set up logging
logging.basicConfig(
    level=logging.INFO,
    format="%(levelname)s %(asctime)s.%(msecs)03d - %(message)s",
    datefmt="%Y-%m-%dT%H:%M:%S",
)
log = logging.getLogger(__file__)

writeable_butler = Butler(args.REPO, writeable=True)
log.info("Instantiated a writeable Butler: %s", args.REPO)

# Do not proceed if output CHAINED collection already exists.
try:
    _ = writeable_butler.registry.queryCollections(args.defaults)
    log.info("Output CHAINED collection '%s' already exists. Exiting.", args.defaults)
    sys.exit(0)
except MissingCollectionError:
    pass

# Define the DatasetRefs associated with this subset.
COSMOS_G_SUBSET = (11690, 11694, 11696, 11698, 11704, 11710, 29336, 29350)
COSMOS_R_SUBSET = (1204, 1206, 1214, 1220, 23694, 23704, 23706, 23718)
COSMOS_I_SUBSET = (1242, 1248, 19680, 19684, 19694, 19696, 30482, 30490)
COSMOS_Z_SUBSET = (1178, 1184, 17900, 17904, 17906, 17926, 17948, 17950)
COSMOS_Y_SUBSET = (322, 346, 358, 11724, 11738, 11740, 22632, 22662)
COSMOS_SUBSET = COSMOS_G_SUBSET + COSMOS_R_SUBSET + COSMOS_I_SUBSET + COSMOS_Z_SUBSET + COSMOS_Y_SUBSET
DETECTOR_SUBSET = (41, 42, 47, 49, 50, 58)
expected_num_datasetRefs = len(COSMOS_SUBSET) * len(DETECTOR_SUBSET)
subset_where = f"instrument='HSC' AND visit IN {COSMOS_SUBSET} AND detector IN {DETECTOR_SUBSET}"
datasetRefs = writeable_butler.registry.queryDatasets("raw", collections=args.all, where=subset_where)
if (actual_num_datasetRefs := datasetRefs.count()) != expected_num_datasetRefs:
    log.error(
        "Expected %d DatasetRefs but found %d. Check the subset definition.",
        expected_num_datasetRefs,
        actual_num_datasetRefs,
    )
    sys.exit(1)
log.info("Identified %d DatasetRefs in the repo to be tagged.", datasetRefs.count())

# Register a new raw-data TAGGED collection if it doesn't already exist.
# This returns False if the collection already exists (essentially a no-op).
new = writeable_butler.registry.registerCollection(args.raw, CollectionType.TAGGED)
if not new:
    log.info("Using existing TAGGED collection: %s", args.raw)
else:
    log.info("Registered a new TAGGED collection: %s", args.raw)

# Associate DatasetRefs with the new TAGGED collection.
# If a DatasetRef with the same ID already exists, nothing is changed.
writeable_butler.registry.associate(args.raw, datasetRefs)

# Make a CHAINED collection for standard processing.
writeable_butler.registry.registerCollection(args.defaults, CollectionType.CHAINED)
writeable_butler.registry.setCollectionChain(
    args.defaults,
    [args.raw, "HSC/calib", "HSC/masks", "HSC/fgcmcal/lut/RC2", "refcats", "skymaps"],
)
runner = LogCliRunner()
chained_collections = runner.invoke(cli, ["query-collections", args.REPO, "HSC/RC2_subset/defaults"])
log.info("Registered defaults CHAINED collection: %s\n%s", args.defaults, chained_collections.stdout)
