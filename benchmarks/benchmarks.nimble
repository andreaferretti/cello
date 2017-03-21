# Package

version       = "0.1.0"
author        = "Andrea Ferretti"
description   = "Succinct data structures benchmarks"
license       = "Apache2"

# Dependencies

requires "nim >= 0.16.0", "stopwatch >= 3.2", "spills >= 0.1.1"

task benchmarkRRR, "benchmark RRR bit array":
  --define: release
  --path: ".."
  --run
  setCommand "c", "rrr.nim"

task benchmarkWT, "benchmark wavelet tree":
  --define: release
  --path: ".."
  --run
  setCommand "c", "wavelet_tree.nim"

task benchmarkBW, "benchmark Burrows-Wheeler transform":
  --define: release
  --path: ".."
  --run
  setCommand "c", "burrows_wheeler.nim"

task benchmarkFM, "benchmark FM indices":
  --define: release
  --path: ".."
  --run
  setCommand "c", "fm_index.nim"

task spaceRRR, "benchmark the space of RRR bit array":
  --define: release
  --define: nimTypeNames
  --path: ".."
  --run
  setCommand "c", "rrr_space.nim"

task spaceWT, "benchmark the space of wavelet tree":
  --define: release
  --define: nimTypeNames
  --path: ".."
  --run
  setCommand "c", "wavelet_tree_space.nim"