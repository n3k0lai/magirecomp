-- $83 / $16 pans go through $C843/$C844 and StepHorizontalScroll / StepVerticalScroll
-- (bank 7): each frame's delta is clamped to -4..+4, a step past column 0 fine 0 or the
-- limit column ($C845) fine 15 is cut short, a stride of 10 never steps sideways, and a
-- row limit of $FF never steps vertically. Made-up maps, no ROM bytes.
--   luajit tests/engine/mn_scroll_edge_test.lua
package.path = "./?.lua;./?/init.lua;./src/?.lua;" .. package.path
love = love or { math = { random = function(a) return a or 0 end } } -- luacheck: ignore 111

local failures, checks = 0, 0
local function ok(cond, what)
  checks = checks + 1
  if not cond then failures = failures + 1; print("FAIL " .. what) end
end

local Overworld = require("mn.Overworld")

local function world(w, h, camCol, camRow, px, py)
  local s = setmetatable({ def = { w = w, h = h, camCol = camCol, camRow = camRow, cells = {}, block = {} },
    patches = {}, log = {}, objects = {}, px = px * 16, py = py * 16 }, { __index = Overworld })
  return s
end
local function run(s, frames) for _ = 1, frames do if s.panv then s:panFrame() end end end

do -- a delta past 4 moves 4 a frame
  local s = world(40, 30, 29, 20, 20, 15)
  local x0, y0 = s:cameraXY()
  s.panv = { 3, 7, -9 }
  run(s, 3)
  local x, y = s:cameraXY()
  ok(x == x0 + 12 and y == y0 - 12, "7,-9 for 3 frames moves 12,-12")
  ok(s.panv == nil, "the pan ends after its count")
end

do -- left / up stop at 0, cut short on the frame that would cross
  local s = world(40, 30, 29, 20, 4, 4) -- follow camera at 0,0 is clamped; start at 6,6
  s.camFix = { 6, 6 }
  s.panv = { 5, -4, -4 }
  run(s, 5)
  local x, y = s:cameraXY()
  ok(x == 0 and y == 0, "left/up pan stops at the map's top-left corner")
  ok(s.camOff[1] == -6 and s.camOff[2] == -6, "only 6 of 20 pixels applied")
end

do -- right / down stop at the limit column/row, fine 15
  local s = world(40, 30, 29, 20, 0, 0)
  local hiX, hiY = 29 * 16 + 15, 20 * 16 + 15
  s.camFix = { hiX - 5, hiY - 2 }
  s.panv = { 4, 4, 4 }
  run(s, 4)
  local x, y = s:cameraXY()
  ok(x == hiX and y == hiY, "right/down pan stops at limit*16+15")
  s.panv = { 2, -3, -1 }
  run(s, 2)
  x, y = s:cameraXY()
  ok(x == hiX - 6 and y == hiY - 2, "the way back is open")
end

do -- stride 10: no sideways steps; row limit $FF: no vertical steps
  local s = world(10, 30, 0xFF, 20, 0, 5)
  s.camFix = { 0, 40 }
  s.panv = { 3, 4, 4 }
  run(s, 3)
  local x, y = s:cameraXY()
  ok(x == 0 and y == 52, "width 10: only the vertical half moves")
  s = world(24, 9, 13, 0xFF, 0, 0)
  s.camFix = { 40, 0 }
  s.panv = { 2, -4, 4 }
  run(s, 2)
  x, y = s:cameraXY()
  ok(x == 32 and y == 0, "row limit $FF: only the horizontal half moves")
end

do -- a $16 scroll carries its walkers by the clamped delta
  local s = world(40, 30, 29, 20, 0, 0)
  s.camFix = { 8, 100 }
  s.objects[3] = { x = 5, y = 7 }
  s.panv = { 4, -4, 0, nil, { [3] = true } }
  run(s, 4)
  local x = s:cameraXY()
  local ob = s.objects[3]
  ok(x == 0, "carry pan stops at column 0")
  ok(ob.x * 16 + ob.ox == 5 * 16 - 8, "walker moved 8 pixels, not 16")
end

do -- without header limits the field's W-160 / H-144 apply
  local s = world(20, 18, nil, nil, 0, 0)
  s.camFix = { 158, 142 }
  s.panv = { 1, 4, 4 }
  run(s, 1)
  local x, y = s:cameraXY()
  ok(x == 160 and y == 144, "fallback limits W-160, H-144")
end

print(("mn_scroll_edge: %d checks, %d failures"):format(checks, failures))
os.exit(failures == 0 and 0 or 1)
