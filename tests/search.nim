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
import cello, unittest, random, algorithm
include utils


suite "Search":
  test "backward search with index":
    let
      x = "mississippi"
      pattern = "iss"
      index = searchIndex(x)
      positions = index.search(pattern)

    check positions.sorted(system.cmp[int]) == @[1, 4]

  test "approximate search with index":
    let
      letters = ['A', 'C', 'G', 'T']
      x = randomString(100000, letters)
    var pattern = x[2330 .. 2360]
    # we change a few characters randomly
    var c = random(7)
    while c < pattern.len:
      pattern[c] = letters[random(4)]
      c += random(7)
    let
      index = searchIndex(x)
      options = searchOptions(exactness = 0.2)
      position = index.searchApproximate(x, pattern, options)

    check position == 2330