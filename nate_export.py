from lsst.pipe.base.executionButlerBuilder import _accumulate, _export
from lsst.pipe.base import QuantumGraph
from lsst.daf.butler import Butler, DimensionUniverse


# Build a graph from the command line (use subsets and or labels with # to restrict to what you want to
# export. Likely need to use --output_run as well so it can be pointed at your existing collection. I can go
# into more detail if needed

butler = Butler("/repo/main")
du = DimensionUniverse()
graph = QuantumGraph.loadUri("central_six_coadd_9813.qgraph", universe=du)

export, _ = _accumulate(graph)

exportBuffer = _export(butler, ["HSC/RC2/defaults",], export) #, [], transfer='copy')

with open("coaddDatasetDump.yaml", 'w') as f:
    f.write(exportBuffer.getvalue())