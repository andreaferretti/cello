import briefly, unittest, random, strutils, sequtils
include utils


suite "FM index":
  test "backward search":
    let
      x = "mississippi"
      pattern = "iss"
      fm = fmIndex(x)
      sa = suffixArray(x)
      positions = fm.search(pattern)

    check positions.first == 2
    check positions.last == 3

    for j in positions.first .. positions.last:
      let
        i = sa[j]
        y = $(x.rotate(i))
      check y.startsWith(pattern)

  test "backward search on a random string":
    let
      x = randomString(1000, ['A', 'C', 'G', 'T'])
      pattern = x[133 .. 136]
      fm = fmIndex(x)
      sa = suffixArray(x)
      positions = fm.search(pattern)
      realPositions = toSeq(positions).mapIt(sa[it])

    check(133 in realPositions)

    for j in positions.first .. positions.last:
      let
        i = sa[j]
        y = $(x.rotate(i))
      check y.startsWith(pattern)