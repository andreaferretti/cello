import briefly, unittest


suite "bit access in integers":
  test "printing 32 bit patterns":
    check bin(0'i32)         == "00000000000000000000000000000000"
    check bin(1'i32)         == "00000000000000000000000000000001"
    check bin(-1'i32)        == "11111111111111111111111111111111"
    check bin(-461274'i32)   == "11111111111110001111011000100110"
    check bin(126851658'i32) == "00000111100011111001101001001010"
  test "printing 64 bit patterns":
    check bin(0'i64)         == "0000000000000000000000000000000000000000000000000000000000000000"
    check bin(1'i64)         == "0000000000000000000000000000000000000000000000000000000000000001"
    check bin(-1'i64)        == "1111111111111111111111111111111111111111111111111111111111111111"
    check bin(-461274'i64)   == "1111111111111111111111111111111111111111111110001111011000100110"
    check bin(126851658'i64) == "0000000000000000000000000000000000000111100011111001101001001010"
  test "rank on 32 bit integers":
    check rank(-461274'i32, 0)  == 0
    check rank(-461274'i32, 1)  == 0
    check rank(-461274'i32, 10) == 4
    check rank(-461274'i32, 20) == 10
    check rank(-461274'i32, 32) == 22
    check rank(-461274'i32, 80) == 22
    check rank(126851658'i32, 0)  == 0
    check rank(126851658'i32, 1)  == 0
    check rank(126851658'i32, 10) == 4
    check rank(126851658'i32, 20) == 11
    check rank(126851658'i32, 32) == 15
    check rank(126851658'i32, 80) == 15
  test "rank on 64 bit integers":
    check rank(-461274'i64, 0)  == 0
    check rank(-461274'i64, 1)  == 0
    check rank(-461274'i64, 10) == 4
    check rank(-461274'i64, 20) == 10
    check rank(-461274'i64, 32) == 22
    check rank(-461274'i64, 64) == 54
    check rank(-461274'i64, 80) == 54
    check rank(126851658'i64, 0)  == 0
    check rank(126851658'i64, 1)  == 0
    check rank(126851658'i64, 10) == 4
    check rank(126851658'i64, 20) == 11
    check rank(126851658'i64, 32) == 15
    check rank(126851658'i64, 64) == 15
    check rank(126851658'i64, 80) == 15
  test "select on 32 bit integers":
    check select(-461274'i32, 0)  == 0
    check select(-461274'i32, 1)  == 2
    check select(-461274'i32, 4)  == 10
    check select(-461274'i32, 10) == 20
    check select(-461274'i32, 22) == 32
    check select(-461274'i32, 80) == 0
    check select(126851658'i32, 0)  == 0
    check select(126851658'i32, 1)  == 2
    check select(126851658'i32, 4)  == 10
    check select(126851658'i32, 11) == 20
    check select(126851658'i32, 15) == 27
    check select(126851658'i32, 80) == 0
  test "select on 64 bit integers":
    check select(-461274'i64, 0)  == 0
    check select(-461274'i64, 1)  == 2
    check select(-461274'i64, 4)  == 10
    check select(-461274'i64, 10) == 20
    check select(-461274'i64, 22) == 32
    check select(-461274'i64, 54) == 64
    check select(-461274'i64, 80) == 0
    check select(126851658'i64, 0)  == 0
    check select(126851658'i64, 1)  == 2
    check select(126851658'i64, 4)  == 10
    check select(126851658'i64, 11) == 20
    check select(126851658'i64, 15) == 27
    check select(126851658'i64, 64) == 0
    check select(126851658'i64, 80) == 0