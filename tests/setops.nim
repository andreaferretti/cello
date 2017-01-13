import briefly, unittest


suite "operations over sets":
  let x1 = { 13..27, 35..80 }
  var x: set[int8]
  for q in x1:
    x.incl(q.int8)

  test "rank":
    check x.rank(16) == 3
    check x.rank(30) == 15
    check x.rank(40) == 20
  test "select":
    check x.select(3)  == 16
    check x.select(15) == 28
    check x.select(20) == 40