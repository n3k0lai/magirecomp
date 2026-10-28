-- Map 180 after the crossing: 2A:5D42 fills the slot-0 stand-in at 22,9, inside the
-- cliff (only row 11 is floor). 2A:5DBD then plays 20:505D for 2 frames (+2 px/frame)
-- and the hop 20:5738 for $1A frames (-2..+4 px/frame, then a jump to an idle, so it
-- does not loop). Tony must land on row 11 before control comes back.
--   luajit tests/engine/mn_standin_hop_test.lua
package.path = "./?.lua;./?/init.lua;./src/?.lua;" .. package.path
love = love or { math = { random = function(a) return a or 0 end } } -- luacheck: ignore 111

local failures, checks = 0, 0
local function ok(cond, what)
  checks = checks + 1
  if not cond then failures = failures + 1; print("FAIL " .. what) end
end

local Sprites = require("mn.Sprites")

-- 30x16, walls ($08) except floor row 11
local function cell(x, y) return y == 11 and x >= 1 and x <= 23 and 0 or 8 end

-- the gate
ok(Sprites.walkGate(cell, true, 22, 9, 22, 10), "stand-in inside a wall may move (22,9 -> 22,10)")
ok(not Sprites.walkGate(cell, true, 22, 11, 22, 10), "stand-in on the floor still stops at the wall")
ok(not Sprites.walkGate(cell, false, 22, 9, 22, 10), "other objects keep the strict gate")
ok(Sprites.walkGate(function() return 0xC2 end, true, 10, 8, 10, 9), "stand-in may end on a trigger cell")
ok(not Sprites.walkGate(function() return 0xC2 end, false, 10, 8, 10, 9), "objects may not")

-- the hop, as Sprites.frames decodes 20:505D (loops) and 20:5738 (does not)
local walk = { once = false }
for i = 1, 4 do walk[i] = { n = 8, dx = 0, dy = 2 } end
local hop = { once = true }
for i, d in ipairs({ -2, -1, 0, 0, 2, 2, 2, 3, 3, 4 }) do hop[i] = { n = 2, dx = 0, dy = d } end
hop[11] = { n = 3, dx = 0, dy = 1 }

local o = { x = 22, y = 9, ox = 0, oy = 0, fi = 1, ft = 0, seq = walk }
local gate = function(x, y) return Sprites.walkGate(cell, true, o.x, o.y, x, y) end
for _ = 1, 2 do Sprites.tick(o, gate) end
o.seq, o.fi, o.ft, o.spent = hop, 1, 0, nil
for _ = 1, 0x1A do Sprites.tick(o, gate) end
o.seq, o.fi, o.ft, o.spent = { { n = 255, dx = 0, dy = 0 }, once = true }, 1, 0, nil
Sprites.tick(o, gate)
ok(o.x == 22 and o.y == 11, ("stand-in lands on row 11 (got %d,%d+%d)"):format(o.x, o.y, o.oy))
ok(o.oy >= 0 and o.oy < 8, "lands near the cell top (oy " .. o.oy .. ")")

if failures == 0 then print(("ok %d checks"):format(checks)) else print(("%d FAIL / %d"):format(failures, checks)) end
os.exit(failures == 0 and 0 or 1)
