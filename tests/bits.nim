import briefly, unittest


suite "bit access in integers":
  test "printing 64 bit patterns":
    check bin(0)         == "0000000000000000000000000000000000000000000000000000000000000000"
    check bin(1)         == "0000000000000000000000000000000000000000000000000000000000000001"
    check bin(-1)        == "1111111111111111111111111111111111111111111111111111111111111111"
    check bin(-461274)   == "1111111111111111111111111111111111111111111110001111011000100110"
    check bin(126851658) == "0000000000000000000000000000000000000111100011111001101001001010"
  test "rank on 64 bit integers":
    check rank(-461274, 0)  == 0
    check rank(-461274, 1)  == 0
    check rank(-461274, 10) == 4
    check rank(-461274, 20) == 10
    check rank(-461274, 32) == 22
    check rank(-461274, 64) == 54
    check rank(-461274, 80) == 54
    check rank(126851658, 0)  == 0
    check rank(126851658, 1)  == 0
    check rank(126851658, 10) == 4
    check rank(126851658, 20) == 11
    check rank(126851658, 32) == 15
    check rank(126851658, 64) == 15
    check rank(126851658, 80) == 15
  test "select on 64 bit integers":
    echo bin(-461274)
    echo bin(126851658)
    check select(-461274, 0)  == 0
    check select(-461274, 1)  == 2
    check select(-461274, 4)  == 10
    check select(-461274, 10) == 20
    check select(-461274, 22) == 32
    check select(-461274, 54) == 64
    check select(-461274, 80) == 0
    check select(126851658, 0)  == 0
    check select(126851658, 1)  == 2
    check select(126851658, 4)  == 10
    check select(126851658, 11) == 20
    check select(126851658, 15) == 27
    check select(126851658, 64) == 0
    check select(126851658, 80) == 0