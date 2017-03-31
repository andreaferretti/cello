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
import random
import cello

const width = 1_000_000_000

proc makeWaveletTree(): auto =
  var b = newString(width)
  let letters = ['A', 'C', 'G', 'T']
  randomize(12435)

  for i in 0 .. <  width:
    b[i] = letters[random(4)]

  return waveletTree(b)

proc main() =
  let b = makeWaveletTree()
  GC_fullCollect()
  echo GC_getStatistics()
  dumpNumberOfInstances()
  echo "Number of bytes needed for raw data: ", (width div 8)
  echo "Number of bits: ", b.stats

when isMainModule:
  main()