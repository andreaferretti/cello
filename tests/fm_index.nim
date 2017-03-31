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
import cello, unittest, random, strutils, sequtils, algorithm, spills
include utils


suite "FM index":
  test "backward search":
    let
      x = "mississippi"
      pattern = "iss"
      fm = fmIndex(x)
      sa = suffixArray(x)
      positions = fm.search(pattern)

    check positions.first == 2
    check positions.last == 3

    for j in positions.first .. positions.last:
      let
        i = sa[j]
        y = $(x.rotate(i))
      check y.startsWith(pattern)

  test "backward search with index":
    let
      x = "mississippi"
      pattern = "iss"
      index = searchIndex(x)
      positions = index.search(pattern)

    check positions.sorted(system.cmp[int]) == @[1, 4]

  test "backward search on a random string":
    let
      x = randomString(1000, ['A', 'C', 'G', 'T'])
      pattern = x[133 .. 136]
      fm = fmIndex(x)
      sa = suffixArray(x)
      positions = fm.search(pattern)
      realPositions = toSeq(positions).mapIt(sa[it])

    check(133 in realPositions)

    for j in positions.first .. positions.last:
      let
        i = sa[j]
        y = $(x.rotate(i))
      check y.startsWith(pattern)

  test "backward search on a memory-mapped string":
    initSpills()
    var x = spill[char]("cello.nim", hasHeader = false)
    defer:
      x.close()
    let
      pattern = "fmIndex"
      fm = fmIndex(x)
      sa = suffixArray(x)
      positions = fm.search(pattern)
      realPositions = toSeq(positions).mapIt(sa[it])

    check(realPositions.len > 0)

    for p in realPositions:
      for i in 0 .. pattern.high:
        check(x[p + i] == pattern[i])