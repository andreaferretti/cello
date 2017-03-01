import random
import briefly

proc main() =
  const width = 1_000_000_000
  var b = bits(width)
  randomize(12435)

  for i in 0 .. <  width:
    if random(2) == 0:
      incl(b, i)

  let r = rrr(b)
  dumpNumberOfInstances()

when isMainModule:
  main()