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
import cello, strutils, unittest


suite "operations over strings":
  test "rank on a string":
    let x = "ACGGTACTACGAGAGTAGCAGTTTAGCGTAGCATGCTAGCG"
    check x.rank('A', 17) == 6
    check x.rank('C', 17) == 3
    check x.rank('G', 17) == 5
    check x.rank('T', 17) == 3
    check x.rank('A', 41) == 11
    check x.rank('C', 41) == 8
    check x.rank('G', 41) == 13
    check x.rank('T', 41) == 9
  test "select on a wavelet tree":
    let x = "ACGGTACTACGAGAGTAGCAGTTTAGCGTAGCATGCTAGCG"
    check x.select('A', 6) == 17
    check x.select('C', 3) == 10
    check x.select('G', 5) == 15
    check x.select('T', 3) == 16
    check x.select('A', 11) == 38
    check x.select('C', 8) == 40
    check x.select('G', 13) == 41
    check x.select('T', 9) == 37