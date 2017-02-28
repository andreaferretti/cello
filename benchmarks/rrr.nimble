# Package

version       = "0.1.0"
author        = "Andrea Ferretti"
description   = "Succinct data structures"
license       = "Apache2"

# Dependencies

requires "nim >= 0.16.0", "stopwatch 3.2"

task benchmark, "run briefly benchmarks":
  --define: release
  --path: ".."
  --run
  setCommand "c", "rrr.nim"