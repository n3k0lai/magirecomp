-- mn.PixelWalk: the $5B41 conveyor head family (01:5B6E idle, 5BEB/5C52/5CC8/5D3E
-- walk heads). Made-up scripts and cells only.
--   luajit tests/engine/mn_pixelwalk_test.lua
package.path = "./?.lua;./?/init.lua;./src/?.lua;" .. package.path

local failures, checks = 0, 0
local function ok(cond, what)
  checks = checks + 1
  if not cond then failures = failures + 1; print("FAIL " .. what) end
end

local PW = require("mn.PixelWalk")

-- made-up scripts: walks step 2 px a frame on their axis, idles stand still
local SCR = {
  [PW.WALK.right] = { { n = 3, dx = 2, dy = 0, list = 0x6001 } },
  [PW.WALK.left] = { { n = 3, dx = -2, dy = 0, list = 0x6002 } },
  [PW.WALK.up] = { { n = 3, dx = 0, dy = -2, list = 0x6003 } },
  [PW.WALK.down] = { { n = 3, dx = 0, dy = 2, list = 0x6004 } },
}
for _, p in pairs(PW.IDLE) do SCR[p] = { { n = 8, dx = 0, dy = 0, list = 0x6100 + p % 256 } } end
local function frames(bank, ptr) assert(bank == 0x20); return SCR[ptr], true end

local function plane(set)
  local c = {}
  for i = 0, 63 do c[i] = 0x80 end
  for k, v in pairs(set or {}) do c[k[2] * 8 + k[1]] = v end
  return { cell = function(p) if p < 0 or p > 63 then return 0x08 end; return c[p] end,
           gate = function(v) return v == 0 and 0 or 0xFF end }
end

local function io(env, held, extra)
  local t = { frames = frames, held = held, frame = 0, env = env, facing = nil, pressed = 0 }
  t.face = function(d) t.facing = d end
  t.pressA = function() t.pressed = t.pressed + 1 end
  for k, v in pairs(extra or {}) do t[k] = v end
  return t
end

-- idle on a plain cell does not move
do
  local pw = PW.new(frames, 3, 3, 8, "down")
  local r = PW.tick(pw, io(plane(), 0))
  ok(r == "move" and pw.st.fx == 8 and pw.st.fy == 8, "idle: still")
end
-- idle on $A2 is carried right 3 px a frame with no input
do
  local pw = PW.new(frames, 3, 3, 8, "down")
  local env = plane({ [{ 3, 3 }] = 0xA2 })
  PW.tick(pw, io(env, 0))
  ok(pw.st.fx == 11 and pw.st.cx == 3, "idle on $A2: +3")
  PW.tick(pw, io(env, 0)); PW.tick(pw, io(env, 0))
  ok(pw.st.cx == 4 and pw.st.fx == 1, "idle on $A2: crosses into the next cell")
  PW.tick(pw, io(env, 0))
  ok(pw.st.fx == 1, "next cell is not a conveyor: stops")
end
-- plant: the frame sets facing/head/script and does not move; the walk starts next frame
do
  local pw = PW.new(frames, 3, 3, 8, "down")
  local t = io(plane(), PW.BIT.right)
  ok(PW.tick(pw, t) == "plant" and pw.head == "right" and t.facing == "right", "right held: plant")
  ok(pw.st.fx == 8, "plant frame: no motion")
  PW.tick(pw, t)
  ok(pw.st.fx == 10 and pw.list == 0x6001, "walk: +2 with the walk list")
  -- release: back to the idle script, that frame's step dropped
  local t0 = io(plane(), 0)
  ok(PW.tick(pw, t0) == "release" and pw.head == "idle" and pw.st.fx == 10, "release: idle head, no motion")
  ok(pw.script.ptr == PW.IDLE.right, "release: idle-right script")
end
-- priority: right before left before up before down in idle
do
  local pw = PW.new(frames, 3, 3, 8, "down")
  PW.tick(pw, io(plane(), PW.BIT.up + PW.BIT.left)); ok(pw.head == "left", "idle: left before up")
  pw = PW.new(frames, 3, 3, 8, "down")
  PW.tick(pw, io(plane(), PW.BIT.down + PW.BIT.up)); ok(pw.head == "up", "idle: up before down")
end
-- walking down: left/right held switch heads; walking left: up/down nudge on odd frames
do
  local pw = PW.new(frames, 3, 3, 8, "down")
  PW.tick(pw, io(plane(), PW.BIT.down))
  PW.tick(pw, io(plane(), PW.BIT.down + PW.BIT.right)); ok(pw.head == "right", "down head: right switches")
  pw = PW.new(frames, 3, 3, 8, "down")
  PW.tick(pw, io(plane(), PW.BIT.left))
  PW.tick(pw, io(plane(), PW.BIT.left + PW.BIT.up, { frame = 2 }))
  ok(pw.head == "left" and pw.st.fy == 8, "left head: even frame, no nudge")
  PW.tick(pw, io(plane(), PW.BIT.left + PW.BIT.up, { frame = 3 }))
  ok(pw.st.fy == 7, "left head: odd frame, up nudges -1")
end
-- A: idle presses always reach the dispatch; a walk head only when its step ended 0
do
  local pw = PW.new(frames, 3, 3, 8, "down")
  local t = io(plane(), 0, { a = true }); PW.tick(pw, t)
  ok(t.pressed == 1, "idle A: dispatched")
  pw = PW.new(frames, 3, 3, 8, "down")
  PW.tick(pw, io(plane(), PW.BIT.down))
  t = io(plane(), PW.BIT.down, { a = true }); PW.tick(pw, t)
  ok(t.pressed == 0, "walking down freely: A dropped")
  local env = plane({ [{ 3, 4 }] = 0x09 })
  pw = PW.new(frames, 3, 3, 8, "down")
  PW.tick(pw, io(env, PW.BIT.down))
  t = io(env, PW.BIT.down, { a = true }); PW.tick(pw, t)
  ok(t.pressed == 1 and pw.st.fy == 8, "blocked going down: step 0, A dispatched (4B7B)")
end
-- a trigger staged by 422E ends the frame
do
  local pw = PW.new(frames, 3, 3, 8, "down")
  local t = io(plane(), PW.BIT.right, { trigger = function(st) return st.sx ~= 0 end, a = true })
  PW.tick(pw, t)
  ok(PW.tick(pw, t) == "trigger" and t.pressed == 0, "trigger: frame ends there")
end
-- grass owns the frame
do
  local pw = PW.new(frames, 3, 3, 8, "down")
  ok(PW.tick(pw, io(plane(), PW.BIT.right, { grass = function() return true end })) == "grass" and pw.head == "idle", "grass script: nothing else")
end
-- pixel mapping: fine 8 is the port's cell * 16
do
  local pw = PW.new(frames, 3, 2, 8, "down")
  local x, y = PW.pixel(pw); ok(x == 48 and y == 32, "pixel at fine 8,8")
end
-- a non-looping script holds its last list with no step
do
  local c = PW.cursor(function() return { { n = 1, dx = 1, dy = 0, list = 7 } }, false end, 0x5000)
  local a = PW.nextFrame(c); local b, _, l = PW.nextFrame(c)
  ok(a == 1 and b == 0 and l == 7, "ended script: last list, no step")
end

print(("mn_pixelwalk_test: %d checks, %d failures"):format(checks, failures))
if failures > 0 then os.exit(1) end
