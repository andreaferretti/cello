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

type
  AnyInt* = int32 or int64
  BitArray*[T] = object
    data: seq[T]

proc bits*[T: AnyInt](k: int): BitArray[T] =
  const L = sizeof(T) * 8
  result = BitArray[T](data: newSeq[T](k div L))
  # shallow(result.data)

proc len*[T: AnyInt](bits: BitArray[T]): int =
  bits.data.len * sizeof(T) * 8

proc `[]`*[T: AnyInt](b: T, i: T): bool {.inline.} =
  ((b shr i) mod 2) != 0

proc `[]`*[T: AnyInt](bits: BitArray[T], i: T): bool {.inline.} =
  const L = sizeof(T) * 8
  let
    b = bits.data[(i div L).int]
    j = i mod L
  return b[j]

proc `[]=`*[T: AnyInt](bits: var BitArray[T], i: T, v: bool) {.inline.} =
  const L = sizeof(T) * 8
  let
    j = i mod L
    k = (i div L).int
    p = T(1) shl j
  if v:
    bits.data[k] = bits.data[k] or p
  else:
    bits.data[k] = bits.data[k] and (not p)

template contains*[T: AnyInt](bits: BitArray[T], i: T): bool = bits[i]

template incl*[T: AnyInt](bits: var BitArray[T], i: T) =
  bits[i] = true

proc bits*(xs: varargs[Slice[int32]]): BitArray[int32] =
  var m = 0
  for x in xs:
    m = max(m, x.b)
  result = bits[int32](m.nextPowerOfTwo)
  for x in xs:
    for y in x:
      result.incl(y)

proc bits*(xs: varargs[Slice[int64]]): BitArray[int64] =
  var m = 0'i64
  for x in xs:
    m = max(m, x.b)
  result = bits[int64](m.int.nextPowerOfTwo)
  for x in xs:
    for y in x:
      result.incl(y)

proc bin*[T: AnyInt](t: T): string

proc rank*[T: AnyInt](t: T, i: T): auto =
  const L = sizeof(T) * 8
  if i == 0:
    return 0
  if i >= L:
    return countSetBits(t)
  let mask = T(-1) shr (L - i)
  countSetBits(mask and t)

proc rank*[T: AnyInt](s: BitArray[T], i: T): int =
  const L = sizeof(T) * 8
  let
    j = i mod L
    k = (i div L).int
  for r in 0 .. < k:
    result += countSetBits(s.data[r])
  result += rank(s.data[k], j)

proc select*[T: AnyInt](t: T, i: T): T =
  const L = sizeof(T) * 8
  var
    t1 = t
    i1 = i
  while i1 > 0:
    let s = trailingZeroBits(t1) + 1
    t1 = t1 shr s
    result += s
    dec i1
  if result > L:
    return 0

proc select*[T: AnyInt](s: BitArray[T], i: int): T =
  const L = sizeof(T) * 8
  var
    r = i
    count = 0
  while count < s.data.len:
    let p = countSetBits(s.data[count])
    if r <= p:
      break
    r -= p
    inc count
  return T(count * L) + select(s.data[count], T(r))

proc bin*[T: AnyInt](t: T): string =
  const L = sizeof(T) * 8
  result = ""
  for i in 1 .. T(L):
    if t[L - i]:
      result &= '1'
    else:
      result &= '0'

proc `$`*[T: AnyInt](b: BitArray[T]): string =
  join(b.data.map(bin).reversed, " ")

template nextPerm(v: int32): auto =
  let t = (v or (v - 1)) + 1
  t or ((((t and -t) div (v and -v)) shr 1) - 1)

iterator blocks*(popcount, size: int32): auto {.inline.} =
  let
    initial = (1'i32 shl popcount) - 1
    mask = (1'i32 shl size) - 1
  var v = initial
  while v >= initial:
    yield v
    v = nextPerm(v) and mask


# TODO replace the indices with bit arrays to save space
type RRR*[T] = object
  ba*: BitArray[T]
  index1*: seq[T]
  index2*: seq[int16]

proc rrr*[T: AnyInt](ba: BitArray[T]): RRR[T] =
  const
    step1 = sizeof(T) * 8 * 8
    step2 = sizeof(T) * 8
  let L = ba.len
  var
    index1 = newSeqOfCap[T](L div step1)
    index2 = newSeqOfCap[int16](L div step2)
    i = 0
    pos = T(0)
    last = T(0)
  while pos < L:
    let k = T(rank(ba, pos))
    index2.add(int16(k - last))
    if i mod 8 == 0:
      last = k
      index1.add(k)
    i += 1
    pos += step2
  return RRR[T](ba: ba, index1: index1, index2: index2)

proc rank*[T](r: RRR[T], i: int): T =
  const
    step1 = sizeof(T) * 8 * 8
    step2 = sizeof(T) * 8
  return r.index1[i div step1] + r.index2[i div step2] + rank(r.ba.data[i div step2], i mod step2)

proc binarySearch[T](s: seq[T], value: T, min, max: int): (int, T) =
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

proc select*[T](r: RRR[T], i: int): T =
  const
    step1 = sizeof(T) * 8 * 8
    step2 = sizeof(T) * 8
  let
    (i1, s1) = binarySearch(r.index1, T(i), r.index1.low, r.index1.high)
    (i2, s2) = binarySearch(r.index2, (i - i1).int16, i1, min(i1 + 8, r.index2.high))
  return T(step1 * i1 + step2 * i2) + select(r.ba.data[T(i1 + i2)], T(i - s1 - s2))