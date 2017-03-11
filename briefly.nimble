# Package

version       = "0.1.0"
author        = "Andrea Ferretti"
description   = "Succinct data structures"
license       = "Apache2"
skipFiles     = @["bitopts.nim"] # To be removed when it lands in devel
skipDirs      = @["tests", "benchmarks"]

# Dependencies

requires "nim >= 0.16.0"

task test, "run briefly tests":
  --hints: off
  --linedir: on
  --stacktrace: on
  --linetrace: on
  --debuginfo
  --path: "."
  --run
  setCommand "c", "tests/test.nim"

task tests, "run briefly tests":
  setCommand "test"

task benchmarkRRR, "benchmark RRR bit array":
  withDir "benchmarks":
    exec "nimble benchmarkRRR"

task benchmarkWT, "benchmark wavelet tree":
  withDir "benchmarks":
    exec "nimble benchmarkWT"

task benchmarkBW, "benchmark Burrows-Wheeler transform":
  withDir "benchmarks":
    exec "nimble benchmarkBW"

task spaceRRR, "run briefly space benchmarks":
  --define: release
  --define: nimTypeNames
  --path: "."
  --run
  setCommand "c", "benchmarks/space.nim"

task spaceWT, "run briefly space benchmarks":
  --define: release
  --define: nimTypeNames
  --path: "."
  --run
  setCommand "c", "benchmarks/wavelet_tree_space.nim"