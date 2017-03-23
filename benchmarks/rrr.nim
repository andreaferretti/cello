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
  echo "Initialization starting"
  randomize(12435)
  var
    b = bits(width)
    indicesRank = newSeq[int]()
    indicesSelect = newSeq[int]()
    sw = stopwatch()

  for i in 0 .. <  width:
    if random(2) == 0:
      incl(b, i)

  for _ in 0 .. < ops:
    indicesRank.add(random(width))
    indicesSelect.add(random(width div 3))
  echo "Initialization done"

  sw.start()
  let r = rrr(b)
  sw.stop()

  echo "We have required ", sw.secs(), " seconds to fill a ", width, " size rrr structure."

  sw.start()
  for i in indicesRank:
    discard r.rank(i)
  sw.stop()

  echo "We have required ", sw.secs(), " seconds to compute ", ops, " ranks."

  sw.start()
  for i in indicesSelect:
    discard r.select(i)
  sw.stop()

  echo "We have required ", sw.secs(), " seconds to compute ", ops, " selects."

  sw.start()
  for i in indicesSelect:
    discard r.select0(i)
  sw.stop()

  echo "We have required ", sw.secs(), " seconds to compute ", ops, " selects for 0."

when isMainModule:
  main()