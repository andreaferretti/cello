import stopwatch, random, sequtils
import briefly

proc main() =
  const
    width = 100_000_000
    ops = 10000
    patternLen = 10
    letters = ['A', 'C', 'G', 'T']
  echo "Initialization starting"
  randomize(12435)
  var
    s = newString(width)
    indices = newSeq[int]()
    sw = stopwatch()

  for i in 0 .. <  width:
    s[i] = letters[random(4)]

  for _ in 0 .. < ops:
    indices.add(random(width - patternLen))

  echo "Initialization done"

  sw.start()
  let (fm, sa) = fmIndexWithSuffixArray(s)
  sw.stop()

  echo "We have required ", sw.secs(), " seconds to prepare the FM index for a ", width, " long string."

  sw.start()
  for i in indices:
    let
      pattern = s[i .. (i + patternLen - 1)]
      positions = fm.search(pattern)
    discard positions.toSeq.mapIt(sa[it])
  sw.stop()

  echo "We have required ", sw.secs(), " seconds to find ", ops, " patterns."

  sw.start()
  for i in indices:
    let
      pattern = s[i .. (i + patternLen - 1)]
    discard boyerMooreHorspool(s, pattern)
  sw.stop()

  echo "We have required ", sw.secs(), " seconds to find ", ops, " patterns with Boyer-Moore."

when isMainModule:
  main()