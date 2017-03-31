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
import cello

proc randomString(width: int, letters: openarray[char]): string =
  let L = len(letters)
  result = newString(width)
  for i in 0 ..< width:
    result[i] = letters[random(L)]

proc main() =
  const width = 10_000_000
  echo "Initialization starting"
  randomize(12435)
  var x = randomString(width, letters = ['A', 'C', 'G', 'T'])
  var sw = stopwatch()
  echo "Initialization done"

  sw.start()
  let s = burrowsWheeler(x)
  sw.stop()

  echo "We have required ", sw.secs(), " seconds to do the Burrows-Wheeler transform of a  ", width, " long string."

  sw.start()
  let y = inverseBurrowsWheeler(s)
  sw.stop()

  echo "We have required ", sw.secs(), " seconds to do the inverse Burrows-Wheeler transform of a  ", width, " long string."

when isMainModule:
  main()