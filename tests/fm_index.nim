import briefly, unittest, random, strutils, sequtils, spills
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

  test "backward search on a memory-mapped string":
    initSpills()
    var x = spill[char]("briefly.nim", hasHeader = false)
    defer:
      x.close()
    let
      pattern = "fmIndex"
      fm = fmIndex(x)
      sa = suffixArray(x)
      positions = fm.search(pattern)
      realPositions = toSeq(positions).mapIt(sa[it])

    check(realPositions.len > 0)

    for p in realPositions:
      for i in 0 .. pattern.high:
        check(x[p + i] == pattern[i])