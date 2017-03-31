# Copyright 2017 UniCredit S.p.A.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
import bitops, math, sequtils, strutils, algorithm, tables
import spills

type AnyString* = string or seq[char] or Spill[char]

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

proc rank*(s: AnyString, c: char, i: int): int =
  for j in 0 ..< i:
    if s[j] == c:
      inc result

proc select*(s: AnyString, c: char, i: int): int =
  var count = 0
  while count < i:
    if s[result] == c:
      inc count
    inc result

type BitArray* = ref object
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
    let s = countTrailingZeroBits(t1) + 1
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

proc select0*(s: BitArray, i: int): int =
  const L = sizeof(int) * 8
  var
    r = i
    count = 0
  while count < s.data.len:
    let p = L - countSetBits(s.data[count])
    if r <= p:
      break
    r -= p
    inc count
  return (count * L) + select(not s.data[count], r)

proc naiveRank*(b: BitArray, i: int): int =
  for j in 0 ..< i:
    if b[j]:
      inc result

proc naiveSelect*(b: BitArray, i: int): int =
  var count = 0
  while count < i:
    if b.contains(result):
      inc count
    inc result

proc naiveSelect0*(b: BitArray, i: int): int =
  var count = 0
  while count < i:
    if not b.contains(result):
      inc count
    inc result

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

proc maxBits(n: int): int = log2(n.float).int + 1

proc `[]`*(ints: IntArray, i: int): int {.inline.} =
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

proc `[]=`*(ints: var IntArray, i, v: int) {.inline.} =
  const L = sizeof(int) * 8
  assert((i + 1) * ints.size <= ints.ba.len)
  #assert(v < 2 ^ ints.size)
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

proc ints*(xs: seq[int]): IntArray =
  result = ints(xs.len, maxBits(xs.max))
  for i, x in xs:
    result[i] = x

proc add*(ints: var IntArray, v: int) =
  ints[ints.length] = v

proc len*(ints: IntArray): int = ints.length

proc toIntSeq*(ints: IntArray): seq[int] =
  result = newSeq[int](ints.length)
  for i in 0 ..< ints.length:
    result[i] = ints[i]

proc `$`*(ints: IntArray): string = $(ints.toIntSeq)

type
  RRR* = ref object
    ba: BitArray
    index1, index2: IntArray
  RRRStats* = object
    data*, index1*, index2*: int

const
  stepWidth = 64
  step1 = sizeof(int) * 8 * stepWidth
  step2 = sizeof(int) * 8

proc rrr*(ba: BitArray): RRR =
  let L = ba.len
  var
    index1 = ints(L div step1 + 1, maxBits(L))
    index2 = ints(L div step2 + 1, maxBits(step1))
    sum1 = 0
    sum2 = 0
  index1.add(0)
  index2.add(0)
  for i, cell in ba.data:
    sum2 += countSetBits(cell)
    if (i + 1) mod stepWidth == 0:
      sum1 += sum2
      index1.add(sum1)
      sum2 = 0
    index2.add(sum2)
  return RRR(ba: ba, index1: index1, index2: index2)

proc stats*(r: RRR): RRRStats =
  RRRStats(data: r.ba.len, index1: r.index1.ba.len, index2: r.index2.ba.len)

proc rank*(r: RRR, i: int): int =
  return r.index1[i div step1] + r.index2[i div step2] + rank(r.ba.data[i div step2], i mod step2)

proc binarySearch(s: IntArray, value, min, max: int): (int, int) =
  var
    aMin = min
    aMax = max
  while aMin < aMax:
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

proc binarySearch0(s: IntArray, value, min, max, width: int): (int, int) =
  var
    aMin = min
    aMax = max
  while aMin < aMax:
    let
      middle = (aMin + aMax) div 2
      v = (middle - min) * width - s[middle]
    if v < value:
      if aMin == middle:
        aMax = middle
      else:
        aMin = middle
    else:
      aMax = middle
  return (aMin, (aMin - min) * width - s[aMin])

proc select*(r: RRR, i: int): int =
  let
    (i1, s1) = binarySearch(r.index1,
      value = i,
      min = 0,
      max = r.index1.length)
    (i2, s2) = binarySearch(r.index2,
      value = i - s1,
      min = stepWidth * i1,
      max = min(stepWidth * (i1 + 1 ), r.index2.length))
  return step2 * i2 + select(r.ba.data[i2], i - s1 - s2)

proc select0*(r: RRR, i: int): int =
  let
    (i1, s1) = binarySearch0(r.index1,
      value = i,
      min = 0,
      max = r.index1.length,
      width = step1)
    (i2, s2) = binarySearch0(r.index2,
      value = i - s1,
      min = stepWidth * i1,
      max = min(stepWidth * (i1 + 1), r.index2.length),
      width = step2)
  return step2 * i2 + select(not r.ba.data[i2], i - s1 - s2)

