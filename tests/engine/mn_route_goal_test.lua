-- MN_ROUTE ">" chains (aff7e0f7): a text box or kick counts as the goal's talk
-- only when Tony is standing on the goal. No ROM needed.
--   luajit tests/engine/mn_route_goal_test.lua
package.path = "./?.lua;./?/init.lua;./src/?.lua;" .. package.path

local failures, checks = 0, 0
local function ok(cond, what)
  checks = checks + 1
  if not cond then failures = failures + 1; print("FAIL " .. what) end
end

local G = require("mn.boot.RouteGoal")

-- 249: the 18,5 pirate scene's box pops up with steps to 27,3 still left
ok(not G.talkEndsGoal({ textBox = {}, farFace = "up", farPath = { { 26, 4 }, { 27, 4 }, { 27, 3 } } }),
  "a box on the way does not end the goal")
ok(not G.talkEndsGoal({ kickSeen = true, farFace = "up", farPath = { { 27, 3 } } }), "a kick on the way does not either")
-- on the goal (path used up), facing it: the A press's box ends it
ok(G.talkEndsGoal({ textBox = {}, farFace = "up", farPath = {} }), "a box on the goal ends it")
ok(G.talkEndsGoal({ kickSeen = true, farFace = "up", farPath = {} }), "a kick on the goal ends it")
-- no box, no face, or no path yet: nothing to count
ok(not G.talkEndsGoal({ farFace = "up", farPath = {} }), "no box, no talk")
ok(not G.talkEndsGoal({ textBox = {}, farPath = {} }), "a goal with no facing is not a talk goal")
ok(not G.talkEndsGoal({ textBox = {}, farFace = "up" }), "no path planned yet")

if failures == 0 then print(("ok %d checks"):format(checks)) else print(("%d FAIL / %d"):format(failures, checks)) end
os.exit(failures == 0 and 0 or 1)
