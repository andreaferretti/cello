# Briefly

Briefly is a library of succinct data structures, oriented in particular
for string searching and string operations.

## Operations

The most common operations that we implement on various kind of sequence data
are `rank` and `select`.

For bit sequences, `rank(i)` counts the number of 1 bits in the first `i`
places. The number of 0 bits can easily be obtained as `i - rank(i)`. Viceversa,
`select(i)` finds the position of the `i`-th 1 bit in the sequence. In this
case, there is not an obvious relation to the position of the `i`-th 0 bit,
so we provide a similar operation `select0(i)`.

To ensure that `rank(select(i)) == i`, we define `select(i)` to be 1-based,
that is, we count bits starting from 1.

As a reference, we implement `rank` and `select` on Nim built-in sets, so
that for instance the following is valid:

```nim
let x = { 13..27, 35..80 }

echo x.rank(16)  # 3
echo x.select(3) # 16
```

More generally, one can define 'rank' and `select` for sequence of symbols
taken from a finite alphabet, relative to a certain symbol. Here, `rank(c, i)`
is the number of symbols equal to `c` among the first `i` symbols, and
`select(c, i)` is the position of the `i`-th symbol `c` in the sequence.

Again, we give a reference implementation for strings, so that the following
is valid:

```nim
let x = "ABRACADABRA"

echo x.rank('A', 8)   # 4
echo x.select('A', 4) # 8
```

Notice that in both cases, the implementation of `rank` and `select` is a
naive implementation which takes `O(i)` operations. More sophisticated data
structures allow to perform similar operations in constant (for rank) or
logarithmic (for select) time, by using indices. *Succinct* data structures
allow to do this using indices that take at most `o(n)` space in addition
to the sequence data itself, where `n` is the sequence length.

## Data structures

We now describe the succinct data structures that will generalize the bitset
and the string examples above. In doing so, we also need a few intermediate
data structures that may be of independent interest.

### Bit arrays

Bit arrays are a generalization of Nim default `set` collections. They can
be seen as an ordered sequence of `bool`, which are actually backed by a
`seq[int]`. We implement random access - both read and write - as well as
naive `rank` and `select`. An example follows:

```nim
var x = bits(13..27, 35..80)

echo x[12]   # false
echo x[13]   # true
x[12] = true # or incl(x, 12)
echo x[12]   # true
x[12] = false

echo x.rank(16)    # 3
echo x.select(3)   # 16
echo x.select0(30) # 90
```

### Int arrays

Int arrays are just integer sequences of fixed length. What distinguishes
them by the various types `seq[int64]`, `seq[int32]`, `seq[int16]`, `seq[int8]`
is that the integers can have any length, such as 23.

They are backed by a bit array, and can be used to store many integer numbers
of which an upper bound is known without wasting space. For instance, a sequence
of positive numbers less that 512 can be backed by an int array where each
number has size 9. Using a `seq[int16]` would almost double the space
consumption.

Most sequence operations are available, but they cannot go after the initial
capacity. Here is an example:

```nim
var x = ints(200, 13) # 200 ints at most 2^13 - 1

x.add(123)
x.add(218)
x.add(651)
echo x[2]   # 651
x[12] = 1234
echo x[12]   # 1234

echo x.len       # 13
echo x.capacity  # 200
```