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
proc randomBits(width: int): tuple[bits: BitArray, count: int] =
  result.bits = bits(width)
  result.count = 0
  for i in 0 ..< width:
    if rand(1) == 0:
      result.bits[i] = true
      result.count += 1

proc randomString(width: int, letters: openarray[char]): string =
  let L = len(letters)
  result = newString(width)
  for i in 0 ..< width:
    result[i] = letters[rand(L - 1)]