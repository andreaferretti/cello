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


suite "bit access in integers":
  test "printing 64 bit patterns":
    check bin(0)         == "0000000000000000000000000000000000000000000000000000000000000000"
    check bin(1)         == "0000000000000000000000000000000000000000000000000000000000000001"
    check bin(-1)        == "1111111111111111111111111111111111111111111111111111111111111111"
    check bin(-461274)   == "1111111111111111111111111111111111111111111110001111011000100110"
    check bin(126851658) == "0000000000000000000000000000000000000111100011111001101001001010"
  test "rank on 64 bit integers":
    check rank(-461274, 0)  == 0
    check rank(-461274, 1)  == 0
    check rank(-461274, 10) == 4
    check rank(-461274, 20) == 10
    check rank(-461274, 32) == 22
    check rank(-461274, 64) == 54
    check rank(-461274, 80) == 54
    check rank(126851658, 0)  == 0
    check rank(126851658, 1)  == 0
    check rank(126851658, 10) == 4
    check rank(126851658, 20) == 11
    check rank(126851658, 32) == 15
    check rank(126851658, 64) == 15
    check rank(126851658, 80) == 15
  test "select on 64 bit integers":
    check select(-461274, 0)  == 0
    check select(-461274, 1)  == 2
    check select(-461274, 4)  == 10
    check select(-461274, 10) == 20
    check select(-461274, 22) == 32
    check select(-461274, 54) == 64
    check select(-461274, 80) == 0
    check select(126851658, 0)  == 0
    check select(126851658, 1)  == 2
    check select(126851658, 4)  == 10
    check select(126851658, 11) == 20
    check select(126851658, 15) == 27
    check select(126851658, 64) == 0
    check select(126851658, 80) == 0