type
  WaveletTree* = ref object
    alphabet*: seq[char]
    len*: int
    data*: RRR
    left*, right*: WaveletTree
  WaveletTreeStats* = object
    data*, index1*, index2*, depth*: int

proc uniq*(content: AnyString): seq[char] =
  result = @[]
  for x in content:
    if not result.contains(x):
      result.add(x)

template split(alphabet: seq[char]): auto =
  let L = high(alphabet) div 2
  (alphabet[0 .. L], alphabet[L+1 .. high(alphabet)])

proc waveletTree*(content: AnyString, alphabet: seq[char]): WaveletTree =
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
  return WaveletTree(alphabet: alphabet, len: content.len, data: data, left: left, right: right)

proc waveletTree*(content: AnyString): WaveletTree =
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
    let r = t - w.data.rank(t)
    return w.left.rank(c, r)
  elif alphaRight.contains(c):
    let r = w.data.rank(t)
    return w.right.rank(c, r)

proc `[]`*(w: WaveletTree, t: int): char =
  if w.alphabet.len == 1:
    return w.alphabet[0]
  let bit = w.data.ba[t]
  if bit:
    let r = w.data.rank(t)
    return w.right[r]
  else:
    let r = t - w.data.rank(t)
    return w.left[r]

proc select*(w: WaveletTree, c: char, t: int): auto =
  if not w.alphabet.contains(c):
    return -1
  if w.alphabet.len == 1:
    if t > w.len:
      return -1
    else:
      return t
  let (alphaLeft, alphaRight) = split(w.alphabet)
  if alphaLeft.contains(c):
    let r = w.left.select(c, t)
    if r == -1:
      return -1
    return w.data.select0(r)
  elif alphaRight.contains(c):
    let r = w.right.select(c, t)
    if r == -1:
      return -1
    return w.data.select(r)

proc stats*(w: WaveletTree): WaveletTreeStats =
  if w.alphabet.len == 1:
    return WaveletTreeStats(depth: 1)
  let
    left = stats(w.left)
    right = stats(w.right)
    s = stats(w.data)
  return WaveletTreeStats(
    depth: max(left.depth, right.depth) + 1,
    data: left.data + right.data + s.data,
    index1: left.index1 + right.index1 + s.index1,
    index2: left.index2 + right.index2 + s.index2
  )

type RotatedString* = object
  underlying: string
  shift: int

proc rotate*(s: string, i: int): RotatedString =
  result = RotatedString(underlying: s, shift: i)

proc rotate*(s: var string, i: int): RotatedString =
  result = RotatedString(shift: i)
  shallowCopy(result.underlying, s)

proc `[]`*(r: RotatedString, i: int): char {.inline.} =
  let L = r.underlying.len
  assert 0 <= i and i < L
  let s = i + r.shift
  if s < L:
    return r.underlying[s]
  else:
    return r.underlying[s - L]

proc `[]=`*(r: var RotatedString, i: int, c: char) {.inline.} =
  let L = r.underlying.len
  assert 0 <= i and i < L
  let s = i + r.shift
  if s < L:
    r.underlying[s] = c
  else:
    r.underlying[s - L] = c

proc `$`*(r: RotatedString): string =
  r.underlying[r.shift .. r.underlying.high] & r.underlying[0 ..< r.shift]

####################################################

const padding = 2

template divup(a, b: int): int = a div b + (if a mod b == 0: 0 else: 1)

iterator samples(top: int): int =
  var i = 1
  while i < top - padding:
    yield i
    i += 3
  i = 2
  while i < top - padding:
    yield i
    i += 3

proc radixPass(a: seq[int], b: var seq[int], reference: seq[int], max: int, offset: int) =
  var
    bucketSizes = newSeq[int](max + 1)
    bucketStart = newSeq[int](max + 1)
  for i in a:
    let digit = reference[i + offset]
    inc bucketSizes[digit]
  var total = 0
  for i in 0 .. max:
    bucketStart[i] = total
    total += bucketSizes[i]
  for c in a:
    let
      digit = reference[c + offset]
      position = bucketStart[digit]
    inc bucketStart[digit]
    b[position] = c

