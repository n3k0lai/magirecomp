-- mn.Motion: 05:682D (classify, probes, handler table), 01:5E65 conveyors and
-- the 01:422E once-per-entry trigger rule. Made-up cell planes only.
--   luajit tests/engine/mn_motion_test.lua
package.path = "./?.lua;./?/init.lua;./src/?.lua;" .. package.path

local failures, checks = 0, 0
local function ok(cond, what)
  checks = checks + 1
  if not cond then failures = failures + 1; print("FAIL " .. what) end
end

local Motion = require("mn.Motion")

-- a 6x6 plane, all $80 (open) unless set; gate bytes: cell 0 open, others shut
local function plane(set)
  local c = {}
  for i = 0, 35 do c[i] = 0x80 end
  for k, v in pairs(set or {}) do c[k[2] * 6 + k[1]] = v end
  return {
    cell = function(p) if p < 0 or p > 35 then return 0x08 end; return c[p] end,
    gate = function(v) return v == 0 and 0 or 0xFF end,
  }, c
end
local function at(x, y, fx, fy) return Motion.new(x, y, 6, fx, fy) end

-- free step right on the centre row: class 5 (Right). Fine Y 8 always sets
-- bits 1-0 (ProbeCellsRight 05:6AB1), so occupancy 3 -> 65FF -> fineX
do
  local env = plane()
  local st = at(2, 2); st.sx = 2
  local cls, occ, h = Motion.step(st, env)
  ok(cls == 5 and occ == 3 and h == 0x65FF, "free right: class 5 / occupancy 3 / 65FF")
  ok(st.fx == 10 and st.cx == 2 and st.ox == 2, "free right: fine 8 -> 10, saved step")
end
-- under the centre line: class 8, both fine applies, no probe
do
  local env = plane()
  local st = at(2, 2, 4, 8); st.sx = 2
  ok(Motion.step(st, env) == 8 and st.fx == 6, "fine 4 + 2 stays left of centre: class 8")
end
-- wall right on the centre row: occupancy 7 -> 65BC snaps fine X to 8 and zeroes the step
do
  local env = plane({ [{ 3, 2 }] = 0x08 })
  local st = at(2, 2); st.sx = 2
  local cls, occ, h = Motion.step(st, env)
  ok(cls == 5 and occ == 7 and h == 0x65BC, "wall right: occupancy 7 / 65BC")
  ok(st.fx == 8 and st.sx == 0, "wall right: snapped to 8, step 0")
end
-- a $00 gate cell is open with the normal pattern, $01 is shut
do
  local env = plane({ [{ 3, 2 }] = 0x00 })
  local st = at(2, 2); st.sx = 2
  ok(select(2, Motion.step(st, env)) == 3, "gate $00 open")
  env = plane({ [{ 3, 2 }] = 0x01 })
  st = at(2, 2); st.sx = 2
  ok(select(2, Motion.step(st, env)) == 7, "gate $01 shut")
end
-- crossing the cell edge: fine 15 + 2 wraps to 1 in the next cell
do
  local env = plane()
  local st = at(2, 2, 15, 8); st.sx = 2
  Motion.step(st, env)
  ok(st.fx == 1 and st.cx == 3 and st.ptr == 2 * 6 + 3, "edge: 15+2 -> cell 3 fine 1")
end
-- going left from fine 1 by -2: the 8-bit sum $FF is not < 8, class 7 + 1 = 8 free
do
  local env = plane()
  local st = at(2, 2, 1, 8); st.sx = 0xFE
  ok(Motion.step(st, env) == 8 and st.fx == 0x0F and st.cx == 1, "left wrap: $FF sum is free, fine 15 one cell left")
end
-- corner slide: walking right above the centre (fy 6), the up-right cell solid ->
-- occupancy 3 -> 65FF: SY 0 and fine Y < 8 -> SY = 1, fineY only
do
  local env = plane({ [{ 3, 1 }] = 0x08 })
  local st = at(2, 2, 10, 6); st.sx = 2
  local cls, occ, h = Motion.step(st, env)
  ok(cls == 5 and occ == 3 and h == 0x65FF, "corner: occupancy 3 / 65FF")
  ok(st.fy == 7 and st.fx == 10 and st.sy == 1, "corner: nudged down 1, X held")
end
-- the $C6D6 countdown: a bitwise AND, so (+1,-2) does not arm it and (+2,+2) does
do
  local env = plane()
  local st = at(2, 2, 4, 4); st.sx, st.sy = 1, 0xFE
  Motion.step(st, env); ok(st.c6d6 == 0, "(1,-2): AND is 0, no countdown")
  st = at(2, 2, 4, 4); st.sx, st.sy = 2, 2
  Motion.step(st, env); ok(st.c6d6 == 2, "(2,2): countdown 2")
