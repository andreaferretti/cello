import times, random
import briefly

proc main() =
  const
    width = 10_000_000
    ops = 10000
  echo "Initialization starting"
  randomize(12435)
  var
    b = bits(width)
    indices = newSeq[int]()

  for i in 0 .. <  width:
    if random(2) == 0:
      incl(b, i)

  for _ in 0 .. < ops:
    indices.add(random(width))

  echo "Initialization done"

  let
    r = rrr(b)
    startTime = epochTime()

  for j, i in indices:
    discard r.rank(i)
    if j mod 100 == 0:
      echo j
  let endTime = epochTime()

  echo "We have required ", endTime - startTime, " seconds to compute ", ops, " ranks."

when isMainModule:
  main()