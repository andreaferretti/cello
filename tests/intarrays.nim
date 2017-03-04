import briefly, unittest

import future
suite "int arrays":
  test "int array access":
    let x = @[123, 489, 511, 231, 155, 1, 0, 81, 488, 212]
    var y = ints(x.len, 9)
    for i, v in x:
      y[i] = v
    for i, v in x:
      check(y[i] == v)