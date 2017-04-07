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
import stopwatch, sequtils, strutils
import cello

proc main() =
  let
    words = sequtils.toSeq(lines("/etc/dictionaries-common/words"))
    L = 10000 # words.len
  var sw = stopwatch()

  sw.start()
  for i in 0 .. <  L:
    for j in (i + 1) .. <  L:
      discard ratcliffObershelp(words[i], words[j])
  sw.stop()

  echo "We have required ", sw.secs(), " seconds to compute all Ratcliff-Obershelp similarities among ", L, " strings."

  sw.start()
  for i in 0 .. <  L:
    for j in (i + 1) .. <  L:
      discard levenshtein(words[i], words[j])
  sw.stop()

  echo "We have required ", sw.secs(), " seconds to compute all Levenshtein similarities among ", L, " strings."

when isMainModule:
  main()