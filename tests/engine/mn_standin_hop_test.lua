-- Map 180 after the crossing: 2A:5D42 fills the slot-0 stand-in at 22,9, inside the
-- cliff (only row 11 is floor). 2A:5DBD then plays 20:505D for 2 frames (+2 px/frame)
-- and the hop 20:5738 for $1A frames (-2..+4 px/frame, then a jump to an idle, so it
-- does not loop). Tony must land on row 11 before control comes back.
--
-- ApplyFineXDelta (05:67B1) and ApplyFineYDelta (05:67E7) step the cell when bit 4
-- of the fine sum is set. They do not read the cell byte, so a made-up $08 wall and
-- a $C2 trigger are entered from the floor or from inside the wall, for every slot.
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

ok(Sprites.walkGate(cell, true, 22, 9, 22, 10), "stand-in inside a wall steps into $08 (22,9 -> 22,10)")
ok(Sprites.walkGate(cell, true, 22, 11, 22, 10), "stand-in on the floor steps into $08 (22,11 -> 22,10)")
ok(Sprites.walkGate(cell, false, 22, 9, 22, 10), "other object inside a wall steps into $08")
ok(Sprites.walkGate(cell, false, 22, 11, 22, 10), "other object on the floor steps into $08")
ok(Sprites.walkGate(function() return 0xC2 end, true, 10, 8, 10, 9), "stand-in enters a $C2 trigger")
ok(Sprites.walkGate(function() return 0xC2 end, false, 10, 8, 10, 9), "other object enters a $C2 trigger")

local function cross(standIn, fx, fy, dx, dy)
  local o = { x = fx, y = fy, ox = 0, oy = 0, fi = 1, ft = 0, seq = { { n = 1, dx = dx, dy = dy }, once = true } }
  Sprites.tick(o, function(x, y) return Sprites.walkGate(cell, standIn, o.x, o.y, x, y) end)
  return o.x, o.y
end
local x, y = cross(true, 22, 11, 0, -16)
ok(x == 22 and y == 10, "tick: stand-in on the floor enters the wall")
x, y = cross(false, 22, 11, 0, -16)
ok(x == 22 and y == 10, "tick: other object on the floor enters the wall")
x, y = cross(false, 22, 9, 0, 16)
ok(x == 22 and y == 10, "tick: other object inside the wall keeps stepping")

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
