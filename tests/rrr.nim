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
      check b.select(i) == r.select(i)
  test "computing select0 on rrr structures":
    let
      width = 10000
      (b, count) = randomBits(width)
      r = rrr(b)
    for i in 0 ..< width - count:
      check b.select0(i) == r.select0(i)