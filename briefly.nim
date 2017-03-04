import bitopts, math, sequtils, strutils, algorithm

proc rank*[T](s: set[T], i: T): int =
  for j in 0 ..< i:
    if s.contains(j):
      inc result

proc select*[T](s: set[T], i: int): T =
  var count = 0
  while count < i:
    if s.contains(result):
      inc count
    inc result

type BitArray* = object
  data: seq[int]

proc bits*(k: int): BitArray =
  const L = sizeof(int) * 8
  let r = k div L + (if k mod L == 0: 0 else: 1)
  result = BitArray(data: newSeq[int](r))
  # shallow(result.data)

proc len*(bits: BitArray): int =
  bits.data.len * sizeof(int) * 8

proc `[]`*(b: int, i: int): bool {.inline.} =
  ((b shr i) mod 2) != 0

proc `[]`*(bits: BitArray, i: int): bool {.inline.} =
  const L = sizeof(int) * 8
  let
    b = bits.data[i div L]
    j = i mod L
  return b[j]

proc `[]=`*(bits: var BitArray, i: int, v: bool) {.inline.} =
  const L = sizeof(int) * 8
  let
    j = i mod L
    k = i div L
    p = 1 shl j
  if v:
    bits.data[k] = bits.data[k] or p
  else:
    bits.data[k] = bits.data[k] and (not p)

template contains*(bits: BitArray, i: int): bool = bits[i]

template incl*(bits: var BitArray, i: int) =
  bits[i] = true

proc bits*(xs: varargs[Slice[int]]): BitArray =
  var m = 0
  for x in xs:
    m = max(m, x.b)
  result = bits(m.int.nextPowerOfTwo)
  for x in xs:
    for y in x:
      result.incl(y)

proc rank*(t, i: int): auto =
  const L = sizeof(int) * 8
  if i == 0:
    return 0
  if i >= L:
    return countSetBits(t)
  let mask = -1 shr (L - i)
  countSetBits(mask and t)

proc rank*(s: BitArray, i: int): int =
  const L = sizeof(int) * 8
  let
    j = i mod L
    k = i div L
  for r in 0 .. < k:
    result += countSetBits(s.data[r])
  result += rank(s.data[k], j)

proc select*(t, i: int): int =
  var
    t1 = t
    i1 = i
  if i > countSetBits(t):
    return 0
  while i1 > 0 and t1 != 0:
    let s = trailingZeroBits(t1) + 1
    t1 = t1 shr s
    result += s
    dec i1

proc select*(s: BitArray, i: int): int =
  const L = sizeof(int) * 8
  var
    r = i
    count = 0
  while count < s.data.len:
    let p = countSetBits(s.data[count])
    if r <= p:
      break
    r -= p
    inc count
  return (count * L) + select(s.data[count], r)

proc bin*(t: int): string =
  const L = sizeof(int) * 8
  result = ""
  for i in 1 .. L:
    if t[L - i]:
      result &= '1'
    else:
      result &= '0'

proc `$`*(b: BitArray): string =
  const zeroString = bin(0)
  let blocks = b.data.map(bin).reversed
  var
    nonZero = false
    bs = newSeq[string]()
  for blk in blocks:
    if blk != zeroString:
      nonZero = true
    if nonZero:
      bs.add(blk)
  return join(bs, " ")

template nextPerm(v: int): auto =
  let t = (v or (v - 1)) + 1
  t or ((((t and -t) div (v and -v)) shr 1) - 1)

iterator blocks*(popcount, size: int): auto {.inline.} =
  let
    initial = (1 shl popcount) - 1
    mask = (1 shl size) - 1
  var v = initial
  while v >= initial:
    yield v
    v = nextPerm(v) and mask

type IntArray* = object
  ba*: BitArray
  size: int
  length: int

proc capacity*(ints: IntArray): auto = ints.ba.len div ints.size

proc ints*(k, size: int): IntArray =
  return IntArray(ba: bits(k * size), size: size, length: 0)

import future

proc `[]`*(ints: IntArray, i: int): int =
  const L = sizeof(int) * 8
  assert((i + 1) * ints.size <= ints.ba.len)
  let
    startBit = i * ints.size
    startByte = startBit div L
    startOffset = startBit - (startByte * L)
    inSameWord = startOffset + ints.size <= L
  if inSameWord:
    let
      word = ints.ba.data[startByte]
      shifted = word shr startOffset
      mask = -1 shr (L - ints.size)
    return shifted and mask
  else:
    let
      endOffset = startOffset + ints.size - L
      word1 = ints.ba.data[startByte]
      word2 = ints.ba.data[startByte + 1]
      shifted1 = word1 shr startOffset
      mask = -1 shr (L - endOffset)
      shifted2 = (word2 and mask) shl (L - startOffset)
    return shifted1 or shifted2

