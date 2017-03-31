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
import cello, unittest, random

import future
suite "int arrays":
  test "int array access":
    var
      x = newSeq[int](100)
      y = ints(100, 9)
    for i in 0 .. 99:
      let r = random(512)
      x[i] = r
      y[i] = r
    for i in 0 .. 99:
      check(y[i] == x[i])
  test "adding to int arrays":
    var
      x = newSeq[int](100)
      y = ints(100, 9)
    for i in 0 .. 99:
      x[i] = random(512)
    for i in 0 .. 45:
      y.add(x[i])
    for i in 0 .. 45:
      check(y[i] == x[i])
    check(y.len == 46)
    # because the smallest multiple of 64
    # that is bigger than 9 * 100
    # is 64 * 15 == 960, and
    # 960 div 9 == 106
    check(y.capacity == 106)
  test "transforming to sequence and back":
    var x = newSeq[int](100)
    for i in 0 .. 99:
      x[i] = random(512)
    let y = ints(x)
    check x == y.toIntSeq