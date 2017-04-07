# Package

version       = "0.1.0"
author        = "Andrea Ferretti"
description   = "String algorithms with succinct data structures"
license       = "Apache2"
skipDirs      = @["tests", "benchmarks"]

# Dependencies

requires "nim >= 0.16.0", "spills >= 0.1.1"

task test, "run cello tests":
  --hints: off
  --linedir: on
  --stacktrace: on
  --linetrace: on
  --debuginfo
  --path: "."
  --run
  setCommand "c", "tests/test.nim"

task tests, "run cello tests":
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

task benchmarkFM, "benchmark FM indices":
  withDir "benchmarks":
    exec "nimble benchmarkFM"

task benchmarkRO, "benchmark Ratcliff-Obershelp similarity":
  withDir "benchmarks":
    exec "nimble benchmarkRO"

task spaceRRR, "benchmark the space of RRR bit array":
  withDir "benchmarks":
    exec "nimble spaceRRR"

task spaceWT, "benchmark the space of wavelet tree":
  withDir "benchmarks":
    exec "nimble spaceWT"