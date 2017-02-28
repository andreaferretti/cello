import stopwatch, random
import briefly

proc main() =
  const
    width = 1_000_000
    ops = 10000
  echo "Initialization starting"
  randomize(12435)
  var
    b = bits(width)
    indices = newSeq[int]()
    sw = stopwatch()

  for i in 0 .. <  width:
    if random(2) == 0:
      incl(b, i)

  for _ in 0 .. < ops:
    indices.add(random(width))

  let r = rrr(b)
  echo "Initialization done"

  sw.start()
  for i in indices:
    discard r.rank(i)
  sw.stop()

  echo "We have required ", sw.secs(), " seconds to compute ", ops, " ranks."

when isMainModule:
  main()