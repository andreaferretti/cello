import random
import briefly

proc makeRRR(): auto =
  const width = 1_000_000_000
  var b = bits(width)
  randomize(12435)

  for i in 0 .. <  width:
    if random(2) == 0:
      incl(b, i)

  return rrr(b)

proc main() =
  let r = makeRRR()
  GC_fullCollect()
  echo GC_getStatistics()
  dumpNumberOfInstances()

when isMainModule:
  main()