end
-- diagonal into a corner: class 4 (DownRight) with all three cells solid -> 65C3 snaps both
do
  local env = plane({ [{ 3, 2 }] = 0x08, [{ 3, 3 }] = 0x08, [{ 2, 3 }] = 0x08 })
  local st = at(2, 2); st.sx, st.sy = 2, 2
  local cls, occ, h = Motion.step(st, env)
  ok(cls == 4 and occ == 7 and h == 0x65C3, "down-right corner: 65C3")
  ok(st.fx == 8 and st.fy == 8 and st.sx == 0 and st.sy == 0, "down-right corner: both snapped")
end
-- ystep (675A) stores the sum as the step first: open down, blocked... use 65B5 via
-- class 0 (UpLeft) occupancy 1 (only the up cell solid)
do
  local env = plane({ [{ 2, 1 }] = 0x08 })
  local st = at(2, 2); st.sx, st.sy = 0xFE, 0xFE
  local cls, occ, h = Motion.step(st, env)
  ok(cls == 0 and occ == 1 and h == 0x65B5, "up-left, up cell solid: 65B5")
  ok(st.fx == 6 and st.fy == 8 and st.sy == 0, "65B5: X moves, Y snapped to 8")
end
-- conveyors
do
  local want = { [0xA0] = { 0, 0xFD }, [0xA2] = { 3, 0 }, [0xA5] = { 0xFE, 2 }, [0xA7] = { 0xFE, 0xFE } }
  for v, d in pairs(want) do
    local env = plane({ [{ 2, 2 }] = v })
    local st = at(2, 2)
    Motion.conveyor(st, env)
    ok(st.sx == d[1] and st.sy == d[2], ("conveyor $%02X"):format(v))
  end
  local env = plane({ [{ 2, 2 }] = 0xA8 })
  local st = at(2, 2); st.sx = 1
  Motion.conveyor(st, env); ok(st.sx == 1 and st.sy == 0, "$A8 adds nothing")
  env = plane({ [{ 2, 2 }] = 0xA6 })
  st = at(2, 2); st.sx = 2
  Motion.conveyor(st, env); ok(st.sx == 0xFF, "walking right +2 on $A6 (-3) nets -1")
end
-- 422E
do
  local mem = { m = { [0xC6DE] = 0xFF } }
  function mem:rd8(a) return self.m[a] or 0 end
  function mem:wr8(a, v) self.m[a] = v end
  local kinds = { [1] = 3, [2] = 4, [3] = 1 }
  local function entry(i) if i <= 3 then return kinds[i] or 0, 0x12, 0x4000 + i end end
  local env = plane({ [{ 2, 2 }] = 0xC1, [{ 3, 2 }] = 0xC2, [{ 4, 2 }] = 0xC4 })
  local st = at(2, 2); st.sx = 2; st.ox = 2
  local b, p, idx = Motion.trigger(st, env, mem, entry, false)
  ok(b == 0x12 and p == 0x4001 and idx == 1 and mem.m[0xC6DE] == 1, "kind 3 passes going right")
  ok(Motion.trigger(st, env, mem, entry, false) == nil, "same index again: no restage")
  st = at(3, 2); st.sx = 2; st.ox = 2
  ok(Motion.trigger(st, env, mem, entry, false) == nil and mem.m[0xC6DE] == 1, "kind 4 rejects a rightward step, C6DE kept")
  st = at(4, 2); st.sx = 2; st.ox = 2
  ok(Motion.trigger(st, env, mem, entry, false) == nil, "index 4 past the list")
  st = at(1, 2); st.sx = 2; st.ox = 2
  Motion.trigger(st, env, mem, entry, false); ok(mem.m[0xC6DE] == 0xFF, "an ordinary cell clears C6DE")
  st = at(2, 2); st.sx = 0; st.ox = 0
  ok(Motion.trigger(st, env, mem, entry, false) == nil, "no step: nothing")
  st = at(2, 2); st.sx = 2; st.ox = 2
  ok(Motion.trigger(st, env, mem, entry, true) == nil, "busy third script: nothing")
  ok(Motion.trigger(st, env, mem, entry, false) == 0x12, "re-entry after leaving fires again")
end

print(("mn_motion_test: %d checks, %d failures"):format(checks, failures))
if failures > 0 then os.exit(1) end
