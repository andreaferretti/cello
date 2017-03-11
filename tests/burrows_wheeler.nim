import briefly, unittest, random
include utils


suite "Burrows-Wheeler transform":
  test "computing the suffix array":
    let
      x = "this is a test."
      s = suffixArray(x)
      t = @[7, 4, 9, 14, 8, 11, 1, 5, 2, 6, 3, 12, 13, 10, 0]

    for i in t.low .. t.high:
      check s[i] == t[i]
  test "direct transform":
    let x = "this is a test."

    check burrowsWheeler(x) == ("ssat tt hiies .", 14)
  test "inverse transform":
    let
      x = "this is a test."
      (s, c) = burrowsWheeler(x)
      y = inverseBurrowsWheeler(s, c)
    check x == y
  test "inverse transform of a random string":
    let
      x = randomString(1000, ['A', 'C', 'G', 'T'])
      (s, c) = burrowsWheeler(x)
      y = inverseBurrowsWheeler(s, c)
    check x == y