proc `[]=`*(ints: var IntArray, i, v: int) =
  const L = sizeof(int) * 8
  assert((i + 1) * ints.size <= ints.ba.len)
  assert(v < 2 ^ ints.size)
  let
    startBit = i * ints.size
    startByte = startBit div L
    startOffset = startBit - (startByte * L)
    inSameWord = startOffset + ints.size <= L
  if inSameWord:
    let
      word = ints.ba.data[startByte]
      shifted = v shl startOffset
      mask = not ((-1 shr (L - ints.size)) shl startOffset)
      newWord = (word and mask) or shifted
    ints.ba.data[startByte] = newWord
  else:
    let
      endOffset = startOffset + ints.size - 1 - L
      word1 = ints.ba.data[startByte]
      mask1 = not (-1 shl startOffset)
      shifted1 = v shl startOffset
      newWord1 = (word1 and mask1) or shifted1
      word2 = ints.ba.data[startByte + 1]
      mask2 = not (-1 shr (L - endOffset))
      shifted2 = v shr (L - startOffset)
      newWord2 = (word2 and mask2) or shifted2
    ints.ba.data[startByte] = newWord1
    ints.ba.data[startByte + 1] = newWord2
  ints.length = max(ints.length, i + 1)

proc add*(ints: var IntArray, v: int) =
  ints[ints.length] = v

proc len*(ints: IntArray): int = ints.length

# TODO replace the indices with bit arrays to save space
type RRR* = object
  ba*: BitArray
  index1*: seq[int]
  index2*: seq[int16]

const
  stepWidth = 64
  step1 = sizeof(int) * 8 * stepWidth
  step2 = sizeof(int) * 8

proc rrr*(ba: BitArray): RRR =
  let L = ba.len
  var
    index1 = newSeqOfCap[int](L div step1)
    index2 = newSeqOfCap[int16](L div step2)
    sum1 = 0
    sum2 = 0
  index1.add(0)
  index2.add(0)
  for i, cell in ba.data:
    sum2 += countSetBits(cell)
    index2.add(int16(sum2))
    if i + 1 mod stepWidth == 0:
      sum1 += sum2
      index1.add(sum1)
      sum2 = 0
  return RRR(ba: ba, index1: index1, index2: index2)

proc rank*(r: RRR, i: int): int =
  return r.index1[i div step1] + r.index2[i div step2] + rank(r.ba.data[i div step2], i mod step2)

proc binarySearch[T](s: seq[T], value: T, min, max: int): (int, T) =
  var
    aMin = min
    aMax = max
    count = 0
  while aMin < aMax:
    count += 1
    let
      middle = (aMin + aMax) div 2
      v = s[middle]
    if v < value:
      if aMin == middle:
        aMax = middle
      else:
        aMin = middle
    else:
      aMax = middle
  return (aMin, s[aMin])

proc select*(r: RRR, i: int): int =
  let
    (i1, s1) = binarySearch(r.index1, i, r.index1.low, r.index1.high)
    (i2, s2) = binarySearch(r.index2, (i - i1).int16, i1, min(i1 + stepWidth, r.index2.high))
  return (step1 * i1 + step2 * i2) + select(r.ba.data[i1 + i2], i - s1 - s2)

type WaveletTree* = object
  alphabet*: seq[char]
  len*: int
  data*: ref RRR
  left*, right*: ref WaveletTree

proc uniq*(content: string or seq[char]): seq[char] =
  result = @[]
  for x in content:
    if not result.contains(x):
      result.add(x)

template `~`[T](x: T): auto =
  var t: ref T
  new(t)
  t[] = x
  t

template split(alphabet: seq[char]): auto =
  let L = high(alphabet) div 2
  (alphabet[0 .. L], alphabet[L+1 .. high(alphabet)])

proc waveletTree*(content: string, alphabet: seq[char]): WaveletTree =
  if alphabet.len == 1:
    return WaveletTree(alphabet: alphabet, len: content.len)
  let (alphaLeft, alphaRight) = split(alphabet)
  var
    contentLeft = ""
    contentRight = ""
    b = bits(content.len)
  for i, c in content:
    if alphaLeft.contains(c):
      contentLeft.add(c)
    else:
      incl(b, i)
      contentRight.add(c)
  let
    left = waveletTree(contentLeft, alphaLeft)
    right = waveletTree(contentRight, alphaRight)
    data = rrr(b)
  return WaveletTree(alphabet: alphabet, len: content.len, data: ~data, left: ~left, right: ~right)

proc waveletTree*(content: string): WaveletTree =
  waveletTree(content, uniq(content))

proc rank*(w: WaveletTree, c: char, t: int): auto =
  if not w.alphabet.contains(c):
    return -1
  if w.alphabet.len == 1:
    if t > w.len:
      return -1
    else:
      return t
  let (alphaLeft, alphaRight) = split(w.alphabet)
  if alphaLeft.contains(c):
    let r = t - w.data[].rank(t)
    return w.left[].rank(c, r)
  elif alphaRight.contains(c):
    let r = w.data[].rank(t)
    return w.right[].rank(c, r)

proc `[]`*(w: WaveletTree, t: int): char =
  if w.alphabet.len == 1:
    return w.alphabet[0]
  let bit = w.data.ba[t]
  if bit:
    let r = w.data[].rank(t)
    return w.right[][r]
  else:
    let r = t - w.data[].rank(t)
    return w.left[][r]