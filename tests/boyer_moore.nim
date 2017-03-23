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
import briefly, unittest, random, strutils, sequtils
include utils


suite "Boyer-Moore-Horspool":
  test "Boyer-Moore search":
    let
      x = "mississippi"
      pattern = "iss"

    check boyerMooreHorspool(x, pattern) == 1
    check boyerMooreHorspool(x, pattern, start = 2) == 4

  test "Boyer-Moore search on a random string":
    let
      x = randomString(1000, ['A', 'C', 'G', 'T'])
      pattern = x[133 .. 136]

    var
      positions = newSeq[int]()
      last = boyerMooreHorspool(x, pattern)

    while last != -1:
      positions.add(last)
      last = boyerMooreHorspool(x, pattern, start = last + 1)

    check(133 in positions)

    for j in positions:
      let y = $(x.rotate(j))
      check y.startsWith(pattern)