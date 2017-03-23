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
import stopwatch, random
import briefly

proc main() =
  const
    width = 1_000_000_000
    ops = 10000
    letters = ['A', 'C', 'G', 'T']
  echo "Initialization starting"
  randomize(12435)
  var
    s = newString(width)
    indicesRank = newSeq[(int, char)]()
    indicesSelect = newSeq[(int, char)]()
    sw = stopwatch()

  for i in 0 .. <  width:
    s[i] = letters[random(4)]

  for _ in 0 .. < ops:
    indicesRank.add((random(width), letters[random(4)]))

  for _ in 0 .. < ops:
    indicesSelect.add((random(width div 5), letters[random(4)]))
  echo "Initialization done"

  sw.start()
  let wt = waveletTree(s)
  sw.stop()

  echo "We have required ", sw.secs(), " seconds to fill a ", width, " size wavelet tree."

  sw.start()
  for x in indicesRank:
    let (i, c) = x
    discard wt.rank(c, i)
  sw.stop()

  echo "We have required ", sw.secs(), " seconds to compute ", ops, " ranks."

  sw.start()
  for x in indicesSelect:
    let (i, c) = x
    discard wt.select(c, i)
  sw.stop()

  echo "We have required ", sw.secs(), " seconds to compute ", ops, " selects."

  sw.start()
  for x in indicesRank:
    let (i, _) = x
    discard wt[i]
  sw.stop()

  echo "We have required ", sw.secs(), " seconds to compute ", ops, " accesses."

when isMainModule:
  main()