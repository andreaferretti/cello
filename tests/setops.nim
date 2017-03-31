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
import cello, unittest


suite "operations over sets":
  let x1 = { 13..27, 35..80 }
  var x: set[int8]
  for q in x1:
    x.incl(q.int8)

  test "rank":
    check x.rank(16) == 3
    check x.rank(30) == 15
    check x.rank(40) == 20
  test "select":
    check x.select(3)  == 16
    check x.select(15) == 28
    check x.select(20) == 40