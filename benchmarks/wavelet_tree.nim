import stopwatch, random
import briefly

proc main() =
  const
    width = 1_000_000_000
    ops = 10000
    letters = ['A', 'C', 'G', 'T']
  echo "Initialization starting"
  randomize(12435)
  var
    s = newString(width)
    indicesRank = newSeq[(int, char)]()
    indicesSelect = newSeq[(int, char)]()
    sw = stopwatch()

  for i in 0 .. <  width:
    s[i] = letters[random(4)]

  for _ in 0 .. < ops:
    indicesRank.add((random(width), letters[random(4)]))

  for _ in 0 .. < ops:
    indicesSelect.add((random(width div 5), letters[random(4)]))
  echo "Initialization done"

  sw.start()
  let wt = waveletTree(s)
  sw.stop()

  echo "We have required ", sw.secs(), " seconds to fill a ", width, " size wavelet tree."

  sw.start()
  for x in indicesRank:
    let (i, c) = x
    discard wt.rank(c, i)
  sw.stop()

  echo "We have required ", sw.secs(), " seconds to compute ", ops, " ranks."

  sw.start()
  for x in indicesSelect:
    let (i, c) = x
    discard wt.select(c, i)
  sw.stop()

  echo "We have required ", sw.secs(), " seconds to compute ", ops, " selects."

  sw.start()
  for x in indicesRank:
    let (i, _) = x
    discard wt[i]
  sw.stop()

  echo "We have required ", sw.secs(), " seconds to compute ", ops, " accesses."

when isMainModule:
  main()