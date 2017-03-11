import random
import briefly

const width = 1_000_000_000

proc makeRRR(): auto =
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
  echo "Number of bytes needed for raw data: ", (width div 8)
  echo "Number of bits: ", r.stats

when isMainModule:
  main()