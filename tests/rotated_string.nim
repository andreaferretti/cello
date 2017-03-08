import briefly, unittest


suite "rotated strings":
  test "reading chars":
    let x = "Hello, world".rotate(7)

    check x[0] == 'w'
    check x[1] == 'o'
    check x[2] == 'r'
    check x[3] == 'l'
    check x[4] == 'd'
    check x[5] == 'H'
    check x[6] == 'e'
    check x[7] == 'l'
    check x[8] == 'l'
    check x[9] == 'o'
    check x[10] == ','
    check x[11] == ' '
  test "writing chars":
    var x = "Hello, world".rotate(5)

    check x[0] == ','
    x[0] = 'f'
    check x[0] == 'f'
  test "underlying strings are shared":
    var
      x = "Hello, world"
      y = x.rotate(5)

    y[0] = 'f'
    check x[5] == 'f'
  test "transforming to string":
    var x = "Hello, world".rotate(7)

    check $x == "worldHello, "