import briefly, unittest


suite "Burrows-Wheeler transform":
  test "direct transform":
    let x = "this is a test."

    check burrowsWheeler(x) == "ssat tt hiies ."