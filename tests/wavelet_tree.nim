import briefly, strutils, unittest


suite "wavelet tree structure":
  test "rank on a wavelet tree":
    let
      x = "ACGGTACTACGAGAGTAGCAGTTTAGCGTAGCATGCTAGCG"
      w = waveletTree(x)
    for i in 0 .. high(x):
      for c in "ACGT":
        var count = 0
        for d in x[0..<i]:
          if c == d:
            count += 1
        check w.rank(c, i) == count
  test "random access on a wavelet tree":
    let
      x = "ACGGTACTACGAGAGTAGCAGTTTAGCGTAGCATGCTAGCG"
      w = waveletTree(x)
    for i in 0 .. high(x):
      check w[i] == x[i]
#  test "select on a wavelet tree":
#    let
#      x = "ACGGTACTACGAGAGTAGCAGTTTAGCGTAGCATGCTAGCG"
#      w = waveletTree(x)
#    for i in 0 .. 5:
#      for c in "ACGT":
#        var pos = 0
#        for _ in 0 .. i:
#          pos = x.find(c, pos) + 1
#        check w.select(c, i) == pos