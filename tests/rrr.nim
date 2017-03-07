import briefly, unittest


suite "rrr structure":
  test "computing rank on rrr structures":
    let
      b = bits(13..27, 35..80)
      r = rrr(b)
    check r.rank(16) == 3
    check r.rank(30) == 15
    check r.rank(40) == 20
  test "computing select on rrr structures":
    let
      b = bits(13..27, 35..80)
      r = rrr(b)
    check r.select(3) == 16
    check r.select(15) == 28
    check r.select(20) == 40
  test "computing select 0 on rrr structures":
    let
      b = bits(13..27, 35..80)
      r = rrr(b)
    check r.select0(3) == 3
    check r.select0(15) == 30
    check r.select0(20) == 35
    check r.select0(40) == 101