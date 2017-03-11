# Package

version       = "0.1.0"
author        = "Andrea Ferretti"
description   = "Succinct data structures"
license       = "Apache2"

# Dependencies

requires "nim >= 0.16.0", "stopwatch 3.2"

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