proc dc3(xs: seq[int]): seq[int] =
  var
    sampleIndices = sequtils.toSeq(samples(xs.len))
    scratchIndices = sampleIndices
  let
    L = sampleIndices.len
    L2 = (L+1) div 2
    m = xs.max
  radixPass(sampleIndices, scratchIndices, xs, max = m, offset = 2)
  radixPass(scratchIndices, sampleIndices, xs, max = m, offset = 1)
  radixPass(sampleIndices, scratchIndices, xs, max = m, offset = 0)
  # `scratchIndices` now contains the lexicographic order of
  # triplets starting from indices in the sample set C = { x | x mod 3 != 0 }
  var
    lastTriplet = [-1, -1, -1]
    count = 0
    R12 = newSeq[int](L)
    SA12 = newSeq[int](L)
  for i, c in scratchIndices:
    let triplet = [xs[c], xs[c+1], xs[c+2]]
    if triplet != lastTriplet:
      lastTriplet = triplet
      count += 1
    let
      rem = c mod 3
      quote = c div 3
      position = quote + (if rem == 1: 0 else: L2)
    R12[position] = count
  if count < sampleIndices.len:
    # There was a repeated triple; need to sort again
    # the suffixes of R12 recursively
    for _ in 1 .. padding:
      R12.add(0)
    SA12 = dc3(R12)
    # Reorder R12 accordingly
    for i, c in SA12:
      R12[c] = i + 1
  else:
    # Triples were unique; we can reconstruct the suffix
    # array from R12, which is sorted
    for i, c in R12:
      SA12[c - 1] = i
  var
    R0 = newSeq[int](xs.len div 3)
    SA0 = newSeq[int](xs.len div 3)
    j = 0
  # if the last index in `xs` is = 1 mod 3, insert
  # that in head position
  if xs.len mod 3 == 0:
    R0[j] = xs.len - 3
    inc j
  for c in SA12:
    if c < L2: # only consider the first half of indices
      R0[j] = 3 * c
      inc j
  # R0 now contains the indices sorted by SA12[i + 1]
  # With another radix pass the will now be sorted by the pair
  # (character, following suffix)
  radixPass(R0, SA0, xs, max = xs.max, offset = 0)
  # we can now merge the set C together with its complement
  var k, k0, k12 = 0
  result = newSeq[int](SA0.len + SA12.len)

  template r12(i: int): int =
    if i >= xs.len - padding: 0
    else:
      if i mod 3 == 1: R12[i div 3]
      else: R12[i div 3 + L2]

  template compareB1(i, j: int): bool =
    if xs[i] < xs[j]: true
    elif xs[j] < xs[i]: false
    else: r12(i + 1) < r12(j + 1)

  template compareB2(i, j: int): bool =
    if xs[i] < xs[j]: true
    elif xs[j] < xs[i]: false
    else: compareB1(i + 1, j + 1)

  while k0 < SA0.len and k12 < SA12.len:
    let
      x0 = SA0[k0] # next index from B0
      i12 = SA12[k12] # this is an index in R12, but we have to map it back to an index in B12
      b1case = i12 < L2 # whether the next index in B12 comes from B1
      x12 = if b1case: 1 + 3 * i12 else: 2 + 3 * (i12 - L2) # next index from B12
      nextInB0 = if b1case: compareB1(x0, x12) else: compareB2(x0, x12)
    if nextInB0:
      result[k] = x0
      inc k0
    else:
      result[k] = x12
      inc k12
    inc k
  # Add remaining indices from B0
  if k0 < SA0.len:
    while k < result.len:
      result[k] = SA0[k0]
      inc k
      inc k0
  # Add remaining indices from B12
  if k12 < SA12.len:
    while k < result.len:
      let
        i12 = SA12[k12]
        b1case = i12 < L2
        x12 = if b1case: 1 + 3 * i12 else: 2 + 3 * (i12 - L2) # next index from B12
      result[k] = x12
      inc k
      inc k12

proc uniq(content: string): seq[char] =
  result = @[]
  for x in content:
    if not result.contains(x):
      result.add(x)

proc enumerate(s: AnyString): seq[int] =
  let alphabet = uniq(s).sorted(system.cmp[char])
  result = newSeq[int](s.len)
  for i, c in s:
    result[i] = alphabet.find(c) + 1
  for _ in 1 .. padding:
    result.add(0)

proc dc3suffixArray(s: AnyString): IntArray =
  ints(dc3(enumerate(s)))

proc sortSuffixArray(s: AnyString): IntArray =
  let L = s.len
  proc compareIndices(j, k: int): int =
    var
      currentJ = j
      currentK = k
    for i in 0 ..< L:
      if s[currentJ] < s[currentK]: return -1
      elif s[currentJ] > s[currentK]: return 1
      currentJ += 1
      currentK += 1
      if currentJ == L:
        return -1
      if currentK == L:
        return 1
    return 0
  var r = toSeq(0 ..< s.len)
  r.sort(compareIndices)
  result = ints(s.len, maxBits(s.len))
  for i in 0 ..< s.len:
    result[i] = r[i]

