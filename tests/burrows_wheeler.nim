import briefly, unittest, random
include utils


suite "Burrows-Wheeler transform":
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