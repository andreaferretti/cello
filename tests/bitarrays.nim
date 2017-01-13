import briefly, unittest


suite "bit arrays":
  test "bit array (32 bit) creation and bit access":
    let b = bits(13'i32..27'i32, 35'i32..80'i32)
    for i in 0 .. 12'i32:
      check(not b[i])
    for i in 13'i32 .. 27'i32:
      check(b[i])
    for i in 28'i32 .. 34'i32:
      check(not b[i])
    for i in 35'i32 .. 80'i32:
      check(b[i])
  test "bit array (64 bit) creation and bit access":
    let b = bits(13'i64..27'i64, 35'i64..80'i64)
    for i in 0 .. 12'i64:
      check(not b[i])
    for i in 13'i64 .. 27'i64:
      check(b[i])
    for i in 28'i64 .. 34'i64:
      check(not b[i])
    for i in 35'i64 .. 80'i64:
      check(b[i])
  test "bit array (32 bit) modification":
    var b = bits(13'i32..27'i32, 35'i32..80'i32)
    check(not b[90])
    b.incl(90)
    check(b[90])
    b[90] = false
    check(not b[90])
  test "bit array (64 bit) modification":
    var b = bits(13'i64..27'i64, 35'i64..80'i64)
    check(not b[90])
    b.incl(90)
    check(b[90])
    b[90] = false
    check(not b[90])
  test "rank (32 bits)":
    let b = bits(13'i32..27'i32, 35'i32..80'i32)
    check b.rank(16) == 3
    check b.rank(30) == 15
    check b.rank(40) == 20
  test "rank (64 bits)":
    let b = bits(13'i64..27'i64, 35'i64..80'i64)
    check b.rank(16) == 3
    check b.rank(30) == 15
    check b.rank(40) == 20
  test "select (32 bits)":
    let b = bits(13'i32..27'i32, 35'i32..80'i32)
    check b.select(3) == 16
    check b.select(15) == 28
    check b.select(20) == 40
  test "select (64 bits)":
    let b = bits(13'i64..27'i64, 35'i64..80'i64)
    check b.select(3) == 16
    check b.select(15) == 28
    check b.select(20) == 40
  test "printing bit arrays":
    let b = bits(13'i32..27'i32, 35'i32..80'i32)
    check $b == "00000000000000000000000000000000 00000000000000011111111111111111 11111111111111111111111111111000 00001111111111111110000000000000"