import briefly, unittest, random
include ./utils

suite "rrr structure":
  test "computing rank on rrr structures":
    let
      width = 10000
      (b, _) = randomBits(width)
      r = rrr(b)
    for i in 0 ..< width:
      if b.rank(i) != r.rank(i):
        echo i
        check b.rank(i) == r.rank(i)
  test "computing select on rrr structures":
    let
      width = 10000
      (b, count) = randomBits(width)
      r = rrr(b)
    for i in 0 ..< count:
      if b.select(i) != r.select(i):
        echo i
        check b.select(i) == r.select(i)
  test "computing select 0 on rrr structures":
    let
      b = bits(13..27, 35..80)
      r = rrr(b)
    check r.select0(3) == 3
    check r.select0(15) == 30
    check r.select0(20) == 35
    check r.select0(40) == 101