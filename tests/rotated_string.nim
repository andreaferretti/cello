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


suite "rotated strings":
  test "reading chars":
    let x = "Hello, world".rotate(7)

    check x[0] == 'w'
    check x[1] == 'o'
    check x[2] == 'r'
    check x[3] == 'l'
    check x[4] == 'd'
    check x[5] == 'H'
    check x[6] == 'e'
    check x[7] == 'l'
    check x[8] == 'l'
    check x[9] == 'o'
    check x[10] == ','
    check x[11] == ' '
  test "writing chars":
    var x = "Hello, world".rotate(5)

    check x[0] == ','
    x[0] = 'f'
    check x[0] == 'f'
  test "underlying strings are shared":
    var
      x = "Hello, world"
      y = x.rotate(5)

    y[0] = 'f'
    when declared(shallowCopy):
      check x[5] == 'f'
  test "transforming to string":
    var x = "Hello, world".rotate(7)

    check $x == "worldHello, "