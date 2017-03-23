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
import briefly, unittest


suite "generating blocks in popcount order":
  test "generating blocks":
    var results = newSeq[string]()
    for x in blocks(popcount = 3, size = 5):
      results.add bin(x)[59..64]

    let expected = @[
      "00111",
      "01011",
      "01101",
      "01110",
      "10011",
      "10101",
      "10110",
      "11001",
      "11010",
      "11100"
    ]
    check results == expected