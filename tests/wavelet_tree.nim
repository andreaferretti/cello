import briefly, strutils, unittest


suite "wavelet tree structure":
  test "rank on a wavelet tree":
    let
      x = "ACGGTACTACGAGAGTAGCAGTTTAGCGTAGCATGCTAGCG"
      w = waveletTree(x)
    for i in 0 .. high(x):
      for c in "ACGT":
        check w.rank(c, i) == x.rank(c, i)
  test "random access on a wavelet tree":
    let
      x = "ACGGTACTACGAGAGTAGCAGTTTAGCGTAGCATGCTAGCG"
      w = waveletTree(x)
    for i in 0 .. high(x):
      check w[i] == x[i]
  test "select on a wavelet tree":
    let
      x = "ACGGTACTACGAGAGTAGCAGTTTAGCGTAGCATGCTAGCG"
      w = waveletTree(x)
    for i in 0 .. 5:
      for c in "ACGT":
        check w.select(c, i) == x.select(c, i)