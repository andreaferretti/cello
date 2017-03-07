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
naive implementation which takes `O(i)` operations.