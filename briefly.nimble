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

task benchmarkRRR, "run briefly benchmarks":
  withDir "benchmarks":
    exec "nimble benchmarkRRR"

task benchmarkWT, "run briefly benchmarks":
  withDir "benchmarks":
    exec "nimble benchmarkWT"

task space, "run briefly space benchmarks":
  --define: release
  --define: nimTypeNames
  --path: "."
  --run
  setCommand "c", "benchmarks/space.nim"