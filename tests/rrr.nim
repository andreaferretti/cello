import briefly, unittest


suite "rrr structure":
  test "computing rank on rrr structures":
    let
      b = bits(13'i32..27'i32, 35'i32..80'i32)
      r = rrr(b)
    check r.rank(16) == 3
    check r.rank(30) == 15
    check r.rank(40) == 20
  test "computing select on rrr structures":
    let
      b = bits(13'i32..27'i32, 35'i32..80'i32)
      r = rrr(b)
    check r.select(3) == 16
    check r.select(15) == 28
    check r.select(20) == 40