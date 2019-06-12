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
import stopwatch, random, sequtils
import cello

proc main() =
  const
    width = 100_000_000
    ops = 10000
    patternLen = 10
    letters = ['A', 'C', 'G', 'T']
  echo "Initialization starting"
  randomize(12435)
  var
    s = newString(width)
    indices = newSeq[int]()
    sw = stopwatch()

  for i in 0 ..<  width:
    s[i] = letters[rand(3)]

  for _ in 0 ..< ops:
    indices.add(rand(width - patternLen - 1))

  echo "Initialization done"

  sw.start()
  let index = searchIndex(s)
  sw.stop()

  echo "We have required ", sw.secs(), " seconds to prepare the FM index for a ", width, " long string."

  sw.start()
  for i in indices:
    let
      pattern = s[i .. (i + patternLen - 1)]
      positions = index.fmIndex.search(pattern)
    discard positions.toSeq.mapIt(index.suffixArray[it])
  sw.stop()

  echo "We have required ", sw.secs(), " seconds to find ", ops, " patterns."

  sw.start()
  for i in indices:
    let
      pattern = s[i .. (i + patternLen - 1)]
    discard boyerMooreHorspool(s, pattern)
  sw.stop()

  echo "We have required ", sw.secs(), " seconds to find ", ops, " patterns with Boyer-Moore."

when isMainModule:
  main()