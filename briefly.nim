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