import times, random
import briefly

proc main() =
  const
    width = 1_000_000
    ops = 10000
  echo "Initialization starting"
  var b = bits[int64](width)
  randomize(12435)


  for i in 0 .. <  width:
    if random(2) == 0:
      incl(b, i)

  echo "Initialization done"

  let
    r = rrr(b)
    startTime = epochTime()

  for j in 0 .. < ops:
    let i = random(width)
    discard r.rank(i)
    echo j
  let endTime = epochTime()

  echo "We have required ", endTime - startTime, " seconds to compute ", ops, " ranks."

when isMainModule:
  main()