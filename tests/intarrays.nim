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