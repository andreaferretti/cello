import briefly, unittest, random

import future
suite "int arrays":
  test "int array access":
    var
      x = newSeq[int](100)
      y = ints(100, 9)
    for i in 0 .. 99:
      let r = random(512)
      x[i] = r
      y[i] = r
    for i in 0 .. 99:
      check(y[i] == x[i])
  test "adding to int arrays":
    var
      x = newSeq[int](100)
      y = ints(100, 9)
    for i in 0 .. 99:
      x[i] = random(512)
    for i in 0 .. 45:
      y.add(x[i])
    for i in 0 .. 45:
      check(y[i] == x[i])
    check(y.len == 46)
    # because the smallest multiple of 64
    # that is bigger than 9 * 100
    # is 64 * 15 == 960, and
    # 960 div 9 == 106
    check(y.capacity == 106)