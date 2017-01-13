import briefly, unittest


suite "generating blocks in popcount order":
  test "generating blocks":
    var results = newSeq[string]()
    for x in blocks(popcount = 3, size = 5):
      results.add bin(x)[27..32]

    let expected = @[
      "00111",
      "01011",
      "01101",
      "01110",
      "10011",
      "10101",
      "10110",
      "11001",
      "11010",
      "11100"
    ]
    check results == expected