type SuffixArrayAlgorithm* {.pure.} = enum
  Sort, DC3

proc suffixArray*(s: AnyString, algorithm = SuffixArrayAlgorithm.Sort): IntArray =
  case algorithm
  of SuffixArrayAlgorithm.Sort: sortSuffixArray(s)
  of SuffixArrayAlgorithm.DC3: dc3suffixArray(s)

const specialChar = '\0'

proc burrowsWheeler*(s: AnyString, rotations: IntArray): string =
  let L = s.len
  result = newString(L + 1)
  result[0] = s[s.len - 1]
  for i in 1 .. L:
    let j = rotations[i - 1]
    if j == 0:
      result[i] = specialChar
    else:
      result[i] = s[j - 1]

proc burrowsWheeler*(s: AnyString, algorithm = SuffixArrayAlgorithm.Sort): string =
  burrowsWheeler(s, suffixArray(s, algorithm))

proc inverseBurrowsWheeler*(s: AnyString): string =
  let alphabet = uniq(s).sorted(system.cmp[char])
  var
    eqPartials = newTable[char, int]()
    ltCounters = newTable[char, int]()
    eqCounters = newSeqOfCap[int](s.len)
    currentIndex = 0
    currentChar = specialChar
  for i, c in s:
    if c == specialChar:
      currentIndex = i
    if eqPartials.hasKey(c):
      eqCounters.add(eqPartials[c])
      eqPartials[c] += 1
    else:
      eqCounters.add(0)
      eqPartials[c] = 1
  var total = 0
  for c in alphabet:
    ltCounters[c] = total
    total += eqPartials[c]
  result = newString(s.len - 1)
  for j in countdown(result.high, 0):
    currentIndex = eqCounters[currentIndex] + ltCounters[currentChar]
    currentChar = s[currentIndex]
    result[j] = currentChar

type
  FMIndex* = object
    bwt: WaveletTree
    lookup: TableRef[char, int]
    length: int
  SearchIndex* = object
    fmIndex*: FMIndex
    suffixArray*: IntArray
  Positions* = object
    first*, last*: int

proc searchIndex*(s: AnyString,  algorithm = SuffixArrayAlgorithm.Sort): SearchIndex =
  let
    alphabet = uniq(s).sorted(system.cmp[char])
    sa = suffixArray(s, algorithm)
  var
    charCount = newTable[char, int]()
    lookup = newTable[char, int]()
  for c in s:
    if charCount.hasKey(c):
      charCount[c] += 1
    else:
      charCount[c] = 1
  var total = 1
  lookup[specialChar] = 0
  for c in alphabet:
    lookup[c] = total
    total += charCount[c]
  let bwt = burrowsWheeler(s, sa)
  return SearchIndex(
    fmIndex: FMIndex(bwt: waveletTree(bwt), lookup: lookup, length: bwt.len),
    suffixArray: sa
  )

proc fmIndex*(s: AnyString, algorithm = SuffixArrayAlgorithm.Sort): FMIndex =
  searchIndex(s, algorithm).fmIndex

proc search*(index: FMIndex, pattern: AnyString): Positions =
  var
    s = 0
    e = index.length - 1
  for i in countdown(pattern.high, 0):
    let c = pattern[i]
    s = index.lookup[c] + index.bwt.rank(c, s)
    e = index.lookup[c] + index.bwt.rank(c, e)
    if s > e: break
  return Positions(first: s - 1, last: e - 2)

proc toSeq*(p: Positions): seq[int] = sequtils.toSeq(p.first .. p.last)

proc search*(index: SearchIndex, pattern: AnyString): seq[int] =
  let ps = index.fmIndex.search(pattern)
  result = newSeq[int]()
  for i in ps.first .. ps.last:
    result.add(index.suffixArray[i])

# An implementation of Boyer-Moore-Horspool string searching.
proc boyerMooreHorspool*(target: AnyString, query: string, start = 0): int =
  let
    m = len(query)
    n = len(target)
  if m > n: return -1
  var skip = newSeq[int](257)
  for i in 1 .. 256:
    skip[i] = m
  for k in 0 .. < (m - 1):
    skip[query[k].int] = m - k - 1
  var k = start + m - 1
  while k < n:
    var
      j = m - 1
      i = k
    while j >= 0 and target[i] == query[j]:
      dec(j)
      dec(i)
    if j == -1:
      return i + 1
    k += skip[target[k].int]
  return -1

proc `[]`*(s: Spill[char], x: Slice[int]): string =
  result = newStringOfCap(x.b - x.a + 1)
  for i in x.a .. x.b:
    result.add(s[i])