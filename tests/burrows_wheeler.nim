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


suite "Burrows-Wheeler transform":
  test "direct transform":
    let x = "this is a test."

    check burrowsWheeler(x) == ".ssat tt hiies \0"
  test "direct transform with DC3":
    let x = "this is a test."

    check burrowsWheeler(x, SuffixArrayAlgorithm.DC3) == ".ssat tt hiies \0"
  test "inverse transform":
    let
      x = "this is a test."
      s = burrowsWheeler(x)
      y = inverseBurrowsWheeler(s)
    check x == y
  test "inverse transform of a random string":
    let
      x = randomString(1000, ['A', 'C', 'G', 'T'])
      s = burrowsWheeler(x)
      y = inverseBurrowsWheeler(s)
    check x == y
  test "direct transform of a seq[char]":
    let
      x = sequtils.toSeq("this is a test.".items)
      s = burrowsWheeler(x)
      y = inverseBurrowsWheeler(s)
    check x == sequtils.toSeq(y.items)