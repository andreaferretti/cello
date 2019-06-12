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
import cello, unittest, random, sequtils
include utils


suite "Suffix array":
  test "computing the suffix array":
    let
      x = "this is a test."
      s = suffixArray(x)
      t = @[7'u, 4, 9, 14, 8, 11, 1, 5, 2, 6, 3, 12, 13, 10, 0]

    for i in t.low .. t.high:
      check s[i] == t[i]
  test "computing the suffix array again":
    let
      x = "ACTGTAT"
      s = suffixArray(x)
      t = @[0'u, 5, 1, 3, 6, 4, 2]

    for i in t.low .. t.high:
      check s[i] == t[i]
  test "computing the suffix array with DC3":
    let
      x = "TAATT"
      s = suffixArray(x, SuffixArrayAlgorithm.Sort)
      s1 = suffixArray(x, SuffixArrayAlgorithm.DC3)

    for i in 0 ..< x.len:
      check s[i] == s1[i]
  test "computing the suffix array with DC3 for a random string":
    let
      x = randomString(1000, ['A', 'C', 'T', 'G'])
      s = suffixArray(x, SuffixArrayAlgorithm.Sort)
      s1 = suffixArray(x, SuffixArrayAlgorithm.DC3)

    for i in 0 ..< x.len:
      check s[i] == s1[i]