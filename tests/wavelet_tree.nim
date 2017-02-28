import briefly, unittest


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