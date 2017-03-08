import random
import briefly

const width = 1_000_000_000

proc makeWaveletTree(): auto =
  var b = newString(width)
  let letters = ['A', 'C', 'G', 'T']
  randomize(12435)

  for i in 0 .. <  width:
    b[i] = letters[random(4)]

  return waveletTree(b)

proc main() =
  let b = makeWaveletTree()
  GC_fullCollect()
  echo GC_getStatistics()
  dumpNumberOfInstances()
  echo "Number of bytes needed for raw data: ", (width div 8)
  echo "Number of bits: ", b.stats

when isMainModule:
  main()