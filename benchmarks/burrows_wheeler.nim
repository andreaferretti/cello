import stopwatch, random
import briefly

proc randomString(width: int, letters: openarray[char]): string =
  let L = len(letters)
  result = newString(width)
  for i in 0 ..< width:
    result[i] = letters[random(L)]

proc main() =
  const width = 10_000_000
  echo "Initialization starting"
  randomize(12435)
  var x = randomString(width, letters = ['A', 'C', 'G', 'T'])
  var sw = stopwatch()
  echo "Initialization done"

  sw.start()
  let (s, i) = burrowsWheeler(x)
  sw.stop()

  echo "We have required ", sw.secs(), " seconds to do the Burrows-Wheeler transform of a  ", width, " long string."

  sw.start()
  let y = inverseBurrowsWheeler(s, i)
  sw.stop()

  echo "We have required ", sw.secs(), " seconds to do the inverse Burrows-Wheeler transform of a  ", width, " long string."

when isMainModule:
  main()