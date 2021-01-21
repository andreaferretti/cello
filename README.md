# Cello

![logo](https://raw.githubusercontent.com/andreaferretti/cello/master/img/logo.jpg)

Cello is a library of [succinct data structures](https://en.wikipedia.org/wiki/Succinct_data_structure),
oriented in particular for string searching and other string operations.

Usually, searching for patterns in a string takes `O(n)` time, where `n` is
the length of the string. Indices can speedup the search, but take additional
space, which can be costly for very large strings. A data structure is called
succinct when it takes `n + o(n)` space, where `n` is the space needed to store
the data anyway. Hence succinct data structures can provide additional
operations with limited space overhead.

It turns out that strings admit succinct indices, which do not take much more
space than the string itself, but allow for `O(k)` substring search, where `k`
is the length of the *substring*. Usually, this is much shorter, and this
considerably improves search times. Cello provide such indices and many other
related string operations.

An example of usage would be:

```nim
let
  x = someLongString
  pattern = someShortString
  index = searchIndex(x)
  positions = index.search(pattern)

echo positions
```
Many intermediate data structures are constructed to provide such indices,
though, and as they may be of independent interest, we describe them in the
following.

Notice that a string here just stands for a (usually very long) sequence of
symbols taken from a (usually small) alphabet. Prototypical examples include

* genomic data, where the alphabet is `A, C, G, T` or
* time series, where each value is represented by a symbol, such as `HIGH`,
  `MEDIUM`, `LOW`, or `UP`, `DOWN`
* where only two values are available, it is often convenient to store the
  data as bit sequences to save space.

At the moment all operations are implemented on

```nim
type AnyString = string or seq[char] or Spill[char]
```

where [spills](https://github.com/andreaferretti/spills) are just memory-mapped
sequences. The library may become generic in the future, although this is not
a priority.

Notice that Cello is not Unicode-aware: think more of searching large genomic
strings or symbolized time series, rather then using it for internationalized
text, although I may consider Unicode operations in the future.

## Versions

Cello recent version (>= 0.2) requires Nim >= 0.20. For usage with Nim up to
0.19.4, use Cello 0.1.6.

## Basic operations

The most common operations that we implement on various kind of sequence data
are `rank` and `select`. We first describe them for sequences of bits, which are
the foundation we use to store more complex kind of data.

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
them by the various types `seq[uint64]`, `seq[uint32]`, `seq[uint16]`, `seq[uint8]`
is that the integers can have any length, such as 23.

They are backed by a bit array, and can be used to store many integer numbers
of which an upper bound is known without wasting space. For instance, a sequence
of positive numbers less that 512 can be backed by an int array where each
number has size 9. Using a `seq[uint16]` would almost double the space
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

### RRR

The [RRR](http://alexbowe.com/rrr/) bit vector is the first of our collections
that is actually succinct. It consists of a bit arrays, plus two int arrays
that stores `rank(i)` values for various `i`, at different scales.

It can be created after a bit array, and allows constant time `rank` and
logarithmic time `select` and `select0`.

```nim
let b: BitArray = ...
let r = rrr(b)

echo r.rank(123456)
echo r.select(123456)
echo r.select0(123456)
```

To convince oneself that the structure really is succinct, `stats(rrr)` returns
a data structures that shows the space taken (in bits) by the bit array, as
well as the two auxiliary indices.

[Reference](http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.538.8528&rep=rep1&type=pdf)

### Wavelet tree

The [wavelet tree](http://alexbowe.com/wavelet-trees/) is a tree constructed
in the following way. An input string over a finite alphabet is given. The
alphabet is split in two parts - the left and the right one, call them L and R.

For each character of the string, we use a 1 bit to denote that the character
belongs to R and a 0 bit to denote that it belongs to L. In this way, we
obtain a bit sequence. The node stores the bit sequence as an RRR structures,
and has two children: the one to the left is the wavelet tree associated to
the substring composed by the characters in L, taken in order, and similarly
for the right child.

This structure allows to compute `rank(c, i)`, where `c` is a character in the
alphabet, in time `O(log(l))`, and `select(c, i)` in time `O(log(l)log(n))`
where `l` is the size of the alphabet and `n` is the size of the string.
It also allows `O(log(l))` random access to read elements of the string.

It can be used as follows:

```nim
let
  x = "ACGGTACTACGAGAGTAGCAGTTTAGCGTAGCATGCTAGCG"
  w = waveletTree(x)

echo x.rank('A', 20)   # 7
echo x.select('A', 7)  # 20
echo x[12]             # 'G'
```

[Reference](http://people.unipmn.it/manzini/papers/icalp06.pdf)

### Rotated strings

The next ingredient that we need it the Burrows-Wheeler transform of a string.
It can be implemented using string rotations, so that's what we implement
first. It turns out that this implementation is too slow for our purposes,
but rotated strings may be useful anyway, so we left them in.

A rotated strings is just a view over a string, rotated by a certain amount
and wrapping around the end of the string. If the underlying string is a `var`,
our implementation reuses that memory (which is then shared) to avoid the
copy of the string. We just implement random access and printing:

```nim
var
  s = "The quick brown fox jumps around the lazy dog"
  t = s.rotate(20)

echo t[10] # n
echo t[20] # u

t[18] = e

echo s # The quick brown fox jumps around the lezy dog
echo t # jumps around the lezy dogThe quick brown fox
```

### Suffix array

The suffix array of a string is a permutation of the numbers from 0 up to the
string length excluded. The permutation is obtained by considering, for each
`i`, the suffix starting at `i`, and sorting these strings in lexicographical
order. The resulting order is the suffix array.

Here the suffix array is represented as an IntArray. It can be obtained as
follows:

```nim
let
  x = "this is a test."
  y = suffixArray(x)

echo y # @[7, 4, 9, 14, 8, 11, 1, 5, 2, 6, 3, 12, 13, 10, 0]
```

Sorting the indices may be a costly operation. One can use the fact that the
suffixes of a string are a quite special collection to produce more efficient
algorithms. Other than the sort-based one, we offer the
[DC3 algorithm](http://spencer-carroll.com/the-dc3-algorithm-made-simple/).

Notice that at the moment DC3 is not really optimized and may be neither
space nor time efficient.

To use an alternative algorithm, just pass an additional parameter, of type

```nim
type SuffixArrayAlgorithm* {.pure.} = enum
  Sort, DC3
```

like this

```nim
let
  x = "this is a test."
  y = suffixArray(x, SuffixArrayAlgorithm.DC3)

echo y # @[7, 4, 9, 14, 8, 11, 1, 5, 2, 6, 3, 12, 13, 10, 0]
```

[Reference](https://www.cs.helsinki.fi/u/tpkarkka/publications/jacm05-revised.pdf)

### Burrows-Wheeler transform

The [Burrows-Wheeler transform](http://michael.dipperstein.com/bwt/) of a string
is a string one character longer, together with a distinguished character.
Once one has a suffix array `sa` for the string `s & '\0'`, where `\0` is our
distinguished character, the Burrows-Wheeler transform is the string which at
the index `i` has the last character of the rotation of `s` by `sa[i]`. The
distinguished index if the permutation of `\0`.

We recall the following two facts:

* the Burrows-Wheeler transform can be inverted - the exact algorithm is
  outside the purposes of this documentation
* whenever a character is a good predictor for the next one (in the original
  string), the string in the Burrows-Wheeler transform tends to have many
  repeated characters, which allows to compress it by run-length encoding.

An example of usage is this:

```nim
let
  s = "The quick brown fox jumps around the lazy dog"
  t = burrowsWheeler(s)
  u = inverseBurrowsWheeler(t)

echo t # gskynxeed\0 l in hh otTu c uwudrrfm abp qjoooza
echo u # The quick brown fox jumps around the lazy dog
```

Notice that for this to work we assume that `s` does not contain `\0` itself.
We use the fact that Nim strings are not null terminated, hence `\0` is a
valid character. Notice that printing the transformed string may not work as
intended, since the terminal may interpret the embedded `\0` as a string
terminator.

[Reference](http://www.hpl.hp.com/techreports/Compaq-DEC/SRC-RR-124.pdf)

### FM indices

An [FM index](http://alexbowe.com/fm-index/) for a string puts together
essentially all the pieces that we have described so far. The index itself
holds a walevet tree for the Burrows-Wheeler transform of the string, together
with a small auxiliary table having the size of the string alphabet.

It can be used for various purposes, but the simplest one is backward search.
Given a pattern `p` (a small string) and possibly long string `s`, there is a
way to search all occurrences of `p` in time `O(L)`, where `L` is the length
of `p` - the time is independent of `s` - using an FM index for `s`.

Every occurrence of `p` appears as the prefix of some rotation of `s` - hence
all such occurrences correspond to consecutive positions into the suffix
array for `s`. The first and last such positions can be found as follows:

```nim
let
  x = "mississippi"
  pattern = "iss"
  fm = fmIndex(x)
  sa = suffixArray(x)
  positions = fm.search(pattern)

echo positions.first # 2
echo positions.last  # 3

for j in positions.first .. positions.last:
  let i = sa[j.int]
  echo x.rotate(i)

# issippimiss
# ississippim
```

For economy, the FM index itself does not include the suffix array, as some
applications do not require the latter. Still, it is quite frequent to need
both; since computing the FM index requires the suffix array in any case, and
computing the suffix array is quite costly, there is a way to get both at the
same time. In the above example, we could write as well

```nim
let
  index = searchIndex(x)
  fm = index.fmIndex
  sa = index.suffixArray
```

The above type can be used to streamline search:

```nim
let
  index = searchIndex(x)
  positions = index.search(pattern)

echo positions # @[1, 4]
```

[Reference](http://people.unipmn.it/manzini/papers/focs00draft.pdf)

## Applications

Here we describe a few applications of the above data structures, together
with some other string utilities included in Cello.

### Boyer-Moore-Horspool search

To make a comparison with naive string searching (without using indices),
an implementation of Boyer-Moore-Horspool string searching is provided.

The Boyer-Moore algorithm and variations (such as the one used here, due to
Horspool) scan a string linearly to find a pattern, but use a precomputed table
based on the pattern to skip more than one charachter at a time.
The key observation is that after making a comparison for the pattern in a given
position, one already knows that some subsequent positions will not match for
sure, hence can be skipped. The resulting algorithm is still `O(n)` in the
length of the string, but may perform less than `n` actual comparisons.

The API mimics `strutils.find` and it is meant to be used as follows:

```nim
let
  x = "mississippi"
  pattern = "iss"

echo boyerMooreHorspool(x, pattern) # 1 (ississippi)
echo boyerMooreHorspool(x, pattern, start = 2)  # 4 (issippi)
```

[Reference](http://onlinelibrary.wiley.com/doi/10.1002/spe.4380100608/abstract)

### Levenshtein similarity

The [Levenshtein distance](https://en.wikipedia.org/wiki/Levenshtein_distance)
(or edit distance) between two strings is the minimum number of insertions,
deletions or substitutions required to change one string into the other.

It is computed by `strutils.editDistance`. Here we expose a similarity measure
derived from it, defined as `s = (L - e) / L`, where `L` is the cumulative
length of the two strings, and `e` is the edit distance. It is a number
between 0 and 1, which is 1 only if the two strings are equal.

It is simply used as

```nim
let
  a = someString
  b = someOtherString
  s = levenhstein(a, b)
```

### Ratcliff-Obershelp similarity

The Levenshtein similarity is a quite crude measure of whether two strings
resemble each other. A better measure is given by the
[Ratcliff-Obershelp similarity](https://xlinux.nist.gov/dads/HTML/ratcliffObershelp.html)
which is defined as `s = (2 * m) / L`, where `L` is the cumulative
length of the two strings, and `m` is the number of matching characters.

Matching characters are defined recursively: first we find the longest common
substring `lcs` between the two and count the number of characters of `lcs` as
matching. Then, recursively, we compare the number of matching characters in
the chunks to the left of `lcs` and to the right of `lcs`.

For instance, when comparing `ALEXANDRE` and `ALEKSANDER`, we find the following
sequence of longest common substrings:

* ALE
* AND
* R

giving a Ratcliff-Obershelp similarity of `2 * (3 + 3 + 1) / (9 + 10).`

It is simply used as

```nim
let
  a = someString
  b = someOtherString
  s = ratcliffObershelp(a, b)
```

[Reference](http://collaboration.cmc.ec.gc.ca/science/rpn/biblio/ddj/Website/articles/DDJ/1988/8807/8807c/8807c.htm)

### Jaro similarity

The Jaro similarity of two strings `a` and `b` is given by

```
0 if m == 0
((m / len(a)) + (m / len(b)) + ((m - t / 2) / m)) / 3 otherwise
```

where `m` is number of matching characters and `t` is the number of transpositions.
Here two characters are considered matching if they are equal and their ì
distance is less then `max(len(a), len(b)) / 2`. The substrings of `a` and `b`
given by matching characters are permutations of each other. Characters that
match but appear in different positions in these strings are considered transpositions.

For instance, when comparing `ALEXANDRE` and `ALEKSANDER`, we find the following
matches inside `a` and `b` respectively: `ALEANDRE`, `ALEANDER`. Hence here
`m = 8`, `t = 2`, so that the similarity is `((8 / 9) + (8 / 10) + (7 / 8)) / 3`.

[Reference](https://ilyankou.files.wordpress.com/2015/06/ib-extended-essay.pdf)

### Jaro-Winkler similarity

The Jaro-Winkler similarity of two strings is a correction to the Jaro similarity
that favours strings which have a long common prefix. If `L` is the length of
the common prefix of two strings and `J` is the Jaro similarity, the Jaro-Winkler
similarity is computed as

```
J + p * L * (1 - J)
```

where `p` is a constant factor, commonly set as `p=0.1`.

**NB** The Jaro Winkler similarity can be higher than 1, unlike the other
metrics implemented in Cello.

### Approximate search

We implement a naif form of approximate search for strings. The algorithm is
as follows: when looking for a pattern we randomly select a substring of the
pattern whose length is a given fraction (`exactness`) of the pattern itself.
We then search for this substring exactly in the target string. If we find it,
we focus on a window around this match having the same length as the pattern.
We compare the similarity of the window with the pattern itself, using one
of the similarity functions above. If this is above a given threshold
(`tolerance`) we accept the match and return the position of the window;
otherwise we try with another attempt. After a certain number of attempts
fail, we return `-1`.

The algorithm is driven by the following type:

```nim
type
  Similarity {.pure.} = enum
    RatcliffObershelp, Levenshtein, LongestSubstring, Jaro, JaroWinkler
  SearchOptions = object
    exactness, tolerance: float
    attempts: int
    similarity: Similarity
```

and can be used like this:

```nim
let
  s = someLongString
  pattern = someShortString
  index = searchIndex(s)
  options = searchOptions(exactness = 0.2)
  position = index.searchApproximate(x, pattern, options)

echo position
```

The defaults are `exactness = 0.1`, `tolerance = 0.7`, `attempts = 30` and
`similarity = Similarity.RatcliffObershelp`

## TODO

* Improve DC3 algorithm
* More applications of suffix arrays
* Construct wavelet trees in threads
* Make use of SIMD operations to improve performance
* Allow data structures to work on memory-mapped files
* Implement assembly on top of FM indices following [this thesis](ftp://ftp.sanger.ac.uk/pub/resources/theses/js18/thesis.pdf)

# Thanks

The logo comes from [cliparts.co](http://cliparts.co/clipart/2313124)