proc randomBits(width: int): tuple[bits: BitArray, count: int] =
  result.bits = bits(width)
  result.count = 0
  for i in 0 ..< width:
    if random(2) == 0:
      result.bits[i] = true
      result.count += 1

proc randomString(width: int, letters: openarray[char]): string =
  let L = len(letters)
  result = newString(width)
  for i in 0 ..< width:
    result[i] = letters[random(L)]