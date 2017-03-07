import briefly, unittest, random
include ./utils

suite "bit arrays":
  test "bit array creation and bit access":
    let b = bits(13..27, 35..80)
    for i in 0 .. 12:
      check(not b[i])
    for i in 13 .. 27:
      check(b[i])
    for i in 28 .. 34:
      check(not b[i])
    for i in 35 .. 80:
      check(b[i])
  test "bit array modification":
    var b = bits(13..27, 35..80)
    check(not b[90])
    b.incl(90)
    check(b[90])
    b[90] = false
    check(not b[90])
  test "bit array rank":
    let b = bits(13..27, 35..80)
    check b.rank(16) == 3
    check b.rank(30) == 15
    check b.rank(40) == 20
  test "bit array rank 2":
    let
      width = 10000
      (b, _) = randomBits(width)
    for i in 0 ..< width:
      check b.rank(i) == b.naiveRank(i)
  test "bit array select":
    let b = bits(13..27, 35..80)
    check b.select(3) == 16
    check b.select(15) == 28
    check b.select(20) == 40
  test "bit array select 2":
    let
      width = 10000
      (b, t) = randomBits(width)
    for i in 0 ..< t:
      check b.select(i) == b.naiveSelect(i)
  test "printing bit arrays":
    let b = bits(13..27, 35..80)
    check $b == "0000000000000000000000000000000000000000000000011111111111111111 1111111111111111111111111111100000001111111111111110000000000000"