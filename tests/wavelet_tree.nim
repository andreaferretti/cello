import briefly, unittest


suite "wavelet tree structure":
  test "creating a wavelet tree":
    let
      x = "ACGGTACTACGAGAGTAGCAGTTTAGCGTAGCATGCTAGCG"
      w = waveletTree[int32](x)
    echo w.repr